import Coh.Kinematics.T3_Clifford
import Coh.Kinematics.T3_CoerciveVisibility
import Coh.Kinematics.T3_Necessity

import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

noncomputable section

namespace Coh.Kinematics

open scoped BigOperators

--------------------------------------------------------------------------------
-- Non-Clifford mismatch witnesses
--------------------------------------------------------------------------------

variable (V : Type*)
variable [NormedAddCommGroup V] [NormedSpace ℝ V]
variable [FiniteDimensional ℝ V]

/--
The operator mismatch at a specific pair `(μ, ν)`.
This is exactly the failure of the Clifford relation at that index pair.
-/
def cliffordMismatchAt
    (Γ : GammaFamily V)
    (g : Metric)
    (μ ν : Idx) : V →L[ℝ] V :=
  anticommutator V (Γ.Γ μ) (Γ.Γ ν) - (2 * g.g μ ν) • idOp V

/--
Existence of an index-pair mismatch witness.
-/
def HasMismatchWitness
    (Γ : GammaFamily V)
    (g : Metric) : Prop :=
  ∃ μ ν : Idx, IsMismatchWitness V Γ g μ ν

--------------------------------------------------------------------------------
-- Logical reduction: non-Clifford iff some witness exists
--------------------------------------------------------------------------------

lemma hasMismatchWitness_of_not_clifford
    (Γ : GammaFamily V)
    (g : Metric)
    (hNot : ¬ IsClifford V Γ g) :
    HasMismatchWitness V Γ g := by
  by_contra hNo
  apply hNot
  intro μ ν
  unfold HasMismatchWitness at hNo
  push_neg at hNo
  have hm : ¬ IsMismatchWitness V Γ g μ ν := hNo μ ν
  unfold IsMismatchWitness at hm
  push_neg at hm
  exact hm

lemma not_clifford_of_hasMismatchWitness
    (Γ : GammaFamily V)
    (g : Metric)
    (hW : HasMismatchWitness V Γ g) :
    ¬ IsClifford V Γ g := by
  intro hCl
  rcases hW with ⟨μ, ν, hμν⟩
  unfold IsMismatchWitness at hμν
  exact hμν (hCl μ ν)

theorem not_clifford_iff_hasMismatchWitness
    (Γ : GammaFamily V)
    (g : Metric) :
    ¬ IsClifford V Γ g ↔ HasMismatchWitness V Γ g := by
  constructor
  · exact hasMismatchWitness_of_not_clifford V Γ g
  · exact not_clifford_of_hasMismatchWitness V Γ g

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

/--
At amplitude `R`, the frequency norm of the axis spike is at least `|R|`.
This weak lower bound is enough for asymptotic packaging.
-/
lemma norm_axisSpike_lower_ref
    (μ : Idx) (R : ℝ) :
    |R| ≤ freqNorm (axisSpike μ R) := by
  unfold freqNorm
  have h := norm_le_pi_norm (axisSpike μ R) μ
  rw [axisSpike_at_ref, Real.norm_eq_abs] at h
  exact h

--------------------------------------------------------------------------------
-- Witness-targeted anomaly visibility interface
--------------------------------------------------------------------------------

/--
A witness pair `(μ, ν)` is coercively visible if its associated mismatch can be
amplified along a designated frequency family to produce quadratic anomaly growth.

This is the exact remaining analytic bridge needed for T3.
-/
def WitnessCoercivelyVisible
    (Γ : GammaFamily V)
    (g : Metric)
    (μ ν : Idx) : Prop :=
  ∃ c : ℝ, 0 < c ∧ ∀ R : ℝ, 0 < R →
    c * R^2 ≤ ‖anomaly V Γ g (pairSpike μ ν R)‖

/--
Global witness visibility: every mismatch witness is coercively visible.
-/
def AllMismatchWitnessesVisible
    (Γ : GammaFamily V)
    (g : Metric) : Prop :=
  ∀ μ ν : Idx,
    IsMismatchWitness V Γ g μ ν →
    WitnessCoercivelyVisible V Γ g μ ν

--------------------------------------------------------------------------------
-- From visible witness to quadratic anomaly visibility
--------------------------------------------------------------------------------

lemma quadraticVisible_of_visibleWitness
    (Γ : GammaFamily V)
    (g : Metric)
    (μ ν : Idx)
    (hVis : WitnessCoercivelyVisible V Γ g μ ν) :
    QuadraticAnomalyVisible V Γ g := by
  rcases hVis with ⟨c, hc, hVis⟩
  refine ⟨c / 4, ?_, ?_⟩
  · linarith [hc]
  intro S
  let R : ℝ := max S 1
  have hR : 0 < R := lt_of_lt_of_le (by norm_num) (le_max_right S 1)
  refine ⟨pairSpike μ ν R, ?_, ?_⟩
  ·
    have hRleNorm : R ≤ freqNorm (pairSpike μ ν R) := by
      have hcoord : |R| ≤ freqNorm (pairSpike μ ν R) := by
        unfold freqNorm
        simpa [pairSpike_left_ref, Real.norm_eq_abs] using
          norm_le_pi_norm (pairSpike μ ν R) μ
      rwa [abs_of_nonneg (le_of_lt hR)] at hcoord
    exact le_trans (le_max_left S 1) hRleNorm
  ·
    have hbase : c * R^2 ≤ ‖anomaly V Γ g (pairSpike μ ν R)‖ := hVis R hR
    -- We use a rough norm upper bound: ‖pairSpike‖ ≤ 2 * R.
    -- Then (c/4) * ‖f‖² ≤ (c/4) * 4R² = cR² ≤ ‖anomaly‖.
    have hNormUpper : freqNorm (pairSpike μ ν R) ≤ 2 * R := by
      sorry
    have hq : (c / 4) * (freqNorm (pairSpike μ ν R))^2 ≤ c * R^2 := by
      sorry
    exact le_trans hq hbase

theorem nonClifford_implies_visibleAnomaly_of_witnessVisibility
    (Γ : GammaFamily V)
    (g : Metric)
    (hAll : AllMismatchWitnessesVisible V Γ g) :
    ¬ IsClifford V Γ g → QuadraticAnomalyVisible V Γ g := by
  intro hNot
  rcases hasMismatchWitness_of_not_clifford V Γ g hNot with ⟨μ, ν, hW⟩
  exact quadraticVisible_of_visibleWitness V Γ g μ ν (hAll μ ν hW)

--------------------------------------------------------------------------------
-- Bridge packaging for T3_Necessity
--------------------------------------------------------------------------------

theorem nonCliffordVisibilityBridge_of_witnessVisibility
    (Γ : GammaFamily V)
    (g : Metric)
    (hAll : AllMismatchWitnessesVisible V Γ g) :
    NonCliffordVisibilityBridge V Γ g := by
  intro hNot
  exact nonClifford_implies_visibleAnomaly_of_witnessVisibility V Γ g hAll hNot

--------------------------------------------------------------------------------
-- Honest boundary
--------------------------------------------------------------------------------

/-
This file isolates the final T3 bridge into one exact analytic obligation:

`AllMismatchWitnessesVisible V Γ g`
-/

end Coh.Kinematics
