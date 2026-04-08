import Coh.Prelude
import Mathlib.Analysis.NormedSpace.OperatorNorm.Basic

namespace Coh

universe u

/-- 
Foundational Gamma Family structure. 
Refactored to synchronize with the CarrierSpace parameter requirements.
All gamma-operator families should use this canonical definition.
-/
structure GammaFamily (V : Type u) 
    [NormedAddCommGroup V] [NormedSpace ℝ V] [InnerProductSpace ℝ V] [CarrierSpace V] where
  Γ : Idx → V →L[ℝ] V

end Coh
