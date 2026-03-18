# Vedic Turkiye — Backlog

> Single source of truth. Formerly "Sugata Jyotish".
> Split decision: 17.03.2026 — Vedic Turkiye (platform) + Dr. Sugata (personal site, later).

## Current Sprint — Rebrand & Accuracy Fix (17.03.2026)

### Blockers (manual — needs Duygu)
- [ ] VT-001: **Domain decision** — vedikastroloji.com / vedic.com.tr / vedikturkiye.com — Duygu chooses
- [ ] VT-002: **Shopier account** — Duygu registers on shopier.com → Settings → API → gets API_KEY + API_SECRET → add to Vercel (was SJ-420)
- [ ] VT-003: **Chart accuracy verification** — Duygu tests 10+ charts vs AstroSage: her own + 5 Turkish post-2016 births + 5 international. Log results in a spreadsheet.
- [ ] VT-004: **New pricing approval** — Sade Sati 1,950-2,750 TL / Birth Chart 2,450-3,250 TL / Bundle 4,500-5,500 TL — Duygu confirms final prices
- [ ] VT-005: **Visual direction approval** — soft pink / powder tones / warm neutrals palette — prepare 2 mockups, Duygu picks

### Completed This Sprint
- [x] VT-025: **API comparison research** — tested VedAstro, Prokerala, VedicAstroAPI, AstrologyAPI.com. VedAstro URL format bug found & fixed. Prokerala recommended for paid Sade Sati reports. ✅ (17.03.2026)
- [x] VT-022: **Fix VedAstro URL format** — critical: coordinates in Location field broke parsing. Fixed to use place name only. ✅ (17.03.2026)

### Vercel Env Vars
- [x] NEXT_PUBLIC_BASE_URL ✅
- [x] NEXT_PUBLIC_PLAUSIBLE_DOMAIN ✅
- [x] BREVO_API_KEY ✅
- [x] GROQ_API_KEY ✅
- [x] GOOGLE_AI_API_KEY ✅
- [ ] SHOPIER_API_KEY — awaits VT-002
- [ ] SHOPIER_API_SECRET — awaits VT-002

---

## Phase 0: Rebrand + Architecture Split (Week 1)

### P0 — Identity Split
- [ ] VT-010: **Rebrand codebase** — "Sugata Jyotish" → "Vedik Astroloji Türkiye" everywhere: meta tags, OG, nav, footer, User-Agent headers, CLAUDE.md, README
- [ ] VT-011: **Remove personal website sections from homepage** — cut: full bio, publications, teaching venues (Cihangir Yoga, YogaSala, etc.), consultation CTA ($100/hr), book as main section, social links block. Keep: 2-sentence founder mention as trust element only
- [ ] VT-012: **Remove stub pages** — delete /consultation, /course, /circle and their EN mirrors. These belong on Dr. Sugata personal site
- [ ] VT-013: **Update SiteNav** — remove Consultation, Course, Circle links. Brand text: "Vedik Astroloji" (not "Dr. Sugata Duygu Akartuna")
- [ ] VT-014: **Founder trust section** — redesign about section as 3-line trust block: "Founded by Dr. Sugata Duygu Akartuna — PhD Amrita University, 17 years Jyotish practice, author of 'Karma ve Karmanın Efendisi: Saturn'" with small photo. No CV, no publications, no teaching list
- [ ] VT-015: **Update CLAUDE.md** — new brand, stack (Shopier not iyzico), positioning, removed pages
- [ ] VT-016: **New OG image** — branded for "Vedik Astroloji Türkiye" (not Sugata Jyotish)

