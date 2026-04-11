import Coh.Core.Clifford
import Mathlib.Analysis.Normed.Module.Basic
import Mathlib.Analysis.Normed.Group.BallSphere

namespace Coh.Spectral

open Coh.Core

lemma frequencyNorm_eq_sum (f : Idx → ℝ) :
    (frequencyNorm f)^2 = ∑ i, (f i)^2 := by
  unfold frequencyNorm
  rw [Real.sq_sqrt (by positivity)]

/-- The unit frequency sphere definition. -/
lemma unitFrequencySphere_def :
    {f : Idx → ℝ | (frequencyNorm f)^2 = 1} = {f : Idx → ℝ | ∑ i, (f i)^2 = 1} := by
  sorry

/-- Non-zero frequency profiles have positive frequency norm. -/
lemma frequencyNorm_pos_iff (f : Idx → ℝ) :
    0 < frequencyNorm f ↔ f ≠ 0 := by
  sorry

end Coh.Spectral
