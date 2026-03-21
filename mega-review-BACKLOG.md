# Mega Reviewer — Реестр находок

Все задачи передаются в бэклоги проектов. Здесь — трекинг статуса.
Последнее обновление: 19.03.2026

---

## Review 2026-03-18

### Critical
- [x] **[Vedic → VT-600] CI broken — 6 ESLint errors** — блокирует каждый merge — `reports/page.tsx:289`, `generateReport.ts:84`, `chart-verification.ts`, `sade-sati/route.ts:177`
- [x] **[Vedic → VT-601] Pricing 149 TRY вместо 2,450 TRY** — legacy Sugata Jyotish цены, блокер для Shopier — `src/types/jyotish.ts`
- [x] **[Vedic → VT-602] Paid reports already use Claude** — verified, backlog was stale — `src/lib/ai/interpret.ts` (19.03)
- [x] **[SAMI → done] JSON.parse crash** — обёрнут в валидацию, packet проверяется как объект — `index.ts` (18.03)

### High
- [x] **[Vedic → VT-603] Тесты подтверждают неправильные цены** — `types.test.ts` assert 79 TRY вместо 2450 — `tests/types.test.ts`
- [x] **[Hunter → done] Model ID не существует в Claude API** — `claude-sonnet-4-6` — `cover-letter.ts:114` (18.03, v0.22.0)
- [x] **[Hunter → done] CI стратега упал** — `grep` + `pipefail` fix — `run.sh:139` (18.03, v0.22.0)
- [x] **[SAMI → done] challengeContextMap → SQLite** — перенесён в `approval_sessions` — `approval.ts`, `db.ts` (18.03)
- [x] **[Portfolio → BACKLOG] GoatCounter мёртв** — домен не зарегистрирован, ноль аналитики — `site/index.html` (20.03, аккаунт создан)

### Medium
- [x] **[SAMI → done] Dead reject callback** — удалён из regex — `approval.ts` (18.03)
- [x] **[Hunter → done] employerIndustry dead param** — удалён — `scorer.ts` (18.03, v0.22.0)

### Low
- [x] **[SAMI → done] CATEGORY_EMOJI дубль** — удалён `CATEGORY_EMOJI_MAP` — `shared.ts` (18.03)
- [x] **[Vedic → VT-604] No Groq SDK to remove** — project uses raw fetch, no SDK — verified (19.03)

---

## Review 2026-03-17

### Critical
- [x] **[SAMI → done] JSON.parse packet** — закрыто 18.03 как C4
- [x] **[SAMI → done] challengeContextMap → DB** — закрыто 18.03 как H4
- [x] **[SAMI → done] Dead reject handler** — закрыто 18.03 как M1

### High
- [x] **[Hunter → done] Model ID обновить** — закрыто 18.03 как H2

### Medium
- [x] **[SAMI → done] CATEGORY_EMOJI_MAP дубль** — закрыто 18.03 как L1
- [ ] **[SAMI → P2 code review] Function type → конкретный** — `approval.ts:88`
- [ ] **[SAMI → P2 code review] require → import** — `downloader.ts:78`
- [ ] **[SAMI → P2 code review] escapeMarkdown удалить** — `shared.ts:~305`
- [ ] **[SAMI → P2 code review] Дубль вычисления дат** — `analytics.ts:171`, `rubrics.ts:42,87`
- [ ] **[Hunter → Sprint 9] Дубль reengagement** — `scheduler.ts:~260`
- [ ] **[Hunter → Sprint 9] Hardcoded currency rates** — `scorer.ts:~180`
- [ ] **[Hunter → Sprint 9] Version из package.json** — `config.ts:16`
- [ ] **[Cross] Auth fallback вынести** — `API_KEY ?? BOT_TOKEN` повторяется в каждом index.ts

## From Review 2026-03-20

