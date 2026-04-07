import Coh.Prelude
import Mathlib.Data.Complex.Module
import Mathlib.Data.Complex.FiniteDimensional
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.InnerProductSpace.PiL2

open Coh

noncomputable section

instance : CarrierSpace (Fin 4 → ℂ) where
  -- The underlying type is already a NormedAddCommGroup and NormedSpace ℝ via PiL2.
  -- The finite dimensional instance is provided because Fin 4 is finite and ℂ is finite over ℝ.
  
