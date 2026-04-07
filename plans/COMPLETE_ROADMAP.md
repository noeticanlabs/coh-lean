# Coh Lean: Complete Roadmap to 100% Formalization

> **Plan Status Class:** SUPERSEDED PLAN  
> **Completion Meaning:** This roadmap is complete as a planning artifact only. It does not describe current live completion state.  
> **Current Source of Truth:** [`PLAN_STATUS_INDEX.md`](PLAN_STATUS_INDEX.md) and [`PROJECT_STATUS.md`](PROJECT_STATUS.md).

## Overview

Transform the Coh safety kernel from a formal scaffold with placeholder definitions into a complete, mechanized proof of **Dirac Inevitability**. 

This roadmap combines two complementary strategies:
1. **Architecture Refactor (D+B):** Clean separation of concerns via Prelude → Core → T3/T5/T6
2. **Mineralization Plan:** Replace all 4 bridges + capstone with real proofs

---

## Part A: Architecture Foundation (Prerequisite)

### Why This Must Come First

The current codebase has:
- Prelude full of `True` placeholders
- Each theorem stack reinventing shared concepts
- No clear semantic kernel

**The refactor fixes this by:**
- Making Prelude a thin vocabulary layer (~30 lines)
- Creating Core as the honest semantic foundation (~400–500 lines)
- Making T3/T5/T6 clients of Core (cleaner, DRY)

### What Gets Built

| Layer | Files | Purpose |
|-------|-------|---------|
| **Prelude** | `Coh/Prelude.lean` | Lightweight types, universes, CarrierSpace class |
| **Core** | `Coh/Core/` | Concrete semantics for Carriers, Clifford, Oplax, Minimality, Complexification |
| **Theorem Stacks** | `T3/`, `T5/`, `T6/` | Concrete theorems built on Core |
| **Capstone** | `Coh/Physics/` | Final integration |

### Phase Breakdown

**PHASE 0: Prelude Cleanup** (~1 hour)
- Delete all `True` placeholders
- Keep only lightweight structural definitions
- Remove abstract predicate stubs (they move to Core)

**PHASE 0.5: Core Creation** (~3–4 hours)
- Create `Coh/Core/` directory
- Implement 5 modules:
  - **Carriers.lean:** Lawful carriers, faithfulness, irreducibility, equivalence
  - **Clifford.lean:** IsClifford anticommutation semantics, anticommutator algebra, mismatch operators
  - **Oplax.lean:** OplaxSound via anomaly bounds, SubquadraticDefectBound, CoerciveVisibility, visibility predicates
  - **Minimality.lean:** Metabolic cost, thermodynamic dominance, irreducibility constraints
  - **Complexification.lean:** Complex-like structure (J with J² = -I), persistence, periodicity, commutation

**PHASE 1: Update Prelude** (~30 mins)
- Add minimal import references if needed
- Clean up any remaining cruft

**PHASE 2: Update Coh.lean** (~15 mins)
- Add `import Coh.Core`

**PHASE 3: Update T3, T5, T6 Imports** (~45 mins)
- Replace abstract definitions with Core references
- Remove duplicate definitions
- Add concrete imports

---

## Part B: Mineralization — The Four Bridges + Capstone

Once Core is in place, implement the real theorems.

### Bridge 1: T3 Analytic Visibility

**File:** `Coh/Kinematics/T3_NonCliffordVisible.lean`  
**What:** Prove `AllMismatchWitnessesVisible`

**Obligation:**
```lean
theorem AllMismatchWitnessesVisible
    (Γ : GammaFamily V) (g : Metric) :
  ∀ μ ν : Idx, IsMismatchWitness V Γ g μ ν →
    WitnessCoercivelyVisible V Γ g μ ν
```

**Strategy:**
1. Analyze cliffordMismatchAt operator structure
2. Show mismatch → spectral defect
3. Bound anomaly norm from below using operator norm and frequency pairing
4. Use pairSpike frequency family to extract quadratic growth

**Estimated effort:** 2–3 hours of proof work

---

