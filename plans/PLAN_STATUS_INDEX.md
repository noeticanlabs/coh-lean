# Plan Status Index

This file is the authoritative ledger for the documents in [`plans/`](../plans/).

## Completion Semantics

- **ACTIVE SOURCE OF TRUTH** — the document is the current status reference.
- **ACTIVE PLAN** — the document is still usable for current execution work.
- **REFERENCE PLAN** — the document contains useful strategy or architecture, but live status may have moved.
- **HISTORICAL SNAPSHOT** — the document records a past session or checkpoint. “Complete” means the scope of that snapshot completed, not that the full project completed.
- **SUPERSEDED PLAN** — the document is preserved for provenance only and should not be used as current status.
- **EVERGREEN REFERENCE** — the document defines rules, ownership, or conceptual framing rather than live execution status.

## Current Rule for Reading “Complete”

Unless a document is marked **ACTIVE SOURCE OF TRUTH**, the word **complete** is local to that document’s scope:

- phase-complete means that phase was completed at the time of writing,
- session-complete means that session objective was completed,
- scaffold-complete means structure exists but proofs may still remain,
- project-complete means the whole repo is complete — and no current plan document should be read that way unless it says so explicitly.

## File-by-File Status

| File | Status Class | Interpretation |
|------|--------------|----------------|
| `PROJECT_STATUS.md` | **ACTIVE SOURCE OF TRUTH** | Read this first for current project-wide status. |
| `PLAN_STATUS_INDEX.md` | **ACTIVE SOURCE OF TRUTH** | Authoritative meaning of plan completion labels. |
| `PHASE5B_INITIALIZATION.md` | **ACTIVE PLAN** | Current execution handoff for Phase 5b work. |
| `PHASE5_CRITICAL_BRIDGES.md` | **ACTIVE PLAN** | Current long-range bridge roadmap for Phases 5–7. |
| `MINERALIZATION_PLAN.md` | **REFERENCE PLAN** | Strategic reference; many earlier steps are already executed. |
| `RULE_OF_OWNERSHIP.md` | **EVERGREEN REFERENCE** | Ownership policy, not a status ledger. |
| `SYNTHESIS_FROM_EXISTENCE_TO_DERIVATION.md` | **EVERGREEN REFERENCE** | Conceptual synthesis, not a live tracker. |
| `RICK_VERDICT_AND_T7_PRIORITY.md` | **REFERENCE PLAN** | Priority memo; not the current source of truth. |
| `APPROVAL_CHECKPOINT.md` | **HISTORICAL SNAPSHOT** | Approval state at an earlier checkpoint. |
| `ARCHITECTURE_CHECKPOINT.md` | **HISTORICAL SNAPSHOT** | Architecture progress snapshot from an earlier phase. |
| `ARCHITECTURE_REFACTOR.md` | **SUPERSEDED PLAN** | Original architecture execution plan; retained for provenance. |
| `BUILD_SYSTEM_DEBUG_REPORT.md` | **HISTORICAL SNAPSHOT** | Build/debug incident report from an earlier state. |
| `COMPLETE_ROADMAP.md` | **SUPERSEDED PLAN** | Broad roadmap; no longer the live status ledger. |
| `EXECUTION_SUMMARY.md` | **SUPERSEDED PLAN** | Initial execution plan; kept for provenance. |
| `FINAL_STATUS.md` | **HISTORICAL SNAPSHOT** | Session-level status report, not final global completion. |
| `IMPORT_FIX_PLAN.md` | **HISTORICAL SNAPSHOT** | Completed import-fix task record. |
| `PHASE0_COMPLETION_CHECKPOINT.md` | **HISTORICAL SNAPSHOT** | Phase 0 checkpoint record. |
| `PHASE1_COMPLETION_CHECKPOINT.md` | **HISTORICAL SNAPSHOT** | Phase 1 checkpoint record. |
| `PHASE1_ENTRY_POINT.md` | **SUPERSEDED PLAN** | Entry guide for work that has already been executed. |
| `PHASE1_T3_BRIDGE_PLAN.md` | **SUPERSEDED PLAN** | Detailed Phase 1 implementation plan retained for provenance. |
| `PHASE2_COMPLETION_CHECKPOINT.md` | **HISTORICAL SNAPSHOT** | Phase 2 checkpoint record. |
| `PHASE2_ENTRY_POINT.md` | **SUPERSEDED PLAN** | Entry guide for work that has already been executed. |
| `PHASE2_T5_BRIDGE_PLAN.md` | **SUPERSEDED PLAN** | Detailed Phase 2 implementation plan retained for provenance. |
| `PHASE3_COMPLETION_CHECKPOINT.md` | **HISTORICAL SNAPSHOT** | Phase 3 checkpoint record. |
| `PHASE3_ENTRY_POINT.md` | **SUPERSEDED PLAN** | Entry guide for work that has already been executed. |
| `PHASE3_T6_BRIDGE_PLAN.md` | **SUPERSEDED PLAN** | Detailed Phase 3 implementation plan retained for provenance. |
| `PHASE4_COMPLETE_AND_PHASE5_BEGINS.md` | **HISTORICAL SNAPSHOT** | Phase-transition note; useful context, not live status. |
| `PHASE5_COMPACTNESS_STATUS.md` | **HISTORICAL SNAPSHOT** | In-progress T7 proof snapshot from before later completion work. |
| `PHASE5_FINAL_SUMMARY.md` | **HISTORICAL SNAPSHOT** | Phase 5a/T7 summary; read as a checkpoint, not project completion. |
| `PHASE5_INITIATED.md` | **HISTORICAL SNAPSHOT** | Phase 5 kickoff note. |
| `PHASE7_COMPILATION_STATUS.md` | **HISTORICAL SNAPSHOT** | Earlier compilation-state note for late phases. |
| `SESSION_COMPLETION_SUMMARY.md` | **HISTORICAL SNAPSHOT** | Session wrap-up only; not a project-complete claim. |

## Practical Reading Order

1. [`PROJECT_STATUS.md`](PROJECT_STATUS.md)
2. [`PLAN_STATUS_INDEX.md`](PLAN_STATUS_INDEX.md)
3. Active phase document if one exists for the task at hand
4. Historical snapshots only for provenance or reconstruction
