import Mathlib.Data.Fin.Basic
import Mathlib.Data.Complex.Basic
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.InnerProductSpace.PiL2

def test_equiv : Fin 2 ⊕ Fin 2 ≃ Fin 4 := finSumFinEquiv (show 2 + 2 = 4 from rfl)

instance : InnerProductSpace ℝ ℂ := Complex.innerProductSpace

-- Check if Pi types have InnerProductSpace
example (n : ℕ) : InnerProductSpace ℝ (Fin n → ℂ) := inferInstance
