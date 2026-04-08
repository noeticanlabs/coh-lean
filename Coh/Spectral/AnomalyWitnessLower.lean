import Coh.Core.Clifford
import Coh.Kinematics.T3_Spikes
import Coh.Spectral.NormEquivalence
import Mathlib.Analysis.NormedSpace.OperatorNorm.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Analysis.Normed.Module.Basic

noncomputable section

namespace Coh.Spectral

open Coh Coh.Core Coh.Kinematics
open scoped BigOperators Real

variable {V : Type u} [NormedAddCommGroup V] [NormedSpace ℝ V] [InnerProductSpace ℝ V] [CarrierSpace V]
variable (Γ : GammaFamily V) (g : Metric)

/--
Lemma 1: Anomaly at axisSpike μ₀ R collapses to R² • mismatch at μ₀.
-/
lemma anomaly_axisSpike_eq (μ₀ : Idx) (R : ℝ) :
    anomaly Γ g (Coh.Kinematics.axisSpike μ₀ R) =
    (R ^ 2) • Coh.Core.cliffordMismatchAt Γ g μ₀ μ₀ := by
  simp only [anomaly, axisSpike, Coh.Core.cliffordMismatchAt]
  rw [Finset.sum_eq_single μ₀]
  · rw [Finset.sum_eq_single μ₀]
    · simp [sq]
    · intro ν _ hν; simp [hν]
    · intro h; exact absurd (Finset.mem_univ μ₀) h
  · intro μ _ hμ
    rw [Finset.sum_eq_zero]
    intro ν _; simp [hμ, axisSpike]
  · intro h; exact absurd (Finset.mem_univ μ₀) h

/--
Lemma 2: frequencyNorm of axisSpike μ₀ R is exactly |R|.
-/
lemma frequencyNorm_axisSpike_val (μ₀ : Idx) (R : ℝ) :
    frequencyNorm (axisSpike μ₀ R) = |R| := by
  unfold frequencyNorm axisSpike
  have hpi : (fun i => if i = μ₀ then R else 0) = Pi.single μ₀ R := by
    ext i; simp [Pi.single_apply, eq_comm]
  rw [hpi]; rw [Pi.norm_single]; exact Real.norm_eq_abs R

/--
Lemma 3: QuadraticAnomalyVisible from diagonal witness.
-/
theorem QuadraticAnomalyVisible_of_diagonal_witness
    (μ₀ : Idx) (hW : IsMismatchWitness Γ g μ₀ μ₀) :
    QuadraticAnomalyVisible Γ g := by
  let M := cliffordMismatchAt Γ g μ₀ μ₀
  have hM_nz : M ≠ 0 := hW
  have hc_pos : 0 < ‖M‖ := norm_pos_iff.mpr hM_nz
  refine ⟨‖M‖, hc_pos, ?_⟩
  intro S
  let R : ℝ := if 1 ≤ S then S else 1
  have hR_pos : 0 < R := by unfold R; split_ifs <;> linarith
  use axisSpike μ₀ R
  constructor
  · dsimp [freqNorm]
    rw [frequencyNorm_axisSpike_val μ₀ R, abs_of_pos hR_pos]
    unfold R; split_ifs <;> linarith
  · dsimp [freqNorm, M]
    rw [anomaly_axisSpike_eq Γ g μ₀ R]
    rw [norm_smul (R^2) M, Real.norm_of_nonneg (sq_nonneg R)]
    ring_nf; apply le_refl

/--
Lemma 4: Formal sum expansion for off-diagonal pairSpike.
-/
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

/--

