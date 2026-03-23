# {Project} — Backlog

Следующий номер: **PROJ-001**

---

## Sprint 1 — {Title}

### {Category}
- [ ] **PROJ-001** Task title — description
- [ ] **PROJ-002** Task title — description `[strategist]`
- [ ] **PROJ-003** Task title — description `[mega-review]`

---

## v0.1.0 (дата) — Sprint 0

<details><summary>N задач</summary>

- [x] **PROJ-000** Task — done (дата)

</details>

---

## Правила

### Нумерация
| Проект | Префикс |
|---|---|
| Hunter | `HUNT-` |
| SAMI | `SAMI-` / `SM-` |
| Vedic Turkiye | `VT-` |
| Portfolio | `PORT-` |
| Architect | `ARCH-` |

Номер последовательный, не переиспользуется. "Следующий номер" обновляется при каждом добавлении.

### Source tags (для модерации на дашборде)
- `[strategist]` — задача от стратега (авто)
- `[mega-review]` — задача от мега-ревьюера (авто)
- `[coderabbit]` — задача от CodeRabbit (авто)
- Без тега — задача от владельца (ручная)

Задачи с тегами можно одобрить (Keep) или убрать (Remove) на дашборде localhost:3333.
При Keep — тег удаляется. При Remove — задача удаляется из бэклога.

### Формат задачи
```
- [ ] **PROJ-NNN** Краткое название — детальное описание `[source]`
- [x] **PROJ-NNN** Сделанная задача — описание (дата)
```

### Релизы
Каждый деплой = релиз `vX.Y.Z`. Закрытый спринт оформляется как:
```markdown
## vX.Y.Z (дата) — Sprint N

<details><summary>N задач</summary>

- [x] **PROJ-NNN** Task — description

</details>
```

### Жизненный цикл
1. **Sprint** — набор задач на текущую итерацию
2. **Реализация** — код + тесты
3. **Деплой** — git push + version bump → авто-деплой
4. **Архивация** — спринт → `<details>` под номером релиза
5. **Перенос** — незакрытые задачи → следующий спринт с причиной