### P0 — Calculator: Hide or Beta
- [ ] VT-020: **Hide calculator from homepage** — remove inline ChartCalculator from LandingPage. Replace with waitlist CTA: "Doğum Haritanızı Hesaplattığınızda İlk Siz Öğrenin" + email capture
- [ ] VT-021: **Keep /chart page but mark as BETA** — banner: "Bu hesaplayıcı beta aşamasındadır. Sonuçlar doğrulama sürecindedir." Allow usage but set expectations
- [ ] VT-022: **Fix transit time overflow bug** — `formatTransitTimeParam` hour overflow (22+3=25). Add `% 24` and day correction
- [ ] VT-023: **Fix Dasha date approximation** — parse real start/end dates from VedAstro DasaForNow response instead of hardcoded `now ± N years`
- [ ] VT-024: **Verify timezone handling** — test Turkish cities (İstanbul, Ankara, İzmir) + international cities with DST (London, New York, Berlin). Log timezone offset vs expected
- [ ] VT-025: **API comparison research** — test same birth data on VedAstro vs Prokerala vs VedicAstroAPI vs AstroSage manual. Document accuracy differences. Recommend best API
- [ ] VT-026: **North Indian chart style option** — add toggle for North Indian / South Indian chart display (Duygu's brief: "North Indian / South Indian chart style selection")

---

## Phase 1: MVP Relaunch — Turkish Platform (Week 2-3)

### P0 — Homepage Redesign (per brief section 9)
- [ ] VT-100: **Hero section rewrite** — "Vedik Astrolojiyi Türkiye'de Keşfedin" / "Doğum haritanızı Vedik sistemle anlayın" / "Kadercilik değil, farkındalık, zamanlama ve içgörü". CTA: "Haritamı Gör" or "Ücretsiz Ön Analiz" or waitlist
- [ ] VT-101: **"Vedik Astroloji Nedir?" section** — short Turkish explanation: what is Jyotish, how it differs from Western astrology, why Lagna/Rashi/Nakshatra/Dasha matter
- [ ] VT-102: **"What users can do" section** — 6 short blocks: Doğum haritası, Sade Sati raporu, Dasha zamanlaması, Kavramlar sözlüğü, Danışmanlık, Eğitici içerikler
- [ ] VT-103: **Trust section** — "Real calculation, not generic AI. Educational, not fatalistic. Turkish explanations for Turkish users."
- [ ] VT-104: **Sade Sati highlight section** — strongest first product: what is Sade Sati, why people search for it, what the report offers, why our approach is rigorous
- [ ] VT-105: **Founder section (minimal)** — 3 lines + small photo. NOT the current full bio
- [ ] VT-106: **Newsletter / Waitlist** — email capture with value prop: "Haftada bir, Vedik astroloji dünyasından haberler"
- [ ] VT-107: **Remove sacred geometry backgrounds** — brief says "not overly mystical". Keep subtle dividers only

### P0 — Visual Direction
- [ ] VT-110: **New color palette** — soft pink, powder tones, warm neutrals, light earthy tones (per brief section 16). Replace gold #b8985a
- [ ] VT-111: **Typography review** — keep serif headings but softer weight. Brief: "elegant, soft, premium, feminine without overly decorative"
- [ ] VT-112: **Remove dark/occult feeling** — audit all components for anything that feels "dark occult" or "flashy mystical"
- [ ] VT-113: **Mobile-first audit** — every page must feel native on mobile (brief section 17)

### P0 — New Pages (per brief section 10)
- [ ] VT-120: **"Vedik Astroloji Nedir?" page** — dedicated page, rich SEO content, links to glossary terms
- [ ] VT-121: **"Sade Sati Nedir?" page** — dedicated landing page for #1 product, what it is, 3 phases, why people search, CTA to report
- [ ] VT-122: **"Hakkında" page** — about the platform + brief founder mention
- [ ] VT-123: **"İletişim" page** — contact form or email
- [ ] VT-124: **Update nav order** — Ana Sayfa | Vedik Astroloji Nedir? | Haritamı Gör | Sade Sati Nedir? | Raporlar | Sözlük | Blog | Hakkında | İletişim

---

## Phase 2: Verified Calculator + First Paid Product (Week 4-6)

### P1 — Calculator Accuracy (depends on VT-003 + VT-025)
- [ ] VT-200: **Switch to verified API** — based on VT-025 research, implement the most accurate API (likely Prokerala or VedicAstroAPI)
- [ ] VT-201: **Lahiri Ayanamsha verification** — ensure sidereal zodiac + Lahiri is default (not Tropical)
- [ ] VT-202: **DST handling for historical births** — Turkey pre-2016 had DST. Ensure correct offset for births before 2016
- [ ] VT-203: **Input: Name field (optional)** — add optional name input per brief
- [ ] VT-204: **Input: Email field (optional)** — add optional email for report delivery
- [ ] VT-205: **Free output verified** — Lagna, Rashi, Nakshatra, current Mahadasha+Antardasha, short Turkish summary
- [ ] VT-206: **10-chart validation suite** — automated test comparing VedAstro output to known-correct charts. Run in CI
- [ ] VT-207: **Remove calculator from beta** — if VT-003 + VT-206 pass: remove beta banner, move to homepage
- [ ] VT-208: **Add rate limiting** — max 10 calculations/min per IP on /api/chart

### P1 — Multi-API Architecture
- [ ] VT-230: **Register Prokerala free tier** — get OAuth2 client_id + client_secret, add to Vercel env vars (needs Duygu email for registration)
- [ ] VT-231: **Register VedicAstroAPI trial** — get API key, test Turkish language output
- [ ] VT-232: **VedAstro $1/mo upgrade** — pay for unlimited rate limit, add to billing
- [ ] VT-233: **Prokerala Sade Sati integration test** — verify dates match AstroSage for 5 known charts
- [ ] VT-234: **VedicAstroAPI Turkish output test** — verify quality of Turkish terminology

### P1 — Sade Sati Report (amiral gemisi ürün)
- [ ] VT-210: **Sade Sati Report product** — 1,950-2,750 TL (per VT-004). Personalized Saturn timeline, 3 cycles, 3 phases, Moon sign interpretation, Lagna context, practical upayas
- [ ] VT-211: **Premium AI for paid reports** — use Claude (not Groq/Gemini) for all paid report generation. Quality must match price
- [ ] VT-212: **Protected web view** — report as gated web page (not just PDF download)
- [ ] VT-213: **PDF download option** — downloadable PDF as secondary format
- [ ] VT-214: **Report tone** — "analytical, empathetic, authoritative, calm, not fear-based, not psychic" (brief section 13)
- [ ] VT-215: **Report language** — Turkish with Sanskrit terms in parentheses: "Ay Burcu (Rashi)", "Yükselen (Lagna)"
- [ ] VT-216: **Shopier payment flow for reports** — VT-002 must be done first. Taksit support

### P1 — SEO Knowledge Base (per brief section 12)
- [ ] VT-220: **Article: "Vedik Astroloji Nedir?"** — expand existing, optimize for SEO
- [ ] VT-221: **Article: "Sidereal ve Tropical farkı nedir?"** — NEW, high-value SEO keyword
- [ ] VT-222: **Article: "Grahalar nelerdir?"** — NEW, all 9 planets explained in Turkish
- [ ] VT-223: **Article: "Bhavalar nelerdir?"** — NEW, 12 houses explained
- [ ] VT-224: **Article: "Nakshatra nedir?"** — expand existing
- [ ] VT-225: **Article: "Vimshottari Dasha nedir?"** — expand existing
- [ ] VT-226: **Article: "Sade Sati nedir?"** — expand existing, link to paid report
- [ ] VT-227: **Glossary expansion** — add all missing terms from articles

---

## Phase 3: Full Report Suite + Accounts (Month 2-3)

### P2 — Additional Reports
- [ ] VT-300: **Vedik Doğum Haritası ve Yaşam Yolu Analizi** — 2,450-3,250 TL. Lagna, Rashi, Nakshatra, 12-house analysis
- [ ] VT-301: **Premium Karma Paketi (Bundle)** — 4,500-5,500 TL. Birth Chart + Sade Sati + 1-year Dasha Calendar
- [ ] VT-302: **Update pricing across all touchpoints** — /reports page, email templates, payment flow
- [ ] VT-303: **Report comparison page** — side-by-side feature table of all reports

### P2 — User Accounts
- [ ] VT-310: **Auth system** — email login (no social OAuth needed for MVP)
- [ ] VT-311: **Saved charts** — user can save their birth chart
- [ ] VT-312: **Purchase history** — view past purchases and re-download reports
- [ ] VT-313: **Chart data persistence** — save to DB (SQLite or Postgres)

### P2 — Email Funnel
- [ ] VT-320: **5-email welcome sequence** — implement actual Brevo automation, not just templates
- [ ] VT-321: **Sade Sati awareness campaign** — 3-email series educating about Sade Sati → CTA to report
- [ ] VT-322: **Post-purchase follow-up** — "How to use your report" + upsell to full birth chart

### P2 — Analytics
- [ ] VT-330: **Funnel dashboard** — visitor → chart → email → purchase conversion rates
- [ ] VT-331: **UTM tracking** — Instagram, SEO, direct traffic source attribution
- [ ] VT-332: **Revenue dashboard** — monthly sales, report types, conversion rates

---

## Phase 4: Content + Scale (Month 3-6)

### P2 — Extended Knowledge Base
- [ ] VT-400: **27 Nakshatra pages** — individual page per Nakshatra with Turkish explanations
- [ ] VT-401: **Graha-specific pages** — Sun through Ketu, 9 pages
- [ ] VT-402: **Saturn guides** — deep content, connects to Duygu's book
- [ ] VT-403: **Relationship timing content** — SEO content for compatibility searches
- [ ] VT-404: **Career timing content** — SEO content for career-related astrology searches

### P3 — Dr. Sugata Personal Site (separate project)
- [ ] DS-001: **Create separate repo** — dr-sugata or sugata-personal
- [ ] DS-002: **One-page MVP** — bio, book, publications, teaching, consultation booking, social links
- [ ] DS-003: **Link from Vedic Turkiye** — "Founder" section links to personal site
- [ ] DS-004: **Move consultation flow** — /consultation page moves to personal site
- [ ] DS-005: **Move course content** — /course and Circle pages move to personal site

---

## Code Quality

### Technical Debt
- [ ] VT-500: **Refactor AI interpret.ts** — deduplicate 6 callX/callXPremium functions into 1 generic function with params
- [ ] VT-501: **Add API route rate limiting** — middleware for /api/chart, /api/interpret, /api/payment
- [ ] VT-502: **Add geocode caching** — cache Nominatim + TimeAPI results (in-memory or Redis)
- [ ] VT-503: **Remove eslint-disable comments** — type VedAstro API responses properly
- [ ] VT-504: **Add integration tests** — test full chart calculation flow with known birth data
- [ ] VT-505: **Update CLAUDE.md** — reflect new brand, stack (Shopier), removed pages, accuracy requirements
- [ ] VT-506: **Fix Turkish characters in success message** — "Tesekkurler" → "Teşekkürler" in LandingPage.tsx:332
- [ ] VT-507: **Remove hardcoded content from components** — teaching venues, consultation pricing, publication links should be in i18n/content.ts or removed entirely

---

## Completed (Legacy — Sugata Jyotish era)

> All SJ-xxx tasks are archived. See git history for details.
> Last Sugata Jyotish release: v0.1.0 (16.03.2026)

<details>
<summary>Completed SJ tasks (click to expand)</summary>

- [x] SJ-002–SJ-008: Foundation (brand, landing, fonts, SEO, payments stub, email, analytics)
- [x] SJ-010–SJ-018: Birth chart calculator (form, geocoding, VedAstro, AI, share)
- [x] SJ-020–SJ-025: Paid reports stubs (Saturn, Full Chart, Compatibility, PDF, payment)
- [x] SJ-030–SJ-036: Blog + Glossary (5 articles, glossary page)
- [x] SJ-040–SJ-042: Email templates (lead magnet, welcome, newsletter)
- [x] SJ-050–SJ-060: Phase 2 stubs (Circle, Course landing pages)
- [x] SJ-070–SJ-072: Extended reports in catalog
- [x] SJ-080–SJ-083: Consultation booking
- [x] SJ-090: Mobile strategy doc
- [x] SJ-200–SJ-242: UX overhaul (chat form, hero, copy, art direction, i18n fixes)
- [x] SJ-300–SJ-370: Monetization (iyzico→Shopier, reports, email funnel, analytics)
- [x] SJ-410–SJ-418: Polish (nav, backlog dashboard, Shopier integration)

</details>
