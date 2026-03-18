# Portfolio Backlog

Источник правды для всех задач по портфолио.
Статусы: `[ ]` todo · `[~]` in progress · `[x]` done · `[—]` cancelled

Обновлено: 2026-03-16 (v2 — стратег)

---

## P0 — Критический путь (блокирует запуск)

### BUG-01: Teletype — img-row правая картинка обрезается
- [x] Правая картинка (тотбэг) обрезается снизу — выровнять высоту обеих картинок в паре

### BUG-02: Teletype Landing — серая линия вокруг видео с макбуком
- [x] Убрать еле заметную серую обводку/border вокруг видео с мокапом MacBook (не нарушив воспроизведение)

### BUG-03: Teletype — слайдшоу обрезает картинки сверху
- [x] Картинки в слайдшоу (brief) центрируются по центру контейнера и обрезаются сверху
- [x] Лучший вариант: расширить контейнер по высоте, чтобы картинки влезали полностью
- [—] Запасной: выровнять по верхнему краю (object-position: top), обрезка только снизу

### BUG-04: Teletype — последняя шкала имеет скруглённые углы снизу
- [x] Убрать border-radius снизу у последней шкалы «Доступность — Премиальность», чтобы была как остальные

### BUG-05: ENXT — обводка видео-контейнеров обрезается на закруглениях
- [x] У видео ENXT Booking (было/v1/v2) и Ground Ops border пропадает на закруглённых углах
- [x] Сделать чёткую обводку по всему периметру всех видео в обоих кейсах ENXT

### BUG-06: Index — стрелки и превью не центрированы по вертикали
- [x] Стрелки → внутри строк проектов на главной должны быть отцентрованы по высоте контейнера (как и превью слева)

### BUG-07: Favicon — сделать красный с чёрной D
- [x] Заменить текущий favicon на красный круг с чёрной буквой D (как в Readymag-версии)

### BUG-08: Кнопка «Назад» в stub-кейсах
- [x] Убрать кнопку «← Назад» из всех stub-страниц проектов (RU + EN) — навигация уже есть в nav

### BUG-11: ENXT метрики — вертикальный скролл в iframe
- [x] Увеличить высоту iframe таблицы метрик (480 → 620px) чтобы не было скролла

### BUG-10: Слайдшоу — картинки вытянуты + нет обводки
- [x] Картинки в слайдере не растягивать, сохранять натуральные пропорции (height: auto)
- [x] Добавить незаметную серую обводку вокруг контейнера слайдшоу

### DEV-11: Видео-превью на главной
- [x] Teletype — заменить img на video (video-03.mp4, autoplay muted loop)
- [x] Singularity Hub — мигающий CSS-курсор вместо статичной картинки
- [ ] Singularity Hub — видеофайл от автора (опционально)

### BUG-12: Flora Delivery — обрезанный фон превью
- [x] Логотип отцентрирован, полноценный чёрный квадрат

### BUG-09: Case separator — ширина и отступы
- [x] Разделитель на всю ширину контента айдентики (не уже)
- [x] Вертикальные отступы x2 (было 50px, стало 100px)

### ABOUT-01: Страница «Об авторе» — layout
- [x] Центровать блок текста по центру вьюпорта (вертикально)
- [x] Ссылки (telegram, instagram, email, linkedin) — переместить в нижний правый угол
- [x] Отступ справа у ссылок = отступу навигации (var(--side-padding))
- [x] Проверить EN-версию about.html (те же правки)
- [x] «Based in Kas...» на одной строке со ссылками (текст слева, ссылки справа)
- [x] Подчёркивания ссылок тоньше (1px, по толщине литер)

### CASE-01: Teletype Identity
- [x] Текст кейса (RU)
- [x] Перенести из Readymag
- [x] Визуалы: 4 видео, 6 слайдов brief, 11 слайдов graphic, галерея, шрифт
- [x] Ревью текста
- [x] EN-версия

