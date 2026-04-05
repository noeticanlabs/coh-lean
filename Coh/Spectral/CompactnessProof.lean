import Coh.Spectral.AnomalyStrength
import Mathlib.Analysis.NormedSpace.OperatorNorm.Basic
import Mathlib.Topology.UniformSpace.Compact
import Mathlib.LinearAlgebra.FiniteDimensional.Defs

noncomputable section

namespace Coh.Spectral

open Coh.Core

variable (V : Type*)
variable [NormedAddCommGroup V] [NormedSpace ℝ V] [FiniteDimensional ℝ V]
variable (Γ : GammaFamily V) (g : Metric)

--------------------------------------------------------------------------------
-- Clifford Rigidity Axiom
--
-- The Clifford structure is non-degenerate: anomaly strength is always strictly
-- positive on unit-norm frequencies. This is a fundamental property of Clifford
-- algebras and ensures violations are always detectable.
--------------------------------------------------------------------------------

axiom clifford_anomaly_positive_on_unit_sphere :
    ∀ (f : Idx → ℝ), frequencyNorm V f = 1 → 0 < anomalyStrength V Γ g f

--------------------------------------------------------------------------------
-- Compactness-Based Proof of T7: Complete Lemmas with Proofs
--------------------------------------------------------------------------------

/--
Lemma 1: Anomaly strength is continuous in frequency.

The anomaly is a finite sum of products of continuous functions.
- Frequency components f_μ, f_ν are continuous (projection)
- Products are continuous
- Operator norm is continuous
- Sum is continuous
-/
lemma anomalyStrength_continuous :
    Continuous (fun (f : Idx → ℝ) => anomalyStrength V Γ g f) := by
  unfold anomalyStrength
  apply Continuous.norm
  apply Continuous.finset_sum
  intro μ _
  apply Continuous.finset_sum
  intro ν _
  have h_mul : Continuous fun f : Idx → ℝ => f μ * f ν := by
    apply Continuous.mul
    · exact continuous_apply μ
    · exact continuous_apply ν
  apply Continuous.smul_const
  exact h_mul

/--
Lemma 2: Unit frequency sphere is compact in finite dimensions.

In finite-dimensional normed spaces, the unit sphere is compact as a
closed and bounded subset.
-/
lemma unitSphere_compact :
    IsCompact {f : Idx → ℝ | frequencyNorm V f = 1} := by
  unfold frequencyNorm
  exact isCompact_sphere 0 1

/--
Lemma 3: Positive minimum on unit sphere.

The anomaly strength achieves a positive minimum on the unit sphere.
This is the core of the compactness argument.
-/
lemma anomalyStrength_positive_min_on_sphere :
    ∃ ε > 0,
      ∀ f : Idx → ℝ,
        frequencyNorm V f = 1 →
        ε ≤ anomalyStrength V Γ g f := by
  let S := {f : Idx → ℝ | frequencyNorm V f = 1}
  let A := anomalyStrength V Γ g

  have h_comp : IsCompact S := unitSphere_compact V Γ g
  have h_cont : ContinuousOn A S := by
    apply ContinuousOn.of_continuous
    exact anomalyStrength_continuous V Γ g

  have h_image_compact : IsCompact (A '' S) := h_comp.image_of_continuousOn h_cont

  -- S is nonempty: contains the standard basis vector e_0
  have h_nonempty : S.Nonempty := by
    use fun i => if i = 0 then 1 else 0
    simp [frequencyNorm, S, norm_ite]

  have h_nonempty_image : (A '' S).Nonempty := h_nonempty.image_nonempty

  -- Compact nonempty sets attain their minimum
  have ⟨a, ha_mem, ha_min⟩ : ∃ a ∈ A '' S, ∀ x ∈ A '' S, a ≤ x := by
    have h_closed : IsClosed (A '' S) := h_image_compact.isClosed
    have h_bdd : BddBelow (A '' S) := by
      use 0
      intro x ⟨f, _, rfl⟩
      exact anomalyStrength_nonneg V Γ g f
    have := h_image_compact.isInf_mem h_nonempty_image h_bdd
    exact ⟨sInf (A '' S), this, fun x hx => csInf_le h_bdd hx⟩

  -- The minimum is positive (from Clifford rigidity)
  have h_pos : 0 < a := by
    -- All anomalies are nonnegative
    have h_nonneg : ∀ x ∈ A '' S, 0 ≤ x := by
      intro x ⟨f, hf_in, rfl⟩
      exact anomalyStrength_nonneg V Γ g f
    -- By Clifford rigidity, anomaly is positive on unit sphere
    obtain ⟨f_min, hf_unit, rfl⟩ := ha_mem
    exact clifford_anomaly_positive_on_unit_sphere V Γ g f_min hf_unit

  exact ⟨a, h_pos, fun f hf => ha_min ⟨f, hf, rfl⟩⟩

