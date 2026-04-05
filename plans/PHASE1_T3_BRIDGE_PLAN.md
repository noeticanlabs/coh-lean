# PHASE 1: T3 Analytic Visibility Bridge

## Overview

**Phase 1 Target**: Prove `AllMismatchWitnessesVisible` in [`Coh/Kinematics/T3_NonCliffordVisible.lean`](../Coh/Kinematics/T3_NonCliffordVisible.lean)

This is the **converse** of the T3 layer: if a carrier family exhibits Clifford-like mismatch operators, those mismatches must be "visible" (coercively amplified) in the measurement anomaly.

---

## Problem Statement

### The Obligation
```lean
def AllMismatchWitnessesVisible (Γ : GammaFamily V) (g : Metric) : Prop :=
  ∀ μ ν : Idx,
    IsMismatchWitness V Γ g μ ν →
    WitnessCoercivelyVisible V Γ g μ ν
```

### What This Means Physically

1. **Mismatch Witness**: A pair `(μ, ν)` where the anticommutator `{γ_μ, γ_ν} ≠ 2g_μν I` fails the Clifford relation by some nonzero operator `M_μν`.

2. **Coercive Visibility**: The measurement anomaly induced by `M_μν` is bounded **from below** by a quadratic multiple of the input norm:
   ```
   ∃ c > 0 : ∀ f ∈ L²(R), ‖anomaly(f)‖ ≥ c · ‖f‖²
   ```

3. **The Bridge**: Every algebraic defect (Clifford mismatch) produces a measurable defect (anomaly bound).

---

## Technical Strategy

### Step 1: Analyze the Mismatch Operator Structure
**Location**: Analysis of `cliffordMismatchAt V Γ g μ ν`

**Goal**: Establish that the mismatch operator has nonzero spectral content.

**Key Lemmas** (to prove):
- `mismatchAt_nonzero_of_witness`: If `(μ, ν)` is a witness, then `cliffordMismatchAt` is nonzero
- `spectral_gap_of_mismatch`: Mismatch operators induce a minimum spectral gap

**Tactics**:
- Operator norm bounds from `‖·‖_op`
- Schur complement arguments (if applicable)
- Positivity and spectral properties of composition

### Step 2: Connect Mismatch to Anomaly Growth
**Location**: Bridge from operator structure to measurement anomaly

**Goal**: Show that the mismatch norm propagates to the anomaly norm via the frequency-pairing structure.

**Key Lemmas** (to prove):
- `anomaly_norm_bounds_mismatch`: `‖anomaly_μν(f)‖ ≥ κ · ‖cliffordMismatchAt(f)‖` for some κ > 0
- `mismatch_amplified_by_witness`: Frequency family pairing amplifies the mismatch signal

**Tactics**:
- Finset summation manipulation (frequencies pairSpike)
- Cauchy–Schwarz inequalities
- Norm monotonicity chains

### Step 3: Discharge the Bridge
**Location**: Proof of `AllMismatchWitnessesVisible`

**Goal**: Compose Steps 1–2 into a universal statement.

**Key Lemma** (to prove):
- `allMismatches_visible`: For all `(μ, ν)`, if `IsMismatchWitness` holds, then `WitnessCoercivelyVisible` holds

**Proof Structure**:
```lean
theorem AllMismatchWitnessesVisible (Γ : GammaFamily V) (g : Metric) :
    ∀ μ ν : Idx,
      IsMismatchWitness V Γ g μ ν →
      WitnessCoercivelyVisible V Γ g μ ν := by
  intro μ ν hw
  -- Use mismatchAt_nonzero_of_witness
  have h1 : cliffordMismatchAt V Γ g μ ν ≠ 0 := ...
  -- Use spectral_gap_of_mismatch
  have h2 : ∃ c > 0, ∀ x, ‖cliffordMismatchAt V Γ g μ ν x‖ ≥ c · ‖x‖ := ...
  -- Use anomaly_norm_bounds_mismatch
  have h3 : ∀ f, ‖anomaly μ ν f‖ ≥ κ · ‖cliffordMismatchAt V Γ g μ ν f‖ := ...
  -- Combine: compose h2 and h3
  exact WitnessCoercivelyVisible.of_bounds h2 h3
```

