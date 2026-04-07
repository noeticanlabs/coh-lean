import Coh.Core.Clifford
import Coh.Kinematics.T3_NonCliffordVisible
import Mathlib.Analysis.NormedSpace.OperatorNorm.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

noncomputable section

open Coh Coh.Core Coh.Kinematics
open scoped BigOperators

variable {V : Type*} [CarrierSpace V]
variable (Γ : GammaFamily V) (g : Metric)

lemma double_ite_sum_single (μ₀ : Idx) (R : ℝ) 
    (f : Idx → Idx → V →L[ℝ] V) :
    ∑ μ : Idx, ∑ ν : Idx,
      ((if μ = μ₀ then R else 0) * (if ν = μ₀ then R else 0)) • f μ ν =
    R ^ 2 • f μ₀ μ₀ := by
  -- Step 1: rewrite via congr since (a * b) • x = a • (b • x)
  have step1 : ∀ μ : Idx, ∑ ν : Idx,
      ((if μ = μ₀ then R else 0) * (if ν = μ₀ then R else 0)) • f μ ν =
      (if μ = μ₀ then R else 0) • (R • f μ μ₀) := by
    intro μ
    rw [show ∑ ν : Idx, ((if μ = μ₀ then R else 0) * (if ν = μ₀ then R else 0)) • f μ ν =
      ∑ ν : Idx, (if μ = μ₀ then R else 0) • ((if ν = μ₀ then R else 0) • f μ ν) from by
      apply Finset.sum_congr rfl; intro ν _; rw [mul_smul]]
    rw [← smul_finset_sum]
    congr 1
    rw [Finset.sum_eq_single μ₀]
    · simp
    · intro ν _ hν; simp [hν]
    · intro h; exact absurd (Finset.mem_univ μ₀) h
  simp_rw [step1]
  -- Step 2: collapse outer sum
  simp_rw [smul_smul]
  rw [Finset.sum_eq_single μ₀]
  · ring_nf; rw [sq]
  · intro μ _ hμ; simp [hμ]
  · intro h; exact absurd (Finset.mem_univ μ₀) h

-- anomaly at axisSpike
lemma anomaly_axisSpike_eq (μ₀ : Idx) (R : ℝ) :
    anomaly Γ g (Coh.Kinematics.axisSpike μ₀ R) =
    (R ^ 2) • Coh.Core.cliffordMismatchAt Γ g μ₀ μ₀ := by
  simp only [anomaly, axisSpike, Coh.Core.cliffordMismatchAt]
  exact double_ite_sum_single μ₀ R _

-- Norm of R² • CLM
lemma norm_real_sq_smul_clm (R : ℝ) (x : V →L[ℝ] V) :
    ‖(R ^ 2) • x‖ = R ^ 2 * ‖x‖ := by
  have h := norm_smul (R ^ 2) x
  rw [Real.norm_of_nonneg (sq_nonneg R)] at h
  exact h

-- frequencyNorm axisSpike
lemma frequencyNorm_axisSpike (μ₀ : Idx) (R : ℝ) (hR : 0 ≤ R) :
    Coh.Core.frequencyNorm (Coh.Kinematics.axisSpike μ₀ R) = R := by
  unfold frequencyNorm axisSpike
  have heq : (fun i : Idx => if i = μ₀ then R else (0 : ℝ)) = Pi.single μ₀ R := by
    ext i; simp [Pi.single_apply, eq_comm]
  rw [heq, Pi.norm_single, Real.norm_of_nonneg hR]

-- Lower bound
lemma anomalyStrength_axisSpike_lower
    (μ₀ : Idx) (hW : Coh.Core.IsMismatchWitness Γ g μ₀ μ₀) (R : ℝ) (hR : 0 < R) :
    R ^ 2 * ‖Coh.Core.cliffordMismatchAt Γ g μ₀ μ₀‖ ≤
      ‖anomaly Γ g (Coh.Kinematics.axisSpike μ₀ R)‖ := by
  rw [anomaly_axisSpike_eq Γ g μ₀ R, norm_real_sq_smul_clm]

end Coh.Spectral.WitnessTest
