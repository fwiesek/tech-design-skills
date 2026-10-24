---
name: refine
description: Run one refinement iteration on an existing technical design in docs/design/<slug>/: pick one area, grill it until settled, update the design. Use when the user wants to refine, deepen, iterate on or continue a design, or go deeper on one part of an architecture.
---

One **iteration** = one area, settled completely, written back. Breadth was the base design's job; depth is this skill's, so stay inside the chosen area.

Read [CONVENTIONS.md](CONVENTIONS.md) before editing; it defines the sections, backlog format, ADR and area rules, and readiness checks.

## 1. Load

- Find the design: the slug the user named, or the only/most recently `updated` folder in `docs/design/`. Ask only if several are plausible.
- Read `design.md`, `iterations.md`, and the titles of every ADR and area doc. `iterations.md` tells you where the design has been; take it as settled history.
- Brownfield: re-read code only where the design's Current state looks stale or thin for the likely targets.

Done when: you can state the design's goal, components and every open backlog item from memory.

## 2. Propose targets

Build candidates from two sources:

- Open backlog items, grouped by area.
- A review pass: run the readiness checks from CONVENTIONS.md and hunt for gaps the backlog misses: failure modes, security, consistency between diagrams and prose, scale against the stated constraints, unproven success criteria.

Present a ranked list of 3–6 **targets**. Each: area name, the open items it would settle, and one line on why it matters now. Rank blocking items first, then by how much other work depends on them. Recommend the top one. The user picks one, or names their own area; their pick wins.

Done when: the user has chosen exactly one target.

## 3. Grill the area

Interview the user relentlessly about the target until the area is settled. Map it as a **design tree**: every decision branches into the decisions that hang off it.

- Work in **rounds**. The **frontier** is every decision in the area whose prerequisites are settled. Ask the whole frontier per round: numbered questions, each with your recommended answer, worded so "yes" accepts it. Wait for answers, recompute the frontier, ask again.
- Facts are your job: look up code, configs, docs and versions yourself (a subagent if your harness has one). Decisions are the user's.
- Issues discovered outside the target area go straight to the backlog as new items; keep the rounds on the target.
- Use your harness's structured question tool if it has one.

Done when: the area's frontier is empty: every decision in the area has an answer, and nothing in it is silently assumed.

## 4. Write back

Apply everything the rounds settled:

- Update the affected design.md sections and diagrams. If a section now passes about a page, move its detail to `areas/<area>.md` from [templates/area.md](templates/area.md) and leave a summary plus link.
- Each non-trivial decision: an ADR from [templates/adr.md](templates/adr.md), numbered after the highest existing one, plus its Decisions row. Supersede, never rewrite, a reversed ADR.
- Backlog: tick settled items with where they were settled; add the new items from step 3 with severity and area.
- Frontmatter: `status: refining`, `updated` today.
- Append the entry to `iterations.md`.

Done when: every answer from step 3 lands in a section, an ADR, or the backlog, and diagrams agree with the prose.

## 5. Hand back

Show: what changed (files and sections, one line each), new ADRs, new backlog items, and the next two or three targets. If no blocking items remain, offer the review skill to check readiness.
