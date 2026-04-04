import Coh.Geometry.T6_Complexification

import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Analysis.SpecialFunctions.Exponential
import Mathlib.LinearAlgebra.FiniteDimensional.Defs

noncomputable section

namespace Coh.Geometry

--------------------------------------------------------------------------------
-- Persistence-to-rotation bridge for T6
--------------------------------------------------------------------------------

/-
This file isolates the exact missing bridge for T6.

Already proved in `T6_Complexification.lean`:
* real 1D first-order scalar systems do not admit nontrivial periodic evolution,
* real 2D rotation provides a canonical complex-like structure.

This file adds:
* the “no bounded persistent periodic flow in 1D” consequence,
* an abstract bridge packaging from admissible bounded persistence to rotation,
* the resulting promotion to a complex-like structure.
-/

--------------------------------------------------------------------------------
-- Real 1D linear evolution lemmas
--------------------------------------------------------------------------------

lemma lineTrajectory_of_a_eq_zero
    (sys : RealLineEvolution)
    (ha : sys.a = 0)
    (x₀ t : ℝ) :
    lineTrajectory sys x₀ t = x₀ := by
  simp [lineTrajectory, ha]

lemma lineTrajectory_nonzero_of_nonzero
    (sys : RealLineEvolution)
    {x₀ t : ℝ}
    (hx₀ : x₀ ≠ 0) :
    lineTrajectory sys x₀ t ≠ 0 := by
  unfold lineTrajectory
  have hexp : Real.exp (sys.a * t) ≠ 0 := by
    exact ne_of_gt (Real.exp_pos _)
  exact mul_ne_zero hx₀ hexp

/--
A nontrivial real 1D linear system cannot return to its initial nonzero value
at a nonzero period unless the system is static.
-/
theorem realLine_no_nontrivial_periodic_return
    (sys : RealLineEvolution)
    {x₀ T : ℝ}
    (ha : sys.a ≠ 0)
    (hx₀ : x₀ ≠ 0)
    (hT : T ≠ 0) :
    lineTrajectory sys x₀ T ≠ x₀ := by
  intro hper
  have hmul : x₀ * Real.exp (sys.a * T) = x₀ := by
    simpa [lineTrajectory] using hper
  have hexp_eq_one : Real.exp (sys.a * T) = 1 := by
    apply (mul_left_cancel₀ hx₀)
    simpa [mul_comm] using hmul
  have hprod : sys.a * T = 0 := by
    rw [← Real.exp_zero] at hexp_eq_one
    exact Real.exp_injective hexp_eq_one
  rcases eq_zero_or_eq_zero_of_mul_eq_zero hprod with hA | hT0
  · exact ha hA
  · exact hT hT0

--------------------------------------------------------------------------------
-- Persistent cyclicity in dimension 1 is impossible
--------------------------------------------------------------------------------

/--
A real 1D trajectory is bounded-persistent over all time if it stays uniformly
away from both `0` and `∞`.
-/
def LineBoundedPersistence
    (sys : RealLineEvolution)
    (x₀ lower upper : ℝ) : Prop :=
  0 < lower ∧ lower < upper ∧
  ∀ t : ℝ, lower ≤ |lineTrajectory sys x₀ t| ∧ |lineTrajectory sys x₀ t| ≤ upper

/--
A real 1D trajectory is periodic if it returns after a nonzero period.
-/
def LinePeriodic
    (sys : RealLineEvolution)
    (x₀ T : ℝ) : Prop :=
  T ≠ 0 ∧ ∀ t : ℝ, lineTrajectory sys x₀ (t + T) = lineTrajectory sys x₀ t

/--
Nontrivial bounded-persistent periodic evolution is impossible in real dimension 1
unless the system is static.
-/
theorem realLine_periodic_forces_static
    (sys : RealLineEvolution)
    {x₀ T lower upper : ℝ}
    (hper : LinePeriodic sys x₀ T)
    (hbd : LineBoundedPersistence sys x₀ lower upper) :
    sys.a = 0 := by
  rcases hper with ⟨hT, hper⟩
  rcases hbd with ⟨hlower, _, hbd⟩
  have hx₀_nonzero : x₀ ≠ 0 := by
    intro hx₀
    have h0 := hbd 0
    simp [lineTrajectory_zero_time, hx₀] at h0
    linarith
  by_contra ha
  have hbad := realLine_no_nontrivial_periodic_return sys ha hx₀_nonzero hT
  have hper0 : lineTrajectory sys x₀ T = x₀ := by
    have h := hper 0
    rw [zero_add] at h
    have h0 : lineTrajectory sys x₀ 0 = x₀ := by
      simp [lineTrajectory]
    rwa [h0] at h
  exact hbad hper0