- [ ] **Vedic** — critical — исправить ESLint ошибки (no-html-link-for-pages, prefer-const, no-explicit-any, no-unused-vars) → разблокировать Vercel build и вернуть сайт — `src/app/reports/page.tsx:289`, `src/lib/pdf/generateReport.ts:84`, `tests/chart-verification.ts:99,142,143,148`, `src/app/api/sade-sati/route.ts:177`
- [ ] **Vedic** — critical — убрать fallback `"1406"` в admin key, требовать только env var — `app/api/reports/generate/route.ts:25`
- [ ] **Vedic** — high — запустить `npm audit`, идентифицировать уязвимые пакеты, пропатчить — `package.json`
- [ ] **Vedic** — high — оплатить VedicAstroAPI $18/мес до Mar 31 (498 вызовов осталось, истекает) — VT-703
- [ ] **SAMI** — critical — исправить `JSON.parse(payload.packet)` в `/packet` handler (3-я неделя открыт) — `index.ts:~530`
- [ ] **SAMI** — high — сохранить `challengeContext` в DB вместо in-memory Map — `approval.ts:26`
- [ ] **Hunter** — high — обновить CLAUDE.md: секция AI (Gemini/Groq), удалить упоминание Anthropic SDK — `CLAUDE.md`
- [ ] **Hunter** — high — запустить `/adminstats`, добавить метрики onboarding completion rate и trial→paid conversion — `handlers/admin.ts`
- [ ] **Portfolio** — high — зарегистрировать `diyordesign.goatcounter.com` на goatcounter.com — `index.html:32`
- [ ] **Hunter** — medium — удалить `@anthropic-ai/sdk` из зависимостей (не используется) — `package.json`
- [ ] **Hunter** — medium — убрать `ANTHROPIC_API_KEY` из zod config schema — `config.ts:8`
- [ ] **Vedic** — medium — обновить Claude model ID: `claude-sonnet-4-20250514` → `claude-sonnet-4-6` — `lib/ai/interpret.ts:52,77`
- [ ] **SAMI** — medium — заменить `body += chunk` на `Buffer.concat(chunks)` — `index.ts:382-383`
- [ ] **Portfolio** — medium — обновить Hunter case (SYNC-01): 6 строк про AI provider (RU + EN) — `projects/hunter.html:~74,96,128`
- [ ] **Portfolio** — medium — обновить Vedic case (SYNC-02): секция визуального языка → Flora pink тема — `projects/vedic.html`
- [ ] **Portfolio** — medium — обновить SAMI case (SYNC-03): Seasons→Challenges, LOC 14K+ — `projects/sami.html`
- [ ] **SAMI** — low — удалить `CATEGORY_EMOJI_MAP`, везде использовать `CATEGORY_EMOJI` — `shared.ts:~213`

## Review 2026-03-21

- [ ] **[VT][BUG][CRITICAL] Vercel 404 — 3-я неделя**
- [ ] **[VT][BUG][CRITICAL] VT-703: Upgrade VedicAstroAPI до 28 марта**
- [ ] **[SAMI][BUG][HIGH] CI красный 5 подряд — GitHub Actions environmental**
- [ ] **[HUNTER][BUG][HIGH] Strategist Agent workflow — ANTHROPIC_API_KEY**
- [ ] **[VEDIC][ARCH][MED] VT-806: Rate limit → Redis**
- [ ] **[PORTFOLIO][BUG][MED] GoatCounter мёртв — нет аналитики 1+ мес**
- [ ] **[PORTFOLIO][BUG][MED] QA-скрипт 404 в production (BUG-15)**
- [ ] **[SAMI][ARCH][LOW] Разбить db.ts (2399 ln, 184 exports)**
- [ ] **[HUNTER][ARCH][LOW] Разбить src/db.ts (1291 ln), bot.ts (940 ln), onboarding.ts (955 ln)**
- [ ] **[VEDIC][CLEANUP][LOW] Удалить src/app/test-admin/page.tsx**
- [ ] **[VEDIC][BUG][LOW] VT-613: перевести admin page на турецкий**
