import Coh.Core.Clifford
import Coh.Kinematics.T3_CoerciveVisibility
import Coh.Kinematics.T3_NonCliffordVisible

import Mathlib.Analysis.NormedSpace.OperatorNorm.Basic
import Mathlib.Data.Real.Basic

noncomputable section

namespace Coh.Kinematics

--------------------------------------------------------------------------------
-- Witness amplification layer
--------------------------------------------------------------------------------

variable (V : Type*)
variable [NormedAddCommGroup V] [NormedSpace ℝ V]
variable [FiniteDimensional ℝ V]

/--
A local quadratic coercivity hypothesis for a mismatch witness `(μ, ν)`.

Interpretation:
along the designated frequency family `pairSpike μ ν R`, the anomaly norm grows
at least quadratically in the frequency norm with coefficient `c > 0`.
-/
def WitnessQuadraticLowerBound
    (Γ : GammaFamily V)
    (g : Metric)
    (μ ν : Idx) : Prop :=
  ∃ c : ℝ, 0 < c ∧
    ∀ R : ℝ, 0 < R →
      c * (freqNorm (pairSpike μ ν R))^2 ≤ ‖anomaly V Γ g (pairSpike μ ν R)‖

/--
A uniform amplification principle: every mismatch witness admits a quadratic lower bound.
-/
def UniformWitnessAmplification
    (Γ : GammaFamily V)
    (g : Metric) : Prop :=
  ∀ μ ν : Idx,
    IsMismatchWitness V Γ g μ ν →
    WitnessQuadraticLowerBound V Γ g μ ν

--------------------------------------------------------------------------------
-- Immediate identification with the visibility interface
--------------------------------------------------------------------------------

lemma witnessQuadraticLowerBound_iff_visible
    (Γ : GammaFamily V)
    (g : Metric)
    (μ ν : Idx) :
    WitnessQuadraticLowerBound V Γ g μ ν ↔
    WitnessCoercivelyVisible V Γ g μ ν := by
  rfl

lemma uniformAmplification_iff_allVisible
    (Γ : GammaFamily V)
    (g : Metric) :
    UniformWitnessAmplification V Γ g ↔
    AllMismatchWitnessesVisible V Γ g := by
  rfl

--------------------------------------------------------------------------------
-- Bridge theorem
--------------------------------------------------------------------------------

theorem allMismatchWitnessesVisible_of_uniformAmplification
    (Γ : GammaFamily V)
    (g : Metric)
    (hAmp : UniformWitnessAmplification V Γ g) :
    AllMismatchWitnessesVisible V Γ g := by
  exact hAmp

theorem nonCliffordVisibilityBridge_of_uniformAmplification
    (Γ : GammaFamily V)
    (g : Metric)
    (hAmp : UniformWitnessAmplification V Γ g) :
    NonCliffordVisibilityBridge V Γ g := by
  apply nonCliffordVisibilityBridge_of_witnessVisibility
  exact allMismatchWitnessesVisible_of_uniformAmplification V Γ g hAmp

--------------------------------------------------------------------------------
-- Full converse T3 from uniform witness amplification
--------------------------------------------------------------------------------

theorem clifford_of_subquadratic_soundness_and_uniformAmplification
    (Γ : GammaFamily V)
    (g : Metric)
    (Δ : (Idx → ℝ) → ℝ)
    (hSub : SubquadraticDefectBound Δ)
    (hSound : CoercivelyOplaxSound V Γ g Δ)
    (hAmp : UniformWitnessAmplification V Γ g) :
    IsClifford V Γ g := by
  apply clifford_of_coercive_soundness V Γ g Δ hSub hSound
  exact nonCliffordVisibilityBridge_of_uniformAmplification V Γ g hAmp

theorem oplaxSound_forces_clifford_of_uniformAmplification
    (Γ : GammaFamily V)
    (g : Metric)
    (Δ : (Idx → ℝ) → ℝ)
    (hSub : SubquadraticDefectBound Δ)
    (hSound : CoercivelyOplaxSound V Γ g Δ)
    (hAmp : UniformWitnessAmplification V Γ g) :
    OplaxSound V Γ g := by
  have hCl : IsClifford V Γ g :=
    clifford_of_subquadratic_soundness_and_uniformAmplification
      V Γ g Δ hSub hSound hAmp
  exact oplaxSound_of_clifford V Γ g hCl

--------------------------------------------------------------------------------
-- Honest boundary
--------------------------------------------------------------------------------

/-
This file closes the abstract T3 converse pipeline modulo one exact hypothesis:

`UniformWitnessAmplification V Γ g`
-/

end Coh.Kinematics
