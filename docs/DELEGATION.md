# Delegation Charter

Every task gets answered with two questions: **what class of work is it?** and
**who may run it?** Work classes are fixed; *who* is whatever models you have
configured. Everything else in this file is detail supporting those two.

## The abstraction

**1 · Work classes** — classify the *task* (explicitly or automatically), never
the model. Four classes,
ordered by the cost of a mistake, which is also the capability they demand:
`CRITICAL > COMPLEX > ROUTINE > CHORE`. This order is the whole ladder — there
is no separate tier concept.

| Class | Definition | Examples |
|---|---|---|
| **CRITICAL** | A mistake is expensive or irreversible: contracts, money, identity, personal data, architecture | Architecture decisions, API contracts, DB schema/migrations, auth/sessions, payments/billing, personal-data export/deletion flows, cross-service debugging |
| **COMPLEX** | Algorithmically or structurally hard, but a bad diff is just a bad diff | Non-trivial algorithms, data pipelines, concurrency, intricate UI interactions, performance/load work |
| **ROUTINE** | Bounded and fully specified by an existing contract or pattern | CRUD from a contract, queries against an approved schema, UI from existing patterns, tests, infra from existing modules, i18n, docs, runbooks |
| **CHORE** | Mechanical; zero judgment | Renames, lint/format fixes, fixture generation, copy tweaks, dependency bumps |

**Classifying up front is optional.** A task may arrive already classed — tagged
in a plan or stated in the request — but it doesn't have to be. An unclassified
task is classified by the orchestrator from the definitions above before routing.
When auto-classification is genuinely ambiguous, round *up* to the more capable
class; the reclassify-on-discovery rail (below) still catches work that turns out
to touch Critical territory mid-task.

**2 · Model configuration** — the single knob, and the only place a class meets a
concrete model. Bind each class to an agent + provider + model here; edit this
table to swap models or providers, and nothing else in the charter changes:

<!-- MODEL-CONFIG: source of truth for the class→model binding. Editing this
     table is the supported way to change providers/models. Keep rows ordered
     CRITICAL→CHORE. -->

| Class | Agent | Provider | Model |
|---|---|---|---|
| **CRITICAL** | orchestrator (inline) | Anthropic | `fable` |
| **COMPLEX** | `complex-engineer` | Anthropic | `opus` |
| **ROUTINE** | `routine-builder` | Anthropic | `sonnet` |
| **CHORE** | `chore-runner` | Anthropic | `haiku` |

Rules for this table:
- It is the source of truth for the class→model binding. The `model:` frontmatter
  in each `.claude/agents/*.md` must equal its class's row — change both together.
- Providers may be mixed across classes (e.g. CRITICAL from one vendor, CHORE from
  another); each row is independent. Use each provider's own model identifiers.
- A lineup with fewer distinct models may bind the same model to adjacent classes
  — collapsing downward is allowed; inverting the capability order is not.

**3 · The routing rule** — one sentence:

> **Run each task on its class's configured model** (via that class's agent).

Every configured model is always available, so that's the whole system — no
fallback, no queue. Consequences, spelled out:

- The **orchestrator** is whatever model runs the session (check your system
  prompt; match it against the configuration table to see which class you are).
  It runs Critical work inline *if it is the CRITICAL model*; everything else
  goes to subagents: Complex → `complex-engineer` · Routine → `routine-builder` ·
  Chore → `chore-runner`.
- Because the CRITICAL model is always available, Critical work is always runnable
  and the other classes are always dispatchable — nothing is ever blocked for a
  missing model.
- If the orchestrator is itself the COMPLEX model, it may run Complex work inline
  instead of dispatching (same model, saves a cold start). Never run Routine/Chore
  work inline at the higher model's cost.

## Dispatch protocol

Subagents start cold. Every dispatch carries this brief — no brief, no dispatch:

```
CONTEXT: one paragraph — what this is part of, link to the spec section
FILES: paths to read first / expected to change (keep to one deploy unit)
TASK: the change, stated as behavior ("POST /orders creates an order, returns 201…")
ACCEPTANCE: verifiable criteria (tests to pass, budgets to meet)
OUT OF SCOPE: what NOT to touch (schema, the API contract, other services)
CONVENTIONS: linters/formatters clean, type-checks and tests pass
```

A brief stays within one deploy unit; cross-cutting work becomes sequenced briefs
(contract/producer first). Subagents run in parallel only on disjoint file sets;
shared code touched by more than one brief serializes.

## Safety rails

- **Two-strike rule:** two failed attempts at acceptance → stop, escalate one
  class up (ROUTINE→COMPLEX→CRITICAL) with failure notes. Never a third try at
  the same class.
- **Reclassify on discovery:** a task that turns out to touch Critical territory
  (schema, contract, auth, money, PII) stops and returns to the orchestrator,
  whatever it was classified as at dispatch.
- **Review gates:** Routine diffs reviewed by a Complex-capable model (the
  `complex-engineer` or orchestrator); Complex diffs reviewed by the orchestrator
  when they touch critical paths, spot-checked otherwise; the blocking CI suite
  gates everything once it exists.
- **Never delegated, any class:** deleting user data, dropping tables/buckets,
  open business judgment calls, edits to this file / `CLAUDE.md` / agent definitions.

## Session flow

1. Identify which class's model you are from the configuration table → what you
   may run inline (routing rule).
2. Pick tasks from your project's plan or tracker, or take an ad-hoc request; use
   each task's class if it has one, otherwise classify it yourself.
3. Write briefs → dispatch (parallel where disjoint) → do your own inline work.
4. Review per gates → integrate → update plan status before ending the session.
