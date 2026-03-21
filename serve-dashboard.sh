#!/usr/bin/env bash
# Local dashboard server — serves backlogs live from project files
# Usage: bash serve-dashboard.sh
# Open: http://localhost:3333

PORT=3333

echo "Dashboard: http://localhost:$PORT"
echo "Press Ctrl+C to stop"

cd "$(dirname "${BASH_SOURCE[0]}")"

python3 -c "
import http.server, json, os, pathlib, time

HOME = os.path.expanduser('~')
PROJECTS = HOME + '/Documents/Projects'

def latest_file(directory, pattern='*.md'):
    files = sorted(pathlib.Path(directory).glob(pattern), reverse=True)
    return str(files[0]) if files else None

STATIC_MAP = {
    'hunter-BACKLOG.md': PROJECTS + '/Hunter/BACKLOG.md',
    'sami-BACKLOG.md': PROJECTS + '/Sami/COMMUNITY_TASKS.md',
    'vedic-BACKLOG.md': PROJECTS + '/Vedic Turkey/BACKLOG.md',
    'portfolio-BACKLOG.md': PROJECTS + '/Portfolio/BACKLOG.md',
    'architect-BACKLOG.md': 'BACKLOG.md',
    'mega-review-BACKLOG.md': 'mega-review-BACKLOG.md',
}
DYNAMIC_MAP = {
    'mega-review-latest.md': ('code-reviews', '*.md'),
    'architect-report-latest.md': ('reports', '*.md'),
}

AGENTS = [
    {
        'id': 'sami_strategist',
        'name': 'SAMI Strategist',
        'schedule': '09:30 MSK daily',
        'frequency': 'daily',
        'platform': 'Mac launchd',
        'description': 'Backlog analysis + Telegram report',
        'reports_dir': PROJECTS + '/Sami/reports/strategist',
        'project_dir': PROJECTS + '/Sami',
        'plist': HOME + '/Library/LaunchAgents/com.sami.strategist.plist',
        'run_sh': PROJECTS + '/Sami/agents/community/strategist/run.sh',
    },
    {
        'id': 'hunter_strategist',
        'name': 'Hunter Strategist',
        'schedule': '09:30 MSK daily',
        'frequency': 'daily',
        'platform': 'Mac launchd',
        'description': 'Backlog analysis + Telegram report',
        'reports_dir': PROJECTS + '/Hunter/reports/strategist',
        'project_dir': PROJECTS + '/Hunter',
        'plist': HOME + '/Library/LaunchAgents/com.hunter.strategist.plist',
        'run_sh': PROJECTS + '/Hunter/agents/strategist/run.sh',
    },
    {
        'id': 'portfolio_strategist',
        'name': 'Portfolio Strategist',
        'schedule': 'Sun 11:00 MSK',
        'frequency': 'weekly',
        'platform': 'Mac launchd',
        'description': 'Portfolio content + SEO analysis',
        'reports_dir': PROJECTS + '/Portfolio/reports/strategist',
        'project_dir': PROJECTS + '/Portfolio',
        'plist': HOME + '/Library/LaunchAgents/com.portfolio.strategist.plist',
        'run_sh': PROJECTS + '/Portfolio/agents/strategist/run.sh',
    },
    {
        'id': 'mega_reviewer',
        'name': 'Mega Reviewer',
        'schedule': 'Sat 10:00 MSK',
        'frequency': 'weekly',
        'platform': 'Mac launchd',
        'description': 'Full code + UX + deps audit',
        'reports_dir': os.getcwd() + '/code-reviews',
        'project_dir': os.getcwd(),
        'plist': HOME + '/Library/LaunchAgents/com.diyoriko.code-reviewer.plist',
        'run_sh': os.getcwd() + '/code-reviewer/run.sh',
    },
    {
        'id': 'architect',
        'name': 'Architect',
        'schedule': 'Sun 10:00 MSK',
        'frequency': 'weekly',
        'platform': 'Mac launchd',
        'description': 'Process, workflow, burnout review',
        'reports_dir': os.getcwd() + '/reports',
        'project_dir': os.getcwd(),
        'plist': HOME + '/Library/LaunchAgents/com.diyoriko.architect.plist',
        'run_sh': os.getcwd() + '/run.sh',
    },
    {
        'id': 'backup',
        'name': 'Backup',
        'schedule': '03:00 MSK daily',
        'frequency': 'daily',
        'platform': 'GH Actions cron',
        'description': 'SQLite snapshots (SAMI + Hunter)',
        'reports_dir': None,
        'project_dir': None,
        'plist': None,
        'run_sh': None,
    },
    {
        'id': 'hardstop',
        'name': 'Hard Stop',
        'schedule': '22:30 daily',
        'frequency': 'daily',
        'platform': 'Mac launchd',
        'description': 'End-of-day notification',
        'reports_dir': None,
        'project_dir': None,
        'plist': HOME + '/Library/LaunchAgents/com.diyoriko.hardstop.plist',
        'run_sh': None,
    },
]

