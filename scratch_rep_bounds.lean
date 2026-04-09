import Mathlib.LinearAlgebra.FreeModule.Finite.Matrix
import Mathlib.Data.Complex.FiniteDimensional
import Mathlib.LinearAlgebra.CliffordAlgebra.Contraction
import Mathlib.Data.Fintype.Powerset

open FiniteDimensional

example {K : Type*} [Field K] {H : Type*} [AddCommGroup H] [Module K H]
    [FiniteDimensional K H] :
    Module.finrank K (Module.End K H) = (Module.finrank K H) ^ 2 := by
  simpa [Module.End, pow_two] using
    (Module.finrank_linearMap (R := K) (S := K) (M := H) (N := H))

example {K : Type*} [Field K] {A : Type*} [Ring A] [Algebra K A]
    {H : Type*} [AddCommGroup H] [Module K H]
    [FiniteDimensional K A] [FiniteDimensional K H]
    (ρ : A →ₐ[K] Module.End K H)
    (hρ : Function.Injective ρ) :
    Module.finrank K A ≤ Module.finrank K (Module.End K H) := by
  exact LinearMap.finrank_le_finrank_of_injective (f := ρ.toLinearMap) hρ

#check Complex.finrank_real_complex
#check CliffordAlgebra.equivExterior

variable {Q : QuadraticForm ℂ (Fin 4 → ℂ)}

#synth FiniteDimensional ℂ (CliffordAlgebra Q)

example : Module.finrank ℂ (Fin 4 → ℂ) = 4 := by
  simp

example : Fintype.card (Finset (Fin 4)) = 16 := by
  simp

example : Fintype.card {s : Finset (Fin 4) // s.card = 2} = 6 := by
  norm_num

example {H : Type*} [AddCommGroup H] [Module ℂ H] [FiniteDimensional ℂ H]
    (h : Module.finrank ℂ H = 4) : Module.finrank ℝ H = 8 := by
  simpa [h, mul_comm] using (finrank_real_of_complex H)
