# Architect — Backlog

Задачи создаются автоматически после каждого weekly review + ad-hoc из сессий.
Формат: `ARCH-NNN` — последовательная нумерация. Следующий номер: **ARCH-065**.

---

## Sprint 9 (open, 26.03.2026)

### Epic: GIT — Закоммитить и запушить всё
- [ ] **ARCH-051** Architect: git add + commit + push — dashboard v2 (server.mjs, dashboard/, package.json, .gitignore, serve-dashboard.sh)
- [ ] **ARCH-052** Hunter: git push (1 ahead) + закоммитить перенос файлов (article-vc.md → docs/research/, Tg Avatar → assets/)
- [ ] **ARCH-053** Sami: git push (1 ahead) + закоммитить перенос файлов (DB_SPLIT_PLAN, STRATEGIST_BRIEF → docs/research/)
- [ ] **ARCH-054** Vedic: закоммитить BACKLOG.md + CLAUDE.md + PDF deletion + docs/research/ + push

### Epic: HYGIENE — Структура проектов
- [ ] **ARCH-055** Sami: переименовать COMMUNITY_TASKS.md → BACKLOG.md — обновить все ссылки (CLAUDE.md, serve-dashboard.sh, server.mjs, dashboard)
- [ ] **ARCH-056** Sami: reports/strategist symlink → прямые пути — убрать зависимость от ~/Library
- [ ] **ARCH-057** Architect .gitignore — расширить (node_modules, coverage, *.log)
- [ ] **ARCH-058** Hunter .gitignore — добавить coverage/
- [ ] **ARCH-059** Vedic .gitignore — явно добавить .next/

### Epic: DASH — Dashboard (продолжение Sprint 8)
- [x] **ARCH-043** Dashboard redesign — Crucix-style, Express+SSE, 3 колонки, boot-анимация ✅
- [x] **ARCH-044** Dashboard: полезная сводка — Projects, Alerts, Agents, Insights, Memory Profile ✅
- [ ] **ARCH-045** Dashboard: mobile responsive (сейчас ломается на телефоне)

### Epic: RELIABILITY
- [ ] **ARCH-046** Диагностика Claude CLI timeout — стратегисты не работали 23-25.03
- [ ] **ARCH-060** Radar: Sami .env отсутствует — создать или переключить Telegram на Hunter bot token

### Epic: QUALITY
- [ ] **ARCH-048** Vedic 404 — DATABASE_URL в Vercel env vars
- [ ] **ARCH-049** VedicAstroAPI trial → $18/мес до 28.03 (3 дня, делает Диёр)
- [ ] **ARCH-050** Hunter: GOOGLE_AI_API_KEY в GitHub Secrets (5 мин)
- [ ] **ARCH-061** README.md — создать для Hunter, Sami, Portfolio, Architect
- [ ] **ARCH-062** Architect: агенты в корне → перенести в agents/ (watchdog, morning-briefing, memory-prune)
- [ ] **ARCH-063** Portfolio: очистить orphan dirs (El Animation/, readymag-exports/, screenshots/) — архив или удаление
- [ ] **ARCH-064** 11 орфанных проектов в Projects/ — решить судьбу (Amma, ENXT, FD, HSE, Imran, JobDashboard, Osme, Qlean, Skysmart, Teletype, VK)

---

## Completed — Sprint 7 (23.03.2026, commit 118619c)

<details><summary>9 задач — развернуть</summary>

- [x] **ARCH-031** Architect prompt де-дуплицирован (health/quality/code → "see Mega Review", -30% промпт)
- [x] **ARCH-032** morning-briefing.sh — daily 09:00 MSK, Telegram DM (silent when all OK)
- [x] **ARCH-033** Architect: AI research секция в промпте + @denis_news_feed reference
- [x] **ARCH-034** "Tool Recommendations" секция в формате отчёта Architect
- [x] **ARCH-038** dev.hardstop — verified working
- [x] **ARCH-039** Backup monitoring — both repos running, pinned upload-artifact@v4.6.2
- [x] **ARCH-040** memory-prune.sh — auto-cleanup sessions >14 дней, integrated into run.sh
- [x] **ARCH-041** Backlog pages: Keep/Remove кнопки для auto-задач (dashboard moderation UI)
- [x] **ARCH-042** Visual distinction: цветные полоски + source badges для auto-задач

</details>

## Completed — Sprint 6 (23.03.2026, commit 23c3f76)

<details><summary>7 задач — развернуть</summary>

- [x] **ARCH-035** Все стратеги → @diyoriko_claude_bot
- [x] **ARCH-036** Все стратеги еженедельно (вс 09:30-10:30 MSK)
- [x] **ARCH-037** /deploy skill: Telegram деплой-уведомления
- [x] **ARCH-038+** Dashboard moderation API: POST /api/moderate (Keep/Remove)
- [x] **ARCH-039+** Source tags: `[strategist]` и `[mega-review]` в auto-задачах
- [x] **ARCH-040+** format-telegram.sh: конвертер markdown→Telegram (emoji, bullets, no tables)
- [x] **ARCH-041+** Dashboard: Vedic стратег + обновлённые расписания агентов

</details>

---

## Completed — Sprint 5 (23.03.2026, commit e2831b2)

<details><summary>6 задач — развернуть</summary>

- [x] **ARCH-025** Agent health watchdog — daily 10:00, Telegram DM при overdue агентах
- [x] **ARCH-026** Portfolio стратег: timeout 15 мин + crash alert
- [x] **ARCH-027** Vedic стратег: timeout 15 мин + crash alert
- [x] **ARCH-028** Portfolio: extract-tasks → BACKLOG.md (через shared/extract-tasks-simple.sh)
- [x] **ARCH-029** Vedic: extract-tasks → BACKLOG.md (аналогично)
- [x] **ARCH-030** strategist-base.sh — общая библиотека (PATH, Telegram, Calendar, timeout, feedback, extract)