### Bridge 2: T5 Representation-Theoretic Minimality

**File:** `Coh/Thermo/T5_RepresentationMinimality.lean`  
**What:** Prove `FaithfulIrreducibleBridge`

**Obligation:**
```lean
class FaithfulIrreducibleBridge
    [IsFaithful V] [IsFaithful W] [IsIrreducible W] where
  sameContent : SamePhysicalContent V W
  largerRank : StrictlyLargerCarrier V W
```

**Strategy:**
1. Establish Dirac spinor (4-dimensional complex) as irreducible under Clifford action
2. Show any larger faithful carrier is thermodynamically dominated
3. Invoke thermodynamic dominance to prove minimality

**Estimated effort:** 2–3 hours of representation-theoretic reasoning

---

### Bridge 3: T6 Persistence → Complexification

**File:** `Coh/Geometry/T6_PersistenceForcesRotation.lean`  
**What:** Prove `PersistenceForcesComplexLike`

**Obligation:**
```lean
theorem PersistenceForcesComplexLike (V : Type*) :
  AdmitsPersistentCycle V → HasComplexLikeStructure V
```

**Strategy:**
1. From persistent bounded-periodic orbits, extract 2D invariant subspace
2. Show 2D subspace must support rotation (J operator with J² = -I)
3. Lift J to full carrier space
4. Use `lineTrajectory` lemmas from T6_Complexification to handle 1D degeneracy

**Estimated effort:** 2–3 hours

---

### Bridge 4: T6 Clifford Commutativity

**File:** `Coh/Geometry/T6_CommutesWithClifford.lean`  
**What:** Prove `ComplexLikeCommutesBridge`

**Obligation:**
```lean
theorem ComplexLikeCommutesBridge
    (Γ : GammaFamily V) :
  HasComplexLikeStructure V →
    CliffordCompatibleComplexLike V Γ
```

**Strategy:**
1. Given arbitrary J with J² = -I from `HasComplexLikeStructure`
2. Construct or select J' that commutes with each Γ_μ
3. Use averaging/selection to ensure J'² = -I is preserved
4. Package as `CliffordCompatibleComplexLike`

**Estimated effort:** 1.5–2 hours

---

### Capstone: Dirac Inevitability Integration

**File:** `Coh/Physics/DiracInevitable.lean`  
**What:** Replace `sorry` in `Dirac_Inevitable_Schema` with complete proof

**Obligation:**
```lean
theorem Dirac_Inevitable_Schema
    (V : Type*) [CarrierSpace V]
    (Γ : GammaFamily V) (g : Metric)
    (hSp : IsSpinorCandidate V Γ g) :
    ∃ f : V ≃ₗ[ℝ] (Fin 4 → ℂ), True
```

**Strategy:**
1. Instantiate `LawfulMatterBridge` with the four proved bridges
2. Apply `Dirac_Extermination_Ladder` from `DiracBridgeStack.lean`
3. Compose results: T3 forces Clifford, T5 forces minimality, T6 forces phase structure
4. Show composition uniquely characterizes carrier as C⁴

**Estimated effort:** 1–1.5 hours

---

## Complete Timeline

| Phase | Task | Estimated Time | Status |
|-------|------|-----------------|--------|
| **Arch 0** | Prelude cleanup | 1 hour | Pending |
| **Arch 0.5a** | Core/Carriers.lean | 45 mins | Pending |
| **Arch 0.5b** | Core/Clifford.lean | 45 mins | Pending |
| **Arch 0.5c** | Core/Oplax.lean | 1 hour | Pending |
| **Arch 0.5d** | Core/Minimality.lean | 45 mins | Pending |
| **Arch 0.5e** | Core/Complexification.lean | 1 hour | Pending |
| **Arch 1–3** | Update imports T3/T5/T6 | 1.5 hours | Pending |
| **Thm 1** | AllMismatchWitnessesVisible | 2–3 hours | Pending |
| **Thm 2** | FaithfulIrreducibleBridge | 2–3 hours | Pending |
| **Thm 3** | PersistenceForcesComplexLike | 2–3 hours | Pending |
| **Thm 4** | ComplexLikeCommutesBridge | 1.5–2 hours | Pending |
| **Thm 5** | Dirac_Inevitable_Schema | 1–1.5 hours | Pending |
| **Doc & QA** | README, lake build, verification | 1 hour | Pending |
| | **TOTAL** | **~19–23 hours** | |

