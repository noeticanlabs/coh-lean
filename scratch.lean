import Coh.Core.Clifford
import Coh.Kinematics.T3_Spikes
import Mathlib.Analysis.NormedSpace.OperatorNorm.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

noncomputable section

namespace Coh.Spectral

open Coh Coh.Core Coh.Kinematics
open scoped BigOperators Real

variable {V : Type u} [CarrierSpace V]
variable (Γ : GammaFamily V) (g : Metric)

lemma anomaly_pairSpike_sum_expansion (μ ν : Idx) (R : ℝ) (hμν : μ ≠ ν) :
    anomaly Γ g (pairSpike μ ν R) = 
    (R^2) • (cliffordMismatchAt Γ g μ μ + 
             cliffordMismatchAt Γ g μ ν + 
             cliffordMismatchAt Γ g ν μ + 
             cliffordMismatchAt Γ g ν ν) := by
  unfold anomaly pairSpike
  change (∑ i, ∑ j, ((if i = μ then R else if i = ν then R else 0) * (if j = μ then R else if j = ν then R else 0)) • cliffordMismatchAt Γ g i j) = _
  
  -- The smaller set on the LHS, bigger on the RHS for `Finset.sum_subset`
  have h_split_i : (∑ i ∈ ({μ, ν} : Finset Idx), ∑ j, ((if i = μ then R else if i = ν then R else 0) * (if j = μ then R else if j = ν then R else 0)) • cliffordMismatchAt Γ g i j) = 
    (∑ i, ∑ j, ((if i = μ then R else if i = ν then R else 0) * (if j = μ then R else if j = ν then R else 0)) • cliffordMismatchAt Γ g i j) := by
    apply Finset.sum_subset
    · apply Finset.subset_univ
    · intro i _ hi
      simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hi
      have hi1 : i ≠ μ := hi.1
      have hi2 : i ≠ ν := hi.2
      simp [hi1, hi2]
  rw [← h_split_i]

  have h_split_j : ∀ i ∈ ({μ, ν} : Finset Idx), 
    (∑ j ∈ ({μ, ν} : Finset Idx), ((if i = μ then R else if i = ν then R else 0) * (if j = μ then R else if j = ν then R else 0)) • cliffordMismatchAt Γ g i j) = 
    (∑ j, ((if i = μ then R else if i = ν then R else 0) * (if j = μ then R else if j = ν then R else 0)) • cliffordMismatchAt Γ g i j) := by
    intro i _
    apply Finset.sum_subset
    · apply Finset.subset_univ
    · intro j _ hj
      simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hj
      have hj1 : j ≠ μ := hj.1
      have hj2 : j ≠ ν := hj.2
      simp [hj1, hj2]

  have h_combine : (∑ x ∈ ({μ, ν} : Finset Idx), ∑ j ∈ ({μ, ν} : Finset Idx), ((if x = μ then R else if x = ν then R else 0) * (if j = μ then R else if j = ν then R else 0)) • cliffordMismatchAt Γ g x j) = 
    ∑ x ∈ ({μ, ν} : Finset Idx), ∑ j, ((if x = μ then R else if x = ν then R else 0) * (if j = μ then R else if j = ν then R else 0)) • cliffordMismatchAt Γ g x j := by
    apply Finset.sum_congr rfl
    exact h_split_j
  rw [← h_combine]

  have h_expand_i : ∑ x ∈ ({μ, ν} : Finset Idx), ∑ j ∈ ({μ, ν} : Finset Idx), ((if x = μ then R else if x = ν then R else 0) * (if j = μ then R else if j = ν then R else 0)) • cliffordMismatchAt Γ g x j = 
    (∑ j ∈ ({μ, ν} : Finset Idx), ((R * (if j = μ then R else if j = ν then R else 0)) • cliffordMismatchAt Γ g μ j)) +
    (∑ j ∈ ({μ, ν} : Finset Idx), ((R * (if j = μ then R else if j = ν then R else 0)) • cliffordMismatchAt Γ g ν j)) := by
    rw [Finset.sum_insert (by intro h; apply hμν; exact Finset.mem_singleton.mp h)]
    rw [Finset.sum_singleton]
    congr 1
    · apply Finset.sum_congr rfl
      intro j _
      simp only [if_true, eq_self_iff_true]
    · apply Finset.sum_congr rfl
      intro j _
      have hnm : ν ≠ μ := hμν.symm
      simp [hnm]
      
  rw [h_expand_i]

  have hnm : ν ≠ μ := hμν.symm

  have h_expand_j1 : ∑ j ∈ ({μ, ν} : Finset Idx), ((R * (if j = μ then R else if j = ν then R else 0)) • cliffordMismatchAt Γ g μ j) = 
    (R * R) • cliffordMismatchAt Γ g μ μ + (R * R) • cliffordMismatchAt Γ g μ ν := by
    rw [Finset.sum_insert (by intro h; apply hμν; exact Finset.mem_singleton.mp h)]
    rw [Finset.sum_singleton]
    simp [hnm, hμν]

  have h_expand_j2 : ∑ j ∈ ({μ, ν} : Finset Idx), ((R * (if j = μ then R else if j = ν then R else 0)) • cliffordMismatchAt Γ g ν j) = 
    (R * R) • cliffordMismatchAt Γ g ν μ + (R * R) • cliffordMismatchAt Γ g ν ν := by
    rw [Finset.sum_insert (by intro h; apply hμν; exact Finset.mem_singleton.mp h)]
    rw [Finset.sum_singleton]
    simp [hnm, hμν]

  rw [h_expand_j1, h_expand_j2]
  simp only [sq, smul_add]
  abel

end Coh.Spectral
