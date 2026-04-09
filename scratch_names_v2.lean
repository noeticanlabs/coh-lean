import Mathlib.Data.Fin.Basic
import Mathlib.Data.Complex.Basic
import Mathlib.Analysis.InnerProductSpace.Basic

-- Test Fin equiv
def test_equiv : Fin 2 ⊕ Fin 2 ≃ Fin 4 := 
  finSumFinEquiv.trans (finCongr (by rfl))

-- Test Complex inner product
example : InnerProductSpace ℝ ℂ := inferInstance
