# Coh Lean Architecture Refactor: D + B Strategy

## The Three-Layer Stack

```
┌─────────────────────────────────────────────────────────────────┐
│ T3 (Kinematics) | T5 (Thermodynamics) | T6 (Geometry)          │
│ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓  │
│                      Theorem Stacks                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│                    Coh/Core/ (NEW)                              │
│          Concrete Foundational Semantics Layer                 │
│                  [Carriers, Clifford, Oplax, etc.]            │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│                   Coh/Prelude.lean (MINIMAL)                   │
│            Shared Vocabulary & Interface Layer                 │
│              [Lightweight types, universes, notation]          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 0: Prelude Cleanup

### Current Prelude Status

**Lines 1–13:** ✅ KEEP AS-IS
- Imports, universes, `End`, `dim`, `Idx`

**Lines 15–18:** ✅ KEEP AS-IS
- `Metric` structure (proper definition, not a placeholder)

**Lines 20–30:** ✅ KEEP AS-IS
- Type abbreviations (`FrequencyProbe`, `Budget`, `Lifespan`, `Cost`)

**Lines 32–34:** ⚠️ PROMOTE TO CORE
- `Generator` structure — currently lightweight, but semantics belong in Core

**Lines 36–40:** ⚠️ PROMOTE TO CORE
- `CliffordModule` — abstract, but needs concrete semantics in Core

**Lines 42–48:** 🗑️ DELETE or PROMOTE
- `IsReducible`, `IsFaithful` classes with `True` placeholders
  - **Decision:** Promote to Core with real class constraints

**Lines 50–52:** ⚠️ PROMOTE TO CORE
- `FirstOrderOperator` — currently empty, move to Core with implementation

**Lines 54–65:** 🗑️ DELETE FROM PRELUDE
- `IsClifford`, `OplaxSound`, `SubquadraticDefectBound`, `CoerciveVisibility`
- **Reason:** These are not abstract interfaces; they're theorem-specific definitions
- **Action:** Move to Core with proper semantics

**Lines 67–72:** ⚠️ CONDITIONAL
- `trackingCost`, `lifespanBound` — lightweight helpers
- **Decision:** Keep if used in Prelude; else move to Core

**Lines 74–81:** 🗑️ DELETE or STUB
- `TangentConeAdmissible`, `ComplexCarrier` with `True` fields
- **Action:** Replace with references to Core definitions

**Lines 83–90:** 🗑️ DELETE
- `MinimalAdmissibleCarrier`, `ComplexFourSpinor` — placeholder structures
- **Action:** Concrete versions in Core; Prelude doesn't need them

**Lines 92–94:** ⚠️ PROMOTE or DELETE
- `EquivalentCarrier` class — depends on whether Prelude needs equivalence
- **Decision:** Delete from Prelude; Core defines it

---

## Phase 0.5: New Coh/Core Structure

Create a new directory `Coh/Core/` with the following modules:

### `Coh/Core.lean` (Root)
```lean
import Coh.Prelude
import Coh.Core.Carriers
import Coh.Core.Clifford
import Coh.Core.Oplax
import Coh.Core.Minimality
-- ... more as needed
```

### `Coh/Core/Carriers.lean`
**Contents:**
- Concrete definition of `CarrierSpace` class with proper instance constraints
- Concrete `CliffordModule` with soundness conditions
- `IsFaithful`, `IsReducible` with meaningful class definitions (not `True` witnesses)
- Lawful carrier structure
- Equivalence relation on carriers

**Key theorems:**
- Properties of faithful modules
- Rank preservation under equivalence
- Irreducibility characterization

### `Coh/Core/Clifford.lean`
**Contents:**
- Concrete semantics of `IsClifford` (anticommutation relations)
- Definition of `OplaxSound` via anomaly bounds
- Anticommutator algebra
- Mismatch operator structure

**Key lemmas:**
- Clifford ⟹ Oplax (already in T3_Clifford, summarize here)
- Basic anticommutator identities
- Index pair mismatch characterization

### `Coh/Core/Oplax.lean`
**Contents:**
- Concrete `SubquadraticDefectBound` definition
- `CoerciveVisibility` and coercive oplax soundness
- Frequency norm and anomaly defect structure
- Visibility predicates for mismatch witnesses

**Key lemmas:**
- Defect bound composition
- Frequency-family growth rates
- Anomaly norm bounds

### `Coh/Core/Minimality.lean`
**Contents:**
- Metabolic cost structure (already in T5_Minimality, reference here)
- Minimality predicates
- Representation-theoretic notion of irreducibility
- Thermodynamic dominance

**Key lemmas:**
- Cost ordering ⟹ lifespan ordering
- Rank increase ⟹ cost increase
- Irreducibility as a constraint on module structure

### `Coh/Core/Complexification.lean`
**Contents:**
- Complex-like structure definition (`J` with `J² = -I`)
- Persistence and periodicity notions
- Commutation with gamma family

**Key lemmas:**
- 1D linearity forbids periodicity (from T6_Complexification)
- 2D rotation is complex-like
- Complex structure existence implications

---

## Phase 1: Update Coh/Prelude.lean

**After Core is established:**

```lean
import Mathlib.Data.Real.Basic

