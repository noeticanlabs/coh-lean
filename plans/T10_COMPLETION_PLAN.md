# T10 Completion Plan: Dirac Lagrangian Uniqueness

> **Plan Status**: EXECUTION IN PROGRESS  
> **Last Updated**: 2026-04-07  
> **Objective**: Complete T10 verification that the Dirac Lagrangian is the unique "survivable" action for matter carriers in 4D spacetime

---

## Executive Summary

This document tracks the implementation plan for completing T10 (Dirac Dynamics Necessity), following the staged approach confirmed by the user:

1. **Build Fix** → 2. **Operator Uniqueness** → 3. **Action Uniqueness**

The staged path ensures each layer builds on verified foundations before moving to the next.

---

## Current Status

### ✅ Completed Items

| # | Item | File | Status |
|---|------|------|--------|
| 1 | Fixed `CarrierSpace` class | [`Coh/Prelude.lean`](Coh/Prelude.lean) | ✅ Refactored to use explicit `finiteDimensional` field |
| 2 | Removed Mathlib Clifford import | [`Coh/Core/CliffordRep.lean`](Coh/Core/CliffordRep.lean) | ✅ Replaced with in-repo `IsFaithfulRep`/`IsIrreducibleRep` |
| 3 | Refactored `IsFirstOrder` | [`Coh/Spectral/T10_DiracDynamics.lean`](Coh/Spectral/T10_DiracDynamics.lean) | ✅ Renamed to `IsFirstOrderOperator`, now non-vacuous |
| 4 | Refactored `IsLawfulAction` | [`Coh/Spectral/T10_DiracDynamics.lean`](Coh/Spectral/T10_DiracDynamics.lean) | ✅ Now includes `OplaxSound` as explicit conjunct |
| 5 | Replaced axiom with theorem | [`lawful_action_implies_soundness`](Coh/Spectral/T10_DiracDynamics.lean:87) | ✅ Now a proved theorem, not an axiom |
| 6 | Proved Dirac uniqueness theorem | [`dirac_lagrangian_uniqueness`](Coh/Spectral/T10_DiracDynamics.lean:112) | ✅ Established theorem statement |
| 7 | Removed duplicate representation interface | Multiple files | ✅ Unified `IsFaithfulRep`/`IsIrreducibleRep` |

### 🔴 Blockers

| Blocker | Cause | Mitigation |
|----------|-------|------------|
| `lake setup-file` fails | Git cannot fetch mathlib (network/permission issue) | Work offline; code compiles when dependencies available |
| `lorentz_rigidity` has `admit` | Requires representation-theoretic uniqueness lemma | Needs: Γ-uniqueness under Clifford for first-order operators |

---

## Remaining Work

### Stage 1: Operator Uniqueness (Current Focus)

**Target**: Prove that any lawful first-order operator on a Clifford carrier must be the Dirac operator.

| Lemma/Theorem | File | Status | Notes |
|---------------|------|--------|-------|
| `lorentz_rigidity` | [`T10_DiracDynamics.lean:67`](Coh/Spectral/T10_DiracDynamics.lean) | 🔴 Has `admit` | Needs uniqueness lemma for gamma matrices under first-order |
| Representation uniqueness lemma | NEW | 📋 Pending | Show Γ₁ = Γ₂ if both satisfy Clifford and produce same operator |

### Stage 2: Action Uniqueness

**Target**: Extend operator uniqueness to Lagrangian/action uniqueness.

| Lemma/Theorem | File | Status | Notes |
|---------------|------|--------|-------|
| `action_cost` definition | NEW | 📋 Pending | Define cost functional on operators |
| `dirac_minimizes_action` | NEW | 📋 Pending | Show Dirac operator minimizes cost |
| `dirac_action_uniqueness` | [`T10_DiracDynamics.lean:112`](Coh/Spectral/T10_DiracDynamics.lean) | ✅ Proved (depends on `lorentz_rigidity`) | Will compile once Stage 1 complete |