### CASE-02: Teletype Landing
- [x] Текст кейса (RU)
- [x] Видео лендинга
- [x] Расширить: контекст → задача → решение → результат
- [x] EN-версия

### CASE-03: ENXT Booking
- [x] Текст кейса (RU)
- [x] Визуалы: 3 видео (было / v1 / v2), таблица метрик, таблица сравнения
- [x] Ревью текста
- [x] EN-версия

### CASE-04: ENXT Ground Ops
- [x] Текст кейса (RU)
- [x] Визуалы: 2 видео (создатель / исполнитель)
- [x] Ревью текста
- [x] EN-версия

### CASE-11: Prosto
- [x] Контент есть в Readymag
- [x] Перенести (текст + визуалы) — 12 картинок из Readymag CDN
- [x] Ревью
- [x] EN-версия

### CASE-12: Kombo
- [x] Контент есть в Readymag
- [x] Перенести (текст + визуалы) — 11 картинок из Readymag CDN
- [x] Ревью
- [x] EN-версия

### CASE-05: Osme
- [—] Отложено

---

## P1 — Следующие кейсы

### CASE-06: Singularity Hub — Python/Math
- [—] Отменено (кейс с нуля — не в приоритете)

### CASE-07: Singularity Hub — Words App
- [—] Отменено (кейс с нуля — не в приоритете)

### CASE-10: FloraDelivery
- [—] Отменено (кейс с нуля — не в приоритете)

### CASE-08: Skyeng
- [—] Отменено (кейс с нуля — не в приоритете)

### CASE-09: Qlean
- [—] Отменено (кейс с нуля — не в приоритете)

### CASE-13: SAMI
- [x] Кейс готов (RU + EN)
- [x] Ревью текста: пунктуация, тон, структура, RU/EN sync
- [x] Обновлены метрики: 9 000+ LOC, 260 тестов, Claude API (вместо CLI)
- [ ] Добавить визуалы (скриншоты канала, бота, схема архитектуры)

### CASE-14: Hunter
- [x] Кейс готов (RU + EN)
- [x] Ревью текста: пунктуация, тон, структура, RU/EN sync
- [x] Обновлены метрики: 5 000+ LOC, 412 тестов, Claude API, актуальные цены Pro
- [ ] Добавить визуалы (скриншоты дайджеста, скоринга, онбординга)

### CASE-15: Skysmart (Skyeng Kids)
- [x] Импортировать .fig файлы в Figma (4 файла: 3D Course Map, Goal Setting, Kids Progress, Learning Page)
- [x] Составить кейс (RU + EN) — 9 секций, глубокий анализ Figma, CJM, конкуренты, процесс
- [x] Добавить в index.html и sitemap.xml (перенесён в «Избранные»)
- [x] Создать визуалы из .fig: ЛКУ, итерации, CJM, первый урок, маскоты, бейджи, 3D-объекты, стикеры
- [x] Создать thumb-skysmart.png — 3D Эл с руками вверх
- [x] Фикс вёрстки: ЛКУ разделён на 2 чистых скрина (без серого фона), итерации в слайдшоу (7 слайдов), CJM и Aloha 3.0 очищены от Figma-канваса

---

## P1 — Стратегия (незакрытое)

### STRAT-01: Позиционирование
- [x] About-текст (RU)
- [x] About-текст (EN)

### STRAT-02: Список проектов
- [x] Финальный список и порядок
- [x] Решить по кейсам без визуалов (Skyeng, Qlean) — показываем
- [x] Решить формат SAMI — Featured, без табов, линейный сторителлинг

### STRAT-03: Тон и копирайтинг
- [x] Анализ слога
- [x] Гайд по тону → TONE_GUIDE.md
- [x] Ревью всех текстов (Teletype, ENXT, Prosto, Kombo, Sami, Hunter)

---

## P1 — Разработка

### DEV-05: Шаблон кейса
- [x] HTML-структура
- [x] CSS для текста, картинок, таблиц
- [x] Слайдер (JS, реализован в Teletype)
- [x] Табы
- [x] Responsive

