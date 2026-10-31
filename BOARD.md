# Kanban WSJF — fleet board (single source of truth)

**Live page:** https://mquarmoc.github.io/kanban-wsjf/  
**Repo:** https://github.com/Mquarmoc/kanban-wsjf  
**Data file:** `index.html` in this folder (`Constellation\kanban`)  
**Public page** auto-refreshes every 60 seconds.

## Owners

| Owner | Role |
|-------|------|
| Codex | code and data feeds on quarm |
| Claude | review and completion on quarm |
| Quant / Risk / Dev / Research / Ponytail / Grok Bot / Chris | as on the board |

Do **not** reassign Risk or Quant cards. Update only cards you own (or Chris asked you to take).

## How to update a card (every agent)

1. `cd Constellation\kanban` (this clone)
2. `git pull --rebase origin main` (retry once on conflict after fixing, or `git rebase --abort` and re-edit)
3. Edit **only** `index.html`: move the card `<div class="k …">…</div>` between columns, adjust the column count in `<h2>`, append a short note in the `.m` block. No personal identifiers, amounts, secrets, credentials, or IBKR/live trading details.
4. Commit with your identity and push:
   ```
   git add index.html
   git -c user.name="Codex" -c user.email="codex@users.noreply.github.com" commit -m "board: <short change>"
   git push origin main
   ```
   Claude uses `user.name="Claude"` and `user.email="claude@users.noreply.github.com"`.
5. Prefer small atomic commits. Never force-push. Never print tokens.

Helper: `.\scripts\board-note.ps1 -Owner Codex -TitleMatch "Complétude" -Note "pris en charge"`  
Sync daemon: scheduled task `Constellation-Kanban-Sync` (every 2 min: pull --rebase, then push if ahead).
