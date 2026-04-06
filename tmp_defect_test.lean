import Coh.Spectral.CompactnessProof
import Mathlib.MeasureTheory.Integral.IntervalIntegral

noncomputable section

namespace Coh.Spectral

open Coh.Core
open MeasureTheory intervalIntegral

variable {V : Type*} [CarrierSpace V] [FiniteDimensional ℝ (Idx → ℝ)]
variable (Γ : GammaFamily V) (g : Metric)

def FrequencyPath := ℝ → (Idx → ℝ)

def IsAdmissiblePath (γ : FrequencyPath) (a b : ℝ) : Prop :=
  ContinuousOn γ (Set.Icc a b)

-- Real definition: Integral of anomalyStrength along path
def defectAccumulation (γ : FrequencyPath) (a b : ℝ) : ℝ :=
  ∫ t in a..b, anomalyStrength Γ g (γ t)

-- Helper: anomalyStrength ∘ path is continuous on Icc 
lemma anomalyStrength_cont_on
    (γ : FrequencyPath) (a b : ℝ) (hadm : IsAdmissiblePath γ a b) :
    ContinuousOn (fun t => anomalyStrength Γ g (γ t)) (Set.Icc a b) :=
  (anomalyStrength_continuous Γ g).comp_continuousOn hadm

-- Helper: anomalyStrength ∘ path is integrable on [a,b] (with a ≤ b)
lemma anomalyStrength_integrable
    (γ : FrequencyPath) (a b : ℝ) (ha : a ≤ b) (hadm : IsAdmissiblePath γ a b) :
    IntervalIntegrable (fun t => anomalyStrength Γ g (γ t)) MeasureTheory.volume a b := by
  apply ContinuousOn.intervalIntegrable
  rw [Set.uIcc_of_le ha]
  exact anomalyStrength_cont_on Γ g γ a b hadm

-- freqNorm^2 ∘ path is integrable (no Γ g needed, only continuity of path)
lemma freqNormSq_integrable
    (γ : FrequencyPath) (a b : ℝ) (ha : a ≤ b) (hadm : IsAdmissiblePath γ a b) :
    IntervalIntegrable (fun t => (frequencyNorm (γ t))^2) MeasureTheory.volume a b := by
  apply ContinuousOn.intervalIntegrable
  rw [Set.uIcc_of_le ha]
  apply ContinuousOn.pow
  exact continuous_norm.comp_continuousOn hadm

-- Helper: zero frequency has zero anomaly strength  
lemma anomalyStrength_zero_at_zero : anomalyStrength Γ g (fun _ => 0) = 0 := by
  simp [anomalyStrength, anomaly]

-- Helper: anomalyStrength is nonneg
lemma anomalyStrength_nonneg' (f : Idx → ℝ) : 0 ≤ anomalyStrength Γ g f := norm_nonneg _

-- Lower bound theorem: T7 quadratic gap integrates along any admissible path
theorem defectAccumulation_lower_bound
    (γ : FrequencyPath) (a b : ℝ) (ha : a ≤ b) (hadm : IsAdmissiblePath γ a b) :
    ∃ c₀ > 0, c₀ * ∫ t in a..b, (frequencyNorm (γ t))^2 ≤ defectAccumulation Γ g γ a b := by
  obtain ⟨c₀, hc₀_pos, hc₀_gap⟩ := T7_Quadratic_Spectral_Gap Γ g
  use c₀, hc₀_pos
  unfold defectAccumulation
  rw [← intervalIntegral.integral_const_mul]
  apply intervalIntegral.integral_mono_on ha
      ((freqNormSq_integrable γ a b ha hadm).const_mul c₀)
      (anomalyStrength_integrable Γ g γ a b ha hadm)
  intro t ht
  by_cases h_zero : γ t = fun _ => 0
  · -- zero case: frequencyNorm 0 = 0, so c₀ * 0² = 0 ≤ anomalyStrength ≥ 0
    have hfn0 : frequencyNorm (γ t) = 0 := by
      rw [frequencyNorm, h_zero]; simp [Pi.zero_def]
    rw [hfn0]
    ring_nf
    exact anomalyStrength_nonneg' Γ g _
  · linarith [hc₀_gap (γ t) h_zero]

-- Nontrivial: any path touching a nonzero point accumulates positive defect
theorem defectAccumulation_nontrivial
    (γ : FrequencyPath) (a b : ℝ) (ha : a < b) (hadm : IsAdmissiblePath γ a b)
    (h_nonzero : ∃ t ∈ Set.Icc a b, γ t ≠ fun _ => 0) :
    0 < defectAccumulation Γ g γ a b := by
  unfold defectAccumulation
  obtain ⟨t₀, ht₀, hne⟩ := h_nonzero
  have h_pos_t₀ : 0 < anomalyStrength Γ g (γ t₀) := by
    obtain ⟨c₀, hc₀_pos, hc₀_gap⟩ := T7_Quadratic_Spectral_Gap Γ g
    have hfn_pos : 0 < frequencyNorm (γ t₀) := (frequencyNorm_pos_iff (γ t₀)).2 hne
    linarith [hc₀_gap (γ t₀) hne, mul_pos hc₀_pos (pow_pos hfn_pos 2)]
  exact intervalIntegral.integral_pos ha
      (anomalyStrength_cont_on Γ g γ a b hadm)
      (fun x hx => anomalyStrength_nonneg' Γ g (γ x))
      ⟨t₀, ht₀, h_pos_t₀⟩

-- No-evasion: any path is either entirely zero or accumulates strictly positive defect
theorem no_defect_evasion
    (γ : FrequencyPath) (a b : ℝ) (ha : a < b) (hadm : IsAdmissiblePath γ a b) :
    (∀ t ∈ Set.Icc a b, γ t = fun _ => 0) ∨ 0 < defectAccumulation Γ g γ a b := by
  by_cases h : ∀ t ∈ Set.Icc a b, γ t = fun _ => 0
  · exact Or.inl h
  · push_neg at h
    obtain ⟨t, ht, hne⟩ := h
    exact Or.inr (defectAccumulation_nontrivial Γ g γ a b ha hadm ⟨t, ht, hne⟩)

end Coh.Spectral
