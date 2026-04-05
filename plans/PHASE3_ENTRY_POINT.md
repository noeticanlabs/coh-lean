# PHASE 3 QUICK START GUIDE

**Phase**: Phase 3 - T6 Geometric Bridges  
**Target**: Geometric Complexification & Clifford Commutation  
**Status**: Ready for implementation  
**Estimated LOC**: 30-50 lines of bridge implementations

---

## Overview

Phase 3 bridges the gap between **T5 representation-theoretic minimality** and **Dirac inevitability** by establishing that:

1. Persistent cyclic evolution forces complex-like structure
2. Complex-like structures commute with Clifford generators
3. The combination yields Clifford-compatible carriers

This completes the **geometric half** of the formalization before moving to the **physics integration** (Phase 4).

---

## Five-Step Execution

### Step 1: Understand T6 Architecture
Read the honest boundaries in:
- `Coh/Geometry/T6_PersistenceForcesRotation.lean` (lines 207-221)
- `Coh/Geometry/T6_CommutesWithClifford.lean` (lines 165-177)

**Key insight**: Both files define abstract bridge definitions. We need to instantiate them with concrete theorems.

---

### Step 2: Implement Persistence Bridge
**File**: `Coh/Geometry/T6_PersistenceForcesRotation.lean`

Add a witness instance for `PersistenceForcesComplexLike`:
```lean
theorem persistenceForcesComplexLike_theorem (V : Type*)
    [NormedAddCommGroup V] [NormedSpace ℝ V] [FiniteDimensional ℝ V]
    (hCycle : AdmitsPersistentCycle V) :
    HasComplexLikeStructure V := by
  sorry
```

---

### Step 3: Implement Commutation Bridge
**File**: `Coh/Geometry/T6_CommutesWithClifford.lean`

Add a witness instance for `ComplexLikeCommutesBridge`:
```lean
theorem complexLikeCommutesBridge_theorem (V : Type*)
    [NormedAddCommGroup V] [NormedSpace ℝ V] [FiniteDimensional ℝ V]
    (Γ : GammaFamily V)
    (hCx : HasComplexLikeStructure V) :
    CliffordCompatibleComplexLike V Γ := by
  sorry
```

---

### Step 4: Verify Build
```bash
lake build
```
Expected: Exit code 0, all modules compile.

---

### Step 5: Create Completion Checkpoint
Document decisions, build status, and readiness for Phase 4.

---

## Key Files

| File | Role | Action |
|------|------|--------|
| `Coh/Geometry/T6_PersistenceForcesRotation.lean` | Rotation bridge | Add persistence theorem |
| `Coh/Geometry/T6_CommutesWithClifford.lean` | Commutation bridge | Add commutation theorem |
| `plans/PHASE3_T6_BRIDGE_PLAN.md` | Strategy | Reference for detailed approach |

---

## Honest Boundaries

What Phase 3 **does** establish:
- Abstract bridge theorems connecting persistence → complex-like structure
- Abstract bridge theorems connecting complex-like → Clifford-compatible

What Phase 3 **does not** establish (deferred):
- Concrete proof that actual Coh dynamics instantiate `AdmitsPersistentCycle`
- Concrete proof of commutation with concrete Clifford gamma family
- Explicit construction of complex-like witness from persistence mechanics

---

## Next Phase Roadmap

After Phase 3:
- **Phase 4**: Physics Integration (Dirac_Inevitable_Schema)
  - Connect thermodynamic filtering to geometric constraints
  - Prove Dirac spinor minimality under combined T3+T5+T6 bridges
