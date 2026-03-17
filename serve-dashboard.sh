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

PROJECTS = {
    'hunter-BACKLOG.md': os.path.expanduser('~/Documents/Projects/Hunter/BACKLOG.md'),
    'sami-BACKLOG.md': os.path.expanduser('~/Documents/Projects/Sami/COMMUNITY_TASKS.md'),
    'architect-BACKLOG.md': 'BACKLOG.md',
    'mega-review-latest.md': next(iter(sorted(pathlib.Path('code-reviews').glob('*.md'), reverse=True)), None),
    'architect-report-latest.md': next(iter(sorted(pathlib.Path('reports').glob('*.md'), reverse=True)), None),
}

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        name = self.path.lstrip('/')
        if name in PROJECTS:
            src = PROJECTS[name]
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