</details>

## Completed — Sprint 4 (23.03.2026, commit d7b3b30)

<details><summary>9 задач — развернуть</summary>

- [x] **ARCH-007** Унифицировать бэклоги — формат PROJ-NNN во всех проектах
- [x] **ARCH-008** Автоархивация спринтов — Step 6 в /deploy skill
- [x] **ARCH-009** Процесс sprint→release — CLAUDE.md всех 5 проектов
- [x] **ARCH-010** → Hunter BACKLOG.md (P2)
- [x] **ARCH-011** → Portfolio BACKLOG.md
- [x] **ARCH-012** → SAMI COMMUNITY_TASKS.md
- [x] **ARCH-020** → SAMI (уже был)
- [x] **ARCH-021** → Hunter (уже был)
- [x] **ARCH-022** → Hunter BACKLOG.md

</details>

---

## Completed — Sprint 3 (23.03.2026, commit f67f8b5)

<details><summary>8 задач — развернуть</summary>

- [x] **ARCH-004** Hunter стратег: timeout 15 мин + логирование размера промпта
- [x] **ARCH-013** Telegram alert при critical findings в mega review
- [x] **ARCH-015** Agent Pulse: показывает время последнего запуска (не только "ago")
- [x] **ARCH-017** sync_items() вставляет в текущий спринт (перед первым `---`)
- [x] **ARCH-018** parseMR() в index.html синхронизирован с mega-review.html (From Review, ### Severity, все 3 формата)
- [x] **ARCH-019** Needs Attention: critical findings группируются по проектам с deep links + high findings показываются
- [x] **ARCH-023** Memory pruning — проверено, все 18 файлов в пределах недели, нечего удалять
- [x] **ARCH-024** dev.hardstop — проверен, работает корректно (`- 0` = нормальный статус, нотификация исправна)

</details>

## Completed — Sprint 2 (21.03.2026, commits 77cdbc3..1c606fc)

<details><summary>9 задач — развернуть</summary>

- [x] **ARCH-001** Hunter: фидбек-луп — "Прогресс с прошлого отчёта" (коммиты + закрытые задачи) в run.sh
- [x] **ARCH-002** Portfolio: фидбек-луп + оптимизация токенов (case pages → summary, script.js → structure only)
- [x] **ARCH-003** Vedic: стратегист создан — run.sh + prompt.md + launchd (вс 12:00 МСК)
- [x] **ARCH-005** Система нумерации задач — формат PROJ-NNN, внедрено в Architect
- [x] **ARCH-006** Шаблон бэклога — BACKLOG_TEMPLATE.md
- [x] **ARCH-014** Findings переписаны на человеческий язык — "что сломано?" + "что делать?"
- [x] **ARCH-016** Health парсер: projects из `[Project → Dest]` формата — tagM перехватывал формат с `→`
- [x] Needs Attention кликабельные — expand/collapse detail + extractP0()
- [x] Недостающие findings синхронизированы в Hunter бэклог (стратег сломан, монолиты)

</details>

## Completed — Sprint 1 (21.03.2026, commit 6145808)

<details><summary>4 задачи — развернуть</summary>

- [x] Mega Reviewer починен — tac→tail -r, prompt 621→446KB, set +e, dedup GH Actions
- [x] Health дашборд — парсер 3 форматов findings, scorecard работает
- [x] Mega Review 21.03 — полный цикл 4 мин, бэклоги обновлены
- [x] Бэклог очищен — закрытые архивированы

</details>

## Completed (20.03.2026)

<details><summary>19 задач — развернуть</summary>

- [x] Dashboard redesign — Command Center
- [x] Health page — Scorecard 4x5 + findings
- [x] Единая навигация — nav bar 6 страниц
- [x] Единый header — live dot + timestamp
- [x] Cache-Control — no-cache для HTML
- [x] Backlog discipline — CLAUDE.md всех проектов
- [x] GoatCounter — аккаунт создан
- [x] Авто-закрытие findings
- [x] Дедупликация по контенту
- [x] Стратег-рекомендации в mega-review
- [x] Обратная ссылка на report
- [x] Архивация старых reviews
- [x] `/backlog` `/catchup` `/status` `/deploy` `/copy-review` `/audit-seo` skills
- [x] Единый формат timestamp
- [x] Починить gh cli

</details>

## Completed (15-16.03.2026)

<details><summary>28 задач — развернуть</summary>

- [x] Починить стратегов (API key)
- [x] npm audit fix Hunter
- [x] Тесты: Hunter bot/scheduler/onboarding/cover-letter (262), SAMI approval/poster/index/scheduler (76)
- [x] Hunter CI coverage + thresholds (20%)
- [x] Hard stop 22:30 launchd
- [x] PR-workflow SAMI (branch protection)
- [x] Расширить сбор данных + автозапись BACKLOG.md + глубокий анализ
- [x] Architect launchd fix (API key в plist)
- [x] Hunter backlog audit (P3 свёрнуты)
- [x] Major deps — оба проекта
- [x] SAMI: version guardrail, db.ts split plan, lastPost=null fix
- [x] Self-improving prompt + AI Tooling
- [x] Memory session cleanup, zod v3→v4

</details>

---

### CodeRabbit Suggestions
<!-- CodeRabbit замечания будут добавляться сюда автоматически -->