### DEV-06: Заполнение кейсов
- [x] Teletype Identity
- [x] Teletype Landing
- [x] ENXT Booking
- [x] ENXT Ground Ops
- [x] Prosto
- [x] Kombo
- [ ] Osme
- [ ] Singularity Hub (Python)
- [ ] Singularity Hub (Words)
- [ ] FloraDelivery
- [ ] Skyeng
- [ ] Qlean
- [x] SAMI
- [x] Hunter

### DEV-07: EN-версии
- [x] Структура en/*.html
- [x] Index + About (EN)
- [~] EN-версии кейсов (Teletype, ENXT, Prosto, Kombo — done; остальные — с кейсами)

### DEV-09: Генератор кейсов
- [—] Отменено

### DEV-10: Коммит ассетов
- [x] Закоммитить assets/img/cases/ (teletype 89MB + enxt 127MB)
- [x] Закоммитить assets/embed/ (4 файла)
- [x] Закоммитить CeraMono-Medium.otf
- [x] Удалить .DS_Store из трекинга

---

## P2 — Деплой на diyor.design

### DEPLOY-01: Миграция домена
- [x] CNAME файл в site/ (`diyor.design`)
- [x] DNS: A-записи на GitHub (185.199.108-111.153)
- [x] www CNAME → diyoriko.github.io.
- [x] GitHub Settings > Pages > Custom domain: diyor.design
- [x] Enforce HTTPS
- [x] Проверка: diyor.design, www.diyor.design — работает

### DEPLOY-02: После миграции
- [x] Google Search Console: verification file задеплоен, ждёт подтверждения
- [x] Sitemap исправлен: hreflang для всех страниц, добавлен skyeng.html, приоритеты обновлены
- [x] Проверить OG-meta — исправлены: og:image, og:locale, canonical, meta description, singularity-words title
- [x] Убедиться всё работает
- [x] Отключить Readymag

---

## P2 — Полировка

### POLISH-01: Качество
- [x] Lighthouse audit (Perf 100, A11y 94, BP 100, SEO 100)
- [x] Кросс-браузерное тестирование — аудит CSS/JS/HTML, фиксы: inset fallback, -webkit-fit-content, loading="lazy"
- [x] Responsive аудит: свайп в слайдшоу на мобильных (scroll-snap), text-indent fix для таблетов, стрелки слайдшоу внутри контейнера на 481-900px
- [ ] Проверка на реальных устройствах (телефон + планшет)
- [x] Accessibility (ARIA, контраст)
- [x] Проверка всех ссылок (365 ссылок, 0 битых)

### POLISH-02: Оптимизация
- [x] Сжатие видео (229MB → 28MB, CRF 28, H.264)
- [x] Конвертация картинок в WebP (29 файлов, 41MB PNG/JPG удалено)
- [x] Lazy loading
- [x] Минификация CSS/JS (styles.min.css, script.min.js)

### POLISH-03: Очистка репо
- [x] Удалить readymag-export/, readymag-export-v2/ (не существовали)
- [x] Ревизия screenshots/ — не используются, 101MB, удалить вручную
- [x] Удалить case-study-content.txt
- [x] Удалить audit-readymag.js
- [x] Удалить test-results/

### SEO-03: Аналитика
- [x] Подключить аналитику — GoatCounter (бесплатный, без cookies)
- [x] Зарегистрировать diyordesign.goatcounter.com
- [x] Настроить цели — событийный трекинг (ext links, lang switch, contact, scroll depth, tabs)

---

## P3 — Дистрибуция

### DIST-01: LinkedIn
- [x] Обновить тайтл
- [x] Переписать About
- [ ] Добавить Featured (ссылка на портфолио)

### DIST-02: HH
- [~] Обновить описание (текст готов)

### DIST-03: Outreach
- [~] Пост в Telegram — драфт готов (см. ниже)
- [~] Пост в LinkedIn — драфт готов (см. ниже)
- [ ] Обновить ссылки (Instagram bio, etc.)

**Драфт Telegram (RU):**
> Собрал портфолио: diyor.design
> Skysmart, Anywayanyday, Teletype, два AI-бота в Telegram — продуктовый дизайн, брендинг, интерфейсы. Последнее время пишу код сам и довожу до продакшена. Кейсы с процессом, решениями и цифрами. Открыт к проектам и парт-тайму.

**Драфт LinkedIn (EN):**
> I put together my portfolio at diyor.design. Seven cases from the past few years: product design at Skyeng (Russia's largest online school), enterprise UX for an airline platform, branding for a cloud contact center, and two AI-powered Telegram bots I designed and built. Recently I've been writing code alongside design — shipping things end to end. Open to project work and part-time collaboration.

---

## P2 — Рекомендации стратега (2026-03-16)

### BUG-14: singularity-words.html — неверный h1
- [x] h1 «Singularity Hub» → «Singularity Words» (RU + EN)

### CASE-15-VIS-01: Skysmart — kids goal-setting скрины
- [ ] Добавить skysmart-goals-kids-eng/math в секцию «Первый урок» как пример адаптации под предмет

### CASE-03-VIS-01: ENXT — добавить статику
- [ ] Использовать enxt-booking-01/02/03.png для детального просмотра UI (если файлы существуют)

### CASE-01-LND-01: Teletype Landing — усилить
- [ ] Добавить «что изменилось» + метрику конверсии

### CASE-11-12-CTX: Prosto и Kombo — добавить контекст
- [ ] Год, клиент, задача (сейчас только визуалы без описания проекта)

### POLISH-04: Skysmart PNG → WebP
- [ ] skysmart-3d-badges/mascots/objects/stickers.png → `<picture>` с WebP

### SEO-04: Sitemap — добавить lastmod
- [ ] `<lastmod>` для избранных кейсов

### SEO-05: OG-image для about.html
- [ ] Заменить og:image с thumb-teletype.png на что-то уместное для About

---

## Компонентная библиотека кейсов

14 блоков для сборки кейс-страниц:

| # | Блок | CSS-класс | Описание |
|---|------|-----------|----------|
| 1 | Текстовая секция | `.case-section` | Нумерованный блок с заголовком и текстом |
| 2 | Боковой лейбл | `.case-edge-label` | Фаза/этап слева от текста |
| 3 | Разделитель | `.case-separator` | Горизонтальная линия |
| 4 | Слайдшоу | `.case-slideshow-wrap` | Карусель изображений с навигацией |
| 5 | Герой-видео | `.case-hero-video` | Полноширинное видео с логотипом |
| 6 | Видео | `.case-video` | Видео (--centered / --text-aligned) |
| 7 | Картинка | `.case-img` | Картинка внутри секции |
| 8 | Полноширинная картинка | `.case-img-full` | Картинка на всю ширину |
| 9 | Пара картинок | `.case-img-row` | Два изображения в ряд |
| 10 | Картинка с оверлеем | `.case-img-overlay` | Картинка + наложение (видео/iframe) |
| 11 | Шрифт-витрина | `.case-font-showcase` | Демонстрация типографики |
| 12 | Iframe-вставка | `.case-embed` | Интерактивный контент |
| 13 | Ссылки | `.case-links` | Внешние ссылки (Figma, etc.) |
| 14 | Описание | `.case-description` | Крупный текст с отступом |

---

## Зависимости

```
ABOUT-01 → можно делать сразу
CASE-11,12 (Prosto, Kombo) → DEV-06 → можно делать сразу (контент в Readymag)
CASE-05 (Osme) → проверить Readymag → DEV-06
CASE-06..13 → написать контент → DEV-06
DEV-10 (коммит) → DEPLOY-01
DEPLOY-01 → DEPLOY-02 → DIST-*
```

Критический путь: ABOUT-01 + оставшиеся кейсы → коммит → деплой на diyor.design → дистрибуция
