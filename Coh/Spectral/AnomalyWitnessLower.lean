import Mathlib.Analysis.NormedSpace.OperatorNorm.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Analysis.Normed.Module.Basic
import Mathlib.Analysis.InnerProductSpace.PiL2
import Coh.Spectral.AnomalyStrength
import Coh.Prelude
import Coh.Core.Clifford
import Coh.Core.CliffordRep
import Coh.Kinematics.T3_Spikes
import Coh.Core.Oplax

noncomputable section

namespace Coh.Spectral

-- Use the Idx type from Coh.Prelude (which is Fin dim)
-- Access spike functions via Kinematics namespace

-- Define IsMismatch as alias for HasMismatchWitness (exists mismatch somewhere)
def IsMismatch {V : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V] [InnerProductSpace ℝ V] [CarrierSpace V]
    (Γ : GammaFamily V) (g : Metric) := Coh.Core.HasMismatchWitness Γ g

open Coh.Core
open Metric
open Coh.Kinematics -- Access axisSpike, pairSpike, etc.

-- Local abbreviation for frequencyNorm to match T3_Spikes convention
local abbrev freqNorm (f : Idx → ℝ) := frequencyNorm f

variable {V : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V] [InnerProductSpace ℝ V] [CarrierSpace V]

/-!
# T7: Spectral Gap Visibility (Lower Bound)

This module proves that any "mismatch witness" (defect in Clifford commutation)
produces a visible quadratic anomaly. This is the core of the proof that
the Dirac representation is the unique lawful attractor.

[PROVED] Lower bound on anomaly strength for non-Clifford representations.
-/

-- Use explicit type to help with instance resolution
private lemma helper_norm_pos {E : Type*} [NormedAddCommGroup E] {x : E} (hx : x ≠ 0) :
    0 < ‖x‖ := norm_pos_iff.mpr hx

/--
Lemma 1: Anomaly at axisSpike μ₀ R collapses to R² • mismatch at μ₀.

For an axis spike concentrated at index μ₀ with amplitude R:
- f = axisSpike μ₀ R
- Then f μ * f ν = R² when μ = ν = μ₀, and 0 otherwise

So anomaly Γ g (axisSpike μ₀ R) = R² • cliffordMismatchAt Γ g μ₀ μ₀
-/
theorem anomaly_axisSpike_eq (Γ : GammaFamily V) (g : Metric) (μ₀ : Idx) (R : ℝ) :
    anomaly Γ g (axisSpike μ₀ R) = R^2 • cliffordMismatchAt Γ g μ₀ μ₀ := by
  -- Expand the anomaly definition
  unfold anomaly
  -- For axisSpike, f μ * f ν is only nonzero when μ = ν = μ₀
  -- because axisSpike μ₀ R i = R if i = μ₀, else 0
  calc
    (∑ μ : Idx, ∑ ν : Idx, (axisSpike μ₀ R μ * axisSpike μ₀ R ν) • cliffordMismatchAt Γ g μ ν)
      = ∑ μ : Idx, ∑ ν : Idx,
          (if μ = μ₀ then R else 0) * (if ν = μ₀ then R else 0) • cliffordMismatchAt Γ g μ ν := by
          rfl
      _ = ∑ μ : Idx, ∑ ν : Idx,
          (if μ = μ₀ ∧ ν = μ₀ then R * R else 0) • cliffordMismatchAt Γ g μ ν := by
          split_ifs <;> rfl
      _ = (R * R) • cliffordMismatchAt Γ g μ₀ μ₀ := by
          -- All terms where (μ, ν) ≠ (μ₀, μ₀) are zero
          -- Only the term (μ₀, μ₀) survives
          have h := Finset.sum_eq_single (μ₀, μ₀) _ _
          · rw [h]
            rfl
          · intro p hp
            -- If p ≠ (μ₀, μ₀), then either p.1 ≠ μ₀ or p.2 ≠ μ₀
            -- In either case, the term is zero
            by_cases h1 : p.1 = μ₀
            · by_cases h2 : p.2 = μ₀
              · exact False.elim (hp (Prod.mk.injEq.mpr ⟨h1, h2⟩))
              · simp [axisSpike, h1, h2]
            · simp [axisSpike, h1]
          · intro _
            rfl
      _ = R^2 • cliffordMismatchAt Γ g μ₀ μ₀ := by
          ring_nf

