import Coh.Core.Clifford
import Mathlib.Analysis.Normed.Module.Basic
import Mathlib.Analysis.Normed.Group.BallSphere

namespace Coh.Spectral

open Coh.Core

/-- Identity: frequencyNorm is the standard Euclidean norm. -/
@[simp]
lemma frequencyNorm_eq_norm (f : Idx → ℝ) :
    frequencyNorm f = ‖f‖ := rfl

/-- The unit frequency sphere is exactly the metric sphere (0, 1). -/
@[simp]
lemma unitFrequencySphere_eq_metricSphere :
    {f : Idx → ℝ | frequencyNorm f = 1} = Metric.sphere (0 : Idx → ℝ) 1 := by
  ext f
  simp [Metric.mem_sphere, dist_zero_right]

/-- Non-zero frequency profiles have positive frequency norm. -/
@[simp]
lemma frequencyNorm_pos_iff (f : Idx → ℝ) :
    0 < frequencyNorm f ↔ f ≠ 0 := by
  rw [frequencyNorm_eq_norm, norm_pos_iff]

end Coh.Spectral
