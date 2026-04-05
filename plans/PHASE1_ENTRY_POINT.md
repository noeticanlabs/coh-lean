# PHASE 1 ENTRY POINT

**Status**: Ready for implementation  
**Mode**: Code  
**Target File**: [`Coh/Kinematics/T3_NonCliffordVisible.lean`](../Coh/Kinematics/T3_NonCliffordVisible.lean)

---

## Quick Start

### What We're Proving

**Theorem**: `AllMismatchWitnessesVisible`

```lean
def AllMismatchWitnessesVisible (Γ : GammaFamily V) (g : Metric) : Prop :=
  ∀ μ ν : Idx,
    IsMismatchWitness V Γ g μ ν →
    WitnessCoercivelyVisible V Γ g μ ν
```

### Plain English

**"Every Clifford algebra mismatch is visible in the measurement anomaly."**

If two generators `γ_μ` and `γ_ν` fail to anticommute correctly (creating a mismatch), that failure must show up as a bounded-below deviation in the measured anomaly norm.

---

## 3-Step Implementation

### STEP 1: Mismatch → Nonzero
**Lemma**: `mismatchAt_nonzero_of_witness`

Prove that if `(μ, ν)` is a mismatch witness, the operator `cliffordMismatchAt V Γ g μ ν` is nonzero.

```lean
lemma mismatchAt_nonzero_of_witness 
    (μ ν : Idx) (hw : IsMismatchWitness V Γ g μ ν) :
    cliffordMismatchAt V Γ g μ ν ≠ 0 := by
  -- Contrapositive from definition of witness
  sorry
```

**Difficulty**: Easy–Medium  
**Key Tactic**: Contrapositive, `simp` with definitions

---

### STEP 2: Mismatch → Spectral Bound
**Lemma**: `spectral_gap_of_mismatch`

Prove that the nonzero mismatch operator has a minimum operator norm.

```lean
lemma spectral_gap_of_mismatch 
    (μ ν : Idx) (hw : IsMismatchWitness V Γ g μ ν) :
    ∃ c > 0, ∀ x : V, 
      ‖cliffordMismatchAt V Γ g μ ν x‖ ≥ c · ‖x‖ := by
  -- Extract constant from witness property
  -- Use operator norm definitions
  sorry
```

**Difficulty**: Medium  
**Key Tactics**: Operator norm inequalities, `nlinarith`

---

### STEP 3: Mismatch → Anomaly Growth
**Lemma**: `anomaly_norm_bounds_mismatch`

Prove that the anomaly norm is bounded below by the mismatch norm.

```lean
lemma anomaly_norm_bounds_mismatch 
    (μ ν : Idx) (f : V) :
    ‖anomaly_μν V Γ g f‖ ≥ κ · ‖cliffordMismatchAt V Γ g μ ν f‖ := by
  -- Unfold anomaly definition
  -- Use frequency pairing (pairSpike) structure
  -- Summation and norm inequalities
  sorry
```

**Difficulty**: Medium–Hard  
**Key Tactics**: Finset summation, Cauchy–Schwarz, frequency analysis

---

### STEP 4: Compose All Three
**Main Theorem**: `AllMismatchWitnessesVisible`

```lean
theorem AllMismatchWitnessesVisible (Γ : GammaFamily V) (g : Metric) :
    ∀ μ ν : Idx,
      IsMismatchWitness V Γ g μ ν →
      WitnessCoercivelyVisible V Γ g μ ν := by
  intro μ ν hw
  -- Use Step 1 result
  have h1 := mismatchAt_nonzero_of_witness μ ν hw
  -- Use Step 2 result
  have h2 := spectral_gap_of_mismatch μ ν hw
  -- Use Step 3 result
  have h3 := anomaly_norm_bounds_mismatch μ ν
  -- Combine: h1 + h2 + h3 ⟹ WitnessCoercivelyVisible
  exact WitnessCoercivelyVisible.mk h1 h2 h3
```

**Difficulty**: Easy (composition)  
**Key Tactic**: `exact`, constructor application

---

## Implementation Checklist

