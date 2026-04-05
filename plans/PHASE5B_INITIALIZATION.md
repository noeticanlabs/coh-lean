# Phase 5b Initialization: Defect Accumulation & Stability

**Date**: 2026-04-05  
**Status**: Phase 5b NOW OPEN - T7 complete, defect accumulation scaffolding in place  
**Mission**: Prove that accumulated violations have minimum cost (prerequisite for T8)  

---

## What Phase 5b Accomplishes

T7 proved that **at any single frequency, violations have minimum strength**: c₀·‖f‖² ≤ A(f).

Phase 5b proves that this local bound **accumulates along paths**: if a system evolves through frequency space, its total Clifford violation cost is bounded below by the integral of c₀·‖f(t)‖².

This prevents sneaky paths that "cancel out" violations or hide them through clever evolution.

---

## Files In Place

### Core (T7 Complete)
- ✅ `Coh/Spectral/CompactnessProof.lean` - T7 main theorem
- ✅ `Coh/Spectral/AnomalyStrength.lean` - Anomaly definitions  
- ✅ `Coh/Spectral/VisibilityGap.lean` - T7 statement & corollaries

### Phase 5b Scaffolding
- 🔨 `Coh/Spectral/DefectAccumulation.lean` (175 lines)
  - `defectAccumulation : FrequencyPath → ℝ → ℝ → ℝ` - integral of anomaly
  - `defectAccumulation_lower_bound` - Spectral gap accumulates (skeleton)
  - `defectAccumulation_nontrivial` - Nonzero paths have positive defect (skeleton)
  - `no_defect_evasion` - Can't hide violations through evolution (statement)

### Supporting (Examples & Verification)
- ✅ `Coh/Spectral/GapVerification.lean` - Concrete Euclidean/Minkowski metrics

---

## Phase 5b Roadmap

### Step 1: Complete Defect Accumulation Proofs (2-3 hours)
**Current State**: Theorems stated, core structure in place, 2 main `sorry` gaps

**Gap 1**: Integration of pointwise inequality
```lean
have h_pointwise : ∀ᵐ t ∂volume, t ∈ Set.Icc a b →
  c₀ * (‖γ t‖ : ℝ) ^ 2 ≤ ‖anomaly V Γ g (γ t)‖

-- Need: integral_mono_ae application
-- Then: c₀ * ∫ ‖γ t‖² dt ≤ ∫ A(γ t)) dt
```

**Gap 2**: Positive path constraint (defectAccumulation_nontrivial)
```lean
(h_nonzero : ∀ t ∈ Set.Icc a b, γ t ≠ fun _ => 0)
-- Need: Show ∫ ‖γ(t)‖² dt > 0 when γ stays nonzero
-- Then: 0 < defectAccumulation
```

**Mathlib needed**: `integral_mono_ae`, integrability bounds, integral positivity

### Step 2: Extend to Stability Paths (1-2 hours)
**Goal**: Define stabilizing paths (those that increase gauge stability)

```lean
-- New definitions needed
def IsStabilizingPath (γ : FrequencyPath) : Prop := ...
def stabilityGain (γ : FrequencyPath) (a b : ℝ) : ℝ := ...

-- New theorem
theorem stabilizing_paths_have_bounded_defect :
  ∀ γ, IsStabilizingPath γ → 
    stabilityGain γ a b ≥ (minimum_defect_gain γ a b)
```

### Step 3: Bridge to T8 (1 hour)
**Goal**: Connect defect accumulation to stability-adjusted cost

```lean
-- T8 preview
def cost_minus_stability (V : Type*) (γ : GammaFamily V) : ℝ :=
  (metabolic_cost : ℝ) - (stability_benefit : ℝ)

theorem T8_stability_minimizes :
  ∀ V : Carrier,
    Clifford_complete V →  -- From T3
    thermodynamic_minimal V →  -- From T5  
    geometrically_complex V →  -- From T6
    has_spectral_gap V →  -- From T7
    accumulated_defect_sufficient V →  -- From Phase 5b
    minimal_cost_is_dirac_spinor V
```

---

## Integration with T8 (Phase 5-6)

**T8: Stability-Adjusted Minimality**

Current landscape:
- T3: Clifford necessity
- T5: Thermodynamic minimality  
- T6: Geometric complexity
- **T7**: Visibility spectral gap (✅ DONE)
- **Phase 5b**: Defect accumulation (🔨 IN PROGRESS)
- **T8**: Gauge structures survive because they reduce defect

The logic:
1. Non-Dirac carriers have defect D (from Phase 5b)
2. Adding gauge structure reduces defect cost by G (T8 to prove)
3. Cost = metabolic_cost - gauge_benefit ≥ Dirac_cost
4. Therefore Dirac is unique minimal (T8 conclusion)

---

## Technical Challenges & Solutions

### Challenge 1: Integrability of Anomaly Along Paths
**Problem**: Need to integrate anomalyStrength along continuous path γ  
**Solution**: Use continuity of γ + boundedness assumption in `IsAdmissiblePath`
```lean
def IsAdmissiblePath (γ : FrequencyPath) (a b : ℝ) : Prop :=
  ContinuousOn γ (Set.Icc a b) ∧ 
  BddOn (fun t ∈ Set.Icc a b => frequencyNorm V (γ t)) (Set.Icc a b)
```

