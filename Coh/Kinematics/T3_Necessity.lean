import Coh.Kinematics.T3_Clifford
import Coh.Kinematics.T3_CoerciveVisibility

noncomputable section

namespace Coh.Kinematics

--------------------------------------------------------------------------------
-- Necessity composition layer
--------------------------------------------------------------------------------

variable (V : Type*)
variable [NormedAddCommGroup V] [NormedSpace ℝ V]
variable [FiniteDimensional ℝ V]

/--
Converse T3 theorem schema:
If
* defect is subquadratic,
* soundness is coercive,
* and non-Clifford generators produce visible quadratic anomaly,

then coercive oplax soundness forces the Clifford relation.
-/
theorem clifford_of_coercive_soundness_composition
    (Γ : GammaFamily V)
    (g : Metric)
    (Δ : (Idx → ℝ) → ℝ)
    (hSub : SubquadraticDefectBound Δ)
    (hSound : CoercivelyOplaxSound V Γ g Δ)
    (hBridge : NonCliffordVisibilityBridge V Γ g) :
    IsClifford V Γ g := by
  by_contra hNotCl
  have hVis : QuadraticAnomalyVisible V Γ g := hBridge hNotCl
  exact anomaly_contradicts_subquadratic_defect V Γ g Δ hVis hSub hSound

/--
A convenient corollary phrased directly in terms of the T3 bridge.
-/
theorem oplaxSound_forces_clifford
    (Γ : GammaFamily V)
    (g : Metric)
    (Δ : (Idx → ℝ) → ℝ)
    (hSub : SubquadraticDefectBound Δ)
    (hSound : CoercivelyOplaxSound V Γ g Δ)
    (hBridge : NonCliffordVisibilityBridge V Γ g) :
    OplaxSound V Γ g := by
  have hCl : IsClifford V Γ g :=
    clifford_of_coercive_soundness_composition V Γ g Δ hSub hSound hBridge
  exact oplaxSound_of_clifford V Γ g hCl

--------------------------------------------------------------------------------
-- Best-practice note
--------------------------------------------------------------------------------

/-
This file establishes the T3 necessity layer, reducing measurement soundness to a
Clifford-visibility predicate.

`¬ IsClifford V Γ g -> QuadraticAnomalyVisible V Γ g`.

That bridge is the next real theorem target. Nothing else hidden remains in the
logical composition.
-/

end Coh.Kinematics
