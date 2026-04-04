import Mathlib.Analysis.Normed.Module.Pi
import Mathlib.Data.Real.Basic

variable {Idx : Type*} [Fintype Idx]
def pairSpike (μ ν : Idx) (R : ℝ) : Idx → ℝ :=
  fun i => if i = μ then R else if i = ν then R else 0

lemma freqNorm_le (μ ν : Idx) (R : ℝ) (hR : 0 < R) : ‖pairSpike μ ν R‖ ≤ 2 * R := by
  sorry
