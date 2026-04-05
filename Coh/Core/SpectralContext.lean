import Coh.Prelude

namespace Coh

universe u

/-- 
Foundational Gamma Family structure. 
All gamma-operator families should use this canonical definition.
-/
structure GammaFamily (V : Type u) [CarrierSpace V] where
  Γ : Idx → V →L[ℝ] V

end Coh
