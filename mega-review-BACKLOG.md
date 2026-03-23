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

## Review 2026-03-20

### Critical
- [ ] **[Vedic → CI] Сайт не работает — Vercel не может собрать проект** — 6 ошибок ESLint блокируют билд. Сайт отдаёт 404 уже 2 недели — `src/app/reports/page.tsx`, `src/lib/pdf/generateReport.ts`, `src/app/api/sade-sati/route.ts`
- [ ] **[Vedic → Security] Захардкоженный admin-ключ "1406" в коде** — любой может сгенерировать отчёт бесплатно, зная этот ключ. Нужно требовать env var — `app/api/reports/generate/route.ts:25`
- [ ] **[SAMI → Bug] Стратег не может отправить пакет боту** — JSON.parse падает если payload не строка. Открыт 3 недели — `index.ts:~530`

### High
- [ ] **[Vedic → Deadline] API для платных отчётов скоро отключится** — VedicAstroAPI trial: 498 вызовов, истекает ~28 марта. Без оплаты ($18/мес) premium отчёты перестанут работать
- [ ] **[Vedic → Security] Уязвимости в npm-пакетах** — запустить `npm audit`, пропатчить критические
- [ ] **[SAMI → Reliability] Данные челленджей теряются при перезагрузке** — challengeContext хранится в памяти (Map), при Railway restart всё обнуляется. Перенести в SQLite — `approval.ts:26`
- [ ] **[Hunter → Docs] CLAUDE.md врёт про AI-стек** — написано Anthropic SDK, реально Gemini + Groq. Обновить
- [ ] **[Hunter → Analytics] Нет метрик по воронке** — добавить в /adminstats: % завершения онбординга, trial→paid конверсия
- [ ] **[Portfolio → Analytics] Аналитика не работает** — GoatCounter аккаунт diyordesign не зарегистрирован. Данные не собираются уже месяц

### Medium
- [ ] **[Hunter → Cleanup] Мёртвая зависимость @anthropic-ai/sdk** — Anthropic SDK удалён из кода, но остаётся в package.json. Удалить
- [ ] **[Hunter → Cleanup] ANTHROPIC_API_KEY в zod-схеме** — ключ больше не нужен, но конфиг его требует — `config.ts:8`
- [ ] **[Vedic → Bug] Неправильный model ID для Claude** — `claude-sonnet-4-20250514` не существует, нужно `claude-sonnet-4-6` — `lib/ai/interpret.ts:52,77`
- [ ] **[SAMI → Performance] Сборка HTTP body строкой вместо буфера** — `body += chunk` создаёт лишние копии, использовать Buffer.concat — `index.ts:382`
- [ ] **[Portfolio → Sync] Кейс Hunter врёт про AI-стек** — в тексте "Claude/Haiku", реально Gemini 2.5 Pro + Groq. Обновить RU и EN — `projects/hunter.html`
- [ ] **[Portfolio → Sync] Кейс Vedic — устаревшая визуальная тема** — описывает тёмную тему, реально Flora pink — `projects/vedic.html`
- [ ] **[Portfolio → Sync] Кейс SAMI — устаревшие данные** — LOC показывает ~9K вместо 14K+, "Сезоны" переименованы в "Челленджи" — `projects/sami.html`

### Low
- [ ] **[SAMI → Cleanup] Дубль emoji-маппинга** — CATEGORY_EMOJI_MAP дублирует CATEGORY_EMOJI. Удалить один — `shared.ts:~213`

## Review 2026-03-21

### Critical
- [ ] **[Vedic → Deploy] Сайт лежит 3-ю неделю** — Vercel отдаёт 404. CI не проходит → билд не собирается → деплой не происходит. Нужно починить CI (см. выше)
- [ ] **[Vedic → Deadline] VedicAstroAPI trial истекает ~28 марта** — без оплаты $18/мес premium-отчёты перестанут генерироваться. Осталось 498 вызовов

