import Coh.Core.Clifford
import Coh.Kinematics.T3_CoerciveVisibility
import Coh.Kinematics.T3_Necessity
import Coh.Spectral.VisibilityGap

import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

noncomputable section

namespace Coh.Kinematics

open Coh Coh.Core

open scoped BigOperators

--------------------------------------------------------------------------------
-- Non-Clifford mismatch witnesses
--------------------------------------------------------------------------------

variable (V : Type*)
variable [CarrierSpace V]

abbrev freqNorm : (Idx → ℝ) → ℝ := frequencyNorm

/--
The operator mismatch at a specific pair `(μ, ν)`.
This is exactly the failure of the Clifford relation at that index pair.
-/
def cliffordMismatchAt
    (Γ : GammaFamily V)
    (g : Metric)
    (μ ν : Idx) : V →L[ℝ] V :=
  Coh.Core.cliffordMismatchAt Γ g μ ν

/--
Existence of an index-pair mismatch witness.
-/
def HasMismatchWitness
    (Γ : GammaFamily V)
    (g : Metric) : Prop :=
  ∃ μ ν : Idx, IsMismatchWitness Γ g μ ν

--------------------------------------------------------------------------------
-- Logical reduction: non-Clifford iff some witness exists
--------------------------------------------------------------------------------

lemma hasMismatchWitness_of_not_clifford
    (Γ : GammaFamily V)
    (g : Metric)
    (hNot : ¬ IsClifford Γ g) :
    HasMismatchWitness V Γ g := by
  by_contra hNo
  apply hNot
  intro μ ν
  unfold HasMismatchWitness at hNo
  push_neg at hNo
  have hm : ¬ IsMismatchWitness Γ g μ ν := hNo μ ν
  unfold IsMismatchWitness at hm
  push_neg at hm
  have hm' : Coh.Core.cliffordMismatchAt Γ g μ ν = 0 := hm
  rw [Coh.Core.cliffordMismatchAt] at hm'
  exact sub_eq_zero.mp hm'

lemma not_clifford_of_hasMismatchWitness
    (Γ : GammaFamily V)
    (g : Metric)
    (hW : HasMismatchWitness V Γ g) :
    ¬ IsClifford Γ g := by
  intro hCl
  rcases hW with ⟨μ, ν, hμν⟩
  unfold IsMismatchWitness at hμν
  have hzero : Coh.Core.cliffordMismatchAt Γ g μ ν = 0 := by
    rw [Coh.Core.cliffordMismatchAt]
    exact sub_eq_zero.mpr (hCl μ ν)
  exact hμν hzero

theorem not_clifford_iff_hasMismatchWitness
    (Γ : GammaFamily V)
    (g : Metric) :
    ¬ IsClifford Γ g ↔ HasMismatchWitness V Γ g := by
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
At amplitude `R`, the frequency norm of the pair spike is at least `|R|`.
This is the lower bound needed for the quadratic visibility proof.
-/
lemma norm_pairSpike_lower_ref
    (μ ν : Idx) (R : ℝ) :
    |R| ≤ freqNorm (pairSpike μ ν R) := by
  unfold freqNorm
  have h := norm_le_pi_norm (pairSpike μ ν R) μ
  rw [pairSpike_left_ref, Real.norm_eq_abs] at h
  exact h

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
    c * (freqNorm (pairSpike μ ν R))^2 ≤ ‖anomaly Γ g (pairSpike μ ν R)‖

/--
Global witness visibility: every mismatch witness is coercively visible.
-/
def AllMismatchWitnessesVisible
    (Γ : GammaFamily V)
    (g : Metric) : Prop :=
  ∀ μ ν : Idx,
    IsMismatchWitness Γ g μ ν →
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
  use c, hc
  intro S
  let R : ℝ := max S 1
  have hR : 0 < R := by positivity
  use pairSpike μ ν R
  constructor
  ·
    have hRpos : 0 ≤ R := le_of_lt hR
    have hRabs : |R| = R := abs_of_nonneg hRpos
    have hRle : S ≤ R := le_max_left S 1
    have hRnorm : R ≤ freqNorm (pairSpike μ ν R) := by
      have hlower : |R| ≤ freqNorm (pairSpike μ ν R) := norm_pairSpike_lower_ref μ ν R
      rwa [hRabs] at hlower
    exact le_trans hRle hRnorm
  ·
    exact hVis R hR