- [ ] **Lemma 1**: `mismatchAt_nonzero_of_witness` (~10–15 lines)
- [ ] **Lemma 2**: `spectral_gap_of_mismatch` (~20–30 lines)
- [ ] **Lemma 3**: `anomaly_norm_bounds_mismatch` (~25–35 lines)
- [ ] **Main Theorem**: `AllMismatchWitnessesVisible` (~10–15 lines)
- [ ] **Testing**: Run `lake build` → verify zero errors
- [ ] **Documentation**: Docstrings on all lemmas

---

## Key Files & Dependencies

### Read First (for context)
- [`Coh/Kinematics/T3_CoerciveVisibility.lean`](../Coh/Kinematics/T3_CoerciveVisibility.lean) — Anomaly, visibility, witness definitions
- [`Coh/Kinematics/T3_Clifford.lean`](../Coh/Kinematics/T3_Clifford.lean) — Clifford soundness background
- [`Coh/Kinematics/T3_WitnessAmplification.lean`](../Coh/Kinematics/T3_WitnessAmplification.lean) — Frequency family, mismatch structures

### Modify
- [`Coh/Kinematics/T3_NonCliffordVisible.lean`](../Coh/Kinematics/T3_NonCliffordVisible.lean) — Target file (add lemmas 1–3, replace `sorry` in main theorem)

### New Imports (if needed)
- `Mathlib.Analysis.NormedSpace.OperatorNorm` — Operator norm definitions
- `Mathlib.Data.Finset.Basic` — Finset summation lemmas

---

## Proof Tactics Quick Reference

| Tactic | Use Case | Example |
|--------|----------|---------|
| `contrapose` | Proof by contrapositive | Nonzero property |
| `simp` | Simplify with lemma database | Unfold definitions |
| `nlinarith` | Nonlinear arithmetic | Cost/norm bounds |
| `norm_num` | Numeric computation | Constants |
| `ring` | Ring identities | Algebraic manipulation |
| `exact` | Direct term application | Composition |
| `intro` / `intros` | Introduce assumptions | Universal quantifiers |
| `unfold` | Expand definition | Anomaly, witness |

---

## Common Pitfalls to Avoid

1. **Forgetting absolute values**: Norms are always non-negative; check direction of inequalities
2. **Mixing operator vs. element norms**: `‖A‖_op` vs. `‖x‖`; be explicit about which is which
3. **Finset iteration**: When summing over frequencies, carefully track bounds
4. **Metric signature**: Confirm `g` is being used consistently (non-degenerate, compatible with Clifford)

---

## Success Criteria

✅ **Exit Criteria** (must all pass):

1. **Syntax**: No parse errors in `T3_NonCliffordVisible.lean`
2. **Types**: All terms are well-typed (no unsolved metavariables)
3. **Completeness**: Zero `sorry` or `admit` in the four lemmas + theorem
4. **Compilation**: `lake build` exits with code 0
5. **No Regressions**: All existing T3 tests/examples still pass

---

## Estimated Timeline

| Task | Est. Lines | Est. Time | Difficulty |
|------|-----------|-----------|------------|
| Lemma 1 (nonzero) | 10–15 | 5 min | Easy |
| Lemma 2 (spectral) | 20–30 | 15 min | Medium |
| Lemma 3 (anomaly) | 25–35 | 25 min | Medium–Hard |
| Main theorem | 10–15 | 5 min | Easy |
| **Total** | **65–95** | **50 min** | — |

---

## After Phase 1 Completes

Once Phase 1 is done:
1. ✅ Update [`plans/MINERALIZATION_PLAN.md`](MINERALIZATION_PLAN.md): Mark T3 bridge as complete
2. ✅ Create [`plans/PHASE2_T5_BRIDGE_PLAN.md`](PHASE2_T5_BRIDGE_PLAN.md) for representation-theoretic minimality
3. ✅ Move to **Phase 2: T5 Representation Bridge** (`FaithfulIrreducibleBridge`)

---

## Ready to Implement?

✅ All planning complete  
✅ All dependencies available  
✅ All reference materials prepared  
✅ Go to Code mode and implement the four lemmas + main theorem

**Start with Lemma 1** (`mismatchAt_nonzero_of_witness`) — it's the simplest and builds confidence.

---

**Good luck! 🚀**