def get_agent_status(agent):
    result = dict(agent)
    result['last_run'] = None
    result['last_report'] = None
    result['status'] = 'unknown'

    reports_dir = agent.get('reports_dir')
    if not reports_dir or not os.path.isdir(reports_dir):
        return result

    files = sorted(pathlib.Path(reports_dir).glob('*.md'), key=lambda f: f.stat().st_mtime, reverse=True)
    if not files:
        result['status'] = 'never'
        return result

    latest = files[0]
    mtime = latest.stat().st_mtime
    age_hours = (time.time() - mtime) / 3600
    result['last_run'] = time.strftime('%Y-%m-%d %H:%M', time.localtime(mtime))
    result['last_report'] = str(latest)

    freq = agent.get('frequency', 'daily')
    if freq == 'daily':
        if age_hours < 26:
            result['status'] = 'ok'
        elif age_hours < 50:
            result['status'] = 'warning'
        else:
            result['status'] = 'error'
    else:  # weekly
        if age_hours < 8 * 24:
            result['status'] = 'ok'
        elif age_hours < 15 * 24:
            result['status'] = 'warning'
        else:
            result['status'] = 'error'

    return result

ALLOWED_DIRS = [
    os.path.realpath(PROJECTS),
    os.path.realpath(HOME + '/Library/LaunchAgents'),
    os.path.realpath(os.getcwd()),
    PROJECTS,
    HOME + '/Library/LaunchAgents',
    HOME + '/Library/Application Support',
]

def is_safe_path(path):
    real = os.path.realpath(path)
    return any(real.startswith(d) for d in ALLOWED_DIRS)

def resolve(name):
    if name in STATIC_MAP:
        return STATIC_MAP[name]
    if name in DYNAMIC_MAP:
        d, p = DYNAMIC_MAP[name]
        return latest_file(d, p)
    return None

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        name = self.path.split('?')[0].lstrip('/')

        # Dynamic agents-status endpoint
        if name == 'agents-status.json':
            data = [get_agent_status(a) for a in AGENTS]
            payload = json.dumps(data, ensure_ascii=False, indent=2).encode()
            self.send_response(200)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(payload)
            return

        # File viewer: /view/~/path/to/file.md or /view/full/path
        if name.startswith('view/'):
            raw = name[5:]  # strip 'view/'
            if raw.startswith('~'):
                fpath = HOME + raw[1:]
            else:
                fpath = '/' + raw
            safe = is_safe_path(fpath) if os.path.exists(fpath) else False
            if safe and os.path.isfile(fpath):
                self.send_response(200)
                self.send_header('Content-Type', 'text/plain; charset=utf-8')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(open(fpath, 'rb').read())
            else:
                self.send_response(404)
                self.end_headers()
                self.wfile.write(b'File not found')
            return

        # Static/dynamic file mapping
        src = resolve(name)
        if src and os.path.isfile(str(src)):
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(open(str(src), 'rb').read())
            return

        return super().do_GET()

    def end_headers(self):
        # Prevent aggressive caching (Arc browser)
        if hasattr(self, 'path') and (self.path.endswith('.html') or self.path == '/'):
            self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
            self.send_header('Pragma', 'no-cache')
            self.send_header('Expires', '0')
        super().end_headers()

    def log_message(self, fmt, *args):
        pass  # silent

http.server.HTTPServer(('', $PORT), Handler).serve_forever()
"
