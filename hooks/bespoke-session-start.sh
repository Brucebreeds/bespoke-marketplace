#!/usr/bin/env bash
# bespoke-session-start.sh — Bespoke OS auto-loader for any Claude Code session.
#
# Drop this hook into any project that wants Bespoke-default behavior. When
# Claude Code opens a session in that project, this script fires and loads
# the Bespoke OS doctrine + cast quick-reference + user's audience level into
# context — so the agent treats the project as Bespoke-mode from the first
# message, no project-instruction setup required.
#
# Source-marked: Bespoke OS · v1.0 · 2026-05-27
#
# Install:
#   1. Copy this file to <your project>/hooks/bespoke-session-start.sh
#   2. Make executable: chmod +x hooks/bespoke-session-start.sh
#   3. Register in Claude Code hooks config (see hooks.json template)
#   4. Open a new chat in that project — Bespoke loads automatically.
#
# What it does on session start:
#   1. Outputs a "Bespoke mode active" header so the agent knows the contract
#   2. Lists the slash commands and cast aliases available in this project
#   3. If BESPOKE_OWNER_TOKEN is set, fetches the user's pinned audience level
#      from the live MCP so the session opens at the right register
#
# The doctrine itself is NOT pulled by this hook — it lives behind the MCP
# secret path (protected per doctrine v62 transformation > attribution) and
# loads on the first tool call from any project wired to the MCP.
#
# It does NOT:
#   · Block the session (runs in <2s)
#   · Modify any files
#   · Send any user data anywhere
#   · Require any API key for the public doctrine layer
#   · Override the user's actual prompt
#
# Behavior on failure: prints a soft notice and exits 0. Never blocks the
# session — per doctrine `never-generic` + `live-test-before-shipped`, a
# broken hook should not break the user's flow.

set -u  # unset variable = error, but no -e (failures here are non-fatal)

WORKER_URL="${BESPOKE_WORKER_URL:-https://bespoke-os-mcp.bearback.workers.dev}"
USER_ID="${BESPOKE_USER_ID:-anon}"
PROJECT_NAME="${PWD##*/}"

# Colors for the header (Bespoke gold + glass)
GOLD=$'\033[38;5;221m'
DIM=$'\033[2m'
RESET=$'\033[0m'

# ─── Header banner ───────────────────────────────────────────────────────────

cat <<EOF
${GOLD}
   ✨ Bespoke OS — mode active in this project
${RESET}${DIM}   project: ${PROJECT_NAME}
   user: ${USER_ID}
   live MCP: ${WORKER_URL}
${RESET}
EOF

# ─── 1. Show the active operating mode summary ───────────────────────────────

cat <<EOF
${GOLD}   Active operating mode:${RESET}
   ${DIM}• Ship floor: Plat-8 across 8 rubric axes (only Bruce can raise to 9)${RESET}
   ${DIM}• Polish Checklist (9 binary): runs before every Bespoke gate verdict${RESET}
   ${DIM}• Platform-aware routing: uses your connected tools (Adobe/Canva/Figma/etc.)${RESET}
   ${DIM}• Visual-over-text: audits + scorecards render as visuals, not paragraphs${RESET}
   ${DIM}• Output rated against your audience level before send${RESET}

${GOLD}   Slash commands available:${RESET}
   ${DIM}/brand   — start or refresh a brand${RESET}
   ${DIM}/craft   — design with Bespoke-grade care, taste, finish${RESET}
   ${DIM}/score   — score work against the 8-axis rubric${RESET}
   ${DIM}/voice   — write in your brand voice${RESET}
   ${DIM}/render  — generate visuals via best-available platform${RESET}
   ${DIM}/publish — push to social channels${RESET}
   ${DIM}/bespoke — final launch gate — the brand IS the verb${RESET}

${GOLD}   Cast aliases:${RESET}
   ${DIM}/connie /dex /forge /bea /ivy /posie${RESET}

${GOLD}   Say "Hello, Bespoke!" anytime for the full welcome.${RESET}

EOF

# ─── 2. Audience level (if pinned) ───────────────────────────────────────────

# Try to fetch the user's pinned audience level. Silent on failure.
if [[ -n "${BESPOKE_OWNER_TOKEN:-}" ]]; then
  LEVEL_RESPONSE=$(curl -sS --max-time 2 \
    -X POST "${WORKER_URL}/mcp" \
    -H "Content-Type: application/json" \
    -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"bespoke_get_audience_level\",\"arguments\":{\"user_id\":\"${USER_ID}\",\"owner_token\":\"${BESPOKE_OWNER_TOKEN}\"}}}" \
    2>/dev/null || echo "")
  if [[ -n "$LEVEL_RESPONSE" ]] && echo "$LEVEL_RESPONSE" | grep -q "level"; then
    LEVEL=$(echo "$LEVEL_RESPONSE" | grep -oE '"level":"[a-z]+"' | head -1 | cut -d'"' -f4)
    if [[ -n "$LEVEL" ]]; then
      echo "${GOLD}   Your audience level: ${LEVEL}${RESET}"
      echo
    fi
  fi
fi

# Always exit 0 — never block the session.
exit 0
