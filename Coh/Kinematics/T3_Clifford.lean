import Mathlib.Analysis.NormedSpace.OperatorNorm.Basic
import Mathlib.LinearAlgebra.FiniteDimensional.Defs
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Data.Fin.Basic
import Coh.Prelude

noncomputable section

open scoped BigOperators

namespace Coh.Kinematics

--------------------------------------------------------------------------------
-- Basic spacetime index and metric
--------------------------------------------------------------------------------

-- Idx and Metric are imported from Prelude

--------------------------------------------------------------------------------
-- Carrier space and gamma family
--------------------------------------------------------------------------------

variable (V : Type*)
variable [NormedAddCommGroup V] [NormedSpace ℝ V]
variable [FiniteDimensional ℝ V]

/-- Identity operator as a bounded linear map. -/
def idOp : V →L[ℝ] V :=
  ContinuousLinearMap.id ℝ V

/-- Anticommutator for bounded operators. -/
def anticommutator (A B : V →L[ℝ] V) : V →L[ℝ] V :=
  A.comp B + B.comp A

/-- A family of gamma operators. -/
structure GammaFamily where
  Γ : Idx → V →L[ℝ] V

--------------------------------------------------------------------------------
-- Clifford Property
--------------------------------------------------------------------------------

/--
The Clifford property for a gamma family relative to a metric g.
{Γ_μ, Γ_ν} = 2 g_μν I
-/
def IsClifford (Γ : GammaFamily V) (g : Metric) : Prop :=
  ∀ μ ν : Idx, anticommutator V (Γ.Γ μ) (Γ.Γ ν) = (2 * g.g μ ν) • idOp V

--------------------------------------------------------------------------------
-- Measurement Anomaly
--------------------------------------------------------------------------------

/--
Anomaly at a specific frequency profile `f : Idx -> ℝ`.
A_f = ∑_{μ,ν} f_μ f_ν ({Γ_μ, Γ_ν} - 2 g_μν I)
-/
def anomaly
    (Γ : GammaFamily V)
    (g : Metric)
    (f : Idx → ℝ) : V →L[ℝ] V :=
  ∑ μ : Idx, ∑ ν : Idx,
    (f μ * f ν) • (anticommutator V (Γ.Γ μ) (Γ.Γ ν) - (2 * g.g μ ν) • idOp V)

/--
Oplax Soundness: The measurement anomaly vanishes for all frequency profiles.
-/
def OplaxSound
    (Γ : GammaFamily V)
    (g : Metric) : Prop :=
  ∀ f : Idx → ℝ, anomaly V Γ g f = 0

--------------------------------------------------------------------------------
-- The "Easy" Direction (T3 Forward)
--------------------------------------------------------------------------------

/--
Theorem: If a gamma family satisfies the Clifford relations, it is oplax sound.
Proof: The anomaly summand vanishes for every pair (μ, ν) by definition of IsClifford.
-/
theorem oplaxSound_of_clifford
    (Γ : GammaFamily V)
    (g : Metric)
    (hCl : IsClifford V Γ g) :
    OplaxSound V Γ g := by
  intro f
  unfold anomaly
  apply Finset.sum_eq_zero
  intro μ _
  apply Finset.sum_eq_zero
  intro ν _
  rw [hCl μ ν]
  simp

--------------------------------------------------------------------------------
-- Frequency Norm for asymptotic analysis
--------------------------------------------------------------------------------

/-- Standard Euclidean norm on the frequency space. -/
def freqNorm (f : Idx → ℝ) : ℝ :=
  ‖f‖

/--
A specific pair (μ, ν) witnesses the failure of the Clifford relation.
-/
def IsMismatchWitness
    (Γ : GammaFamily V)
    (g : Metric)
    (μ ν : Idx) : Prop :=
  anticommutator V (Γ.Γ μ) (Γ.Γ ν) ≠ (2 * g.g μ ν) • idOp V

end Coh.Kinematics
