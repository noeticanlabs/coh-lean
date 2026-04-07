import Coh.Core.SpectralContext
import Mathlib.Analysis.NormedSpace.OperatorNorm.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace Coh.Core

open scoped BigOperators
open Coh

variable {V : Type*} [CarrierSpace V]
variable (Γ : GammaFamily V) (g : Metric)

/-- Identity operator as a continuous linear map. -/
def idOp : V →L[ℝ] V :=
  ContinuousLinearMap.id ℝ V

/-- Anticommutator for bounded operators: {A, B} = AB + BA. -/
def anticommutator (A B : V →L[ℝ] V) : V →L[ℝ] V :=
  A.comp B + B.comp A

/-- The Clifford property: {Γ_μ, Γ_ν} = 2 g_μν I. -/
def IsClifford : Prop :=
  ∀ μ ν : Idx, anticommutator (Γ.Γ μ) (Γ.Γ ν) = (2 * g.g μ ν) • idOp

/-- Operator mismatch at index pair (μ, ν): the failure of Clifford at that pair. -/
def cliffordMismatchAt (μ ν : Idx) : V →L[ℝ] V :=
  anticommutator (Γ.Γ μ) (Γ.Γ ν) - (2 * g.g μ ν) • idOp

/-- Symmetry of the Clifford mismatch operator. -/
lemma cliffordMismatchAt_symm (μ ν : Idx) :
    cliffordMismatchAt Γ g μ ν = cliffordMismatchAt Γ g ν μ := by
  unfold cliffordMismatchAt anticommutator
  rw [g.symm]
  rw [add_comm]

/-- Bridge between global Clifford predicate and local mismatch operators. -/
lemma isClifford_iff_mismatch_zero :
    IsClifford Γ g ↔ ∀ μ ν : Idx, cliffordMismatchAt Γ g μ ν = 0 := by
  constructor
  · intro h μ ν
    unfold cliffordMismatchAt
    rw [h μ ν, sub_self]
  · intro h μ ν
    unfold cliffordMismatchAt at h
    rw [← sub_eq_zero]
    exact h μ ν

/-- A specific index pair is a mismatch witness if the Clifford relation fails there. -/
def IsMismatchWitness (μ ν : Idx) : Prop :=
  cliffordMismatchAt Γ g μ ν ≠ 0

/-- Existential: there exists some mismatch witness. -/
def HasMismatchWitness : Prop :=
  ∃ μ ν : Idx, IsMismatchWitness Γ g μ ν

/-- Frequency norm (Euclidean). -/
def frequencyNorm (f : Idx → ℝ) : ℝ :=
  ‖f‖

/-- Measurement anomaly at a frequency profile. -/
def anomaly (f : Idx → ℝ) : V →L[ℝ] V :=
  ∑ μ : Idx, ∑ ν : Idx,
    (f μ * f ν) • (anticommutator (Γ.Γ μ) (Γ.Γ ν) - (2 * g.g μ ν) • idOp)

/-- Oplax soundness: the anomaly vanishes for all frequency profiles. -/
def OplaxSound : Prop :=
  ∀ f : Idx → ℝ, anomaly Γ g f = 0

/-- Theorem: Clifford implies Oplax Sound. -/
theorem oplaxSound_of_clifford
    (hCl : IsClifford Γ g) :
    OplaxSound Γ g := by
  intro f
  simp only [anomaly]
  apply Finset.sum_eq_zero
  intro μ _
  apply Finset.sum_eq_zero
  intro ν _
  rw [hCl μ ν]
  simp

--------------------------------------------------------------------------------
-- Anomaly Bilinearity: Fundamental Structural Properties
--
-- The anomaly operator is bilinear in the frequency profile f, hence the
-- anomaly strength (norm of the anomaly) scales quadratically with frequency.
-- These are foundational properties used throughout Spectral phase proofs.
--------------------------------------------------------------------------------

/--
Anomaly bilinearity (left): scalar multiplication.

The anomaly at scaled frequency (c • f) equals the square of the scalar times
the anomaly at f. This follows from the definition: each term (c*f_μ)*(c*f_ν)
contributes c² to every summand.

This is the key structural property enabling the quadratic spectral gap.
-/
lemma anomaly_smul_left (c : ℝ) (f : Idx → ℝ) :
    anomaly Γ g (c • f) = (c ^ 2) • anomaly Γ g f := by
  unfold anomaly
  simp only [Pi.smul_apply]
  calc
    (∑ μ : Idx, ∑ ν : Idx, (c * f μ * (c * f ν)) • cliffordMismatchAt Γ g μ ν)
      = ∑ μ : Idx, ∑ ν : Idx, (c ^ 2 * (f μ * f ν)) • cliffordMismatchAt Γ g μ ν := by
      apply Finset.sum_congr rfl
      intro μ _
      apply Finset.sum_congr rfl
      intro ν _
      congr 1
      ring
    _ = (c ^ 2) • (∑ μ : Idx, ∑ ν : Idx, (f μ * f ν) • cliffordMismatchAt Γ g μ ν) := by
      rw [Finset.smul_sum]
      apply Finset.sum_congr rfl
      intro μ _
      rw [Finset.smul_sum]
      apply Finset.sum_congr rfl
      intro ν _
      rw [mul_smul]

/--
Anomaly strength homogeneity: quadratic scaling.

The strength (norm) of the anomaly scales quadratically with scalar multiple:
‖anomaly Γ g (c • f)‖ = c² · ‖anomaly Γ g f‖.

This follows from the scalar multiplication homogeneity of the norm.
-/
lemma anomaly_homogeneous_quadratic (c : ℝ) (f : Idx → ℝ) :
    ‖anomaly Γ g (c • f)‖ = (c ^ 2) * ‖anomaly Γ g f‖ := by
  rw [anomaly_smul_left Γ g c f]
  have h := norm_smul (c^2) (anomaly Γ g f)
  rw [h]
  rw [Real.norm_of_nonneg (sq_nonneg c)]

end Coh.Core
