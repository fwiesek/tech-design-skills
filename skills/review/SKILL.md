---
name: review
description: Review a technical design in docs/design/<slug>/ for gaps, inconsistencies, risks and readiness to publish. Use when the user wants a design critiqued, audited, or checked for readiness.
---

Critique a design like a skeptical staff engineer seeing it for the first time. Findings go to the user first and into the design's backlog only once accepted, so the backlog stays the single queue of work.

Read [CONVENTIONS.md](CONVENTIONS.md) first; its readiness checks are the checklist for step 2.

## 1. Load

Find the design (the named slug, else the only/most recently `updated` folder in `docs/design/`). Read `design.md`, every ADR, every area doc, and `iterations.md`. Brownfield: spot-check the Current state section against the code.

Done when: everything under the design folder has been read.

## 2. Readiness checks

Run every readiness check in CONVENTIONS.md. For each, record pass or fail with the evidence: the section, diagram, or item that proves it.

Done when: every check has a verdict and evidence.

## 3. Critique

Go beyond the checklist. Hunt for:

- **Contradictions**: prose, tables, diagrams and ADRs that disagree.
- **Unproven claims**: a success criterion or constraint no flow or decision actually addresses.
- **Failure modes**: what happens when each external system, store, or network hop fails or is slow.
- **Security and data**: authn/authz, secrets, PII, retention, abuse.
- **Scale and cost**: the design against the stated scale and budget.
- **Operability**: how it is deployed, observed, and recovered, at the depth the goal needs.
- **Stale or weak decisions**: ADRs whose context changed, or alternatives dismissed without a reason.

Skip findings already in the backlog; reference their ID instead.

Done when: every component, flow and ADR has been examined under each lens.

## 4. Report

In chat:

1. Readiness table: check, pass/fail, evidence.
2. Findings ranked by severity (`blocking`, `major`, `minor`), each one line with its area and a proposed backlog line in the CONVENTIONS.md format.
3. Verdict: ready, or what blocks readiness.

Ask which findings to accept (default: all).

Done when: the user has said which findings to accept.

## 5. Record

- Append accepted findings to Open questions and risks with fresh IDs.
- If every readiness check passes with the accepted findings included, propose `status: ready`; set it when the user agrees.
- Update `updated` if you edited the file. Review does not add an `iterations.md` entry.
