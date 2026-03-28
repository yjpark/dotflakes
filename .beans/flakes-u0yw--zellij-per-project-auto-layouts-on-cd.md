---
# flakes-u0yw
title: Zellij per-project auto-layouts on cd
status: in-progress
type: feature
priority: normal
created_at: 2026-03-28T04:30:38Z
updated_at: 2026-03-28T04:31:31Z
---

## Spec

When cd'ing to a project directory inside Zellij, automatically open a new tab with a layout matching the project's configuration.

### Preset Layout Files

Location: `modules/home/programs/zellij/layouts/` → deployed to `~/.config/zellij/layouts/`

**`claude_terminal.kdl`** — claude on left (50%), terminal on right (50%)

**`claude_beans-terminal.kdl`** — claude on left (50%), right side split: `beans-serve --cors-origin "*"` on top, stacked terminals below

Presets have no `cwd` — the fish hook passes `--cwd` at open time, keeping presets project-agnostic.

### Layout Resolution Order

1. `.zellij-layout.kdl` file in project root (inline layout, highest priority)
2. `ZELLIJ_LAYOUT_{USERNAME}` env var (e.g., `ZELLIJ_LAYOUT_yj=claude_beans-terminal`) — only if `$USER` matches
3. `ZELLIJ_LAYOUT` env var — generic fallback
4. Neither → do nothing

Env vars are set via `.envrc` (direnv), e.g.:
```bash
export ZELLIJ_LAYOUT=claude_terminal
export ZELLIJ_LAYOUT_yj=claude_beans-terminal
export ZELLIJ_LAYOUT_yjpark=claude_terminal
```

### Fish Hook Logic

Extend existing PWD hook in `modules/home/programs/fish/init/zellij.fish`:

1. Not in Zellij? → skip
2. Resolve project root (existing git root detection)
3. Determine layout (resolution order above)
4. Guard: check `__zellij_opened_layouts` fish global var — if project root already in list → skip
5. `zellij action new-tab --layout {layout_file} --cwd {project_root}`
6. Add project root to `__zellij_opened_layouts`

State resets when fish session ends. Re-opening after terminal restart is acceptable.

### Relationship to existing bean

Related to flakes-kxju (predefined layout files) — this is the broader feature that subsumes it.

## Tasks

- [x] Create `claude_terminal.kdl` preset layout
- [x] Create `claude_beans-terminal.kdl` preset layout
- [x] Extend `zellij.fish` PWD hook with layout resolution and auto-open logic
- [ ] Test: cd to project with `ZELLIJ_LAYOUT` set → new tab opens with layout
- [ ] Test: cd again to same project → no duplicate tab
- [ ] Test: `ZELLIJ_LAYOUT_yj` overrides `ZELLIJ_LAYOUT` for user `yj`
- [ ] Test: `.zellij-layout.kdl` in project root takes priority