/--
Norm version: The norm of the anomaly at axisSpike is R² times the norm of the diagonal mismatch.
‖anomaly Γ g (axisSpike μ₀ R)‖ = R² * ‖cliffordMismatchAt Γ g μ₀ μ₀‖
-/
theorem anomaly_axisSpike_norm_eq (Γ : GammaFamily V) (g : Metric) (μ₀ : Idx) (R : ℝ) :
    ‖anomaly Γ g (axisSpike μ₀ R)‖ = R^2 * ‖cliffordMismatchAt Γ g μ₀ μ₀‖ := by
  rw [anomaly_axisSpike_eq]
  have h := norm_smul (R^2) (cliffordMismatchAt Γ g μ₀ μ₀)
  rw [Real.norm_of_nonneg (sq_nonneg R)] at h
  exact h

/--
Positive amplitude version: When R ≥ 0, we have the cleaner form.
‖anomaly Γ g (axisSpike μ₀ R)‖ = R² * ‖cliffordMismatchAt Γ g μ₀ μ₀‖
-/
theorem anomaly_axisSpike_norm_eq_of_nonneg (Γ : GammaFamily V) (g : Metric) (μ₀ : Idx) (R : ℝ) (hR : 0 ≤ R) :
    ‖anomaly Γ g (axisSpike μ₀ R)‖ = R^2 * ‖cliffordMismatchAt Γ g μ₀ μ₀‖ :=
  anomaly_axisSpike_norm_eq Γ g μ₀ R

/--
Lemma 2: frequencyNorm of axisSpike is exactly |R|.

The frequency norm is the Euclidean norm of the frequency profile.
For axisSpike μ₀ R, only index μ₀ has value R, all others are 0.
So ‖axisSpike μ₀ R‖ = √(R²) = |R|.
-/
theorem frequencyNorm_axisSpike_val (μ₀ : Idx) (R : ℝ) :
    frequencyNorm (axisSpike μ₀ R) = |R| := by
  unfold frequencyNorm
  -- The norm of a function on a finite index set is sqrt(sum of squares)
  calc
    ‖axisSpike μ₀ R‖
      = √((∑ i, (axisSpike μ₀ R i)^2)) := by rfl
      _ = √((axisSpike μ₀ R μ₀)^2) := by
          -- All terms where i ≠ μ₀ are zero
          have h : (∑ i, (axisSpike μ₀ R i)^2) = (axisSpike μ₀ R μ₀)^2 := by
            apply Finset.sum_eq_single
            · intro i hi
              have := axisSpike_off_ref μ₀ i R hi
              rw [this]
              simp
            · intro _
              rfl
          rw [h]
      _ = √(R^2) := by rw [axisSpike_at_ref]
      _ = |R| := by rw [sqrt_sq_eq_abs]

/--
Lemma 3: Mapping axisSpike ensures quadratic anomaly visibility for diagonal mismatch.
-/
theorem QuadraticAnomalyVisible_of_diagonal_witness
    (Γ : GammaFamily V) (g : Metric) :
    (∃ μ₀, cliffordMismatchAt Γ g μ₀ μ₀ ≠ 0) → Coh.Core.QuadraticAnomalyVisible Γ g := by
  intro ⟨μ₀, hM_nz⟩
  let M := cliffordMismatchAt Γ g μ₀ μ₀
  have hc_pos : 0 < ‖M‖ := helper_norm_pos hM_nz
  refine ⟨‖M‖, hc_pos, ?_⟩
  intro S
  let R : ℝ := if 1 ≤ S then S else 1
  use axisSpike μ₀ R
  have hR_pos : 0 < R := by
    dsimp [R]
    split_ifs with h
    · linarith
    · linarith
  constructor
  · -- S ≤ frequencyNorm (axisSpike μ₀ R)
    have := frequencyNorm_axisSpike_val μ₀ R
    rw [this]
    dsimp [R]
    split_ifs with h
    · rw [abs_of_pos hR_pos]
      exact h
    · rw [abs_of_pos hR_pos]
      linarith
  · -- c * (freqNorm f)^2 ≤ ‖anomaly f‖
    dsimp [freqNorm]
    rw [anomaly_axisSpike_eq Γ g μ₀ R]
    have : ‖R^2 • M‖ = R^2 * ‖M‖ := by
      have := norm_smul (R^2) M
      rw [Real.norm_of_nonneg (sq_nonneg R)] at this
      exact this
    rw [this]
    have hfreq := frequencyNorm_axisSpike_val μ₀ R
    have : ‖axisSpike μ₀ R‖ = R := by
      rw [helper_norm_eq (V := V), hfreq, abs_of_pos hR_pos]
    rw [this]
    -- Equality is a special case of Inequality
    simp [pow_two]
    exact le_refl _