### Challenge 2: Positivity of Integral When Path Stays Nonzero
**Problem**: ∀ t, γ t ≠ 0 ⟹ ∫ ‖γ t‖² dt > 0?  
**Solution**: 
- γ t ≠ 0 ⟹ ‖γ t‖ > 0 (norm positivity)
- ∃ δ > 0, ∀ t, ‖γ t‖ ≥ δ (uniform lower bound from compactness)
- ⟹ ∫ ‖γ t‖² dt ≥ ∫ δ² dt = δ² (b - a) > 0

### Challenge 3: Relating Defect to Stability Gain
**Problem**: How much stability must a gauge structure provide to justify its metabolic cost?  
**Solution**: T8 will formalize the **trade-off function**:
```lean
def stabilityRequired (metabolic_cost : ℝ) : ℝ :=
  function describing how much stability gain needed to offset cost
```

---

## Success Criteria for Phase 5b

- [ ] `defectAccumulation_lower_bound` fully proven (no `sorry`)
- [ ] `defectAccumulation_nontrivial` fully proven (no `sorry`)
- [ ] `no_defect_evasion` fully proven (no `sorry`)
- [ ] All supporting lemmas on integrability complete
- [ ] GapVerification.lean examples either proven or well-documented
- [ ] Clear transition path to T8 established
- [ ] Code compiles without import errors

**Estimated completion**: 4-6 hours

---

## Handoff to Phase 6 (T8 Stability)

When Phase 5b is complete, the next phase begins with:

**Key Assumption from Phase 5b**:
```
Accumulated Defect Bound:
  ∀ γ : FrequencyPath,
    defectAccumulation γ a b ≥ 
    ∫ t ∈ [a,b], c₀ · ‖γ(t)‖² dt
```

**T8 Problem**: Show that Dirac spinors minimize `cost - stability_benefit` subject to:
- Clifford necessity (T3)
- Thermodynamic minimality (T5)
- Geometric complexity (T6)
- Accumulated defect bound (T7 + Phase 5b)

**T8 Solution Strategy**:
1. Enumerate possible carrier structures
2. For each, compute defect and stability benefit
3. Show Dirac has unique optimum
4. Prove non-Dirac carriers have defect > cost reduction

---

## Code Architecture

```
Coh/Spectral/
├── AnomalyStrength.lean        (Core definitions)
├── VisibilityGap.lean           (T7 statements)
├── CompactnessProof.lean        (T7 proofs) ✅
├── GapVerification.lean         (Concrete examples)
├── DefectAccumulation.lean      (Phase 5b) 🔨
├── StabilityBenefit.lean        (Phase 6 prep) [TO CREATE]
└── T8_Stability.lean            (Phase 6) [TO CREATE]
```

---

## Phase 5b Entry Checklist

✅ T7 fully proven
✅ Defect accumulation file created with main theorems
✅ File structure and imports valid
✅ Concrete examples file created
⏳ Complete remaining proof gaps (START HERE)
⏳ Verify compilation
⏳ Document stability benefit definition
⏳ Create T8 preview

---

## Next Immediate Actions

**For Phase 5b Completion** (in order):

1. **Fix integral gaps** in `defectAccumulation_lower_bound`
   - Use `integral_mono_ae` from Mathlib.Integration
   - Establish integrability from continuity + boundedness

2. **Prove positivity lemma** for `defectAccumulation_nontrivial`
   - Show nonzero path ⟹ positive minimum distance from zero
   - Use uniform bound argument on compact interval

3. **Verify GapVerification examples** (or mark as conjectural)
   - Can leave as `sorry` with clear documentation
   - Will be solved in Phase 6 via explicit computation

4. **Compile and document**
   - Update plans/PROJECT_STATUS.md with Phase 5b completion
   - Create Phase 6 entry document with T8 specifications
   - List remaining `sorry` statements with justification

---

## Physics Summary

**T7** proved violations are locally detectable (spectral gap).  
**Phase 5b** proves violations are globally unavoidable (defect accumulates).  
**Together**: Carriers satisfying T3+T5+T6+T7 have no way to hide from the Clifford constraint—they are forced toward Dirac structure by the combination of:
- Algebraic necessity (T3)
- Thermodynamic pressure (T5)
- Geometric constraints (T6)
- Physical robustness (T7)

**T8** will prove that once forced here, Dirac is the unique minimum.

---

## Summary

Phase 5b opens the analysis of **evolutionary paths through frequency space**. By proving that accumulated defect has a lower bound, we ensure that no clever evolution can evade the Clifford constraint. This sets the stage for T8, which will prove that Dirac spinors are not just necessary (T3), minimal (T5-T6), and robust (T7)—they are the **unique equilibrium** when stability and cost are balanced.

**Status**: Ready to proceed. Start with integral gaps in DefectAccumulation.lean.
