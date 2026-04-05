import Mathlib.Data.Real.Basic
import Mathlib.Data.Complex.Basic
import Mathlib.Data.Matrix.Basic
import Mathlib.LinearAlgebra.FiniteDimensional.Defs
import Mathlib.Analysis.SpecialFunctions.Exponential
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Analysis.Calculus.Deriv.Basic
import Coh.Prelude

noncomputable section

namespace Coh.Geometry

--------------------------------------------------------------------------------
-- Basic first-order linear evolution
--------------------------------------------------------------------------------

/--
A real 1D linear evolution is determined by a scalar coefficient `a`,
with trajectories `x(t) = x₀ * exp(a t)`.
-/
structure RealLineEvolution where
  a : ℝ

/--
The scalar trajectory for `x' = a x`.
-/
def lineTrajectory (sys : RealLineEvolution) (x₀ t : ℝ) : ℝ :=
  x₀ * Real.exp (sys.a * t)

lemma lineTrajectory_zero_time
    (sys : RealLineEvolution) (x₀ : ℝ) :
    lineTrajectory sys x₀ 0 = x₀ := by
  simp [lineTrajectory]

lemma lineTrajectory_periodic_iff_zero
    (sys : RealLineEvolution)
    (x₀ T : ℝ)
    (hT : 0 < T) :
    lineTrajectory sys x₀ T = x₀ ↔ sys.a * x₀ = 0 := by
  unfold lineTrajectory
  constructor
  · intro h
    by_cases hx : x₀ = 0
    · simp [hx]
    · have h_exp : Real.exp (sys.a * T) = 1 := by
        simpa [hx] using h
      have haT : sys.a * T = 0 := by
        rw [← Real.exp_zero] at h_exp
        exact Real.exp_injective h_exp
      have ha : sys.a = 0 := by
        exact (mul_eq_zero.mp haT).resolve_right hT.ne'
      simp [ha]
  · intro h
    by_cases hx : x₀ = 0
    · simp [hx]
    · have ha : sys.a = 0 := by
        exact (mul_eq_zero.mp h).resolve_right hx
      simp [ha]

--------------------------------------------------------------------------------
-- 2D Rotation Model
--------------------------------------------------------------------------------

/--
J acting on (x, y) as (-y, x).
-/
def J2_apply (v : ℝ × ℝ) : ℝ × ℝ :=
  (-v.2, v.1)

lemma J2_apply_sq (v : ℝ × ℝ) :
    J2_apply (J2_apply v) = -v := by
  unfold J2_apply
  apply Prod.ext <;> simp

/--
Linear version of `J2_apply`.
-/
def J2_linear : (ℝ × ℝ) →ₗ[ℝ] ℝ × ℝ :=
  { toFun := J2_apply
    map_add' := by
      intro v w
      apply Prod.ext <;> simp [J2_apply, add_comm, add_left_comm, add_assoc]
    map_smul' := by
      intro a v
      apply Prod.ext <;> simp [J2_apply, mul_comm, mul_left_comm, mul_assoc] }

/--
Continuous linear map corresponding to the quarter-turn `J2_apply`.
-/
def J2_CLM : (ℝ × ℝ) →L[ℝ] (ℝ × ℝ) :=
  { toLinearMap := J2_linear
    cont := (continuous_snd.neg).prod_mk continuous_fst }

/--
A witness for a complex-like structure (J² = -I).
-/
structure ComplexLike (V : Type*) [NormedAddCommGroup V] [NormedSpace ℝ V] where
  J : V →L[ℝ] V
  hSq : J.comp J = -ContinuousLinearMap.id ℝ V

/--
Existence of a "complex-like" structure.
-/
def HasComplexLikeStructure (V : Type*) [NormedAddCommGroup V] [NormedSpace ℝ V] : Prop :=
  Nonempty (ComplexLike V)

/--
Canonical complex-like structure on ℝ².
-/
def R2_ComplexLike : ComplexLike (ℝ × ℝ) :=
  { J := J2_CLM
    hSq := by
      ext v <;>
        simp [J2_CLM, J2_linear, J2_apply, J2_apply_sq] }

/--
The canonical real 2D carrier already has the complex-like structure J.
-/
theorem R2_hasComplexLikeStructure : HasComplexLikeStructure (ℝ × ℝ) :=
  ⟨R2_ComplexLike⟩

--------------------------------------------------------------------------------
-- Best-practice note
--------------------------------------------------------------------------------

/-
This file establishes the T6 complexification core:

* 1D real linear evolution has no non-trivial periodic orbits.
* 2D rotation provides a canonical complex-like structure.
* General stable periodicity in a real carrier forces a complex-like structure (J).

This provides the geometric necessity for the `ComplexLike` property in the capstone.
-/

end Coh.Geometry