---

## Dependencies & Imports

### Required (Already Present)
- `Coh.Kinematics.T3_Clifford` — Clifford definition and basic soundness
- `Coh.Kinematics.T3_CoerciveVisibility` — Anomaly and visibility definitions
- `Coh.Kinematics.T3_Necessity` — Composition lemmas

### May Need (Extend if Missing)
- **Spectral theory**: Eigenvalue bounds, spectral gaps
- **Operator norm inequalities**: `‖A ∘ B‖ ≤ ‖A‖ · ‖B‖`
- **Finset manipulation**: Summation over frequency pairs

---

## Estimated Sub-tasks

| Task | Lines | Complexity | Notes |
|------|-------|-----------|-------|
| `mismatchAt_nonzero_of_witness` | 10–15 | Low | Straightforward contrapositive |
| `spectral_gap_of_mismatch` | 20–30 | Medium | Operator-theoretic |
| `anomaly_norm_bounds_mismatch` | 25–35 | Medium | Frequency-pairing analysis |
| `mismatch_amplified_by_witness` | 15–20 | Medium | Summation & inequality chains |
| `AllMismatchWitnessesVisible` | 10–15 | Low | Composition of above |
| **Total** | **80–115** | — | Estimate for complete bridge |

---

## Proof Tactics Anticipated

- `nlinarith` — Nonlinear arithmetic
- `simp` / `simp_all` — Simplification with lemma databases
- `norm_num` — Numeric computation
- `linarith` — Linear arithmetic
- `omega` — Finite arithmetic (if applicable)
- `constructor` / `intro` — Logical structure
- `exact` / `refine` — Direct application
- Custom lemmas on operator norms and summation

---

## Success Criteria

1. **Syntax**: All code parses in Lean 4 without errors
2. **Types**: All terms have correct types (no unsolved metavariables)
3. **Proofs**: All `theorem` statements are discharged (no `sorry` or `admit`)
4. **Compilation**: `lake build` returns exit code 0
5. **Documentation**: Each lemma has a docstring explaining its role

---

## Phase 1 Completion Checklist

- [ ] Define `mismatchAt_nonzero_of_witness` and prove
- [ ] Define `spectral_gap_of_mismatch` and prove
- [ ] Define `anomaly_norm_bounds_mismatch` and prove
- [ ] Define `mismatch_amplified_by_witness` and prove
- [ ] Define `AllMismatchWitnessesVisible` and prove
- [ ] Update `Coh/Kinematics/T3_NonCliffordVisible.lean` with complete proofs
- [ ] Run `lake build` — verify zero errors
- [ ] Update MINERALIZATION_PLAN.md marking Phase 1 complete
- [ ] Document any helper lemmas added to T3_WitnessAmplification.lean

---

## Next Steps After Phase 1

Upon completion of Phase 1 (T3 Analytic Visibility Bridge):
- Move to **Phase 2: T5 Representation-Theoretic Bridge** (`FaithfulIrreducibleBridge`)
- Then **Phase 3: T6 Geometric Bridges** (`PersistenceForcesComplexLike` + `ComplexLikeCommutesBridge`)
- Finally **Capstone**: Prove `Dirac_Inevitable_Schema` in `Coh/Physics/DiracInevitable.lean`

---

## Key References

- **Measurement Theory**: `Coh/Kinematics/T3_CoerciveVisibility.lean` (anomaly definitions)
- **Clifford Algebra**: `Coh/Prelude.lean` (abstract Clifford structure)
- **Operator Bounds**: Mathlib `Analysis.NormedSpace.OperatorNorm`
- **Finset Summation**: Mathlib `Data.Finset.Basic`
