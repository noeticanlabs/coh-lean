import Coh.Prelude
import Coh.Core.Clifford
import Mathlib.Analysis.NormedSpace.OperatorNorm.Basic

namespace Coh.Core

open Coh

variable (V : Type*) [CarrierSpace V]

/-- Subquadratic defect bound: anomaly grows slower than quadratic in frequency norm. -/
def SubquadraticDefectBound (Δ : (Idx → ℝ) → ℝ) : Prop :=
  ∀ ε : ℝ, 0 < ε → ∃ S : ℝ, ∀ f : Idx → ℝ, S ≤ freqNorm f →
    Δ f ≤ ε * (freqNorm f)^2

/-- Coercively Oplax Sound: anomaly norm bounded by defect function. -/
def CoercivelyOplaxSound
    (Γ : GammaFamily V) (g : Metric) (Δ : (Idx → ℝ) → ℝ) : Prop :=
  ∀ f : Idx → ℝ, ‖anomaly V Γ g f‖ ≤ Δ f

/-- Quadratic anomaly visibility: anomaly norm has quadratic lower bound at large frequencies. -/
def QuadraticAnomalyVisible
    (Γ : GammaFamily V) (g : Metric) : Prop :=
  ∃ c : ℝ, 0 < c ∧ ∀ S : ℝ, ∃ f : Idx → ℝ, S ≤ freqNorm f ∧
    c * (freqNorm f)^2 ≤ ‖anomaly V Γ g f‖

/-- Core contradiction lemma: visible quadratic anomaly contradicts subquadratic defect + soundness. -/
theorem anomaly_contradicts_subquadratic_defect
    (Γ : GammaFamily V) (g : Metric) (Δ : (Idx → ℝ) → ℝ)
    (hVis : QuadraticAnomalyVisible V Γ g)
    (hSub : SubquadraticDefectBound Δ)
    (hSound : CoercivelyOplaxSound V Γ g Δ) :
    False := by
  rcases hVis with ⟨c, hc_pos, hVis⟩
  rcases hSub (c / 2) (by positivity) with ⟨S₁, hSubS⟩
  let S₂ := max S₁ 1
  rcases hVis S₂ with ⟨f, hfS, hf_low⟩
  have hf_norm_pos : 0 < freqNorm f := by
    have : 1 ≤ S₂ := le_max_right S₁ 1
    exact lt_of_lt_of_le (by norm_num) (le_trans this hfS)
  have hAnom := hSound f
  have hfS₁ : S₁ ≤ freqNorm f := le_trans (le_max_left S₁ 1) hfS
  have hSubf := hSubS f hfS₁
  have hContra : c * (freqNorm f)^2 ≤ (c / 2) * (freqNorm f)^2 :=
    le_trans hf_low (le_trans hAnom hSubf)
  have hf_sq_pos : 0 < (freqNorm f)^2 := pow_pos hf_norm_pos 2
  have : c ≤ c / 2 := (mul_le_mul_right hf_sq_pos).mp hContra
  linarith

/-- Coercive visibility predicate for a specific mismatch witness pair. -/
def WitnessCoercivelyVisible (Γ : GammaFamily V) (g : Metric) (μ ν : Idx) : Prop :=
  ∃ c : ℝ, 0 < c ∧ ∀ R : ℝ, 0 < R →
    c * (freqNorm (pairSpike μ ν R))^2 ≤ ‖anomaly V Γ g (pairSpike μ ν R)‖

where
  pairSpike (μ ν : Idx) (R : ℝ) : Idx → ℝ :=
    fun i => if i = μ then R else if i = ν then R else 0

/-- Helper: all mismatch witnesses are coercively visible. -/
def AllMismatchWitnessesVisible (Γ : GammaFamily V) (g : Metric) : Prop :=
  ∀ μ ν : Idx,
    IsMismatchWitness V Γ g μ ν →
    WitnessCoercivelyVisible V Γ g μ ν

/-- Core bridge: non-Clifford implies visible quadratic anomaly. -/
def NonCliffordVisibilityBridge (Γ : GammaFamily V) (g : Metric) : Prop :=
  ¬ IsClifford V Γ g → QuadraticAnomalyVisible V Γ g

end Coh.Core
