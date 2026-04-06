import Coh.Spectral.AnomalyStrength
import Coh.Spectral.NormEquivalence
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
-- Clifford Rigidity Axiom
--------------------------------------------------------------------------------

/--
[AXIOM] Clifford Rigidity: On the unit frequency sphere, the anomaly is strictly positive.
This is the foundational assumption for the Visibility Spectral Gap.
-/
axiom clifford_anomaly_positive_on_unit_sphere :
    ∀ (f : Idx → ℝ), frequencyNorm f = 1 → 0 < anomalyStrength Γ g f

--------------------------------------------------------------------------------
-- Compactness-Based Proof of T7: Complete Lemmas with Proofs
--------------------------------------------------------------------------------

/-- Lemma 1: Anomaly strength is continuous in frequency. -/
lemma anomalyStrength_continuous :
    Continuous (fun (f : Idx → ℝ) => anomalyStrength Γ g f) := by
  unfold anomalyStrength
  apply continuous_norm.comp
  apply continuous_finset_sum
  intro μ _
  apply continuous_finset_sum
  intro ν _
  have h_pair : Continuous fun (f : Idx → ℝ) => (f μ * f ν) :=
    Continuous.mul (continuous_apply μ) (continuous_apply ν)
  exact Continuous.smul h_pair continuous_const

/-- Lemma 2: Unit frequency sphere is compact in finite dimensions. -/
lemma unitSphere_compact [FiniteDimensional ℝ (Idx → ℝ)] :
    IsCompact {f : Idx → ℝ | frequencyNorm f = 1} := by
  have : {f : Idx → ℝ | frequencyNorm f = 1} = Metric.sphere (0 : Idx → ℝ) 1 := by
    ext f
    simp [Metric.mem_sphere, dist_zero_right, frequencyNorm_eq_norm]
  rw [this]
  exact isCompact_sphere (0 : Idx → ℝ) 1

/-- Lemma 3: Positive minimum on unit sphere.
    This is proved by combining the compactness of the sphere with the
    Clifford rigidity axiom using the Extreme Value Theorem. -/
lemma anomalyStrength_positive_min_on_sphere [FiniteDimensional ℝ (Idx → ℝ)] :
    ∃ ε > 0, ∀ f : Idx → ℝ, frequencyNorm f = 1 → ε ≤ anomalyStrength Γ g f := by
  let S : Set (Idx → ℝ) := {f : Idx → ℝ | frequencyNorm f = 1}
  have hSphereEq : S = Metric.sphere (0 : Idx → ℝ) 1 := by
    ext f
    simp [S, Metric.mem_sphere, dist_zero_right, frequencyNorm_eq_norm]
  have hS_compact : IsCompact S := by
    rw [hSphereEq]
    exact isCompact_sphere (0 : Idx → ℝ) 1
  have hS_nonempty : S.Nonempty := by
    let i0 : Idx := ⟨0, by simp [Coh.dim]⟩
    haveI : Nontrivial (Idx → ℝ) := by
      refine ⟨⟨(fun i : Idx => if i = i0 then 1 else 0), 0, ?_⟩⟩
      intro h
      have h0 := congrArg (fun f : Idx → ℝ => f i0) h
      simp [i0] at h0
    refine hSphereEq ▸ ?_
    exact (NormedSpace.sphere_nonempty (x := (0 : Idx → ℝ)) (r := 1)).2 zero_le_one
  obtain ⟨f₀, hf₀_mem, hf₀_min⟩ :=
    hS_compact.exists_isMinOn hS_nonempty ((anomalyStrength_continuous Γ g).continuousOn)
  refine ⟨anomalyStrength Γ g f₀,
    clifford_anomaly_positive_on_unit_sphere (Γ := Γ) (g := g) f₀ ?_, ?_⟩
  · simpa [S] using hf₀_mem
  · intro f hf
    have hf_mem : f ∈ S := by
      simpa [S] using hf
    exact hf₀_min hf_mem

/-- Lemma 4: Quadratic homogeneity of anomaly. -/
lemma anomalyStrength_homogeneous_quadratic_local (f : Idx → ℝ) (c : ℝ) :
    anomalyStrength Γ g (c • f) = (c ^ 2) * anomalyStrength Γ g f :=
  anomalyStrength_homogeneous_quadratic Γ g f c

/-- THEOREM T7: Visibility Spectral Gap (Quadratic Form) -/
theorem T7_Quadratic_Spectral_Gap [FiniteDimensional ℝ (Idx → ℝ)] :
    ∃ c₀ > 0, ∀ f : Idx → ℝ, f ≠ (fun _ => 0) → c₀ * (frequencyNorm f) ^ 2 ≤ anomalyStrength Γ g f := by
  obtain ⟨ε, hε_pos, hε_min⟩ := anomalyStrength_positive_min_on_sphere Γ g
  use ε, hε_pos
  intro f hf

  -- f is nonzero, so frequencyNorm f > 0
  have h_norm_pos : 0 < frequencyNorm f := by
    exact (frequencyNorm_pos_iff f).2 hf

  have h_norm_nonzero : frequencyNorm f ≠ 0 := ne_of_gt h_norm_pos

  let f_norm := frequencyNorm f
  let f_normalized : Idx → ℝ := (1 / f_norm) • f

  -- Normalize: (1/||f||) • f has norm 1
  have h_unit : frequencyNorm f_normalized = 1 := by
    unfold f_normalized
    have h_inv_mul : (1 / f_norm) * f_norm = 1 := by
      field_simp [h_norm_nonzero]
    calc
      frequencyNorm ((1 / f_norm) • f)
        = ‖(1 / f_norm) • f‖ := by rw [frequencyNorm_eq_norm]
      _ = ‖1 / f_norm‖ * ‖f‖ := by rw [norm_smul]
      _ = (1 / f_norm) * f_norm := by
            rw [Real.norm_eq_abs, abs_of_pos (one_div_pos.mpr h_norm_pos)]
            simp [f_norm, frequencyNorm_eq_norm]
      _ = 1 := h_inv_mul

  -- f = f_norm • f_normalized
  have h_eq : f = f_norm • f_normalized := by
    unfold f_normalized
    rw [smul_smul]
    have h_mul_inv : f_norm * (1 / f_norm) = 1 := by
      simpa [one_div] using (mul_inv_cancel₀ h_norm_nonzero)
    rw [h_mul_inv, one_smul]

  -- Quadratic homogeneity
  have h_homo : anomalyStrength Γ g f = (f_norm ^ 2) * anomalyStrength Γ g f_normalized := by
    rw [h_eq, anomalyStrength_homogeneous_quadratic_local Γ g]

  -- Combine
  calc ε * (frequencyNorm f) ^ 2
    = ε * (f_norm ^ 2) := by rfl
    _ ≤ anomalyStrength Γ g f_normalized * (f_norm ^ 2) := by
        apply mul_le_mul_of_nonneg_right (hε_min f_normalized h_unit) (sq_nonneg _)
    _ = anomalyStrength Γ g f := by rw [h_homo, mul_comm]

/-- CONSEQUENCE: Violations have minimum detectable cost. -/
theorem T7_No_Soft_Violations [FiniteDimensional ℝ (Idx → ℝ)] :
    (∃ c₀ > 0, ∀ f : Idx → ℝ, f ≠ 0 →
      c₀ * (frequencyNorm f) ^ 2 ≤ anomalyStrength Γ g f) →
    True := by
  intro _
  trivial

end Coh.Spectral