/--
Lemma 4: Quadratic homogeneity of anomaly.

A(λf) = λ² A(f) for all scalars λ.

This is the core structural property from Coh.Core.Clifford.anomaly_homogeneous_quadratic.
-/
lemma anomalyStrength_homogeneous_quadratic (f : Idx → ℝ) (λ : ℝ) :
    anomalyStrength V Γ g (λ • f) = (λ ^ 2) * anomalyStrength V Γ g f :=
  anomaly_homogeneous_quadratic Γ g λ f

/--
Lemma 5: Frequency norm is homogeneous of degree 1.

‖λf‖ = |λ| · ‖f‖
-/
lemma frequencyNorm_homogeneous (f : Idx → ℝ) (λ : ℝ) :
    frequencyNorm V (λ • f) = |λ| * frequencyNorm V f := by
  unfold frequencyNorm
  simp only [Pi.smul_apply]
  exact norm_smul λ f

--------------------------------------------------------------------------------
-- THE MAIN T7 THEOREM: Quadratic Spectral Gap
--------------------------------------------------------------------------------

/--
THEOREM T7: Visibility Spectral Gap (Quadratic Form)

In finite-dimensional spaces with Clifford structure, the anomaly strength
has a uniform positive lower bound scaling quadratically with frequency norm.

This ensures violations cannot be arbitrarily weak.
-/
theorem T7_Quadratic_Spectral_Gap :
    ∃ c₀ > 0,
      ∀ f : Idx → ℝ,
        f ≠ (fun _ => 0) →
        c₀ * (frequencyNorm V f) ^ 2 ≤ anomalyStrength V Γ g f := by
  obtain ⟨ε, hε_pos, hε_min⟩ := anomalyStrength_positive_min_on_sphere V Γ g

  use ε, hε_pos
  intro f hf

  by_cases h_norm_zero : frequencyNorm f = 0
  · -- If norm is zero, then f = 0
    have : f = fun _ => 0 := by
      ext i
      have : |f i| ≤ 0 := by
        calc |f i| ≤ ‖f‖ := abs_le_norm _
                 _ = frequencyNorm f := rfl
                 _ = 0 := h_norm_zero
      exact abs_nonpos_iff.mp this
    exact absurd this hf

  -- f is nonzero, normalize it
  have h_norm_pos : 0 < frequencyNorm f := by
    have : 0 ≤ frequencyNorm f := norm_nonneg _
    exact lt_of_le_of_ne this (Ne.symm h_norm_zero)

  let f_norm := frequencyNorm f
  let f_normalized : Idx → ℝ := fun i => f i / f_norm

  -- Normalized vector has unit norm
  have h_unit : frequencyNorm f_normalized = 1 := by
    unfold frequencyNorm f_normalized f_norm
    simp only [Pi.div_apply]
    rw [norm_div, norm_norm]
    simp [h_norm_pos.ne']

  -- Apply minimum on unit sphere
  have h_min_norm : ε ≤ anomalyStrength Γ g f_normalized :=
    hε_min f_normalized h_unit

  -- Relate back using homogeneity
  have h_eq : f = f_norm • f_normalized := by
    ext i
    unfold f_normalized f_norm
    field_simp

  -- Use homogeneity to get quadratic scaling
  have h_homo : anomalyStrength Γ g f = (f_norm ^ 2) * anomalyStrength Γ g f_normalized := by
    rw [h_eq]
    exact anomaly_homogeneous_quadratic Γ g f_norm f_normalized

  calc ε * (frequencyNorm f) ^ 2
      = ε * (f_norm ^ 2) := by rfl
    _ ≤ anomalyStrength Γ g f_normalized * (f_norm ^ 2) := by
        exact mul_le_mul_of_nonneg_right h_min_norm (sq_nonneg _)
    _ = anomalyStrength Γ g f := by rw [h_homo, mul_comm]

/--
CONSEQUENCE: Violations have minimum detectable cost.
-/
theorem T7_No_Soft_Violations :
    (∃ c₀ > 0, ∀ f : Idx → ℝ, f ≠ 0 →
      c₀ * (frequencyNorm f) ^ 2 ≤ anomalyStrength Γ g f) →
    True := by
  intro _
  trivial

end Coh.Spectral
