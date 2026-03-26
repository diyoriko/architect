#!/usr/bin/env node
// Architect Dashboard v2 — Express + SSE server
// Serves Crucix-style dashboard, sweeps project data every 60s, pushes via SSE

import express from 'express';
import { readFileSync, writeFileSync, readdirSync, statSync, existsSync } from 'fs';
import { dirname, join, resolve } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const HOME = process.env.HOME;
const PROJECTS = join(HOME, 'Documents/Projects');
const PORT = parseInt(process.env.PORT) || 3333;

// === File Mapping (ported from serve-dashboard.sh) ===

const STATIC_MAP = {
  'hunter-BACKLOG.md': join(PROJECTS, 'Hunter/BACKLOG.md'),
  'sami-BACKLOG.md': join(PROJECTS, 'Sami/BACKLOG.md'),
  'vedic-BACKLOG.md': join(PROJECTS, 'Vedic Turkey/BACKLOG.md'),
  'portfolio-BACKLOG.md': join(PROJECTS, 'Portfolio/BACKLOG.md'),
  'radar-BACKLOG.md': join(PROJECTS, 'Portfolio/BACKLOG.md'),
  'architect-BACKLOG.md': join(__dirname, 'BACKLOG.md'),
  'mega-review-BACKLOG.md': join(__dirname, 'mega-review-BACKLOG.md'),
};

function latestFile(dir, pattern = /\.md$/) {
  if (!existsSync(dir)) return null;
  const files = readdirSync(dir)
    .filter(f => pattern.test(f))
    .map(f => ({ name: f, mtime: statSync(join(dir, f)).mtimeMs }))
    .sort((a, b) => b.mtime - a.mtime);
  return files.length ? join(dir, files[0].name) : null;
}

const DYNAMIC_MAP = {
  'mega-review-latest.md': [join(__dirname, 'code-reviews'), /\.md$/],
  'architect-report-latest.md': [join(__dirname, 'reports'), /\.md$/],
};

// === Agent Configuration ===

const AGENTS = [
  {
    id: 'sami_strategist', name: 'SAMI Strategist',
    schedule: 'Sun 09:30 MSK', frequency: 'weekly', platform: 'launchd',
    description: 'Backlog analysis + Telegram report',
    reports_dir: join(PROJECTS, 'Sami/reports/strategist'),
  },
  {
    id: 'hunter_strategist', name: 'Hunter Strategist',
    schedule: 'Sun 09:45 MSK', frequency: 'weekly', platform: 'launchd',
    description: 'Backlog analysis + Telegram report',
    reports_dir: join(PROJECTS, 'Hunter/reports/strategist'),
  },
  {
    id: 'portfolio_strategist', name: 'Portfolio Strategist',
    schedule: 'Sun 10:15 MSK', frequency: 'weekly', platform: 'launchd',
    description: 'Portfolio content + SEO analysis',
    reports_dir: join(PROJECTS, 'Portfolio/reports/strategist'),
  },
  {
    id: 'vedic_strategist', name: 'Vedic Strategist',
    schedule: 'Sun 10:30 MSK', frequency: 'weekly', platform: 'launchd',
    description: 'Platform health + blockers',
    reports_dir: join(PROJECTS, 'Vedic Turkey/reports/strategist'),
  },
  {
    id: 'mega_reviewer', name: 'Mega Reviewer',
    schedule: 'Sat 10:00 MSK', frequency: 'weekly', platform: 'launchd',
    description: 'Full code + UX + deps audit',
    reports_dir: join(__dirname, 'code-reviews'),
  },
  {
    id: 'architect', name: 'Architect',
    schedule: 'Sun 10:00 MSK', frequency: 'weekly', platform: 'launchd',
    description: 'Process, workflow, burnout review',
    reports_dir: join(__dirname, 'reports'),
  },
  {
    id: 'portfolio_radar', name: 'Portfolio Radar',
    schedule: '10:30 MSK daily', frequency: 'daily', platform: 'launchd',
    description: 'Design × AI news scout',
    reports_dir: join(PROJECTS, 'Portfolio/reports/radar'),
  },
  {
    id: 'backup', name: 'Backup',
    schedule: '03:00 MSK daily', frequency: 'daily', platform: 'GH Actions',
    description: 'SQLite snapshots (SAMI + Hunter)',
    reports_dir: null,
  },
  {
    id: 'hardstop', name: 'Hard Stop',
    schedule: '22:30 daily', frequency: 'daily', platform: 'launchd',
    description: 'End-of-day notification',
    reports_dir: null,
  },
];

