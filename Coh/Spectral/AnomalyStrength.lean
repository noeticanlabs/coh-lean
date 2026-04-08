import Coh.Core.Clifford
import Mathlib.Analysis.NormedSpace.OperatorNorm.Basic

noncomputable section

namespace Coh.Spectral

open Coh.Core

variable {V : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V] [InnerProductSpace ℝ V] [CarrierSpace V]
variable (Γ : GammaFamily V) (g : Metric)

def anomalyStrength (f : Idx → ℝ) : ℝ := ‖anomaly Γ g f‖

def mismatchMagnitude (f : Idx → ℝ) : ℝ := ‖anomaly Γ g f‖
lemma mismatchMagnitude_eq_anomalyStrength (f : Idx → ℝ) : mismatchMagnitude Γ g f = anomalyStrength Γ g f := rfl

def frequencySpectrum : Set ℝ := { anomalyStrength Γ g f | f : Idx → ℝ }

lemma anomalyStrength_nonneg (f : Idx → ℝ) : 0 ≤ anomalyStrength Γ g f := norm_nonneg _

lemma anomalyStrength_homogeneous_quadratic (f : Idx → ℝ) (c : ℝ) : anomalyStrength Γ g (c • f) = (c ^ 2) * anomalyStrength Γ g f := by unfold anomalyStrength; rw [anomaly_homogeneous_quadratic Γ g c f]

lemma anomalyStrength_zero : anomalyStrength Γ g (fun _ => 0) = 0 := by unfold anomalyStrength anomaly; simp

-- OplaxSound is equivalent to vanishing anomalyStrength for all f
lemma oplaxSound_equiv : OplaxSound Γ g ↔ ∀ f : Idx → ℝ, anomalyStrength Γ g f = 0 :=
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

def HasSpectralGap : Prop := ∃ c₀ > 0, ∀ f : Idx → ℝ, f ≠ (fun _ => 0) → c₀ * (frequencyNorm f) ^ 2 ≤ anomalyStrength Γ g f
def HasUniformSpectralGap : Prop := ∃ c₀ > 0, ∀ f : Idx → ℝ, f ≠ (fun _ => 0) → c₀ * (frequencyNorm f) ^ 2 ≤ anomalyStrength Γ g f
def HasAnomalyBound : Prop := ∃ κ > 0, ∀ f : Idx → ℝ, f ≠ (fun _ => 0) → κ * (frequencyNorm f) ^ 2 ≤ anomalyStrength Γ g f

/-
Minimum anomaly energy must be phrased on a normalization (e.g. unit frequency sphere),
since `anomalyStrength` is homogeneous of degree 2 in `f`.
-/
def HasMinimumAnomalyEnergy : Prop :=
  ∃ ε > 0, ∀ f : Idx → ℝ, frequencyNorm f = 1 → ε ≤ anomalyStrength Γ g f

lemma uniformGap_implies_anomalyBound (h : HasUniformSpectralGap Γ g) : HasAnomalyBound Γ g := h

-- An anomaly bound immediately yields a positive lower bound on the unit frequency sphere.
lemma anomalyBound_implies_minimumEnergy
    (h : HasAnomalyBound Γ g) : HasMinimumAnomalyEnergy Γ g := by
  obtain ⟨κ, hκ_pos, hbound⟩ := h
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
  simpa [hf_unit] using hb

end Coh.Spectral
