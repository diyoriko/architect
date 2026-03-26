# Architect — Command Center

Cross-project dashboard, weekly code review, process review. Monitors Hunter, SAMI, Vedic, Portfolio, Radar.

## Stack

Node.js 22, Express 5, SSE, launchd agents

## Run

```bash
npm install && npm start
```

Dashboard: [localhost:3333](http://localhost:3333)

## Agents

| Agent | Schedule | Purpose |
|-------|----------|---------|
| Mega Reviewer | Sat 10:00 MSK | Code + UX + deps audit |
| Architect | Sun 10:00 MSK | Process + workflow review |
| Dashboard | KeepAlive | Express + SSE server |
