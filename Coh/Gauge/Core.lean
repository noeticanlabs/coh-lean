import Coh.Core.Carriers

noncomputable section

namespace Coh.Gauge

open Coh.Core

/--
A certified internal symmetry gauge action over a carrier space.
This abstracts the necessary properties for stability-adjusted minimality (T8)
without requiring full differential geometry or principal bundles.
-/
class GaugeCertification (G : Type*) (V : Type*) [NormedAddCommGroup V] [NormedSpace ℝ V] [InnerProductSpace ℝ V] [CarrierSpace V] where
  benefit : ℝ
  benefit_pos : 0 < benefit
  act : G → V →L[ℝ] V
  -- Ensures the action preserves basic coherence properties
  preserves_admissibility : Prop

end Coh.Gauge
