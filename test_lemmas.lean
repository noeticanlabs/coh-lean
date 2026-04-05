import Mathlib.Analysis.NormedSpace.OperatorNorm.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

open scoped BigOperators

variable {V : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V]
variable (c : ℝ) (f : ℕ → ℝ) (M : ℕ → ℕ → (V →L[ℝ] V))
variable (s : Finset ℕ)

lemma test_smul :
  (∑ μ ∈ s, ∑ ν ∈ s, (c * f μ * (c * f ν)) • M μ ν) =
  (c ^ 2) • (∑ μ ∈ s, ∑ ν ∈ s, (f μ * f ν) • M μ ν) := by
  calc
    (∑ μ ∈ s, ∑ ν ∈ s, (c * f μ * (c * f ν)) • M μ ν)
      = ∑ μ ∈ s, ∑ ν ∈ s, (c ^ 2 * (f μ * f ν)) • M μ ν := by
      apply Finset.sum_congr rfl
      intro μ _
      apply Finset.sum_congr rfl
      intro ν _
      congr 1
      ring
    _ = (c ^ 2) • (∑ μ ∈ s, ∑ ν ∈ s, (f μ * f ν) • M μ ν) := by
      rw [Finset.smul_sum]
      apply Finset.sum_congr rfl
      intro μ _
      rw [Finset.smul_sum]
      apply Finset.sum_congr rfl
      intro ν _
      rw [mul_smul]

lemma test_norm_2 (X : V →L[ℝ] V) (c : ℝ) :
  ‖(c ^ 2) • X‖ = c ^ 2 * ‖X‖ := by
  have h := norm_smul (c^2) X
  rw [h]
  have hc : 0 ≤ c^2 := sq_nonneg c
  rw [Real.norm_of_nonneg hc]