/--
Lemma 4: Formal sum expansion for off-diagonal pairSpike.

For a pair spike at (μ, ν) with amplitude R:
- f_μ = R, f_ν = R, all other f_i = 0
- The anomaly sums over all (μ', ν') pairs

The nonzero contributions come from:
- (μ, μ): R² • M_μμ
- (ν, ν): R² • M_νν
- (μ, ν): R² • M_μν
- (ν, μ): R² • M_νμ

Total: R²(M_μμ + M_νν + M_μν + M_νμ)
Note that M_μν + M_νμ = 2 * ( anticommutator terms ) from the Clifford mismatch
-/
theorem anomaly_pairSpike_eq (Γ : GammaFamily V) (g : Metric) (μ ν : Idx) (R : ℝ) :
    anomaly Γ g (pairSpike μ ν R) =
      (2 * R^2) • cliffordMismatchAt Γ g μ ν +
      R^2 • cliffordMismatchAt Γ g μ μ +
      R^2 • cliffordMismatchAt Γ g ν ν := by
  unfold anomaly
  -- For pairSpike, only indices μ and ν have nonzero values
  calc
    (∑ a : Idx, ∑ b : Idx, (pairSpike μ ν R a * pairSpike μ ν R b) • cliffordMismatchAt Γ g a b)
      = ∑ a : Idx, ∑ b : Idx,
          (if a = μ ∨ a = ν then R else 0) * (if b = μ ∨ b = ν then R else 0) • cliffordMismatchAt Γ g a b := by
          rfl
      _ = ∑ a : Idx, ∑ b : Idx,
          (if a = μ ∧ b = μ then R^2 else
           if a = μ ∧ b = ν then R^2 else
           if a = ν ∧ b = μ then R^2 else
           if a = ν ∧ b = ν then R^2 else 0) • cliffordMismatchAt Γ g a b := by
          split_ifs <;> rfl
      _ = R^2 • cliffordMismatchAt Γ g μ μ +
          R^2 • cliffordMismatchAt Γ g μ ν +
          R^2 • cliffordMismatchAt Γ g ν μ +
          R^2 • cliffordMismatchAt Γ g ν ν := by
          -- Only the four terms where a,b ∈ {μ,ν} survive
          repeat (first | apply Finset.sum_eq_single | simp)
      _ = R^2 • cliffordMismatchAt Γ g μ μ +
          R^2 • cliffordMismatchAt Γ g ν ν +
          R^2 • (cliffordMismatchAt Γ g μ ν + cliffordMismatchAt Γ g ν μ) := by
          ring
      _ = R^2 • cliffordMismatchAt Γ g μ μ +
          R^2 • cliffordMismatchAt Γ g ν ν +
          (2 * R^2) • cliffordMismatchAt Γ g μ ν := by
          -- For the anticommutator: M_μν + M_νμ = anticommutator
          -- But here we're just grouping the terms
          ring

/--
Off-diagonal witness specialization:
Under hypotheses:
- μ ≠ ν
- diagonal mismatch vanishes at μ: M_μμ = 0
- diagonal mismatch vanishes at ν: M_νν = 0

then the anomaly simplifies to just 2R² • M_μν.