--------------------------------------------------------------------------------
-- Rotation bridge interface
--------------------------------------------------------------------------------

variable (V : Type*)
variable [NormedAddCommGroup V] [NormedSpace ℝ V] [FiniteDimensional ℝ V]

/--
Abstract marker: `V` supports an admissible persistent cyclic evolution.
At this layer we do not yet encode the full tangent-cone / Lipschitz mechanics;
we isolate exactly the bridge shape T6 needs.
-/
class AdmitsPersistentCycle (V : Type*) : Prop where
  witness : True

/--
Abstract bridge: admissible persistent cyclic evolution on `V` produces a
complex-like structure on `V`.

This is the exact remaining T6 bridge theorem target once the full governed
admissibility machinery is formalized.
-/
def PersistenceForcesComplexLike : Prop :=
  AdmitsPersistentCycle V → HasComplexLikeStructure V

/--
Once the bridge is supplied, persistent cyclic admissibility yields a
complex-like structure immediately.
-/
theorem hasComplexLike_of_persistentCycle
    (hBridge : PersistenceForcesComplexLike V)
    [hCycle : AdmitsPersistentCycle V] :
    HasComplexLikeStructure V := by
  exact hBridge hCycle

--------------------------------------------------------------------------------
-- Minimal real rotation model
--------------------------------------------------------------------------------

/--
The canonical real 2D carrier supports persistent cyclic evolution.
This is the model witness coming from rotation.
-/
instance : AdmitsPersistentCycle (ℝ × ℝ) where
  witness := trivial

/--
Therefore `ℝ²` satisfies the abstract T6 bridge whenever the bridge theorem is available.
-/
theorem real2_hasComplexLike_of_bridge
    (hBridge : PersistenceForcesComplexLike (ℝ × ℝ)) :
    HasComplexLikeStructure (ℝ × ℝ) := by
  exact hasComplexLike_of_persistentCycle (V := ℝ × ℝ) hBridge

/--
Independent of the abstract bridge, `ℝ²` already has the canonical complex-like
structure from `T6_Complexification.lean`.
-/
theorem real2_hasCanonicalComplexLike :
    HasComplexLikeStructure (ℝ × ℝ) := by
  exact R2_hasComplexLikeStructure

--------------------------------------------------------------------------------
-- 1D obstruction packaged as a bridge target
--------------------------------------------------------------------------------

/--
A real one-dimensional admissible persistent cycle would contradict the scalar
evolution obstruction unless the dynamics were static.
-/
def RealLineObstruction : Prop :=
  ∀ (sys : RealLineEvolution) (x₀ T lower upper : ℝ),
    LinePeriodic sys x₀ T →
    LineBoundedPersistence sys x₀ lower upper →
    sys.a = 0

theorem realLineObstruction_holds : RealLineObstruction := by
  intro sys x₀ T lower upper hper hbd
  exact realLine_periodic_forces_static sys hper hbd

--------------------------------------------------------------------------------
-- Honest boundary
--------------------------------------------------------------------------------

/-
This file proves the T6 persistence core:

* real 1D first-order linear dynamics cannot support nontrivial bounded periodic flow,
* any such periodic bounded 1D flow is forced to be static,
* the exact remaining T6 bridge is now isolated as:

    PersistenceForcesComplexLike V :
      AdmitsPersistentCycle V -> HasComplexLikeStructure V

What is still NOT proved here:
* that full Coh admissible persistent evolution instantiates `AdmitsPersistentCycle`,
* that the resulting complex-like structure commutes with the Clifford generators,
* that the carrier therefore upgrades canonically to a complex Clifford module.
-/

end Coh.Geometry
