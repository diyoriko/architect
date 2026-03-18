#!/usr/bin/env bash
# Local dashboard server — serves backlogs live from project files
# Usage: bash serve-dashboard.sh
# Open: http://localhost:3333

PORT=3333

echo "Dashboard: http://localhost:$PORT"
echo "Press Ctrl+C to stop"

cd "$(dirname "${BASH_SOURCE[0]}")"

# Simple HTTP server that also serves backlog files from project dirs
python3 -c "
import http.server, json, os, pathlib

def latest_file(directory, pattern='*.md'):
    files = sorted(pathlib.Path(directory).glob(pattern), reverse=True)
    return str(files[0]) if files else None

STATIC_MAP = {
    'hunter-BACKLOG.md': os.path.expanduser('~/Documents/Projects/Hunter/BACKLOG.md'),
    'sami-BACKLOG.md': os.path.expanduser('~/Documents/Projects/Sami/COMMUNITY_TASKS.md'),
    'vedic-BACKLOG.md': os.path.expanduser('~/Documents/Projects/Vedic Turkey/BACKLOG.md'),
    'portfolio-BACKLOG.md': os.path.expanduser('~/Documents/Projects/Portfolio/BACKLOG.md'),
    'architect-BACKLOG.md': 'BACKLOG.md',
    'mega-review-BACKLOG.md': 'mega-review-BACKLOG.md',
}
DYNAMIC_MAP = {
    'mega-review-latest.md': ('code-reviews', '*.md'),
    'architect-report-latest.md': ('reports', '*.md'),
}

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
        src = resolve(name)
        if src and os.path.isfile(str(src)):
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(open(str(src), 'rb').read())
            return
        return super().do_GET()

    def log_message(self, fmt, *args):
        pass  # silent

http.server.HTTPServer(('', $PORT), Handler).serve_forever()
"