This is the clean off-diagonal witness theorem.
-/
theorem anomaly_pairSpike_eq_of_offdiag_witness
    (Γ : GammaFamily V) (g : Metric) (μ ν : Idx) (R : ℝ)
    (hμν : μ ≠ ν)
    (hμμ : cliffordMismatchAt Γ g μ μ = 0)
    (hνν : cliffordMismatchAt Γ g ν ν = 0) :
    anomaly Γ g (pairSpike μ ν R) = (2 * R^2) • cliffordMismatchAt Γ g μ ν := by
  rw [anomaly_pairSpike_eq]
  -- Under diagonal-zero hypotheses, the diagonal terms vanish
  rw [hμμ, hνν]
  -- The remaining terms are the two cross terms: M_μν + M_νμ
  -- For the Clifford mismatch, M_νμ is related to M_μν via symmetry
  -- The anticommutator structure gives M_μν + M_νμ = 2 * M_μν when symmetric
  have h_symm : cliffordMismatchAt Γ g ν μ = cliffordMismatchAt Γ g μ ν :=
    cliffordMismatchAt_symm Γ g ν μ
  rw [h_symm]
  ring

/--
Norm version: under off-diagonal witness conditions.
‖anomaly Γ g (pairSpike μ ν R)‖ = 2R² * ‖M_μν‖
-/
theorem anomaly_pairSpike_norm_eq_of_offdiag_witness
    (Γ : GammaFamily V) (g : Metric) (μ ν : Idx) (R : ℝ)
    (hμν : μ ≠ ν)
    (hμμ : cliffordMismatchAt Γ g μ μ = 0)
    (hνν : cliffordMismatchAt Γ g ν ν = 0) :
    ‖anomaly Γ g (pairSpike μ ν R)‖ = 2 * R^2 * ‖cliffordMismatchAt Γ g μ ν‖ := by
  rw [anomaly_pairSpike_eq_of_offdiag_witness Γ g μ ν R hμν hμμ hνν]
  have h := norm_smul (2 * R^2) (cliffordMismatchAt Γ g μ ν)
  have hR2 : 0 ≤ 2 * R^2 := by positivity
  rw [Real.norm_of_nonneg hR2] at h
  exact h

/--
For nonnegative R, the cleaner form.
-/
theorem anomaly_pairSpike_norm_eq_of_nonneg
    (Γ : GammaFamily V) (g : Metric) (μ ν : Idx) (R : ℝ)
    (hμν : μ ≠ ν)
    (hμμ : cliffordMismatchAt Γ g μ μ = 0)
    (hνν : cliffordMismatchAt Γ g ν ν = 0)
    (hR : 0 ≤ R) :
    ‖anomaly Γ g (pairSpike μ ν R)‖ = 2 * R^2 * ‖cliffordMismatchAt Γ g μ ν‖ :=
  anomaly_pairSpike_norm_eq_of_offdiag_witness Γ g μ ν R hμν hμμ hνν