namespace Coh

universe u v

-- Lightweight structural definitions

abbrev End (V : Type u) := V → V

def dim : ℕ := 4
abbrev Idx := Fin dim

/-- Real-valued metric tensor. -/
structure Metric where
  g : Idx → Idx → ℝ
  symm : ∀ i j, g i j = g j i

-- Type abbreviations for parameters
abbrev FrequencyProbe := Idx → ℝ
abbrev Budget := ℝ
abbrev Lifespan := ℝ
abbrev Cost := ℝ

-- Abstract carrier space class
class CarrierSpace (V : Type*) extends
  NormedAddCommGroup V,
  NormedSpace ℝ V,
  FiniteDimensional ℝ V

-- Notation and shared vocabulary below

end Coh
```

**Key deletions:**
- All `True` placeholders
- Abstract generator definitions (move to Core)
- Module abstractions (move to Core)
- Theorem-specific predicates (move to Core)

**Key additions:**
- Clean import reference to Core

---

## Phase 2: Update Coh.lean to Import Core

```lean
import Coh.Prelude
import Coh.Core

import Coh.Kinematics.T3_Clifford
import Coh.Kinematics.T3_CoerciveVisibility
-- ... etc
```

---

## Phase 3: Update T3, T5, T6 to Use Core

Each theorem stack should import `Coh.Core` and use definitions from there.

### T3 Kinematics Changes

**File:** `Coh/Kinematics/T3_Clifford.lean`

- Import `Coh.Core.Clifford` for `IsClifford` semantics
- Remove duplicate definitions
- Reference Core lemmas for anticommutator properties

**Impact:** Code becomes shorter, denser, more reusable

### T5 Thermodynamics Changes

**File:** `Coh/Thermo/T5_Minimality.lean`

- Import `Coh.Core.Minimality` for cost/lifespan structure
- Remove duplicate definitions
- Reference Core for minimality predicates

### T6 Geometry Changes

**File:** `Coh/Geometry/T6_Complexification.lean`

- Import `Coh.Core.Complexification`
- Reference Core for complex-like structure
- Remove redundant definitions

---

## Migration Checklist

### For each placeholder in current Prelude:

| Placeholder | Decision | Destination | Action |
|-------------|----------|-------------|--------|
| `Generator` | Promote | Core/Clifford | Define with proper semantics |
| `CliffordModule` | Promote | Core/Carriers | Concrete definition with constraints |
| `IsReducible` | Promote | Core/Carriers | Real class with meaningful witness |
| `IsFaithful` | Promote | Core/Carriers | Real class definition |
| `FirstOrderOperator` | Promote | Core/Clifford | Move with implementation |
| `IsClifford` | Promote | Core/Clifford | Real anticommutation definition |
| `OplaxSound` | Promote | Core/Oplax | Anomaly-based definition |
| `SubquadraticDefectBound` | Promote | Core/Oplax | Real growth rate definition |
| `CoerciveVisibility` | Promote | Core/Oplax | Mismatch visibility |
| `trackingCost` | Keep/Move | Prelude or Core/Minimality | Lightweight enough for Prelude if used |
| `lifespanBound` | Keep/Move | Same as trackingCost | |
| `TangentConeAdmissible` | Delete | — | Not needed in lightweight layer |
| `ComplexCarrier` | Promote | Core/Complexification | Real definition with J operator |
| `MinimalAdmissibleCarrier` | Delete | — | Replaced by Core definitions |
| `ComplexFourSpinor` | Delete | — | Replaced by Core definitions |
| `EquivalentCarrier` | Promote | Core/Carriers | Real equivalence definition |

---

## Why This Works

### ✅ Prelude Stays Minimal
- No fake theorems masquerading as definitions
- No `True` placeholders
- Pure vocabulary and structural types
- Import-safe, version-stable

### ✅ Core Carries Ontology
- All semantic content lives here
- Real type constraints, real classes
- Theorem stacks reference Core, not abstract Prelude
- Single source of truth for each concept

### ✅ Theorem Stacks Stay Focused
- T3, T5, T6 build on Core, not on scattered definitions
- No local reinvention of shared concepts
- Easier composition at the capstone

### ✅ Path to 100% Formalization
- No hidden placeholders in the foundation
- Clear distinction between interface and implementation
- Concrete obligations visible and traceable

---

## Ordering of Work

1. **Create Core/** with Carriers, Clifford, Oplax, Minimality, Complexification modules
2. **Clean Prelude.lean** — remove all `True` placeholders, keep only vocabulary
3. **Update imports** in T3, T5, T6 to use Core definitions
4. **Implement four bridges** (as planned)
5. **Integrate capstone** with LawfulMatterBridge composition

---

## Expected Result

After Phase 0–2, the repo will have:

- **Coh/Prelude.lean:** ~30 lines of lightweight interface
- **Coh/Core/:** ~400–500 lines of honest semantic definitions
- **T3, T5, T6:** Cleaner imports, fewer duplicate definitions
- **Capstone:** Can clearly see what bridges are missing

This is the **architectural foundation** for 100% formalization without accumulating technical debt.

