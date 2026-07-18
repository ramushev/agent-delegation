# Agent Delegation

A small, provider-agnostic framework for delegating engineering work to the right
model.

## The idea

- **Four work classes**, ordered by the cost of a mistake:
  `CRITICAL > COMPLEX > ROUTINE > CHORE`. You classify the *task*, never the model
  — explicitly when it helps, or automatically inferred by the orchestrator when a
  task arrives untagged.
- **One configuration table** binds each class to a provider + model + agent —
  the single knob. Swap models or providers by editing that table; nothing else
  in the charter changes.
- **Three agents** execute the delegated classes; CRITICAL work is done inline by
  the orchestrator (the session model). Routing, safety rails, and the dispatch
  brief format all live in the charter.

Full rules: [`docs/DELEGATION.md`](docs/DELEGATION.md).

## What's in here

```
agent-delegation/
├── README.md            # this file
├── INSTALL.md           # how to inject into a project (script or agent-driven)
├── install.sh           # copies agents + charter, appends the CLAUDE.md block
├── CLAUDE.md            # the portable delegation context block (marker-wrapped)
├── docs/
│   └── DELEGATION.md    # the charter (work class → model, dispatch, safety rails)
└── .claude/agents/
    ├── complex-engineer.md   # COMPLEX
    ├── routine-builder.md    # ROUTINE
    └── chore-runner.md       # CHORE
```

## Install

```bash
./install.sh /path/to/your-project
```

or tell an assistant: *"Read this repo's INSTALL.md and inject it into the current
project."* See [`INSTALL.md`](INSTALL.md) for the manual steps and how to set your
own model lineup afterward.

## Default lineup

Ships configured for Anthropic (Fable / Opus / Sonnet / Haiku). Edit the
model-configuration table in `docs/DELEGATION.md` and the agents' `model:`
frontmatter to point at any provider.
