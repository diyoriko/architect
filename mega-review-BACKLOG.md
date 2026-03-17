# Mega Reviewer — Backlog

Action items из code/UX/test reviews. Задачи попадают в бэклоги проектов автоматически.

---

## From Review 2026-03-17

### SAMI — Critical
- [ ] **JSON.parse packet** — стратег-пакет записывается как строка → бот получает DEFAULT_PACKET — `index.ts:~530`
- [ ] **challengeContextMap → DB** — in-memory Map теряется при деплое — `approval.ts:26`
- [ ] **Dead reject handler** — callback зарегистрирован но кнопки нет — `approval.ts:~280`

### SAMI — Medium
- [ ] **CATEGORY_EMOJI_MAP удалить** — дубль с разными значениями — `shared.ts:~213`
- [ ] **Function type → конкретный** — `approval.ts:88`
- [ ] **require → import** — `downloader.ts:78`
- [ ] **escapeMarkdown удалить** — deprecated, не используется — `shared.ts:~305`
- [ ] **Дубль вычисления дат** — `analytics.ts:171`, `rubrics.ts:42,87` → использовать `dates.ts`

### Hunter — High
- [ ] **Model ID обновить** — `claude-sonnet-4-20250514` → `claude-sonnet-4-6` — `cover-letter.ts:140`

### Hunter — Medium
- [ ] **employerIndustry dead param** — никогда не передаётся — `scorer.ts:~273`
- [ ] **Дубль reengagement** — два механизма спамят пользователя — `scheduler.ts:~260`
- [ ] **Hardcoded currency rates** — USD×90, EUR×95 неточны — `scorer.ts:~180`
- [ ] **Version из package.json** — хардкод рассинхронизируется — `config.ts:16`

### Cross-Project
- [ ] **Auth fallback вынести** — `API_KEY ?? BOT_TOKEN` повторяется 5+ раз в каждом index.ts
