import Coh.Spectral.CompactnessProof
import Mathlib.Analysis.Calculus.Integral.Basic
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.MeasureTheory.Integral.SetIntegral
import Mathlib.MeasureTheory.Measure.Typeclasses
import Mathlib.Topology.Algebra.ContinuousMonoid

noncomputable section

namespace Coh.Spectral

open Coh.Core MeasureTheory

variable {V : Type*} [CarrierSpace V]
variable (Γ : GammaFamily V) (g : Metric)

--------------------------------------------------------------------------------
-- Phase 5b: Defect Accumulation
--
-- T7 established that violations have minimum strength at each frequency.
-- Phase 5b establishes that accumulated violations along a path also have
-- minimum cost, preventing "sneaky" ways to evade the spectral gap.
--------------------------------------------------------------------------------

/--
A frequency path is a continuous function from [a,b] to frequency space.
This represents how a system "moves" through frequency configurations over time.
-/
def FrequencyPath := ℝ → (Idx → ℝ)

/--
A frequency path is admissible if it is continuous and bounded.
-/
def IsAdmissiblePath (γ : FrequencyPath) (a b : ℝ) : Prop :=
  ContinuousOn γ (Set.Icc a b) ∧ BddOn (fun t ∈ Set.Icc a b => frequencyNorm (γ t)) (Set.Icc a b)

/--
The defect accumulation along a path is the integral of anomaly strength.
-/
def defectAccumulation (γ : FrequencyPath) (a b : ℝ) : ℝ :=
  ∫ t in Set.Icc a b, anomalyStrength Γ g (γ t) ∂volume

/--
Key property: Accumulated defect respects the spectral gap.
-/
theorem defectAccumulation_lower_bound
    (γ : FrequencyPath) (a b : ℝ) (ha : a ≤ b) (hadm : IsAdmissiblePath Γ g γ a b) :
    ∃ c₀ > 0,
      c₀ * ∫ t in Set.Icc a b, (frequencyNorm (γ t)) ^ 2 ∂volume ≤
      defectAccumulation Γ g γ a b := by
  obtain ⟨c₀, hc₀_pos, hc₀_gap⟩ := T7_Quadratic_Spectral_Gap Γ g
  use c₀, hc₀_pos
  unfold defectAccumulation
  
  have h_int_anomaly : IntegrableOn (fun t => anomalyStrength Γ g (γ t)) (Set.Icc a b) := by
    apply ContinuousOn.integrableOn_Icc
    apply (anomalyStrength_continuous Γ g).comp_continuousOn hadm.1

  have h_int_norm_sq : IntegrableOn (fun t => (frequencyNorm (γ t)) ^ 2) (Set.Icc a b) := by
    apply ContinuousOn.integrableOn_Icc
    apply ContinuousOn.pow
    apply (continuous_norm.comp_continuousOn hadm.1); exact 2

  rw [← set_integral_mul_left]
  apply set_integral_mono_ae (h_int_norm_sq.mul_left c₀) h_int_anomaly
  
  filter_upwards [ae_restrict_mem_Icc ha] with t ht
  by_cases hn : γ t = fun _ => 0
  · simp [hn, anomalyStrength_zero]
  · exact hc₀_gap (γ t) hn

/--
Corollary: Any nontrivial path accumulates nonzero defect.
-/
theorem defectAccumulation_nontrivial
    (γ : FrequencyPath) (a b : ℝ) (ha : a < b) (hadm : IsAdmissiblePath Γ g γ a b)
    (h_nonzero : ∃ t ∈ Set.Icc a b, γ t ≠ fun _ => 0) :
    0 < defectAccumulation Γ g γ a b := by
  obtain ⟨c₀, hc₀_pos, h_bound⟩ := defectAccumulation_lower_bound Γ g γ a b (le_of_lt ha) hadm
  
  have h_int_pos : 0 < ∫ t in Set.Icc a b, (frequencyNorm (γ t)) ^ 2 ∂volume := by
    apply set_integral_pos_of_continuous_nonnegative_nonzero
    · exact (measure_Icc_pos.mpr ha)
    · apply ContinuousOn.pow
      apply (continuous_norm.comp_continuousOn hadm.1); exact 2
    · intro t ht; exact sq_nonneg _
    · obtain ⟨t, ht_mem, ht_nz⟩ := h_nonzero
      use t, ht_mem
      have h_norm_nz : frequencyNorm (γ t) ≠ 0 := by
        intro h
        apply ht_nz
        ext i
        have : |γ t i| ≤ frequencyNorm (γ t) := abs_le_norm _
        rw [h] at this
        exact abs_nonpos_iff.mp this
      apply pow_pos (lt_of_le_of_ne (norm_nonneg _) h_norm_nz.symm) 2

  exact mul_pos hc₀_pos h_int_pos

/--
Consequence for stability analysis:
"A nontrivial path through the anomaly landscape always accumulates 
strictly positive defect."
-/
theorem no_defect_evasion
    (γ : FrequencyPath) (a b : ℝ) (ha : a < b) (hadm : IsAdmissiblePath Γ g γ a b) :
    (∀ t ∈ Set.Icc a b, γ t = fun _ => 0) ∨ 0 < defectAccumulation Γ g γ a b := by
  by_cases h : ∀ t ∈ Set.Icc a b, γ t = fun _ => 0
  · exact Or.inl h
  · push_neg at h
    exact Or.inr (defectAccumulation_nontrivial Γ g γ a b ha hadm h)

end Coh.Spectral
