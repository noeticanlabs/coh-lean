import Coh.Core.Clifford
import Coh.Kinematics.T3_CoerciveVisibility
import Coh.Kinematics.T3_Necessity
import Coh.Kinematics.T3_Spikes
import Coh.Spectral.AnomalyWitnessLower

import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

noncomputable section

namespace Coh.Kinematics

open Coh Coh.Core
open scoped BigOperators Real

variable {V : Type*} [CarrierSpace V]
variable (Γ : GammaFamily V) (g : Metric)

--------------------------------------------------------------------------------
-- T3: Non-Clifford Visibility Theorem
--------------------------------------------------------------------------------

/--
A non-Clifford family has at least one mismatch witness.
-/
lemma hasMismatchWitness_of_not_clifford
    (Γ : GammaFamily V)
    (g : Metric)
    (hNot : ¬ IsClifford Γ g) :
    HasMismatchWitness Γ g := by
  by_contra h_no_W
  unfold HasMismatchWitness IsMismatchWitness at h_no_W
  push_neg at h_no_W
  have hCl : IsClifford Γ g := by
    intro μ ν
    exact h_no_W μ ν
  contradiction

lemma not_clifford_of_hasMismatchWitness
    (Γ : GammaFamily V)
    (g : Metric)
    (hW : HasMismatchWitness Γ g) :
    ¬ IsClifford Γ g := by
  intro hCl
  obtain ⟨μ, ν, hM⟩ := hW
  exact hM (hCl μ ν)

theorem nonClifford_iff_hasMismatchWitness :
    ¬ IsClifford Γ g ↔ HasMismatchWitness Γ g := by
  constructor
  · exact hasMismatchWitness_of_not_clifford Γ g
  · exact not_clifford_of_hasMismatchWitness Γ g

--------------------------------------------------------------------------------
-- From visible witness to quadratic anomaly visibility
--------------------------------------------------------------------------------

lemma quadraticVisible_of_visibleWitness
    (μ ν : Idx)
    (hVis : WitnessCoercivelyVisible Γ g μ ν) :
    QuadraticAnomalyVisible Γ g := by
  obtain ⟨c, hc_pos, h_bound⟩ := hVis
  use c, hc_pos
  intro S
  let R := max 1 (S + 1)
  have hR_pos : 0 < R := lt_of_lt_of_le zero_lt_one (le_max_left 1 (S + 1))
  refine ⟨pairSpike μ ν R, ?_⟩
  constructor
  · -- Prove S ≤ freqNorm (pairSpike μ ν R)
    have hNorm := norm_pairSpike_lower_ref μ ν R
    rw [abs_of_pos hR_pos] at hNorm
    have : S ≤ R := le_trans (le_add_self) (le_max_right 1 (S + 1))
    exact le_trans (by linarith) hNorm
  · exact h_bound R hR_pos

theorem nonClifford_implies_visibleAnomaly_of_witnessVisibility
    (hAll : AllMismatchWitnessesVisible Γ g)
    (hNot : ¬ IsClifford Γ g) :
    QuadraticAnomalyVisible Γ g := by
  rcases hasMismatchWitness_of_not_clifford Γ g hNot with ⟨μ, ν, hW⟩
  exact quadraticVisible_of_visibleWitness Γ g μ ν (hAll μ ν hW)

--------------------------------------------------------------------------------
-- Bridge packaging for T3_Necessity
--------------------------------------------------------------------------------

theorem nonCliffordVisibilityBridge_of_witnessVisibility
    (hAll : AllMismatchWitnessesVisible Γ g) :
    NonCliffordVisibilityBridge V Γ g := by
  intro hNot
  exact nonClifford_implies_visibleAnomaly_of_witnessVisibility Γ g hAll hNot

--------------------------------------------------------------------------------
-- Bridge from T7
--------------------------------------------------------------------------------

/--
Direct T3 bridge: From derived T7-via-witness to non-Clifford visibility.
-/
theorem nonCliffordVisibilityBridge_of_T7 :
    NonCliffordVisibilityBridge V Γ g := by
  intro hNotCl
  exact Coh.Spectral.T7_via_witness Γ g hNotCl

end Coh.Kinematics
