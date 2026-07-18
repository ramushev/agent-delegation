# Installing agent-delegation into a project

Two ways to inject this framework into a target project. Both end with the same
result: the agents in `.claude/agents/`, the charter in `docs/`, and a delegation
summary block in the project's `CLAUDE.md`.

## Option A — run the script

```bash
# from anywhere, pass the target project directory (defaults to cwd)
/path/to/agent-delegation/install.sh /path/to/your-project
```

## Option B — tell an agent to do it

Point an assistant at this repo and say: *"Read this repository's INSTALL.md and
inject the agent-delegation framework into the current project."* It should
perform exactly these steps:

1. **Agents** — copy `.claude/agents/*.md` → `<project>/.claude/agents/`.
2. **Charter** — copy `docs/DELEGATION.md` → `<project>/docs/DELEGATION.md`.
3. **Context** — append the block in this repo's `CLAUDE.md` (everything between
   the `<!-- BEGIN agent-delegation -->` / `<!-- END agent-delegation -->`
   markers) to the project's `CLAUDE.md`. If those markers are already present,
   leave it unchanged.

## After installing — configure models

The framework ships with a default lineup (Anthropic Fable/Opus/Sonnet/Haiku).
To use your own:

1. Edit the **model-configuration table** in `docs/DELEGATION.md` — set the
   provider and model for each class (CRITICAL / COMPLEX / ROUTINE / CHORE).
   Providers may be mixed across rows.
2. Set each agent's `model:` frontmatter in `.claude/agents/` to match its row.

That table is the single source of truth; nothing else in the charter needs to
change when you swap models or providers.

## Updating later

Re-run the script (or re-do the copy). The charter and agents are refreshed;
your `CLAUDE.md` block is left untouched.
