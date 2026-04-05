# Rule of Ownership: Architectural Discipline

## The Principle

> **No theorem stack may define a concept that belongs in Core.**

This enforces semantic unity across the formalization and prevents ontological drift.

---

## Rule of Ownership: Three Parts

### Part 1: Concept Placement Rule

If a concept appears in more than one theorem stack → **it must live in Core**.

**Examples:**

| Concept | Appears In | Location | Reason |
|---------|-----------|----------|--------|
| `IsClifford` | T3 | Core/Clifford | Shared across stacks |
| `OplaxSound` | T3 | Core/Oplax | Shared across stacks |
| `MetabolicParams` | T5 | Core/Minimality | Shared across stacks |
| `ComplexLike` | T6 | Core/Complexification | Used in T6 + Physics |
| `Metric` | All (T3, T6) | Prelude (already OK) | Universal |
| `GammaFamily` | T3, T6 | Core/Clifford | Shared definition |

### Part 2: Ontological Rule

If a concept affects legality, equivalence, or structure → **it must live in Core**.

**Examples:**

| Concept | Type | Location | Reason |
|---------|------|----------|--------|
| `CliffordModule` | Structure | Core/Carriers | Defines what is "lawful" |
| `IsFaithful` | Class | Core/Carriers | Defines carrier legality |
| `IsReducible` | Class | Core/Carriers | Defines structure constraints |
| `EquivalentCarrier` | Class | Core/Carriers | Equivalence is foundational |
| `SamePhysicalContent` | Class | Core/Minimality | Affects comparison logic |
| `Carrier.Space` | Class | Prelude (OK) | Universal constraint |

### Part 3: Client Rule

**Theorem stacks (T3, T5, T6, Physics) are allowed to:**

✅ **Use** Core definitions
✅ **Specialize** Core concepts for their domain
✅ **Extend** Core with theorem-specific lemmas
✅ **Apply** Core to prove their theorems

❌ **Must NOT:**

❌ Redefine Core concepts locally
❌ Create synonyms for Core concepts
❌ Duplicate Core logic
❌ Import from outside their theorem stack for shared concepts (must use Core)

---

## Enforcement Checklist

Before merging any code, verify:

### In Core Files

