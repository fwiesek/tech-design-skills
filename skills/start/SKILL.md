---
name: start
description: Start a new technical architecture design from a goal, producing a small base design (v0) under docs/design/<slug>/. Use when the user wants to design a new system, service, or feature architecture, or says "start a design", "design the architecture for".
---

Turn a goal into a small, complete **base design**: every section present, each one thin. Depth comes later, one area at a time, from the refine skill. Breadth over depth: a thin section beats a missing one.

Read [CONVENTIONS.md](CONVENTIONS.md) before writing anything; it defines the layout, sections, backlog format and diagram rules this skill writes to.

## 1. Locate

- Check `docs/design/` for existing designs. If one already covers this goal, stop and offer the refine skill instead.
- Decide **kind**: `brownfield` if the goal changes an existing codebase, else `greenfield`.

Done when: you know the kind and that no existing design covers the goal.

## 2. Explore (brownfield only)

Read the code the goal touches: entry points, the components involved, data stores, integrations. Delegate to a subagent if your harness has one. Capture only what the goal touches, with file paths; this becomes the Current state section.

Done when: you can name every existing component, store and integration the goal will change or call.

## 3. Intake

Ask **one** round of numbered questions, each with your recommended answer, worded so "yes" accepts it:

1. Goal in one sentence, and the success criteria that prove it is met.
2. Non-goals.
3. Constraints: language/stack, hosting, budget, team size, deadlines, systems that must be reused.
4. Expected scale: users, requests, data volume, order of magnitude only.
5. Slug and title for the design folder.

Skip questions the user's request or the codebase already answers; state those answers as assumptions instead. Use your harness's structured question tool if it has one. Wait for answers.

Done when: every question is answered or explicitly left as an assumption.

## 4. Draft v0

Create `docs/design/<slug>/` with:

- `design.md` from [templates/design.md](templates/design.md), every section filled. Drop the brownfield-only sections for greenfield.
- `iterations.md` from [templates/iterations.md](templates/iterations.md), with entry 0.
- `decisions/` ADRs only for decisions that are already non-trivial at v0 (usually zero to two). Use the ADR sections listed in CONVENTIONS.md.

Draft rules:

- Pick a concrete choice wherever the intake leaves room, record it in Decisions, and flag shaky choices as open questions.
- Every gap, guess and unknown goes into Open questions and risks with a severity and an area. This list is the refinement backlog, so make it honest: a v0 with an empty backlog is a sign of hidden guesses.
- Status `draft`, `updated` today.

Done when: every section is filled or explicitly marked "none", every diagram follows the Diagrams conventions, and every assumption you made is either in Decisions or in the backlog.

## 5. Hand back

Show the user: the folder path, a five-line summary (goal, components, key flows covered), and the top open items by severity. Offer the refine skill as the next step.