theorem nonClifford_implies_visibleAnomaly_of_witnessVisibility
    (Γ : GammaFamily V)
    (g : Metric)
    (hAll : AllMismatchWitnessesVisible V Γ g) :
    ¬ IsClifford Γ g → QuadraticAnomalyVisible V Γ g := by
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
-- Phase 1: Supporting lemmas for AllMismatchWitnessesVisible
--------------------------------------------------------------------------------

/--
Lemma 1: If (μ, ν) is a mismatch witness, the operator mismatch is nonzero.

Proof: By contrapositive. If the mismatch operator equals zero, then the
anticommutator would equal 2 g_μν I, contradicting the witness definition.
-/
lemma mismatchAt_nonzero_of_witness
    (Γ : GammaFamily V)
    (g : Metric)
    (μ ν : Idx)
    (hw : IsMismatchWitness Γ g μ ν) :
    cliffordMismatchAt V Γ g μ ν ≠ 0 := by
  simpa [cliffordMismatchAt, Coh.Core.IsMismatchWitness] using hw

/--
Main Theorem: Visibility follows directly from anomaly coupling hypothesis.

This theorem encodes the bridge: if we can prove that the anomaly couples
the mismatch norm to the pairSpike probing with a positive coefficient
(measured in terms of the frequency norm), then every mismatch witness is
coercively visible.

The coupling hypothesis is the honest analytic boundary - it must be
established from the specific structure of the anomaly definition.
-/
theorem allMismatchWitnessesVisible_of_anomalyCoupling
    (Γ : GammaFamily V)
    (g : Metric)
    (h_coupling : ∀ μ ν : Idx, IsMismatchWitness Γ g μ ν →
      ∃ c : ℝ, 0 < c ∧
        ∀ R : ℝ, 0 < R →
          c * (freqNorm (pairSpike μ ν R))^2 ≤
            ‖anomaly Γ g (pairSpike μ ν R)‖) :
    AllMismatchWitnessesVisible V Γ g := by
  intro μ ν hw
  unfold WitnessCoercivelyVisible
  rcases h_coupling μ ν hw with ⟨c, hc_pos, hc_bound⟩
  exact ⟨c, hc_pos, hc_bound⟩

/--
Bridge theorem: The global quadratic spectral gap (T7) guarantees the local coupling hypothesis.

This directly fulfills the `WitnessCoercivelyVisible` property for any mismatch witness
by inheriting the uniform strictly positive lower bound from the full spectrum.
-/
theorem spectral_gap_of_mismatch
    (Γ : GammaFamily V)
    (g : Metric)
    (μ ν : Idx)
    (hw : IsMismatchWitness Γ g μ ν) :
     WitnessCoercivelyVisible V Γ g μ ν := by
  obtain ⟨c₀, hc₀_pos, hc₀_gap⟩ := Coh.Spectral.T7_Quadratic_Spectral_Gap Γ g
  use c₀, hc₀_pos
  intro R hR_pos
  -- pairSpike μ ν R is nonzero when R > 0
  have h_nonzero : pairSpike μ ν R ≠ fun _ => 0 := by
    intro h_eq
    have h_val := congrArg (fun f : Idx → ℝ => f μ) h_eq
    simp [pairSpike, hR_pos.ne] at h_val
    exact hR_pos.ne h_val.symm
  -- Apply the global T7 bound to pairSpike
  exact hc₀_gap (pairSpike μ ν R) h_nonzero

/--
Bridge lemma: The global quadratic spectral gap (T7) implies witness-local coercivity.

This is the key bridge from T7 to T3. Given the proved T7_Quadratic_Spectral_Gap,
we can directly obtain the quadratic lower bound for any pairSpike μ ν R,
which establishes WitnessCoercivelyVisible for all mismatch witnesses.
-/
lemma allMismatchWitnessesVisible_of_T7_spectralGap
    (Γ : GammaFamily V)
    (g : Metric) :
    AllMismatchWitnessesVisible V Γ g := by
  intro μ ν hw
  exact spectral_gap_of_mismatch V Γ g μ ν hw

/--
Direct T3 bridge: From proved T7 quadratic gap to non-Clifford visibility.

This theorem provides a direct route to establish NonCliffordVisibilityBridge
by consuming the proved T7_Quadratic_Spectral_Gap theorem, bypassing the need
for an ad hoc coupling hypothesis.
-/
theorem nonCliffordVisibilityBridge_of_T7
    (Γ : GammaFamily V)
    (g : Metric) :
    NonCliffordVisibilityBridge V Γ g :=
  nonCliffordVisibilityBridge_of_witnessVisibility V Γ g
    (allMismatchWitnessesVisible_of_T7_spectralGap V Γ g)

end Coh.Kinematics
