# Architect — Backlog

Задачи создаются автоматически после каждого weekly review.
Стратег и Architect приоритизируют. Диёр решает.

---

## From Review 2026-03-15

### P0 — Блокеры
- [x] **Починить стратегов (оба)** — API key настроен (15.03)
- [x] ~~Привлечь первого пользователя в SAMI~~ — *(product, out of scope для архитектора)*

### P1 — Высокий приоритет
- [x] **npm audit fix в Hunter** — undici high severity, fixed (15.03)
- [x] **Верифицировать Hunter версию** — health v0.7.0, OK (15.03)
- [x] **Тесты Hunter bot.ts** — 93 теста (команды, платежи, callbacks, guards) (15.03)
- [x] **Тесты Hunter scheduler.ts** — 29 тестов (cron, push, expiration, digest) (15.03)
- [x] **Тесты Hunter onboarding.ts** — 105 тестов (state machine, transitions, editing) (15.03)
- [x] **Тесты SAMI approval.ts** — 33 теста (lifecycle, queue, soft-delete) (15.03)
- [x] **Фикс SAMI strategist** — launchd runner указывал на стейлый скрипт в ~/Library, исправлен на ~/Documents (15.03)
- [x] **Hunter: env vars в CI для coverage** — ci.yml обновлён на test:coverage (15.03)
- [ ] **Hunter backlog audit** — из 35 задач убрать устаревшие и дубликаты

### P2 — Улучшения
- [x] **Coverage thresholds** — lines: 20%, functions: 20% в обоих проектах (15.03)
- [x] **SAMI poster.ts smoke-тест** — 10 тестов (15.03)
- [x] **SAMI index.ts smoke-тест** — 17 тестов (15.03)
- [ ] **Обновить better-sqlite3 9→12** (в обоих проектах, с тестами)
- [ ] **Версионный лимит SAMI** — max 2 версии/неделю *(process, мониторить)*
- [ ] **Темп SAMI** — risk при 22% coverage *(process, мониторить)*

### Process
- [ ] **Hard stop 21:00** — пик коммитов 22-23h, burnout risk HIGH *(мониторить)*

---

## Architect Self-Improvement
- [x] **Расширить сбор данных:** churn, outdated, large files, commit patterns (15.03)
- [x] **Автоматическая запись в BACKLOG.md** после отчёта (15.03)
- [x] **Продуктовый анализ:** в prompt.md (15.03)
- [x] **Фикс формата записи** — grep -v code blocks в run.sh (15.03)
- [x] **Глубокий анализ процесса** — prompt расширен: паттерны работы, инструменты, context switching (15.03)

---

### CodeRabbit Suggestions
<!-- CodeRabbit замечания будут добавляться сюда автоматически -->