- [ ] Each module defines exactly one semantic domain
- [ ] No cross-module definitions (Clifford.lean doesn't define minimality concepts)
- [ ] All shared structures and classes present
- [ ] No local duplicates of Prelude concepts

### In Theorem Stacks (T3/T5/T6/Physics)

- [ ] All imports from Core (not from other stacks)
- [ ] Specialization lemmas only (e.g., "for T3, if X then Y")
- [ ] No redefinition of anything in Core
- [ ] No circular imports back to Core

### In Prelude

- [ ] Fewer than 50 lines total
- [ ] No `True` placeholders
- [ ] Only: types, universes, lightweight classes (CarrierSpace)
- [ ] All semantic content removed (moved to Core)

---

## Examples: Correct vs Incorrect

### ❌ INCORRECT: Duplicate Definition

```lean
-- In Coh/Thermo/T5_Minimality.lean
def OplaxSound (Γ : GammaFamily V) (g : Metric) : Prop := ...

-- ❌ WRONG: Redefines what should be in Core/Oplax.lean
```

**Fix:** Import from Core
```lean
-- In Coh/Thermo/T5_Minimality.lean
import Coh.Core.Oplax

-- Use the Core definition
theorem minimality_requires_oplax (hOplax : OplaxSound V Γ g) : ...
```

---

### ❌ INCORRECT: Local Synonym

```lean
-- In Coh/Kinematics/T3_Clifford.lean
def T3_Clifford := Coh.Core.Clifford.IsClifford

-- ❌ WRONG: Creates a local alias
-- This causes future confusion: are they the same? Should they be?
```

**Fix:** Use Core definition directly
```lean
-- In Coh/Kinematics/T3_Clifford.lean
import Coh.Core.Clifford

theorem clifford_property (hCl : IsClifford V Γ g) : ...
```

---

### ✅ CORRECT: Specialization

```lean
-- In Coh/Kinematics/T3_Clifford.lean
import Coh.Core.Clifford

-- Specialize a Core theorem for T3 context
theorem clifford_implies_oplax
    (Γ : GammaFamily V) (g : Metric)
    (hCl : IsClifford V Γ g) :
    OplaxSound V Γ g := by
  -- Use Core definitions, prove T3-specific consequence
  sorry

-- Helper lemmas for T3
lemma anomaly_norm_vanishes_when_clifford
    (Γ : GammaFamily V) (g : Metric)
    (hCl : IsClifford V Γ g)
    (f : Idx → ℝ) :
    ‖anomaly V Γ g f‖ = 0 := by
  sorry
```

---

### ✅ CORRECT: Using Core + Domain-Specific Theorem

```lean
-- In Coh/Thermo/T5_RepresentationMinimality.lean
import Coh.Core.Carriers
import Coh.Core.Minimality

theorem FaithfulIrreducibleBridge
    [IsFaithful V] [IsFaithful W] [IsIrreducible W]
    (hEquiv : SamePhysicalContent V W)
    (hRank : StrictlyLargerCarrier V W) :
    ThermodynamicallyDominated V W := by
  -- Uses Core definitions, proves T5-specific result
  sorry
```

---

## Migration Validation

### Per-File Audit

For each file that will be modified, verify:

**T3 Files:**
- [ ] `T3_Clifford.lean` imports `Coh.Core.Clifford`
- [ ] `T3_Necessity.lean` imports `Coh.Core.Clifford` + `Coh.Core.Oplax`
- [ ] `T3_CoerciveVisibility.lean` imports `Coh.Core.Oplax`
- [ ] `T3_NonCliffordVisible.lean` imports `Coh.Core.Clifford` + `Coh.Core.Oplax`
- [ ] `T3_WitnessAmplification.lean` imports Core modules (not other T3 modules for shared defs)

**T5 Files:**
- [ ] `T5_Minimality.lean` imports `Coh.Core.Minimality`
- [ ] `T5_RepresentationMinimality.lean` imports `Coh.Core.Carriers` + `Coh.Core.Minimality`

**T6 Files:**
- [ ] `T6_Complexification.lean` imports `Coh.Core.Complexification`
- [ ] `T6_PersistenceForcesRotation.lean` imports `Coh.Core.Complexification`
- [ ] `T6_CommutesWithClifford.lean` imports `Coh.Core.Clifford` + `Coh.Core.Complexification`

**Physics Files:**
- [ ] `DiracInevitable.lean` imports all needed Core modules
- [ ] `DiracBridgeStack.lean` imports all needed Core modules

---

## Consequences of Violating the Rule

### If Duplicate Definitions Are Allowed

❌ System becomes:
- Ambiguous (which IsClifford is "correct"?)
- Hard to maintain (fix one, miss the other)
- Impossible to compose (modules disagree on semantics)
- Unmechanizable (compiler can't track which version is used)

### If Concepts Scatter Across Stacks

❌ System becomes:
- Fragmented (local truth vs global truth)
- Circular (T3 imports T5 to use shared concept)
- Hard to understand (where does X really live?)
- Unmaintainable (moving it later breaks everything)

---

## Enforcement Mechanism

### Phase 0–3 Validation Checklist

After Architecture Refactor, before Mineralization:

```lean
-- Pseudo-validation (run in REPL or test file)

-- Check 1: Core modules compile independently
#check Coh.Core.Carriers
#check Coh.Core.Clifford
#check Coh.Core.Oplax
#check Coh.Core.Minimality
#check Coh.Core.Complexification

-- Check 2: T3 can import Core without circular dependency
#check Coh.Kinematics.T3_Clifford
#check Coh.Kinematics.T3_CoerciveVisibility

-- Check 3: No orphaned definitions in Prelude
-- (Manually inspect Coh/Prelude.lean < 50 lines, no True)

-- Check 4: Coh.lean imports in right order
#check Coh
```

---

## Summary Table

| Layer | Allowed to Define | Not Allowed to Define |
|-------|-------------------|----------------------|
| **Prelude** | Types, universes, lightweight classes | Theorems, semantic predicates, `True` |
| **Core** | Semantic structures, classes, foundational laws | Theorem-specific proofs |
| **T3/T5/T6** | Theorem-specific lemmas, specializations | Concepts that appear in >1 stack |
| **Physics** | Capstone composition, final integration | Concepts that should be in Core |

---

## Approval Gate

Before switching to Code mode:

✅ **Rule of Ownership** is understood and agreed
✅ **Enforcement Checklist** will be run after Phase 0–3
✅ **Any violation during implementation will be caught and fixed**

This rule ensures that when mineralization begins, the architectural foundation is not just clean—it's **enforceably clean**.

