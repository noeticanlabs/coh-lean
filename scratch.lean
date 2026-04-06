import Mathlib.Data.Real.Basic
lemma realLine_no_nontrivial_periodic :
    ¬∃ (x₀ : ℝ) (a : ℝ), x₀ ≠ 0 ∧ 0 ≤ a ∧ a ≠ 1 ∧
      ∃ N : ℕ, 0 < N ∧ (a : ℝ) ^ N * x₀ = x₀ := by
  rintro ⟨x₀, a, hx₀, ha_nonneg, ha_ne_one, N, hN, hperiod⟩
  have eq_one : a ^ N = 1 := by
    calc a ^ N = a ^ N * 1 := by rw [mul_one]
      _ = a ^ N * (x₀ * x₀⁻¹) := by rw [mul_inv_cancel₀ hx₀]
      _ = (a ^ N * x₀) * x₀⁻¹ := by rw [mul_assoc]
      _ = x₀ * x₀⁻¹ := by rw [hperiod]
      _ = 1 := by rw [mul_inv_cancel₀ hx₀]
  have a_eq_one : a = 1 := (pow_eq_one_iff_of_nonneg ha_nonneg hN.ne').mp eq_one
  exact ha_ne_one a_eq_one
