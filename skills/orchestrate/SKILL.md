---
name: orchestrate
description: "Orchestrate software-development tasks: classify their scale, then coordinate substantial changes through research, design, implementation, integration, and review."
---

Use this skill for a substantial development task: one that crosses modules, has an uncertain approach, or contains genuinely independent implementation chunks. The pipeline spends stronger reasoning where an early mistake would compound, delegates settled work economically, and closes with a review against the original intent.

## Start with a run record

Choose one durable task directory already appropriate for the repository (for example, an issue or planning directory). Create the following files there, using a consistent task-specific prefix if the repository has no convention:

| Artifact | Required contents | Completion criterion |
|---|---|---|
| `research.md` | relevant code facts, external sources when used, open questions | every design-relevant claim is linked to evidence or marked as an assumption |
| `design.md` | chosen approach, committed interfaces, test strategy, task graph | an implementer can take one chunk without making an architectural decision |
| `status.md` | chunk state, integration order, checks, review findings and their disposition | it identifies the current frontier and the next owner for every unresolved item |

Write the original task and acceptance criteria at the top of `design.md`. Point agents to these artifacts and paths; do not paste their contents into every hand-off.

## Choose the scale

- **Trivial:** the approach is clear and touches only a few related files. Work inline and run the relevant tests and review; this pipeline adds more overhead than value.
- **Substantial:** use the phases below. A phase may be skipped only when its artifact already satisfies its completion criterion from this conversation or an earlier run. Record the skip and evidence in `status.md`.

## Select capabilities by role

Use the strongest available reasoning model for **research**, **design**, and the **review gate**; use the least expensive model that can reliably follow a settled chunk for **implementation**; reserve the cheapest tier for changes that need no design judgement. Names such as `opus`, `sonnet`, and `haiku` are examples, not requirements.

If model tiers, subagents, background execution, or worktree isolation are unavailable, keep the same artifacts and gates but execute phases sequentially in the current session. Lack of an orchestration feature must not weaken the acceptance criteria or review gate.

## Run the pipeline

1. **Research — strong reasoning, when needed.** Investigate the affected code and external primary documentation when relevant. Write `research.md`. End only when unknowns that could change the design are resolved or explicitly recorded.

2. **Design — strong reasoning.** Write `design.md`, including:
   - the chosen approach, constraints, and interfaces it commits to;
   - a test strategy tied to the acceptance criteria;
   - a task graph whose chunks each have an owner, dependencies, expected files or seams, validation command, and a clear done condition;
   - an integration order.

   A chunk is large enough to justify one implementer hand-off but small enough that one implementer can retain its entire contract. Mark a chunk `mechanical` only when it cannot alter behaviour or design.

3. **Implement the frontier — implementation tier.** Dispatch one implementer per chunk whose dependencies are complete. Give it the design path, status path, and chunk identifier. For a testable seam, ask it to use the repository's test-first workflow if one exists. Each implementer updates its chunk's status with changed files, commands run, results, and deviations from the design.

   Run chunks concurrently only when their declared file ownership and interfaces do not overlap. Otherwise sequence them. As completed chunks unblock successors, update the frontier and dispatch the successor.

4. **Integrate and test.** Integrate chunks in the recorded order. Before each merge, inspect the change and resolve conflicts against `design.md`; a conflict that changes an interface returns to Design. Run the full relevant suite after integration, plus each chunk's focused checks. Record exact commands and outcomes in `status.md`.

5. **Review gate — strong reasoning, mandatory.** Review the integrated change against the original task, acceptance criteria, `research.md`, and `design.md`. Use the repository's review skill when available, or perform equivalent spec and standards checks. Record every finding in `status.md` with severity, evidence, and a disposition. Completion requires no unresolved blocking or high-severity findings.

6. **Route findings, then repeat the minimum loop.**

   | Finding source | Return to | Next action |
   |---|---|---|
   | Implementation defect or missing test | Implementation | dispatch a focused fix, integrate, then rerun the review gate |
   | Design flaw, incompatible interface, or changed scope | Design | revise the design and task graph, then implement affected chunks |
   | Missing or contradictory evidence | Research | update findings, then revalidate the design |

   Do not treat a design or research issue as an implementation-only fix. Re-run only the phases invalidated by the finding, followed by integration, relevant tests, and the review gate.

7. **Hand off.** Report the implemented outcome, artifacts, tests run, remaining non-blocking risks, and review disposition. Ask before pushing or opening a PR.

## Economy rules

- Pay subagent overhead per meaningful chunk, never per file or function.
- Prefer fresh agents when a different model tier or isolated context is required; use inherited context only within the same role when it materially saves briefing work.
- Parallelism improves elapsed time, not token cost. Split only along real independence.
- Review the integrated result once per loop, rather than reviewing partial chunks against an incomplete system.
