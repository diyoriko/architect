# Architect — Control Center & Review System

## Overview
Кросс-проектный дашборд + еженедельный code review + process review.
Не пишет код проектов — только мониторит, ревьюит, создаёт задачи.

## Dashboard (serve-dashboard.sh)

**ВАЖНО:** Дашборд работает через Python HTTP-сервер (`serve-dashboard.sh`) на localhost:3333.

Бэклоги проектов **НЕ хранятся** в директории Architect. Сервер маппит URL на файлы проектов напрямую:

```python
STATIC_MAP = {
    'hunter-BACKLOG.md':    '~/Documents/Projects/Hunter/BACKLOG.md',
    'sami-BACKLOG.md':      '~/Documents/Projects/Sami/COMMUNITY_TASKS.md',
    'vedic-BACKLOG.md':     '~/Documents/Projects/Vedic Turkey/BACKLOG.md',
    'portfolio-BACKLOG.md': '~/Documents/Projects/Portfolio/BACKLOG.md',
    'architect-BACKLOG.md': 'BACKLOG.md',
}
```

- **НЕ создавай симлинки** *-BACKLOG.md в директории Architect — они не нужны
- **НЕ копируй** файлы бэклогов — сервер читает оригиналы live
- Данные обновляются при каждом HTTP-запросе (каждые 30 сек на дашборде)
- `agents-status.json` — динамический endpoint, вычисляется на лету из reports/

## Ключевые файлы

| Файл | Назначение |
|---|---|
| `index.html` | Command Center — agents, projects, alerts, insights |
| `mega-review.html` | Health — scorecard + findings |
| `serve-dashboard.sh` | HTTP-сервер (localhost:3333), launchd KeepAlive |
| `code-reviewer/run.sh` | Mega Reviewer (сб 10:00) — code/UX/deps audit |
| `run.sh` | Architect (вс 10:00) — process review |
| `BACKLOG.md` | Бэклог архитектора (инфра-задачи) |
| `mega-review-BACKLOG.md` | Реестр findings из mega review |
| `deployments.json` | Метаданные проектов (URLs, health endpoints) |

## Agents (launchd)

| Agent | Schedule | Script |
|---|---|---|
| Mega Reviewer | Sat 10:00 MSK | `code-reviewer/run.sh` |
| Architect | Sun 10:00 MSK | `run.sh` |
| Dashboard | KeepAlive | `serve-dashboard.sh` |

Все агенты имеют `RunAtLoad: true` — запускаются при включении Mac если пропустили расписание.

## Sprint → Release Process

Единый процесс для всех проектов:

1. **Sprint** — набор задач в `## Sprint N` секции бэклога
2. **Реализация** — код + тесты в feature branch или main
3. **Деплой** — `git push` + version bump (vX.Y.Z)
4. **Архивация** — закрытый спринт сворачивается в `<details>` с номером релиза
5. **Перенос** — незакрытые задачи переносятся в следующий спринт с причиной

### Нумерация задач
- `ARCH-NNN` — Architect
- `HUNT-NNN` — Hunter (в процессе перехода)
- `SAMI-NNN` — SAMI (в процессе перехода)
- `VT-NNN` — Vedic Turkiye (уже используется)
- `PORT-NNN` — Portfolio (в процессе перехода)

### Автоматизация
- Mega Reviewer (сб) → sync_items() → вставляет в текущий спринт проекта
- Стратегисты (ежедневно/еженедельно) → extract-tasks → proposals → approval → бэклог
- CodeRabbit (PR review) → coderabbit-to-backlog.yml → бэклог
- Telegram alert при critical findings

## Quality Gate
- Бэклог = единственный источник правды
- mega-review-BACKLOG.md = реестр findings (auto-close при закрытии в проектных бэклогах)
- Findings автоматически раскидываются в бэклоги проектов через `sync_items()` в code-reviewer/run.sh