// === Agent Status (ported from Python) ===

function getAgentStatus(agent) {
  const result = { ...agent, last_run: null, last_report: null, status: 'unknown' };

  if (!agent.reports_dir || !existsSync(agent.reports_dir)) return result;

  const files = readdirSync(agent.reports_dir)
    .filter(f => f.endsWith('.md'))
    .map(f => {
      const fp = join(agent.reports_dir, f);
      return { path: fp, mtime: statSync(fp).mtimeMs };
    })
    .sort((a, b) => b.mtime - a.mtime);

  if (!files.length) {
    result.status = 'never';
    return result;
  }

  const latest = files[0];
  const ageHours = (Date.now() - latest.mtime) / 3600000;
  result.last_run = new Date(latest.mtime).toISOString().replace('T', ' ').slice(0, 16);
  result.last_report = latest.path;

  if (agent.frequency === 'daily') {
    result.status = ageHours < 26 ? 'ok' : ageHours < 50 ? 'warning' : 'error';
  } else {
    result.status = ageHours < 8 * 24 ? 'ok' : ageHours < 15 * 24 ? 'warning' : 'error';
  }

  return result;
}

// === Insight Extraction ===

function extractInsight(md) {
  const lines = md.split('\n');
  let pastHeader = false;
  for (const l of lines) {
    if (/^#{1,3}\s/.test(l)) { pastHeader = true; continue; }
    if (!pastHeader || /^---/.test(l) || !l.trim()) continue;
    const clean = l.replace(/^[-*]\s*/, '').replace(/\*\*/g, '').trim();
    if (clean.length > 10) return clean.length > 140 ? clean.slice(0, 137) + '...' : clean;
  }
  return null;
}

// === Process Analysis Extraction ===

function extractProcessAnalysis(md) {
  const lines = md.split('\n');
  const observations = [];
  const actionItems = [];
  let inProcess = false;
  let inObservations = false;
  let inActions = false;

  for (const l of lines) {
    if (/^## Process Analysis/i.test(l)) { inProcess = true; continue; }
    if (inProcess && /^## /.test(l)) { inProcess = false; continue; }

    if (inProcess && /^### Главные наблюдения|^### Key observations/i.test(l)) { inObservations = true; inActions = false; continue; }
    if (inProcess && /^### Action Items/i.test(l)) { inActions = true; inObservations = false; continue; }
    if (inProcess && /^### /.test(l)) { inObservations = false; inActions = false; continue; }

    if (inObservations && /^\*\*/.test(l.trim())) {
      const clean = l.trim().replace(/\*\*/g, '').replace(/^\d+\.\s*/, '');
      if (clean.length > 5) observations.push(clean.length > 160 ? clean.slice(0, 157) + '...' : clean);
    }

    if (inActions && /^\d+\.\s*\*\*/.test(l.trim())) {
      const clean = l.trim().replace(/\*\*/g, '').replace(/^\d+\.\s*/, '');
      if (clean.length > 5) actionItems.push(clean.length > 120 ? clean.slice(0, 117) + '...' : clean);
    }
  }

  // Extract week summary
  let weekSummary = [];
  let inWeek = false;
  for (const l of lines) {
    if (/^## Week Summary/i.test(l)) { inWeek = true; continue; }
    if (inWeek && /^## /.test(l)) break;
    if (inWeek && /^- /.test(l)) {
      const clean = l.replace(/^- /, '').replace(/\*\*/g, '').trim();
      if (clean.length > 5) weekSummary.push(clean.length > 140 ? clean.slice(0, 137) + '...' : clean);
    }
  }

  return { observations, actionItems, weekSummary };
}

// === Path Security ===

const ALLOWED_DIRS = [
  PROJECTS,
  join(HOME, 'Library/LaunchAgents'),
  join(HOME, 'Library/Application Support'),
  __dirname,
].map(d => { try { return resolve(d); } catch { return d; } });

function isSafePath(p) {
  try {
    const real = resolve(p);
    return ALLOWED_DIRS.some(d => real.startsWith(d));
  } catch { return false; }
}

// === SSE ===

const sseClients = new Set();

function broadcast(data) {
  const msg = `data: ${JSON.stringify(data)}\n\n`;
  for (const client of sseClients) {
    try { client.write(msg); } catch { sseClients.delete(client); }
  }
}

// === Sweep Cycle ===

let currentData = null;
let lastSweepTime = null;
let sweepInProgress = false;
const startTime = Date.now();

const PROJECT_DEFS = [
  { id: 'hunter', name: 'Hunter', color: '#00e676', health: 'https://hunter-production-0b65.up.railway.app/' },
  { id: 'sami', name: 'SAMI', color: '#448aff', health: 'https://courageous-happiness-production.up.railway.app/health' },
  { id: 'vedic', name: 'Vedic', color: '#ff80ab', health: 'https://vedic-turkiye.vercel.app/' },
  { id: 'portfolio', name: 'Portfolio', color: '#ff1744', health: 'https://diyor.design/' },
  { id: 'radar', name: 'Radar', color: '#ff9800', health: null },
  { id: 'architect', name: 'Architect', color: '#b388ff', health: null },
];

async function checkHealth(url) {
  if (!url) return null;
  try {
    const r = await fetch(url, { signal: AbortSignal.timeout(8000) });
    return r.ok || r.status < 500;
  } catch { return false; }
}

async function runSweep() {
  if (sweepInProgress) return;
  sweepInProgress = true;
  const sweepStart = Date.now();

  try {
    // 1. Agent statuses
    const agents = AGENTS.map(getAgentStatus);

    // 2. Read backlogs
    const backlogs = {};
    const BACKLOG_IDS = {
      'hunter-BACKLOG.md': 'hunter',
      'sami-BACKLOG.md': 'sami',
      'vedic-BACKLOG.md': 'vedic',
      'portfolio-BACKLOG.md': 'portfolio',
      'radar-BACKLOG.md': 'radar',
      'architect-BACKLOG.md': 'architect',
    };
    for (const [key, path] of Object.entries(STATIC_MAP)) {
      const id = BACKLOG_IDS[key];
      if (!id) continue;
      try { backlogs[id] = readFileSync(path, 'utf-8'); } catch { backlogs[id] = ''; }
    }

    // 3. Read mega-review
    let megaReview = '';
    try { megaReview = readFileSync(join(__dirname, 'mega-review-BACKLOG.md'), 'utf-8'); } catch {}

    // 4. Insights from strategist reports
    const insights = [];
    const strategistAgents = agents.filter(a => a.id.includes('strategist') && a.last_report);
    for (const a of strategistAgents) {
      try {
        const md = readFileSync(a.last_report, 'utf-8');
        const text = extractInsight(md);
        const projName = a.name.replace(' Strategist', '');
        const projDef = PROJECT_DEFS.find(p => p.name.toUpperCase() === projName.toUpperCase());
        insights.push({
          project: projName,
          color: projDef?.color || '#8b949e',
          text: text || 'No summary available',
          ago: a.last_run,
        });
      } catch {
        insights.push({
          project: a.name.replace(' Strategist', ''),
          color: '#8b949e',
          text: 'Report unreadable',
          ago: a.last_run,
        });
      }
    }

    // 5. Health checks (parallel)
    const healthResults = {};
    await Promise.all(PROJECT_DEFS.map(async (p) => {
      healthResults[p.id] = await checkHealth(p.health);
    }));

    const agentsOk = agents.filter(a => a.status === 'ok').length;

    // 6. Process Analysis from latest Architect report
    let processAnalysis = null;
    const architectAgent = agents.find(a => a.id === 'architect');
    if (architectAgent?.last_report) {
      try {
        const reportMd = readFileSync(architectAgent.last_report, 'utf-8');
        processAnalysis = extractProcessAnalysis(reportMd);
        processAnalysis.reportDate = architectAgent.last_run;
      } catch {}
    }

    // 7. User Profile from memory
    let userProfile = null;
    const MEMORY_DIR = join(HOME, '.claude/projects/-Users-diyoriko/memory');
    try {
      const profileMd = readFileSync(join(MEMORY_DIR, 'user_profile.md'), 'utf-8');
      const feedbackFiles = readdirSync(MEMORY_DIR)
        .filter(f => f.startsWith('feedback_') && f.endsWith('.md'));
      const feedbacks = feedbackFiles.map(f => {
        try {
          const content = readFileSync(join(MEMORY_DIR, f), 'utf-8');
          const nameMatch = content.match(/^name:\s*(.+)$/m);
          const descMatch = content.match(/^description:\s*(.+)$/m);
          return {
            id: f.replace('.md', ''),
            name: nameMatch?.[1] || f.replace('feedback_', '').replace('.md', '').replace(/_/g, ' '),
            description: descMatch?.[1] || '',
          };
        } catch { return null; }
      }).filter(Boolean);

      const memoryMd = readFileSync(join(MEMORY_DIR, 'MEMORY.md'), 'utf-8');
      const totalMemories = (memoryMd.match(/^- \[/gm) || []).length;
      const profileStat = statSync(join(MEMORY_DIR, 'user_profile.md'));

      userProfile = {
        profile: profileMd.replace(/---[\s\S]*?---\n*/, '').trim(),
        feedbacks,
        totalMemories,
        totalFiles: readdirSync(MEMORY_DIR).filter(f => f.endsWith('.md')).length,
        lastUpdated: new Date(profileStat.mtimeMs).toISOString().slice(0, 10),
      };
    } catch {}

    currentData = {
      agents,
      backlogs,
      megaReview,
      insights,
      health: healthResults,
      projects: PROJECT_DEFS,
      processAnalysis,
      userProfile,
      meta: {
        timestamp: new Date().toISOString(),
        sweepMs: Date.now() - sweepStart,
        agentsOk,
        agentsTotal: agents.length,
      },
    };

    lastSweepTime = currentData.meta.timestamp;
    broadcast({ type: 'update', data: currentData });

  } catch (err) {
    console.error('[Architect] Sweep failed:', err.message);
  } finally {
    sweepInProgress = false;
  }
}

// === Express Server ===

const app = express();
app.use(express.json());

// Serve dashboard static files
app.use('/assets', express.static(join(__dirname, 'dashboard')));

// Main route: loading until first sweep, then dashboard
function serveDashboard(req, res) {
  if (!currentData) {
    res.sendFile(join(__dirname, 'dashboard/loading.html'));
  } else {
    res.set('Cache-Control', 'no-cache, no-store, must-revalidate');
    res.sendFile(join(__dirname, 'dashboard/index.html'));
  }
}
app.get('/', serveDashboard);
app.get('/index.html', serveDashboard);
// Project views — same SPA, JS handles routing
app.get('/hunter', serveDashboard);
app.get('/sami', serveDashboard);
app.get('/vedic', serveDashboard);
app.get('/portfolio', serveDashboard);
app.get('/radar', serveDashboard);
app.get('/architect', serveDashboard);

// API: current data
app.get('/api/data', (req, res) => {
  if (!currentData) return res.status(503).json({ error: 'First sweep in progress' });
  res.json(currentData);
});

// API: health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    uptime: Math.floor((Date.now() - startTime) / 1000),
    lastSweep: lastSweepTime,
    sweepInProgress,
  });
});

// SSE: live updates
app.get('/events', (req, res) => {
  res.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    Connection: 'keep-alive',
    'Access-Control-Allow-Origin': '*',
  });
  res.write('data: {"type":"connected"}\n\n');
  sseClients.add(res);
  req.on('close', () => sseClients.delete(res));
});

// Legacy compat: agents-status.json
app.get('/agents-status.json', (req, res) => {
  res.json(AGENTS.map(getAgentStatus));
});

// File viewer: /view/~/path or /view/abs/path
app.get('/view/{*path}', (req, res) => {
  let raw = Array.isArray(req.params.path) ? req.params.path.join('/') : req.params.path;
  let fpath;
  if (raw.startsWith('~')) {
    fpath = join(HOME, raw.slice(1));
  } else {
    fpath = '/' + raw;
  }

  if (!existsSync(fpath) || !isSafePath(fpath)) {
    return res.status(404).send('File not found');
  }

  res.set('Content-Type', 'text/plain; charset=utf-8');
  res.set('Access-Control-Allow-Origin', '*');
  res.sendFile(resolve(fpath));
});

// Static/dynamic file mapping (backlog files)
app.get('/:name', (req, res, next) => {
  const name = req.params.name;

  // Static map
  if (STATIC_MAP[name] && existsSync(STATIC_MAP[name])) {
    res.set('Content-Type', 'text/plain; charset=utf-8');
    res.set('Access-Control-Allow-Origin', '*');
    return res.sendFile(resolve(STATIC_MAP[name]));
  }

  // Dynamic map
  if (DYNAMIC_MAP[name]) {
    const [dir, pattern] = DYNAMIC_MAP[name];
    const file = latestFile(dir, pattern);
    if (file) {
      res.set('Content-Type', 'text/plain; charset=utf-8');
      res.set('Access-Control-Allow-Origin', '*');
      return res.sendFile(resolve(file));
    }
  }

  next();
});

// POST: moderate tasks
app.post('/api/moderate', (req, res) => {
  const { action, project, task } = req.body || {};
  if (!task?.trim() || !project) {
    return res.status(400).json({ error: 'missing task or project' });
  }

  const fileMap = {
    hunter: join(PROJECTS, 'Hunter/BACKLOG.md'),
    sami: join(PROJECTS, 'Sami/BACKLOG.md'),
    vedic: join(PROJECTS, 'Vedic Turkey/BACKLOG.md'),
    portfolio: join(PROJECTS, 'Portfolio/BACKLOG.md'),
    architect: join(__dirname, 'BACKLOG.md'),
  };

  const fpath = fileMap[project];
  if (!fpath || !existsSync(fpath)) {
    return res.status(404).json({ error: 'project not found' });
  }

  const content = readFileSync(fpath, 'utf-8');
  const lines = content.split('\n');

  if (action === 'remove') {
    const newLines = lines.filter(l => !l.includes(task.trim()));
    if (newLines.length < lines.length) {
      writeFileSync(fpath, newLines.join('\n'));
      return res.json({ ok: true, removed: true });
    }
    return res.json({ ok: true, removed: false, reason: 'not found' });
  }

  if (action === 'keep') {
    const newLines = lines.map(l => {
      if (l.includes(task.trim())) {
        for (const tag of ['strategist', 'mega-review', 'coderabbit']) {
          l = l.replace(` \`[${tag}]\``, '');
        }
      }
      return l;
    });
    writeFileSync(fpath, newLines.join('\n'));
    return res.json({ ok: true, kept: true });
  }

  res.status(400).json({ error: 'unknown action' });
});

// === Startup ===

const server = app.listen(PORT);

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`[Architect] Port ${PORT} in use. Kill existing process or change PORT.`);
  } else {
    console.error('[Architect] Server error:', err.message);
  }
  process.exit(1);
});

server.on('listening', async () => {
  console.log(`
  ╔════════════════════════════════════════╗
  ║      ARCHITECT COMMAND CENTER v2       ║
  ╠════════════════════════════════════════╣
  ║  Dashboard:  http://localhost:${PORT}${' '.repeat(9 - String(PORT).length)}║
  ║  Health:     http://localhost:${PORT}/api/health
  ║  Refresh:    Every 60s (SSE push)      ║
  ╚════════════════════════════════════════╝
  `);

  // First sweep
  await runSweep();
  console.log(`[Architect] First sweep done in ${currentData?.meta?.sweepMs}ms — ${currentData?.meta?.agentsOk}/${currentData?.meta?.agentsTotal} agents OK`);

  // Recurring sweeps
  setInterval(runSweep, 60_000);
});

process.on('unhandledRejection', (err) => {
  console.error('[Architect] Unhandled rejection:', err?.message || err);
});
