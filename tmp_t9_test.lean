import Coh.Core.Clifford

noncomputable section

namespace Coh.Spectral

open Coh.Core

variable {V : Type*} [CarrierSpace V]
variable (Γ : GammaFamily V) (g : Metric)

theorem commutation_implies_gauge_invariance
    (J : V →L[ℝ] V)
    (h_comm : ∀ μ, J.comp (Γ.Γ μ) = (Γ.Γ μ).comp J) :
    ∀ f : Idx → ℝ, J.comp (anomaly Γ g f) = (anomaly Γ g f).comp J := by
  intro f
  ext v
  unfold anomaly
  simp only [ContinuousLinearMap.comp_apply, ContinuousLinearMap.sum_apply, ContinuousLinearMap.smul_apply, ContinuousLinearMap.sub_apply]
  simp_rw [map_sum, map_smul, map_sub]
  apply Finset.sum_congr rfl
  intro μ _
  apply Finset.sum_congr rfl
  intro ν _
  have hA_μ : ∀ x, J ((Γ.Γ μ) x) = (Γ.Γ μ) (J x) := by
    intro x
    exact ContinuousLinearMap.ext_iff.mp (h_comm μ) x
  have hA_ν : ∀ x, J ((Γ.Γ ν) x) = (Γ.Γ ν) (J x) := by
    intro x
    exact ContinuousLinearMap.ext_iff.mp (h_comm ν) x
  unfold anticommutator idOp
  simp only [ContinuousLinearMap.comp_apply, ContinuousLinearMap.add_apply, ContinuousLinearMap.id_apply, ContinuousLinearMap.smul_apply]
  simp only [map_add, map_smul]
  rw [hA_ν, hA_μ, hA_μ, hA_ν]
  -- map_sub J x y = J x - J y
  rfl

end Coh.Spectral