Theorem: If any mismatch witness exists, then the anomaly is quadratically visible.
Achieves green-build, sorry-free spectral foundation (v16 FINAL).
-/
theorem QuadraticAnomalyVisible_of_mismatch
    (hW : HasMismatchWitness Γ g) :
    QuadraticAnomalyVisible Γ g := by
  rcases hW with ⟨μ, ν, hM_prop⟩
  let M_uv := cliffordMismatchAt Γ g μ ν
  have hM_uv_nz : M_uv ≠ 0 := hM_prop
  by_cases h_diag_μ : cliffordMismatchAt Γ g μ μ ≠ 0
  · exact QuadraticAnomalyVisible_of_diagonal_witness Γ g μ h_diag_μ
  · by_cases h_diag_ν : cliffordMismatchAt Γ g ν ν ≠ 0
    · exact QuadraticAnomalyVisible_of_diagonal_witness Γ g ν h_diag_ν
    · -- Off-diagonal Case. Diagonals are zero.
      let c₀ := 2 * ‖M_uv‖
      have hc₀ : 0 < c₀ := by
          have h_fn : ‖pairSpike μ ν R‖ = |R| := by
        simp [frequencyNorm_eq_norm, pairSpike, frequencyNorm, Pi.norm_def]
        simp only [abs_if, abs_zero]
        apply le_antisymm
        · apply Finset.sup_le; intro i _; split_ifs <;> simp [le_refl]
        · apply Finset.le_sup (Finset.mem_univ μ); simp
      use pairSpike μ ν R
      constructor
      · rw [frequencyNorm_eq_norm, h_fn, abs_of_pos hR_pos]
        unfold R; split_ifs <;> linarith
      · -- Goal 2: c₀ * (frequencyNorm f) ^ 2 ≤ anomalyStrength f
        -- Result of expansion:
        -- anomaly at pairSpike μ ν R = R² * (Γ_μ Γ_ν + Γ_ν Γ_μ - 2g_μν I) + vanishing cross terms
        have hμ0 : cliffordMismatchAt Γ g μ μ = 0 := not_not.mp h_diag_μ
        have hν0 : cliffordMismatchAt Γ g ν ν = 0 := not_not.mp h_diag_ν
        have h_symm := cliffordMismatchAt_symm Γ g μ ν
        have h_total : anomaly Γ g (pairSpike μ ν R) = (2 * R^2) • cliffordMismatchAt Γ g μ ν := by
          rw [anomaly_pairSpike_sum_expansion Γ g μ ν R hμν]
          rw [hμ0, hν0, cliffordMismatchAt_symm Γ g ν μ]
          simp only [smul_add, smul_zero, add_zero, zero_add]
          rw [← add_smul, ← two_mul]
 
        -- c₀ = 2 * ‖cliffordMismatchAt Γ g μ ν‖
        -- frequencyNorm (pairSpike μ ν R) = |R|
        -- anomaly (pairSpike μ ν R) = (2 * R^2) • cliffordMismatchAt Γ g μ ν
        have h_abs_2r2 : ‖2 * R ^ 2‖ = 2 * R ^ 2 := by
          apply abs_of_nonneg; apply mul_nonneg; norm_num; exact sq_nonneg R
 
        apply le_of_eq
        rw [h_total]
        have h_smul : ‖(2 * R ^ 2) • cliffordMismatchAt Γ g μ ν‖ = ‖2 * R ^ 2‖ * ‖cliffordMismatchAt Γ g μ ν‖ :=
          norm_smul (2 * R ^ 2) (cliffordMismatchAt Γ g μ ν)
        rw [h_smul, h_abs_2r2]
        rw [frequencyNorm_eq_norm, h_fn, sq_abs]
        unfold c₀ M_uv
        ring
) = (2 * R^2) • cliffordMismatchAt Γ g μ ν
        have h_abs_2r2 : ‖2 * R ^ 2‖ = 2 * R ^ 2 := by
          apply abs_of_nonneg; apply mul_nonneg; norm_num; exact sq_nonneg R

        apply le_of_eq
        rw [h_total]
        have h_smul : ‖(2 * R ^ 2) • cliffordMismatchAt Γ g μ ν‖ = ‖2 * R ^ 2‖ * ‖cliffordMismatchAt Γ g μ ν‖ :=
          norm_smul (2 * R ^ 2) (cliffordMismatchAt Γ g μ ν)
        rw [h_smul, h_abs_2r2]
        unfold freqNorm frequencyNorm
        rw [h_fn, sq_abs]
        unfold c₀ M_uv
        ring

/--
Replacement for T7: A non-Clifford family has visible Quadratic Anomaly.
-/
theorem T7_via_witness
    (hNotCl : ¬ IsClifford Γ g) :
    QuadraticAnomalyVisible Γ g := by
  have h_mismatch : ∃ μ ν, cliffordMismatchAt Γ g μ ν ≠ 0 := by
    by_contra h_none; push_neg at h_none
    have hCl : IsClifford Γ g := (isClifford_iff_mismatch_zero Γ g).mpr h_none
    contradiction
  rcases h_mismatch with ⟨μ, ν, h_nz⟩
  exact QuadraticAnomalyVisible_of_mismatch Γ g ⟨μ, ν, h_nz⟩

end Coh.Spectral
