# Architect — Backlog

Задачи создаются автоматически после каждого weekly review + ad-hoc из сессий.
Стратег и Architect приоритизируют. Диёр решает.

---

## Open

### P0: Strategist Improvements
- [ ] **Hunter: починить обрезанный отчёт** — последний отчёт ~400 слов, пропущены секции. Проверить run.sh: timeout, output size, claude --print обрезает?
- [ ] **Фидбек-луп для всех стратегов** — перед генерацией отчёта собрать: какие задачи из прошлого отчёта были выполнены (`[x]` в бэклоге). Добавить секцию "Выполнено с прошлого раза" в промпт

### P1: Единый процесс Sprint → Release → Backlog
- [ ] **Унифицировать бэклоги** — во всех проектах вести таски с номерами (SAMI-xxx, HUNT-xxx, VT-xxx, PORT-xxx). Единый формат: `- [ ] **PROJ-NNN** Title — description`
- [ ] **Процесс спринт-релиз-тесты** — чёткий пайплайн: спринт (набор задач) → реализация → тесты → деплой → релиз (vX.Y.Z). После деплоя спринт архивируется под номером релиза
- [ ] **Автоархивация спринтов** — при деплое (git tag / version bump) текущий спринт сворачивается в `<details>` с номером версии и датой. Открытые задачи переносятся в следующий спринт с причиной
- [ ] **Шаблон бэклога** — единый BACKLOG.md template для всех проектов: Current Sprint, Open (P0-P3), Completed (по релизам), CodeRabbit Suggestions

### P1: Strategist Data Quality
- [ ] **Hunter: метрики через /report endpoint** — добавить в бота эндпоинт с DAU/WAU, trial→paid, scraper success rate. Стратег будет фетчить как SAMI
- [ ] **Portfolio: GoatCounter парсинг** — агрегировать данные (top pages, total views, trends) вместо raw JSON
- [ ] **Portfolio: оптимизировать токены** — вместо FULL HTML кейсов отправлять summary (title + h1 + meta + первый параграф). Экономия ~60% токенов
- [ ] **SAMI: автосинхронизация proposal-status** — читать COMMUNITY_TASKS.md и автоотмечать выполненные предложения вместо ручного обновления

### P2: Strategist Polish
- [ ] **Architect: Telegram alert** — при critical findings (coverage crash, high vulns) отправлять DM
- [ ] **Vedic: создать стратега** — пока нет стратега, Vedic не анализируется ежедневно

---

## Completed (21.03.2026)

- [x] **Mega Reviewer починен** — tac→tail -r (macOS), prompt 621KB→446KB (тесты заменены на CI status), set +e в пост-обработке, дубль секции GH Actions убран. Время сборки: 2ч → 17с
- [x] **Health дашборд: парсер обновлён** — mega-review.html теперь понимает 3 формата findings: `[Project → Dest]`, `[VT][BUG][CRITICAL]`, `Project — severity — title`. Scorecard и findings отображаются корректно
- [x] **Mega Review 21.03 запущен** — полный цикл 4 мин, отчёт сохранён, бэклоги проектов обновлены, Google Calendar создан
- [x] **Бэклог очищен** — закрытые задачи архивированы, структура упорядочена

## Completed (20.03.2026)

<details><summary>19 задач закрыто — развернуть</summary>

- [x] **Dashboard redesign** — index.html → Command Center (Agent Pulse, Projects, Needs Attention, Insights)
- [x] **Health page** — mega-review.html → Scorecard матрица 4x5 + findings с категориями
- [x] **Единая навигация** — nav bar на всех 6 страницах (Home, Health, Hunter, SAMI, Vedic, Portfolio)
- [x] **Единый header** — nav сверху, затем title + live dot + timestamp, desc, links на всех backlog-страницах
- [x] **Cache-Control** — serve-dashboard.sh отдаёт no-cache для HTML (Arc browser fix)
- [x] **Backlog discipline** — добавлено правило обновления бэклогов в CLAUDE.md всех 4 проектов
- [x] **GoatCounter** — аккаунт создан, аналитика работает
- [x] **Авто-закрытие findings** — closure check добавлен в `code-reviewer/run.sh`
- [x] **Дедупликация по контенту** — fingerprint dedup добавлен в `code-reviewer/run.sh`
- [x] **Стратег-рекомендации в mega-review** — добавлен extract в code-reviewer/run.sh
- [x] **Обратная ссылка на report** — sync_items теперь добавляет `<!-- Source: -->` комментарий
- [x] **Архивация старых reviews** — archive_old_reviews добавлен в `code-reviewer/run.sh`
- [x] **`/backlog` skill** — читает BACKLOG.md / COMMUNITY_TASKS.md, stats, фильтры
- [x] **`/catchup` skill** — последний отчёт стратега + P0 задачи
- [x] **`/status` skill** — health check: curl endpoints + gh run list + npm audit
- [x] **`/deploy` skill** — typecheck → test → push → verify → report
- [x] **`/copy-review` skill** — Portfolio: ревью текстов по TONE_GUIDE.md
- [x] **`/audit-seo` skill** — Portfolio: meta/OG/canonical/hreflang/sitemap/alt
- [x] **Единый формат timestamp** — SAMI и Vedic приведены к `HH:MM`
- [x] **Починить gh cli** — работает, авторизован (diyoriko). Проблема была в PATH для launchd агентов

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