---

## Success Criteria

### Architectural
- [ ] Prelude.lean ≤ 40 lines, no `True` placeholders
- [ ] Core/ directory exists with 5 modules
- [ ] All imports clean, no circular dependencies
- [ ] lake build succeeds

### Theorem Completion
- [ ] AllMismatchWitnessesVisible: fully proved (no sorry)
- [ ] FaithfulIrreducibleBridge: fully proved (no sorry)
- [ ] PersistenceForcesComplexLike: fully proved (no sorry)
- [ ] ComplexLikeCommutesBridge: fully proved (no sorry)
- [ ] Dirac_Inevitable_Schema: fully proved (no sorry)

### Final State
- [ ] Zero `sorry` in core theorems
- [ ] Zero `admit` anywhere
- [ ] README.md updated with proof status
- [ ] All modules compile cleanly
- [ ] Example in `Coh/Examples/MinimalWitness.lean` works end-to-end

---

## How to Proceed

### Option A: Start with Architecture (Recommended)
1. Switch to **Code mode**
2. Execute **PHASE 0–3** (Architecture Refactor)
3. Then return to **Architect** to plan Mineralization in detail
4. Switch back to **Code mode** for bridges + capstone

### Option B: Parallel Streams
1. Have Code mode do Architecture work
2. Have this Architect mode refine Mineralization details
3. Merge when both are ready

### Option C: Full Sequential
1. Complete all Architecture here in Architect mode
2. Get approval from user
3. Switch to Code mode once for all Mineralization

---

## Key Assumptions & Decisions

✅ **Accepted:** D+B Architecture (thin Prelude, real Core, focused theorem stacks)
✅ **Assumption:** Mathlib provides sufficient linear algebra & analysis infrastructure
✅ **Scope:** Four bridges + capstone integration (in progress)
✅ **Outcome:** Mechanized proof of Dirac Inevitability (work in progress)

---

## Files Affected

### New
- `Coh/Core.lean` (umbrella)
- `Coh/Core/Carriers.lean`
- `Coh/Core/Clifford.lean`
- `Coh/Core/Oplax.lean`
- `Coh/Core/Minimality.lean`
- `Coh/Core/Complexification.lean`

### Modified
- `Coh/Prelude.lean` (shrink from ~97 to ~40 lines)
- `Coh.lean` (add Core import)
- `Coh/Kinematics/T3_NonCliffordVisible.lean` (add proof of AllMismatchWitnessesVisible)
- `Coh/Kinematics/T3_Clifford.lean` (remove duplicate definitions)
- `Coh/Thermo/T5_RepresentationMinimality.lean` (add FaithfulIrreducibleBridge proof)
- `Coh/Geometry/T6_PersistenceForcesRotation.lean` (add PersistenceForcesComplexLike proof)
- `Coh/Geometry/T6_CommutesWithClifford.lean` (add ComplexLikeCommutesBridge proof)
- `Coh/Physics/DiracInevitable.lean` (replace sorry with proof)
- `README.md` (update completion status)

### Untouched
- `Coh/Kinematics/T3_Necessity.lean`
- `Coh/Kinematics/T3_CoerciveVisibility.lean`
- `Coh/Kinematics/T3_WitnessAmplification.lean`
- `Coh/Thermo/T5_Minimality.lean`
- `Coh/Geometry/T6_Complexification.lean`
- `Coh/Physics/DiracBridgeStack.lean`
- `Coh/Examples/MinimalWitness.lean`

---

## Next Action

**Ready to proceed to Code mode?**

Recommend starting with **PHASE 0: Prelude Cleanup** and **PHASE 0.5: Core Creation**, then returning to Architect mode to finalize Mineralization details before implementing the bridges.

