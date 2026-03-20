# Architect — Backlog

Задачи создаются автоматически после каждого weekly review + ad-hoc из сессий.
Стратег и Architect приоритизируют. Диёр решает.

---

## Open

### P0: Mega Review → Project Sync
- [x] **Авто-закрытие findings** — closure check добавлен в `code-reviewer/run.sh` (20.03)
- [x] **Дедупликация по контенту** — fingerprint dedup добавлен в `code-reviewer/run.sh` (20.03)

### P1: Process Improvements
- [ ] **Стратег-рекомендации в mega-review** — извлекать секцию стратегических инсайтов из отчётов и добавлять в mega-review-BACKLOG.md
- [x] **Обратная ссылка на report** — sync_items теперь добавляет `<!-- Source: -->` комментарий (20.03)
- [x] **Архивация старых reviews** — archive_old_reviews добавлен в `code-reviewer/run.sh` (20.03)

### P2: Dashboard Polish
- [x] **Единый формат timestamp** — SAMI и Vedic приведены к `HH:MM` (20.03)
- [x] **GoatCounter finding** — отмечен `[x]` в mega-review-BACKLOG.md (20.03)

---

## Completed (20.03.2026)

- [x] **Dashboard redesign** — index.html → Command Center (Agent Pulse, Projects, Needs Attention, Insights)
- [x] **Health page** — mega-review.html → Scorecard матрица 4x5 + findings с категориями
- [x] **Единая навигация** — nav bar на всех 6 страницах (Home, Health, Hunter, SAMI, Vedic, Portfolio)
- [x] **Единый header** — nav сверху, затем title + live dot + timestamp, desc, links на всех backlog-страницах
- [x] **Cache-Control** — serve-dashboard.sh отдаёт no-cache для HTML (Arc browser fix)
- [x] **Backlog discipline** — добавлено правило обновления бэклогов в CLAUDE.md всех 4 проектов
- [x] **GoatCounter** — аккаунт создан, аналитика работает

## Completed (15-16.03.2026)

<details><summary>28 задач закрыто — развернуть</summary>

- [x] Починить стратегов (API key)
- [x] npm audit fix Hunter
- [x] Верифицировать Hunter версию
- [x] Тесты Hunter bot.ts (93)
- [x] Тесты Hunter scheduler.ts (29)
- [x] Тесты Hunter onboarding.ts (105)
- [x] Тесты SAMI approval.ts (33)
- [x] Фикс SAMI strategist (launchd path)
- [x] Hunter CI coverage
- [x] Coverage thresholds (20%)
- [x] SAMI poster.ts smoke (10)
- [x] SAMI index.ts smoke (17)
- [x] Hard stop 22:30 launchd
- [x] PR-workflow SAMI (branch protection)
- [x] Расширить сбор данных архитектора
- [x] Автозапись в BACKLOG.md
- [x] Фикс формата записи
- [x] Глубокий анализ процесса
- [x] Architect launchd fix (API key в plist)
- [x] Hunter backlog audit (P3 свёрнуты)
- [x] Major deps (better-sqlite3 12, dotenv 17, node-cron 4) — оба проекта
- [x] SAMI version velocity guardrail (max 3/нед в CLAUDE.md)
- [x] SAMI db.ts split plan (DB_SPLIT_PLAN.md)
- [x] Верифицировать dev.hardstop (notification работает)
- [x] Fix run.sh дубль (проверка на дату)
- [x] Self-improving prompt + AI Tooling + Evolution секции
- [x] Hunter cover-letter.ts тесты — 35 тестов
- [x] SAMI scheduler.ts тесты — 16 тестов
- [x] Диагностировать SAMI lastPost=null
- [x] Memory session cleanup
- [x] zod v3→v4

</details>

---

### CodeRabbit Suggestions
<!-- CodeRabbit замечания будут добавляться сюда автоматически -->

## From Review 2026-03-20


### From Review 2026-03-20
- [ ] **Hunter: ai-client.ts тесты + документация** — новый модуль (free AI для cover letters), 0% coverage, Pro-feature риск; записать провайдер/причину в CLAUDE.md
- [ ] **SAMI: db.ts split фаза 1** — вынести analytics или approval из db.ts (2399 строк, план есть)
- [ ] **SAMI: pre-release checklist в CLAUDE.md** — typecheck + test перед каждым feat-релизом
- [ ] **Memory: удалить session_* старше 14 дней** — MEMORY.md приближается к лимиту (138/200)
- [ ] **SAMI backlog triage** — 43 open задач: sprint assignment, закрыть нерелевантные, цель ≤15 open
- [ ] **Hunter: верифицировать деплой v0.22.1** — health endpoint отдаёт 0.22.0
- [ ] **Починить gh cli или добавить GitHub MCP** — CI мониторинг слепой 2 недели подряд
