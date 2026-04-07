import Coh.Prelude
import Coh.Spectral.CompactnessProof
import Mathlib.MeasureTheory.Integral.IntervalIntegral

noncomputable section

namespace Coh.Spectral

open Coh.Core
open MeasureTheory intervalIntegral

variable {V : Type*} [CarrierSpace V] [FiniteDimensional ℝ (Idx → ℝ)]
variable (Γ : GammaFamily V) (g : Metric)

/--
A frequency path is a continuous function from [a,b] to frequency space.
-/
def FrequencyPath := ℝ → (Idx → ℝ)

/--
The defect accumulation along a path is the integral of anomaly strength.
-/
def defectAccumulation (γ : FrequencyPath) (a b : ℝ) : ℝ :=
  ∫ t in a..b, anomalyStrength Γ g (γ t)

/--
Key property: Accumulated defect respects the spectral gap.
- Updated to follow the new machine-verified T7_Quadratic_Spectral_Gap.
- Replaces the rcases failure on the old rigidity axiom.
-/
theorem defectAccumulation_lower_bound
    (hRigid : HasCliffordRigidity Γ g)
    (γ : FrequencyPath) (a b : ℝ) (ha : a ≤ b) 
    (hadm : ContinuousOn γ (Set.Icc a b)) :
    ∃ c₀ > 0, c₀ * ∫ t in a..b, (frequencyNorm (γ t))^2 ≤ defectAccumulation Γ g γ a b := by
  obtain ⟨c₀, hc₀_pos, hc₀_gap⟩ := T7_Quadratic_Spectral_Gap Γ g hRigid
  use c₀, hc₀_pos
  unfold defectAccumulation
  rw [← intervalIntegral.integral_const_mul]
  apply intervalIntegral.integral_mono_on ha
  · -- Const mul integrable
    apply (ContinuousOn.intervalIntegrable _ (Set.uIcc_of_le ha)).const_mul c₀
    exact (continuous_norm.comp_continuousOn hadm).pow 2
  · -- Anomaly integrable
    apply (anomalyStrength_continuous Γ g).comp_continuousOn hadm |>.intervalIntegrable (Set.uIcc_of_le ha)
  · intro t ht
    by_cases h_zero : γ t = fun _ => 0
    · simp [h_zero, Pi.zero_def]
      exact anomalyStrength_nonneg Γ g _
    · linarith [hc₀_gap (γ t) h_zero]

/--
Corollary: Any nontrivial path accumulates nonzero defect.
-/
theorem defectAccumulation_nontrivial
    (hRigid : HasCliffordRigidity Γ g)
    (γ : FrequencyPath) (a b : ℝ) (ha : a < b) 
    (hadm : ContinuousOn γ (Set.Icc a b))
    (h_nonzero : ∃ t ∈ Set.Icc a b, γ t ≠ fun _ => 0) :
    0 < defectAccumulation Γ g γ a b := by
  obtain ⟨c₀, hc₀_pos, hc₀_gap⟩ := T7_Quadratic_Spectral_Gap Γ g hRigid
  obtain ⟨t₀, ht₀, hne⟩ := h_nonzero
  apply intervalIntegral.integral_pos ha
  · exact (anomalyStrength_continuous Γ g).comp_continuousOn hadm
  · intro x _; exact anomalyStrength_nonneg Γ g (γ x)
  · use t₀, ht₀
    have hfn_pos : 0 < frequencyNorm (γ t₀) := (frequencyNorm_pos_iff (γ t₀)).2 hne
    linarith [hc₀_gap (γ t₀) hne, mul_pos hc₀_pos (pow_pos hfn_pos 2)]

end Coh.Spectral
