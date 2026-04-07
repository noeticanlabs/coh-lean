import Coh.Core.Clifford
import Coh.Spectral.AnomalyStrength
import Coh.Spectral.NormEquivalence

noncomputable section

namespace Coh.Kinematics

open Coh Coh.Core
open scoped BigOperators Real

variable {V : Type*} [CarrierSpace V]

--------------------------------------------------------------------------------
-- Canonical coordinate frequency families
--------------------------------------------------------------------------------

/--
A one-axis frequency spike at coordinate `μ` with amplitude `R`.
-/
def axisSpike (μ : Idx) (R : ℝ) : Idx → ℝ :=
  fun i => if i = μ then R else 0

/--
A two-axis frequency packet supported on `(μ, ν)` with common amplitude `R`.
-/
def pairSpike (μ ν : Idx) (R : ℝ) : Idx → ℝ :=
  fun i => if i = μ then R else if i = ν then R else 0

lemma axisSpike_at_ref
    (μ : Idx) (R : ℝ) :
    axisSpike μ R μ = R := by
  simp [axisSpike]

lemma axisSpike_off_ref
    (μ i : Idx) (R : ℝ) (h : i ≠ μ) :
    axisSpike μ R i = 0 := by
  simp [axisSpike, h]

lemma pairSpike_left_ref
    (μ ν : Idx) (R : ℝ) :
    pairSpike μ ν R μ = R := by
  by_cases h : μ = ν
  · simp [pairSpike, h]
  · simp [pairSpike, h]

lemma pairSpike_right_ref
    (μ ν : Idx) (R : ℝ)
    (h : ν ≠ μ) :
    pairSpike μ ν R ν = R := by
  simp [pairSpike, h, eq_comm]

-- Locally define freqNorm to avoid dependency issues
abbrev freqNorm (f : Idx → ℝ) : ℝ := frequencyNorm f

/--
At amplitude `R`, the frequency norm of the pair spike is at least `|R|`.
-/
lemma norm_pairSpike_lower_ref
    (μ ν : Idx) (R : ℝ) :
    |R| ≤ freqNorm (pairSpike μ ν R) := by
  unfold freqNorm frequencyNorm
  calc
    |R| = ‖pairSpike μ ν R μ‖ := by rw [pairSpike_left_ref, Real.norm_eq_abs]
    _ ≤ ‖pairSpike μ ν R‖ := norm_le_pi_norm (pairSpike μ ν R) μ

/--
At amplitude `R`, the frequency norm of the axis spike is at least `|R|`.
-/
lemma norm_axisSpike_lower_ref
    (μ : Idx) (R : ℝ) :
    |R| ≤ freqNorm (axisSpike μ R) := by
  unfold freqNorm frequencyNorm
  calc
    |R| = ‖axisSpike μ R μ‖ := by rw [axisSpike_at_ref, Real.norm_eq_abs]
    _   ≤ ‖axisSpike μ R‖   := norm_le_pi_norm (axisSpike μ R) μ

--------------------------------------------------------------------------------
-- Witness-targeted anomaly visibility interface
--------------------------------------------------------------------------------

/--
A witness pair `(μ, ν)` is coercively visible if its associated mismatch can be
amplified along a designated frequency family to produce quadratic anomaly growth.
-/
def WitnessCoercivelyVisible
    (Γ : GammaFamily V)
    (g : Metric)
    (μ ν : Idx) : Prop :=
  ∃ c : ℝ, 0 < c ∧ ∀ R : ℝ, 0 < R →
    c * (freqNorm (pairSpike μ ν R))^2 ≤ ‖anomaly Γ g (pairSpike μ ν R)‖

/--
Global witness visibility: every mismatch witness is coercively visible.
-/
def AllMismatchWitnessesVisible
    (Γ : GammaFamily V)
    (g : Metric) : Prop :=
  ∀ μ ν : Idx,
    IsMismatchWitness Γ g μ ν →
    WitnessCoercivelyVisible Γ g μ ν

/--
Quadratic anomaly visibility: there exist arbitrarily large frequency vectors
with significant observable anomaly.
-/
def QuadraticAnomalyVisible
    (Γ : GammaFamily V)
    (g : Metric) : Prop :=
  ∃ c : ℝ, 0 < c ∧ ∀ S : ℝ, ∃ f : Idx → ℝ, S ≤ freqNorm f ∧
    c * (freqNorm f)^2 ≤ ‖anomaly Γ g f‖

end Coh.Kinematics