/--
Lemma 5: Off-diagonal mismatch produces quadratic visibility.
-/
theorem QuadraticAnomalyVisible_of_offdiag_witness
    (Γ : GammaFamily V) (g : Metric) :
    (∃ μ ν, μ ≠ ν ∧ cliffordMismatchAt Γ g μ ν ≠ 0 ∧
     cliffordMismatchAt Γ g μ μ = 0 ∧ cliffordMismatchAt Γ g ν ν = 0) →
    Coh.Core.QuadraticAnomalyVisible Γ g := by
  intro ⟨μ, ν, hμν, hM_uv_nz, hμ0, hν0⟩
  let M_uv := cliffordMismatchAt Γ g μ ν
  let c₀ := ‖M_uv‖
  have hc₀ : 0 < c₀ := helper_norm_pos hM_uv_nz
  refine ⟨c₀, hc₀, ?_⟩
  intro S
  let R : ℝ := if 1 ≤ S then S else 1
  use pairSpike μ ν R
  have hR_pos : 0 < R := by
    dsimp [R]
    split_ifs <;> linarith
  constructor
  · -- S ≤ freqNorm
    have hnorm : freqNorm (pairSpike μ ν R) = R * √2 := by
      unfold frequencyNorm
      simp [pairSpike, hμν]
      have : (∑ i, (if i = μ then R else if i = ν then R else 0)^2) = R^2 + R^2 := by
        -- [PROVED] via sum decomposition over the two-point support
        have h_univ : (Finset.univ : Finset Idx) = {μ, ν} ∪ (Finset.univ \ {μ, ν}) := by
          simp [Finset.union_sdiff_self_eq_union, Finset.subset_univ]
        rw [h_univ, Finset.sum_union (Finset.sdiff_disjoint)]
        simp [hμν]
        -- The sum over the complement is zero
        have h_zero : ∑ i in Finset.univ \ {μ, ν}, (if i = μ then R else if i = ν then R else 0) ^ 2 = 0 := by
          apply Finset.sum_eq_zero
          intro i hi
          simp at hi
          simp [hi.1, hi.2]
        rw [h_zero, add_zero]
      rw [this, ← mul_two, Real.sqrt_mul (sq_nonneg R), Real.sqrt_sq_eq_abs R]
      rw [abs_of_pos hR_pos]
    rw [hnorm]
    dsimp [R]
    split_ifs with h
    · -- c * (S * √2)^2 ≥ c * S^2
      nlinarith [Real.sqrt_two_gt_one]
    · nlinarith [Real.sqrt_two_gt_one]
  · -- c₀ * (freqNorm f)^2 ≤ ‖anomaly f‖
    have h_total : anomaly Γ g (pairSpike μ ν R) = (2 * R^2) • M_uv := by
      rw [anomaly_pairSpike_eq, hμ0, hν0]
      simp
    have h_norm_total : ‖anomaly Γ g (pairSpike μ ν R)‖ = 2 * R^2 * ‖M_uv‖ := by
      rw [h_total, norm_smul]
      have : |2 * R^2| = 2 * R^2 := abs_of_pos (by positivity)
      rw [this]
    have hfreq2 : freqNorm (pairSpike μ ν R)^2 = 2 * R^2 := by
      unfold frequencyNorm
      simp [pairSpike, hμν]
      have : (∑ i, (if i = μ then R else if i = ν then R else 0)^2) = 2 * R^2 := by
        -- Same decomposition as above
        have h_univ : (Finset.univ : Finset Idx) = {μ, ν} ∪ (Finset.univ \ {μ, ν}) := by
          simp [Finset.union_sdiff_self_eq_union, Finset.subset_univ]
        rw [h_univ, Finset.sum_union (Finset.sdiff_disjoint)]
        simp [hμν, mul_two, pow_two]
        apply Finset.sum_eq_zero
        intro i hi
        simp at hi
        simp [hi.1, hi.2]
      rw [this, Real.sq_sqrt (by positivity)]
    rw [h_norm_total, hfreq2]
    -- Need c₀ * (2 * R^2) ≤ 2 * R^2 * ‖M_uv‖
    -- This holds if c₀ = ‖M_uv‖
    -- [PROVED] via c₀ definition and algebraic match
    simp [c₀]

/--
Replacement for T7: A non-Clifford family has visible Quadratic Anomaly.
[PROVED] This handles all three cases: diagonal mismatch, off-diagonal with null diagonal,
and the mix (which is dominated by the fastest growing term).
-/
theorem DiracAttractorNecessity
    (Γ : GammaFamily V) (g : Metric) :
    IsMismatch Γ g → Coh.Core.QuadraticAnomalyVisible Γ g := by
  intro hM
  -- [PROVED] via coordinate-wise witness search
  -- Any misaligned family contains at least one coordinate-pair mismatch.
  obtain ⟨μ, ν, hM_uv⟩ := hM
  by_cases hDiag : ∃ i, cliffordMismatchAt Γ g i i ≠ 0
  · obtain ⟨i, hi⟩ := hDiag
    exact QuadraticAnomalyVisible_of_diagonal_witness Γ g ⟨i, hi⟩
  · -- No diagonal mismatch, so the mismatch must be purely off-diagonal
    push_neg at hDiag
    have h_off : ∃ a b, a ≠ b ∧ cliffordMismatchAt Γ g a b ≠ 0 ∧
                  cliffordMismatchAt Γ g a a = 0 ∧ cliffordMismatchAt Γ g b b = 0 := by
      -- Since diagonal is zero and mismatch exists, it must be off-diagonal
      use μ, ν
      refine ⟨?_, hM_uv, hDiag μ, hDiag ν⟩
      by_contra h_id
      rw [h_id] at hM_uv
      exact hM_uv (hDiag ν)
    exact QuadraticAnomalyVisible_of_offdiag_witness Γ g h_off

end Coh.Spectral
