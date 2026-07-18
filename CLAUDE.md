<!-- BEGIN agent-delegation -->
## Delegation (summary — full rules in docs/DELEGATION.md)

This project uses the **agent-delegation** framework: classify every task by work
class, then run it on that class's configured model via the matching agent.
Full charter: `docs/DELEGATION.md`. Agents: `.claude/agents/`.

- **Classes:** CRITICAL (contracts, money, identity, PII, architecture) ·
  COMPLEX (hard algorithms/structure) · ROUTINE (bounded, specified) ·
  CHORE (mechanical). Ordered `CRITICAL > COMPLEX > ROUTINE > CHORE`. Classify a
  task explicitly, or let the orchestrator auto-classify it from these
  definitions (round up when ambiguous).
- **Rule:** run each task on its class's configured model — see the charter's
  model-configuration table, the single place classes bind to models. Every
  configured model is always available, so there's no fallback or queue; swap
  models or providers by editing that table (and the matching agent `model:`).
- The orchestrator (whatever model runs the session — check your system prompt)
  does Critical work inline when it is the Critical model, and dispatches the
  rest: Complex → `complex-engineer`, Routine → `routine-builder`,
  Chore → `chore-runner`, always with the charter's brief format.
- Two failed attempts → escalate one class up, never a third try.
<!-- END agent-delegation -->
