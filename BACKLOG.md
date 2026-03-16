# Architect — Backlog

Задачи создаются автоматически после каждого weekly review.
Стратег и Architect приоритизируют. Диёр решает.

---

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

</details>

---

## Open

### P0
- [ ] **Верифицировать SAMI cron fix** — fix в main (f7e0413) но Railway мог не подхватить. Проверить /health после redeploy.

### P1
- [x] **Hunter cover-letter.ts тесты** — 35 тестов (16.03)
- [x] **SAMI scheduler.ts тесты** — 16 тестов, PR #2 (16.03)
- [x] **Диагностировать SAMI lastPost=null** — баг в poster.ts (не передавал video в postVideoToChannel). Fix в main.

### P2
- [ ] **Memory session cleanup** — архивировать session files старше 30 дней
- [ ] **zod v3→v4** — отложено (breaking changes, отдельная сессия)

---

### CodeRabbit Suggestions
<!-- CodeRabbit замечания будут добавляться сюда автоматически -->
