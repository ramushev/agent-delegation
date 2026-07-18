#!/usr/bin/env bash
# Inject the agent-delegation framework into a target project.
#
#   ./install.sh [TARGET_DIR]     # defaults to the current directory
#
# Copies the agents and the charter into place and appends the delegation
# context block to the target's CLAUDE.md. Idempotent: re-running won't
# duplicate the CLAUDE.md block.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-$PWD}"

if [ "$SRC" = "$TARGET" ]; then
  echo "Refusing to install into the framework repo itself." >&2
  exit 1
fi

echo "Installing agent-delegation into: $TARGET"
mkdir -p "$TARGET/.claude/agents" "$TARGET/docs"

# Agents → .claude/agents/
cp "$SRC/.claude/agents/"*.md "$TARGET/.claude/agents/"

# Charter (always refreshed)
cp "$SRC/docs/DELEGATION.md" "$TARGET/docs/DELEGATION.md"

# CLAUDE.md context block (idempotent via markers)
CLAUDE="$TARGET/CLAUDE.md"
if [ -f "$CLAUDE" ] && grep -qF "<!-- BEGIN agent-delegation -->" "$CLAUDE"; then
  echo "CLAUDE.md already has the agent-delegation block — left unchanged."
else
  [ -f "$CLAUDE" ] && printf '\n' >> "$CLAUDE"
  cat "$SRC/CLAUDE.md" >> "$CLAUDE"
  echo "Appended the delegation context block to CLAUDE.md."
fi

echo
echo "Done. Next: open docs/DELEGATION.md and set the model-configuration table"
echo "(provider + model per class), then match each agent's 'model:' frontmatter."
