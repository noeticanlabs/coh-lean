import Coh.Core.Clifford
import Coh.Core.Oplax
import Coh.Kinematics.T3_CoerciveVisibility

noncomputable section

namespace Coh.Kinematics

open Coh Coh.Core

--------------------------------------------------------------------------------
-- Necessity composition layer
--------------------------------------------------------------------------------

variable (V : Type*) [NormedAddCommGroup V] [NormedSpace ℝ V] [InnerProductSpace ℝ V] [CarrierSpace V]

/--
Converse T3 theorem schema:
If
* defect is subquadratic,
* soundness is coercive,
* and non-Clifford generators produce visible quadratic anomaly,

then coercive oplax soundness forces the Clifford relation.
-/
theorem T3_Necessity_Attractor
    (Γ : GammaFamily V)
    (g : Metric)
    (Δ : (Idx → ℝ) → ℝ)
    (hSub : SubquadraticDefectBound Γ g Δ)
    (hSound : CoercivelyOplaxSound Γ g Δ)
    (hBridge : NonCliffordVisibilityBridge Γ g) :
    IsClifford Γ g := by
  by_contra hNotCl
  have hVis : QuadraticAnomalyVisible Γ g := hBridge hNotCl
  exact anomaly_contradicts_subquadratic_defect Γ g Δ hVis hSub hSound

/--
A convenient corollary phrased directly in terms of the T3 bridge.
-/
theorem T3_Necessity_Corollary
    (Γ : GammaFamily V)
    (g : Metric)
    (Δ : (Idx → ℝ) → ℝ)
    (hSub : SubquadraticDefectBound Γ g Δ)
    (hSound : CoercivelyOplaxSound Γ g Δ)
    (hBridge : NonCliffordVisibilityBridge Γ g) :
    OplaxSound Γ g := by
  have hCl : Coh.IsClifford Γ g :=
    @T3_Necessity_Attractor V instNormedAddCommGroup instNormedSpace instInnerProductSpace instCarrierSpace Γ g Δ hSub hSound hBridge
  exact oplaxSound_of_clifford Γ g hCl

--------------------------------------------------------------------------------
-- Best-practice note
--------------------------------------------------------------------------------

/-
This file establishes the T3 necessity layer, reducing measurement soundness to a
Clifford-visibility predicate.

`¬ IsClifford Γ g -> QuadraticAnomalyVisible V Γ g`.

That bridge is the next real theorem target. Nothing else hidden remains in the
logical composition.
-/

end Coh.Kinematics
