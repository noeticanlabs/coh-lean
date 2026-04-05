import Coh.Core.Clifford
import Mathlib.Analysis.NormedSpace.OperatorNorm.Basic

noncomputable section

namespace Coh.Spectral

open Coh.Core

def anomalyStrength {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) (f : Idx → ℝ) : ℝ := ‖anomaly Γ g f‖

def mismatchMagnitude {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) (f : Idx → ℝ) : ℝ := ‖anomaly Γ g f‖
lemma mismatchMagnitude_eq_anomalyStrength {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) (f : Idx → ℝ) : mismatchMagnitude Γ g f = anomalyStrength Γ g f := rfl

def frequencySpectrum {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) : Set ℝ := { anomalyStrength Γ g f | f : Idx → ℝ }

lemma anomalyStrength_nonneg {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) (f : Idx → ℝ) : 0 ≤ anomalyStrength Γ g f := norm_nonneg _

lemma anomalyStrength_homogeneous_quadratic {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) (f : Idx → ℝ) (c : ℝ) : anomalyStrength Γ g (c • f) = (c ^ 2) * anomalyStrength Γ g f := by unfold anomalyStrength; rw [anomaly_homogeneous_quadratic Γ g c f]

lemma anomalyStrength_zero {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) : anomalyStrength Γ g (fun _ => 0) = 0 := by unfold anomalyStrength anomaly; simp

-- OplaxSound is equivalent to vanishing anomalyStrength for all f
lemma oplaxSound_equiv {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) : OplaxSound Γ g ↔ ∀ f : Idx → ℝ, anomalyStrength Γ g f = 0 :=
  by
    constructor
    · intro h f
      simp [anomalyStrength, h f]
    · intro h f
      have hnorm : ‖anomaly Γ g f‖ = 0 := by
        simpa [anomalyStrength] using h f
      ext x
      have hx : ‖anomaly Γ g f x‖ ≤ ‖anomaly Γ g f‖ * ‖x‖ :=
        (anomaly Γ g f).le_opNorm x
      rw [hnorm] at hx
      simp at hx
      simpa using hx

def HasSpectralGap {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) : Prop := ∃ c₀ > 0, ∀ f : Idx → ℝ, f ≠ (fun _ => 0) → c₀ * (frequencyNorm f) ^ 2 ≤ anomalyStrength Γ g f
def HasUniformSpectralGap {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) : Prop := ∃ c₀ > 0, ∀ f : Idx → ℝ, f ≠ (fun _ => 0) → c₀ * (frequencyNorm f) ^ 2 ≤ anomalyStrength Γ g f
def HasAnomalyBound {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) : Prop := ∃ κ > 0, ∀ f : Idx → ℝ, f ≠ (fun _ => 0) → κ * (frequencyNorm f) ^ 2 ≤ anomalyStrength Γ g f
/-
Minimum anomaly energy must be phrased on a normalization (e.g. unit frequency sphere),
since `anomalyStrength` is homogeneous of degree 2 in `f`.

This is the "no soft violations at unit scale" statement used by the compactness proof.
-/
def HasMinimumAnomalyEnergy {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) : Prop :=
  ∃ ε > 0, ∀ f : Idx → ℝ, frequencyNorm f = 1 → ε ≤ anomalyStrength Γ g f

lemma uniformGap_implies_anomalyBound {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) : HasUniformSpectralGap Γ g → HasAnomalyBound Γ g := fun ⟨c₀, hc₀, h⟩ => ⟨c₀, hc₀, h⟩

-- An anomaly bound immediately yields a positive lower bound on the unit frequency sphere.
lemma anomalyBound_implies_minimumEnergy {V : Type*} [CarrierSpace V]
    (Γ : GammaFamily V) (g : Metric) :
    HasAnomalyBound Γ g → HasMinimumAnomalyEnergy Γ g := by
  rintro ⟨κ, hκ_pos, hbound⟩
  refine ⟨κ, hκ_pos, ?_⟩
  intro f hf_unit
  have hf_ne : f ≠ (fun _ => 0) := by
    intro h0
    have h0' : f = 0 := by simpa using h0
    have hnorm0 : frequencyNorm f = 0 := by
      simp [frequencyNorm, h0']
    have : (0 : ℝ) = 1 := by
      simpa [hnorm0] using hf_unit
    exact zero_ne_one this
  have hb := hbound f hf_ne
  -- On the unit sphere, the bound reads `κ ≤ anomalyStrength Γ g f`.
  simpa [hf_unit] using hb

end Coh.Spectral
