---
name: publish
description: Publish a technical design from docs/design/<slug>/ into polished architecture docs under docs/architecture/: an engineering doc and a stakeholder one-pager. Use when the user wants to publish, export, or write up a design as documentation.
---

Turn the working design into clean **published docs** for readers who never saw the iterations. The working design is the single source of truth: published docs are generated, overwritten on every run, and never edited by hand.

Read [CONVENTIONS.md](CONVENTIONS.md) first; it defines the layout, status rules and readiness checks.

## 1. Gate

Find the design (the named slug, else the only/most recently `updated` folder in `docs/design/`) and read all of it: `design.md`, ADRs, area docs.

- `status: ready` or `published`: continue.
- Any open `blocking` item: refuse. List the blocking items and offer the refine skill.
- Otherwise: run the readiness checks, list the failures, and continue only if the user confirms.

Done when: the design is ready, or the user has confirmed publishing despite the listed failures.

## 2. Engineering doc

Write `docs/architecture/<slug>.md` from [templates/architecture.md](templates/architecture.md).

- Rewrite as narrative for a new engineer: why the system exists, how it works, what was decided and why. Carry over the diagrams, restyled only where needed for clarity.
- Inline area-doc detail where it serves the reader; otherwise summarise it.
- Decisions: one line each with its rationale, linking the ADR at `../design/<slug>/decisions/`.
- Open non-blocking items become **Known limitations**, stated as facts about the system, not as questions.
- Leave out the working-layer material: backlog IDs, iteration history, superseded decisions, rejected options.

Done when: every component, entity, key flow and current decision from the design appears in the doc, and nothing in the doc is absent from the design.

## 3. Stakeholder one-pager

Write `docs/architecture/<slug>-summary.md` from [templates/summary.md](templates/summary.md): goal, approach, top risks, cost and effort. Plain language, at most one diagram (the Context one). Where the design has no cost or effort estimate, write "not estimated" rather than inventing one.

Done when: it fits on one page and a non-engineer could repeat the goal and approach back.

## 4. Index and status

- Create or update `docs/architecture/README.md` from [templates/index.md](templates/index.md): one row per published design with title, one-line goal, and links to both docs. Keep rows sorted by title.
- Set the design's `status: published` and `updated` to today.

Done when: the index lists this design and the frontmatter is updated.

## 5. Hand back

Show the paths of the files written and any readiness failures the user chose to publish with.
