# Architect — Backlog

Задачи создаются автоматически после каждого weekly review + ad-hoc из сессий.
Формат: `ARCH-NNN` — последовательная нумерация. Следующий номер: **ARCH-025**.

---

## Sprint 3 (следующий)

### Epic: PROC — Sprint/Release/Backlog Process

- [ ] **ARCH-007** Унифицировать бэклоги Hunter/SAMI/Vedic/Portfolio — перевести на PROJ-NNN формат, привязать к спринтам
- [ ] **ARCH-008** Автоархивация спринтов — при деплое (git tag) текущий спринт сворачивается в `<details>`, открытые переносятся с причиной
- [ ] **ARCH-009** Процесс спринт-релиз-тесты — задокументировать пайплайн в CLAUDE.md всех проектов
- [ ] **ARCH-017** sync_items() должен вставлять таски в текущий спринт проекта — сейчас append в конец файла вне спринтов

### Epic: STRAT — Strategist Improvements

- [ ] **ARCH-004** Hunter: починить долгий запуск стратега — 21.03 запуск занял 11ч26м, нет таймаута. Добавить проверку размера промпта и timeout
- [ ] **ARCH-010** Hunter: метрики через /report endpoint — DAU/WAU, trial→paid, scraper success rate для стратега
- [ ] **ARCH-011** Portfolio: GoatCounter парсинг — top pages, total views, trends вместо raw JSON
- [ ] **ARCH-012** SAMI: автосинхронизация proposal-status — читать COMMUNITY_TASKS.md и автоотмечать выполненные

### Epic: INFRA — Infrastructure

- [ ] **ARCH-013** Architect: Telegram alert — при critical findings DM admin
- [ ] **ARCH-015** Dashboard: агент-статусы — показывать время последнего запуска каждого стратега на index.html
- [ ] **ARCH-018** Health парсер: parseMR() не видит `## From Review` и `### Critical/High` в новом формате — привести в sync с mega-review.html парсером
- [ ] **ARCH-019** Needs Attention: добавить deep link на конкретный таб проекта в mega-review.html (сейчас ведёт на общую страницу)

### Epic: QUALITY — From Review 2026-03-22

- [ ] **ARCH-020** SAMI: починить CI — после коммита b4c79db (moderation relax) typecheck/lint падает; CI красный блокирует весь PR workflow
- [ ] **ARCH-021** Hunter: HireHi category-фильтр до scorer — API поддерживает `category=design/dev/QA`, сейчас тянет все 8000+ вакансий без фильтра (O(n²) при росте аудитории)
- [ ] **ARCH-022** Hunter: обновить pdf-parse 1.1.1 → 2.4.5 — major версия, проверить breaking changes в resume import
- [ ] **ARCH-023** Memory system pruning — удалить session files старше 4 недель (18 штук), освободить MEMORY.md индекс
- [ ] **ARCH-024** Проверить dev.hardstop launchd — агент показывает "- 0", не запускается; работа до 23:00 ежедневно без hard stop

---

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