### High
- [ ] **[SAMI → CI] GitHub Actions красный 5 запусков подряд** — тесты проходят локально (334), проблема в CI-окружении (env vars или Node version)
- [ ] **[Hunter → Infra] Стратег-агент сломан в GitHub Actions** — ANTHROPIC_API_KEY протух или не настроен в GitHub Secrets

### Medium
- [ ] **[Vedic → Architecture] Rate limiter сбрасывается при холодном старте** — in-memory Map обнуляется на каждом Vercel cold start. Для прода нужен Redis/KV — `rateLimit.ts`
- [ ] **[Portfolio → Analytics] GoatCounter не собирает данные** — аккаунт создан, но код пишет на несуществующий домен. Проверить настройки
- [ ] **[Portfolio → Bug] 4 страницы грузят несуществующий qa.js** — kombo, prosto, skysmart, teletype содержат `<script src="/qa.js">` → 404 в проде

### Low
- [ ] **[SAMI → Refactor] db.ts — монолит 2399 строк, 184 экспорта** — нечитаемо, невозможно тестировать. Выделить db-approval.ts, db-analytics.ts
- [ ] **[Hunter → Refactor] 3 файла-монолита** — db.ts (1291), bot.ts (940), onboarding.ts (955). Разбить на модули
- [ ] **[Vedic → Cleanup] Тестовая admin-страница видна в проде** — `test-admin/page.tsx` показывает "Not available" вместо 404. Заменить на `notFound()`
- [ ] **[Vedic → i18n] Admin-панель на английском** — остальной сайт на турецком, admin забыли перевести

## From Review 2026-03-23

- [ ] **Vedic** — critical — Исправить 404: открыть Vercel dashboard → Deployments → найти failed build → проверить DATABASE_URL в Environment Variables → передеплоить — немедленно
- [ ] **Vedic** — critical — Оплатить VedicAstroAPI $18/мес до 28 марта (5 дней, 498 вызовов осталось) — VT-703
- [ ] **Hunter** — critical — Добавить `GOOGLE_AI_API_KEY` в GitHub → Settings → Secrets → Actions — 5 минут, фиксирует CI стратега
- [ ] **Vedic** — high — `npm audit fix` — выявить 3 high vulnerabilities, обновить react 19.2.3→19.2.4
- [ ] **Hunter** — high — Опубликовать пост в 3 Telegram чата с разработчиками/дизайнерами — стратег прав: один пост = 20-50 юзеров
- [ ] **Portfolio** — high — Опубликовать черновики (Telegram @diyoriko, LinkedIn Featured, HH описание) — DIST-NOW
- [ ] **Portfolio** — high — Зарегистрировать аккаунт на goatcounter.com (diyordesign) — 2 минуты, 3 недели потеряны
- [ ] **Portfolio** — medium — `git rm vedic-v2.html && git commit` — ZOMBIE-01
- [ ] **SAMI** — medium — SM-1010: вынести videos, posts, members, challenges из `db.ts` (остаток ~1800L после db-approval.ts) — фаза 2-5
- [ ] **SAMI** — medium — Вынести `sendMyWorkouts`, `sendChallengeView`, `sendFilterResults` из `bot-menu.ts:1745,1875,1950` в отдельный файл
- [ ] **Hunter** — medium — Проверить `resume-import.ts:22-24`: `new PDFParse({ data: buffer })` на совместимость с pdf-parse v2 — риск молчащего бага
- [ ] **Vedic** — medium — `rateLimit.ts`: задокументировать ограничение (in-memory = не работает на serverless) — добавить TODO комментарий или перейти на Upstash Redis — `lib/utils/rateLimit.ts:3`
- [ ] **Portfolio** — medium — Проверить mobile nav burger на 375px (JS toggle), если сломан — добавить в `script.js`
- [ ] **SAMI** — medium — Написать оставшимся 9 знакомым (SM-1000: 1/10 за 2 недели) — единственный рычаг роста при 16 подписчиках
- [ ] **Vedic** — low — `payment/success/page.tsx:128` — кнопка "Raporu İndir" (`href="#"`) — добавить `disabled` стиль и tooltip "Yakında" до реализации VT-702
