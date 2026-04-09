import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Data.Matrix.Basic
import Mathlib.Analysis.NormedSpace.OperatorNorm.Basic

variable {𝕜 : Type*} [IsROrC 𝕜] {n : Type*} [Fintype n]

example (A : Matrix n n 𝕜) : EuclideanSpace 𝕜 n →L[𝕜] EuclideanSpace 𝕜 n :=
  A.toLin' -- Does this work?