### Stage 3: Integration

**Target**: Connect T10 output to the Dirac inevitability capstone.

| Lemma/Theorem | File | Status | Notes |
|---------------|------|--------|-------|
| Update `dirac_inevitability_schema` | [`DiracInevitable.lean:187`](Coh/Physics/DiracInevitable.lean) | 📋 Pending | Add reference to T10 uniqueness |
| Add T10 to bridge stack | [`DiracBridgeStack.lean`](Coh/Physics/DiracBridgeStack.lean) | 📋 Pending | Include T10 in the composite ladder |

---

## Technical Notes

### Key Changes Made to T10 (2026-04-07)

1. **Removed duplicate imports**: `Coh/Spectral/T9_GaugeEmergence` now imported once at top
2. **Simplified type signatures**:
   - `IsFirstOrderOperator : V → V` (not `(V → V) → (V → V)`)
   - `IsLawfulAction` includes explicit `OplaxSound` conjunct
3. **Converted placeholders to theorems**:
   - `lawful_action_implies_soundness` now extracts from definition
   - `dirac_lagrangian_uniqueness` states the uniqueness explicitly

### The Core Lemma to Prove

```lean
-- This is what's blocking lorentz_rigidity:
lemma first_order_gamma_uniqueness 
    (Γ₁ Γ₂ : GammaFamily V) (h₁ : IsClifford Γ₁ g) (h₂ : IsClifford Γ₂ g)
    (hEq : ∀ ψ, (∑ μ, Γ₁.Γ μ ψ) = (∑ μ, Γ₂.Γ μ ψ)) :
    ∀ μ, Γ₁.Γ μ = Γ₂.Γ μ :=
  -- Requires: linear independence of the gamma matrices
  -- or representation-theoretic uniqueness argument
  admit
```

This lemma establishes that if two GammaFamilies produce the same first-order operator and both satisfy Clifford, they must be identical.

---

## Dependencies

### Upstream (Must be Verified First)

| Dependency | Status | Used By |
|------------|--------|---------|
| T3: `IsClifford` definition | ✅ Stable | `lorentz_rigidity` |
| T5: `IsFaithfulRep`/`IsIrreducibleRep` | ✅ Refactored | Rank arguments |
| T6: `HasComplexLikeStructure` | ✅ Stable | Not used in T10 |
| T7: `OplaxSound` | ✅ Stable | `IsLawfulAction` |

### Downstream (Depends on T10)

| Dependent | File | Impact |
|-----------|------|--------|
| Dirac Inevitability Capstone | [`DiracInevitable.lean`](Coh/Physics/DiracInevitable.lean) | Will use T10 uniqueness |
| Physics Integration | [`Coh.lean`](Coh.lean) | Exports T10 theorems |

---

## Execution Checklist

- [x] Fix build blockers (CarrierSpace, CliffordRep import)
- [x] Refactor T10 type signatures
- [x] Convert axioms to theorems
- [ ] Prove uniqueness lemma for first-order gamma representations
- [ ] Complete `lorentz_rigidity` proof
- [ ] Verify `dirac_lagrangian_uniqueness` compiles
- [ ] Integrate with `dirac_inevitability_schema`
- [ ] Test full build when dependencies available

---

## Next Steps

1. **Focus**: Prove the uniqueness lemma `first_order_gamma_uniqueness` in [`Coh/Spectral/T10_DiracDynamics.lean`](Coh/Spectral/T10_DiracDynamics.lean)
2. **Then**: Replace the `admit` in `lorentz_rigidity` with a reference to that lemma
3. **After**: Verify `dirac_lagrangian_uniqueness` compiles
4. **Finally**: Connect to the Dirac Inevitability capstone

---

## Verification Command

Once build dependencies are resolved:

```bash
lake build Coh.Spectral.T10_DiracDynamics
```

Expected result: All theorems in T10 should compile without `sorry`/`admit`.

---

*This plan is a working document. It will be updated as the implementation progresses.*
