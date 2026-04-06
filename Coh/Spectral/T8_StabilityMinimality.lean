import Coh.Thermo.T5_Minimality
import Coh.Gauge.Core

noncomputable section

namespace Coh.Spectral

open Coh.Thermo
open Coh.Gauge
open Coh.Core

--------------------------------------------------------------------
-- Phase 5-6: Stability-Adjusted Minimality (T8)
--------------------------------------------------------------------

/--
The aggregate stability benefit extracted from the formal gauge certification.
-/
def stabilityBenefit (G : Type*) (V : Type*) [CarrierSpace V] [GaugeCertification G V] : ℝ := 
  GaugeCertification.benefit G V

/--
The stability-adjusted cost uses the trackingCost from T5_Minimality
minus the provable certification benefit.
-/
def adjustedCost (G : Type*) (V : Type*) [CarrierSpace V] [GaugeCertification G V]
    (p : MetabolicParams) : ℝ :=
  p.κ * (Module.finrank ℝ V : ℝ) - stabilityBenefit G V

--------------------------------------------------------------------
-- Key T8 Theorems
--------------------------------------------------------------------

/--
T8.1: Generic Gauge Cost Certification
If a symmetry family carries a certified stability benefit, then its benefit is strictly positive.
-/
theorem gauge_benefit_positive (G : Type*) (V : Type*) [CarrierSpace V] [inst : GaugeCertification G V] :
    0 < stabilityBenefit G V := by
  exact inst.benefit_pos

/--
T8.4: Stability Minimality Theorem - Abstract Interface Form
If a symmetry family carries a certified stability benefit, then it survives
the stability-adjusted minimality criterion by strictly reducing the thermodynamic cost.
-/
theorem cost_reduced_of_stabilityBenefit 
    (G : Type*) (V : Type*) [CarrierSpace V] [GaugeCertification G V]
    (p : MetabolicParams) :
    adjustedCost G V p < p.κ * (Module.finrank ℝ V : ℝ) := by
  unfold adjustedCost
  have h_pos := gauge_benefit_positive G V
  linarith

end Coh.Spectral
