import Mathlib.Data.Complex.Module
import Mathlib.LinearAlgebra.FiniteDimensional
#check Complex.finrank_real_complex
-- Also try:
example : Module.finrank ℝ ℂ = 2 := Complex.finrank_real_complex
