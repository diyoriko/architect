# Architect — Backlog

Задачи создаются автоматически после каждого weekly review + ad-hoc из сессий.
Формат: `ARCH-NNN` — последовательная нумерация. Следующий номер: **ARCH-016**.

---

## Sprint 2 (21.03.2026)

### Epic: STRAT — Strategist Improvements

- [x] **ARCH-001** Hunter: фидбек-луп — добавлен блок "Прогресс с прошлого отчёта" (коммиты + закрытые задачи) в run.sh
- [x] **ARCH-002** Portfolio: фидбек-луп — аналогично, + оптимизация токенов (case pages → summary, script.js → structure only)
- [x] **ARCH-003** Vedic: создать стратега — run.sh + prompt.md + launchd (вс 12:00 МСК)
- [ ] **ARCH-004** Hunter: починить обрезанный отчёт — 21.03 запуск занял 11ч26м, нет таймаута в run.sh. Добавить проверку размера промпта и логирование

### Epic: PROC — Sprint/Release/Backlog Process

- [x] **ARCH-005** Система нумерации задач — формат `PROJ-NNN` (ARCH, SAMI, HUNT, VT, PORT). Внедрено в Architect
- [x] **ARCH-006** Шаблон бэклога — BACKLOG_TEMPLATE.md для всех проектов
- [ ] **ARCH-007** Унифицировать бэклоги Hunter/SAMI/Vedic/Portfolio — перевести на PROJ-NNN формат
- [ ] **ARCH-008** Автоархивация спринтов — при деплое (git tag) текущий спринт сворачивается в `<details>`, открытые переносятся с причиной
- [ ] **ARCH-009** Процесс спринт-релиз-тесты — задокументировать пайплайн в CLAUDE.md всех проектов

### Epic: STRAT — Data Quality

- [ ] **ARCH-010** Hunter: метрики через /report endpoint — DAU/WAU, trial→paid, scraper success rate
- [ ] **ARCH-011** Portfolio: GoatCounter парсинг — top pages, total views, trends вместо raw JSON
- [ ] **ARCH-012** SAMI: автосинхронизация proposal-status — читать COMMUNITY_TASKS.md и автоотмечать выполненные

### Epic: INFRA — Infrastructure

- [ ] **ARCH-013** Architect: Telegram alert — при critical findings (coverage crash, vulns) DM admin
- [x] **ARCH-014** Mega Reviewer: человекопонятные findings — каждая строка отвечает на "что сломано?" и "что делать?", а не сухие теги типа `[VT][BUG][CRITICAL]`
- [ ] **ARCH-015** Dashboard: агент-статусы — показывать время последнего запуска каждого стратега на index.html

---

## Completed — Sprint 1 (21.03.2026, commit 6145808)

<details><summary>4 задачи — развернуть</summary>

- [x] **Mega Reviewer починен** — tac→tail -r, prompt 621→446KB, set +e, dedup GH Actions
- [x] **Health дашборд** — парсер 3 форматов findings, scorecard работает
- [x] **Mega Review 21.03** — полный цикл 4 мин, бэклоги обновлены
- [x] **Бэклог очищен** — закрытые архивированы

</details>

## Completed (20.03.2026)

<details><summary>19 задач закрыто — развернуть</summary>

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
- [x] `/backlog` skill
- [x] `/catchup` skill
- [x] `/status` skill
- [x] `/deploy` skill
- [x] `/copy-review` skill
- [x] `/audit-seo` skill
- [x] Единый формат timestamp
- [x] Починить gh cli

</details>

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
- [x] Major deps — оба проекта
- [x] SAMI version velocity guardrail
- [x] SAMI db.ts split plan
- [x] Верифицировать dev.hardstop
- [x] Fix run.sh дубль
- [x] Self-improving prompt + AI Tooling
- [x] Hunter cover-letter.ts тесты — 35
- [x] SAMI scheduler.ts тесты — 16
- [x] Диагностировать SAMI lastPost=null
- [x] Memory session cleanup
- [x] zod v3→v4

</details>

---

### CodeRabbit Suggestions
<!-- CodeRabbit замечания будут добавляться сюда автоматически -->
