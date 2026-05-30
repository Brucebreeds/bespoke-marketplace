# Bespoke OS Hooks

Drop these files into any project's `hooks/` folder to make that project **Bespoke-default** — the doctrine + cast + standards auto-load on every new Claude Code session, no project-instruction setup needed.

## What's here

- **`bespoke-session-start.sh`** — runs at the start of every Claude Code session in the project. Fetches Bespoke OS doctrine from the live MCP. Surfaces a header banner so the agent knows it's in Bespoke mode.
- **`hooks.json`** — config that registers the session-start hook with Claude Code.

## Install (per project)

1. Copy the `hooks/` folder into your project root.
2. Make the script executable: `chmod +x hooks/bespoke-session-start.sh`
3. Open a new Claude Code chat in that project — Bespoke header appears at the top.

## Env vars

| Var | Default | What it does |
|---|---|---|
| `BESPOKE_USER_ID` | `anon` | Identifies you across projects |
| `BESPOKE_OWNER_TOKEN` | _unset_ | Bruce-mode elevation |
| `BESPOKE_WORKER_URL` | live worker | Override for staging/dev |

## Manual fallback

If you don't want the hook, just type `Hello, Bespoke!` in any chat — Bespoke responds with the full welcome and the 7 slash commands.

Source-marked: Bespoke OS · v1.0
