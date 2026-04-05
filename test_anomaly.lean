import Coh.Core.Clifford
import Mathlib.Analysis.NormedSpace.OperatorNorm.Basic

noncomputable section

open Coh.Core

namespace Coh.Spectral

def anomalyStrength {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) (f : Idx → ℝ) : ℝ :=
  ‖anomaly Γ g f‖

lemma anomalyStrength_zero {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) :
    anomalyStrength Γ g (fun _ => 0) = 0 := by
  unfold anomalyStrength anomaly
  simp

lemma oplaxSound_iff_anomalyStrength_zero {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) :
    OplaxSound Γ g ↔ ∀ f : Idx → ℝ, anomalyStrength Γ g f = 0 := by
  unfold OplaxSound anomalyStrength
  simp only [norm_eq_zero]
  exact Iff.rfl

end Coh.Spectral
