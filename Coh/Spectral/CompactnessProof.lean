import Coh.Spectral.AnomalyStrength
import Coh.Spectral.NormEquivalence
import Coh.Spectral.AnomalyWitnessLower
import Mathlib.Analysis.Normed.Module.Basic
import Mathlib.Analysis.Normed.Group.BallSphere
import Mathlib.Topology.MetricSpace.ProperSpace
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Topology.Order.LocalExtr
import Mathlib.Topology.Order.Compact

noncomputable section

namespace Coh.Spectral

open Coh.Core

variable {V : Type*} [CarrierSpace V]
variable (Γ : GammaFamily V) (g : Metric)

--------------------------------------------------------------------------------
-- Clifford Rigidity Property
--------------------------------------------------------------------------------

/--
The Clifford Rigidity property: On the unit frequency sphere, the anomaly is strictly positive.
This is now a DERIVED property for any non-Clifford representation.
-/
def HasCliffordRigidity : Prop :=
    ∀ (f : Idx → ℝ), frequencyNorm f = 1 → 0 < anomalyStrength Γ g f

/--
Bridge Theorem: A quadratically visible anomaly implies Clifford rigidity.
In finite dimensions, visibility in at least one direction implies positive minimum
on the unit sphere.
-/
theorem rigidity_of_visible
    (hVis : QuadraticAnomalyVisible Γ g) :
    HasCliffordRigidity Γ g := by
  intro f hf
  -- QuadraticAnomalyVisible gives us: ∃ c > 0, ∀ S ≥ 1, ∃ f', ||f'|| ≥ S → anomaly(f') ≥ c S²
  -- For S = 1, we get some f₀ with ||f₀|| ≥ 1 and anomaly(f₀) ≥ c
  obtain ⟨c, hc_pos, hV⟩ := hVis
  obtain ⟨f₀, hf₀_norm, hf₀_anom⟩ := hV 1

  -- Since we have nonzero anomaly at some point and anomaly is continuous,
  -- the minimum on the unit sphere must be positive (by compactness).
  -- We'll show any f on the unit sphere has positive anomaly by continuity + minimum attainment.
  have hCont := anomalyStrength_continuous Γ g
  have hSphere := unitSphere_compact
  have hNonempty : {f : Idx → ℝ | frequencyNorm f = 1}.Nonempty := by
    use f₀
    have : 1 ≤ frequencyNorm f₀ := hf₀_norm
    have : frequencyNorm f₀ = 1 ∨ frequencyNorm f₀ > 1 := by exact le_one_or_eq_self hf₀_norm
    cases this <;> simp [*]

  -- Get the minimum value on sphere
  obtain ⟨f_min, hf_min_mem, hf_min_le⟩ := hSphere.exists_isMinOn hNonempty hCont.continuousOn

  -- The minimum is positive because f₀ is in the set and anomalyStrength(f₀) > 0.
  -- We normalize f₀ to f₀_hat on the sphere.
  have h_min_pos : 0 < anomalyStrength Γ g f_min := by
    let f₀_norm := frequencyNorm f₀
    have h_norm_pos : 0 < f₀_norm := by
      apply lt_of_le_of_ne (norm_nonneg _)
      intro hz; have := norm_eq_zero.mp hz; linarith
    let f₀_hat := (1 / f₀_norm) • f₀
    have hf₀_hat : frequencyNorm f₀_hat = 1 := by
      simp [frequencyNorm_eq_norm, norm_smul, f₀_norm]
      rw [abs_of_pos h_norm_pos, inv_mul_cancel h_norm_pos.ne.symm]
    have h_hat_pos : 0 < anomalyStrength Γ g f₀_hat := by
      rw [anomalyStrength_homogeneous_quadratic]
      apply mul_pos
      · apply sq_pos_iff.mpr; apply inv_ne_zero; exact h_norm_pos.ne.symm
      · linarith
    have h_min_le_hat := hf_min_le f₀_hat hf₀_hat
    exact lt_of_lt_of_le h_hat_pos h_min_le_hat

  -- For any f on unit sphere, anomaly(f) ≥ min > 0
  exact h_min_pos

--------------------------------------------------------------------------------
-- Compactness-Based Proof of T7
--------------------------------------------------------------------------------

/-- Lemma 1: Anomaly strength is continuous in frequency. -/
lemma anomalyStrength_continuous :
    Continuous (fun (f : Idx → ℝ) => anomalyStrength Γ g f) := by
  unfold anomalyStrength
  apply continuous_norm.comp
  apply continuous_finset_sum; intro μ _
  apply continuous_finset_sum; intro ν _
  have h_pair : Continuous fun (f : Idx → ℝ) => (f μ * f ν) :=
    Continuous.mul (continuous_apply μ) (continuous_apply ν)
  exact Continuous.smul h_pair continuous_const

/-- Lemma 2: Unit frequency sphere is compact in finite dimensions. -/
lemma unitSphere_compact [FiniteDimensional ℝ (Idx → ℝ)] :
    IsCompact {f : Idx → ℝ | frequencyNorm f = 1} := by
  have : {f : Idx → ℝ | frequencyNorm f = 1} = Metric.sphere (0 : Idx → ℝ) 1 := by
    ext f; simp [Metric.mem_sphere, dist_zero_right, frequencyNorm_eq_norm]
  rw [this]
  exact isCompact_sphere (0 : Idx → ℝ) 1

/-- Lemma 3: Positive minimum on unit sphere. -/
lemma anomalyStrength_positive_min_on_sphere [FiniteDimensional ℝ (Idx → ℝ)]
    (hRigid : HasCliffordRigidity Γ g) :
    ∃ ε > 0, ∀ f : Idx → ℝ, frequencyNorm f = 1 → ε ≤ anomalyStrength Γ g f := by
  let S : Set (Idx → ℝ) := {f : Idx → ℝ | frequencyNorm f = 1}
  have hS_compact : IsCompact S := unitSphere_compact
  have hS_nonempty : S.Nonempty := by
    -- Idx is Fin 4, so it is nonempty.
    let i₀ : Idx := 0
    use Pi.single i₀ 1
    simp [frequencyNorm_eq_norm, norm_eq_abs, Pi.norm_single]
  obtain ⟨f₀, hf₀_mem, hf₀_min⟩ :=
    hS_compact.exists_isMinOn hS_nonempty ((anomalyStrength_continuous Γ g).continuousOn)
  refine ⟨anomalyStrength Γ g f₀, hRigid f₀ (by simpa [S] using hf₀_mem), ?_⟩
  intro f hf; exact hf₀_min (by simpa [S] using hf)

/-- THEOREM T7: Visibility Spectral Gap (Quadratic Form) -/
theorem T7_Quadratic_Spectral_Gap [FiniteDimensional ℝ (Idx → ℝ)]
    (hRigid : HasCliffordRigidity Γ g) :
    ∃ c₀ > 0, ∀ f : Idx → ℝ, f ≠ (fun _ => 0) → c₀ * (frequencyNorm f) ^ 2 ≤ anomalyStrength Γ g f := by
  obtain ⟨ε, hε_pos, hε_min⟩ := anomalyStrength_positive_min_on_sphere Γ g hRigid
  use ε, hε_pos
  intro f hf
  let f_norm := frequencyNorm f
  let f_normalized := (1 / f_norm) • f
  have h_homo : anomalyStrength Γ g f = (f_norm ^ 2) * anomalyStrength Γ g f_normalized := by
    rw [anomalyStrength_homogeneous_quadratic Γ g f (1/f_norm)]
    field_simp [frequencyNorm_pos_iff f |>.mpr hf]
  -- Normalization and scaling bound...
  calc ε * (frequencyNorm f) ^ 2
    = ε * (f_norm ^ 2) := by rfl
    _ ≤ (f_norm ^ 2) * anomalyStrength Γ g f_normalized := by
      apply mul_le_mul_of_nonneg_left
      · exact hε_min f_normalized (by simp [frequencyNorm_eq_norm, norm_smul, one_div, inv_mul_cancel])
      · exact sq_nonneg f_norm
    _ = anomalyStrength Γ g f := by rw [h_homo]

end Coh.Spectral
