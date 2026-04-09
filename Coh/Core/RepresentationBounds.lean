import Mathlib.Algebra.Algebra.Basic
import Mathlib.Data.Complex.FiniteDimensional
import Mathlib.LinearAlgebra.CliffordAlgebra.Basic
import Mathlib.LinearAlgebra.Dimension.Finrank
import Mathlib.LinearAlgebra.FiniteDimensional
import Mathlib.LinearAlgebra.FreeModule.Finite.Matrix
import Coh.Prelude
import Coh.Core.Clifford

noncomputable section

namespace Coh.Core

--------------------------------------------------------------------
-- Faithful Representation Dimension Bounds
--------------------------------------------------------------------

/-
This file provides dimension bounds for faithful representations.

Status:
1. [PROVED] `dim End(H) = (dim H)^2`
2. [PROVED] faithful representations satisfy `dim A ≤ (dim H)^2`
3. [PROVED] conditional Clifford lower bound from the external input
   `dim_ℂ CliffordAlgebra Q = 16`
4. [PROVED] real dimension doubles complex dimension

The only remaining external dependency is the specific 4-dimensional Clifford
dimension computation for the chosen quadratic form.
-/

open FiniteDimensional

variable {K : Type*} [Field K]
variable {A : Type*} [Ring A] [Algebra K A]
variable {H : Type*} [AddCommGroup H] [Module K H]

/-- Lemma 1: `End(K,H)` has dimension `(dim H)^2`. -/
theorem finrank_end_eq_square [FiniteDimensional K H] :
    Module.finrank K (Module.End K H) = (Module.finrank K H) ^ 2 := by
  simpa [Module.End, pow_two] using
    (Module.finrank_linearMap (R := K) (S := K) (M := H) (N := H))

/--
Lemma 2: an injective algebra representation embeds `A` into `End(H)`, hence
`dim A ≤ dim End(H)`.
-/
theorem faithful_representation_finrank_le_end
    [FiniteDimensional K A] [FiniteDimensional K H]
    (ρ : A →ₐ[K] Module.End K H)
    (hρ : Function.Injective ρ) :
    Module.finrank K A ≤ Module.finrank K (Module.End K H) := by
  exact LinearMap.finrank_le_finrank_of_injective (f := ρ.toLinearMap) hρ

/--
Corollary: any faithful finite-dimensional representation satisfies the quadratic
bound `dim A ≤ (dim H)^2`.
-/
theorem faithful_representation_square_bound
    [FiniteDimensional K A] [FiniteDimensional K H]
    (ρ : A →ₐ[K] Module.End K H)
    (hρ : Function.Injective ρ) :
    Module.finrank K A ≤ (Module.finrank K H) ^ 2 := by
  have h := faithful_representation_finrank_le_end ρ hρ
  rw [finrank_end_eq_square] at h
  exact h

--------------------------------------------------------------------
-- Clifford Specialization
--------------------------------------------------------------------

/--
Conditional complex Clifford lower bound.

If a 4-generator complex Clifford algebra has dimension `16`, then every faithful
representation on `H` satisfies `16 ≤ (dim H)^2`.
-/
theorem faithful_clifford_rank_lower_bound_complex
    {Q : QuadraticForm ℂ (Fin 4 → ℂ)}
    {H : Type*} [AddCommGroup H] [Module ℂ H]
    [FiniteDimensional ℂ (CliffordAlgebra Q)]
    [FiniteDimensional ℂ H]
    (hCliffDim : Module.finrank ℂ (CliffordAlgebra Q) = 16)
    (ρ : CliffordAlgebra Q →ₐ[ℂ] Module.End ℂ H)
    (hρ : Function.Injective ρ) :
    16 ≤ (Module.finrank ℂ H) ^ 2 := by
  have h := faithful_representation_square_bound (K := ℂ) ρ hρ
  rw [hCliffDim] at h
  exact h

/--
From the conditional square bound, deduce the carrier rank lower bound `4 ≤ dim H`.
-/
theorem faithful_clifford_rank_at_least_four
    {Q : QuadraticForm ℂ (Fin 4 → ℂ)}
    {H : Type*} [AddCommGroup H] [Module ℂ H]
    [FiniteDimensional ℂ (CliffordAlgebra Q)]
    [FiniteDimensional ℂ H]
    (hCliffDim : Module.finrank ℂ (CliffordAlgebra Q) = 16)
    (ρ : CliffordAlgebra Q →ₐ[ℂ] Module.End ℂ H)
    (hρ : Function.Injective ρ) :
    4 ≤ Module.finrank ℂ H := by
  have hSq : 16 ≤ (Module.finrank ℂ H) ^ 2 :=
    faithful_clifford_rank_lower_bound_complex hCliffDim ρ hρ
  have hSqReal : (16 : ℝ) ≤ (Module.finrank ℂ H : ℝ) ^ 2 := by
    exact_mod_cast hSq
  have hRankReal : (4 : ℝ) ≤ (Module.finrank ℂ H : ℝ) := by
    nlinarith
  exact_mod_cast hRankReal

/-- If a complex carrier has complex rank `4`, then its underlying real rank is `8`. -/
theorem real_finrank_of_complex_rank_four
    {H : Type*} [AddCommGroup H] [Module ℂ H]
    (h : Module.finrank ℂ H = 4) :
    Module.finrank ℝ H = 8 := by
  simpa [h, mul_comm] using (finrank_real_of_complex H)

end Coh.Core
