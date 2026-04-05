import Coh.Core.Clifford
import Mathlib.Analysis.NormedSpace.OperatorNorm.Basic

noncomputable section

namespace Coh.Spectral

open Coh.Core

--------------------------------------------------------------------------------
-- Anomaly Strength: Magnitude of Clifford Violation
--------------------------------------------------------------------------------

/--
The strength (magnitude) of an anomaly at a frequency profile.
-/
def anomalyStrength {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) (f : Idx → ℝ) : ℝ :=
  ‖anomaly Γ g f‖

/--
The mismatch at a frequency profile.
-/
def mismatchMagnitude {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) (f : Idx → ℝ) : ℝ :=
  ‖anomaly Γ g f‖

/--
Equivalently: mismatch at a profile is the same as anomaly strength.
-/
lemma mismatchMagnitude_eq_anomalyStrength {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) (f : Idx → ℝ) :
    mismatchMagnitude Γ g f = anomalyStrength Γ g f := rfl

/--
The frequency spectrum of a carrier relative to a gamma family and metric.
-/
def frequencySpectrum {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) : Set ℝ :=
  { anomalyStrength Γ g f | f : Idx → ℝ }

--------------------------------------------------------------------------------
-- Basic Properties
--------------------------------------------------------------------------------

/--
Anomaly strength is nonnegative (it's an operator norm).
-/
lemma anomalyStrength_nonneg {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) (f : Idx → ℝ) :
    0 ≤ anomalyStrength Γ g f := by
  unfold anomalyStrength
  exact norm_nonneg _

/--
Anomaly strength scales quadratically with frequency: A(λf) = λ² * A(f).

This is a direct consequence of the bilinearity of the anomaly operator
established in Coh.Core.Clifford.anomaly_homogeneous_quadratic.
-/
lemma anomalyStrength_homogeneous_quadratic {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) (f : Idx → ℝ) (c : ℝ) :
    anomalyStrength Γ g (c • f) = (c ^ 2) * anomalyStrength Γ g f := by
  unfold anomalyStrength
  rw [anomaly_homogeneous_quadratic Γ g c f]

/--
Zero frequency gives zero anomaly.
-/
lemma anomalyStrength_zero {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) :
    anomalyStrength Γ g (fun _ => 0) = 0 := by
  unfold anomalyStrength
  simp only [Pi.zero_apply, zero_mul, Finset.sum_const_zero]
  norm_num

/--
OplaxSound is equivalent to anomaly strength vanishing for all frequencies.
-/
lemma oplaxSound_iff_anomalyStrength_zero {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) :
    OplaxSound Γ g ↔ ∀ f : Idx → ℝ, anomalyStrength Γ g f = 0 := by
  unfold OplaxSound anomalyStrength
  simp only [norm_eq_zero]
  rfl

--------------------------------------------------------------------------------
-- Spectral Gap: The Key Property
--------------------------------------------------------------------------------

/--
A spectral gap exists if there is a uniform lower bound on nonzero anomalies.
-/
def HasSpectralGap {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) : Prop :=
  ∃ c₀ > 0,
    ∀ f : Idx → ℝ,
      f ≠ (fun _ => 0) →
      c₀ * (frequencyNorm f) ^ 2 ≤ anomalyStrength Γ g f

/--
Strong spectral gap: lower bound is uniform over all nonzero frequencies.
-/
def HasUniformSpectralGap {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) : Prop :=
  ∃ c₀ > 0,
    ∀ f : Idx → ℝ,
      f ≠ (fun _ => 0) →
      c₀ * (frequencyNorm f) ^ 2 ≤ anomalyStrength Γ g f

/--
Equivalently (possibly weaker): gap by direct mismatch bound.
-/
def HasAnomalyBound {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) : Prop :=
  ∃ κ > 0,
    ∀ f : Idx → ℝ,
      f ≠ (fun _ => 0) →
      κ * (frequencyNorm f) ^ 2 ≤ anomalyStrength Γ g f

/--
Direct mismatch bounded away from zero.
-/
def HasMinimumAnomalyEnergy {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) : Prop :=
  ∃ ε > 0,
    ∀ f : Idx → ℝ,
      anomalyStrength Γ g f ≠ 0 →
      ε ≤ anomalyStrength Γ g f

--------------------------------------------------------------------------------
-- Relationships
--------------------------------------------------------------------------------

/--
Uniform spectral gap implies direct anomaly bound.
-/
lemma uniformGap_implies_anomalyBound {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) :
    HasUniformSpectralGap Γ g → HasAnomalyBound Γ g := by
  unfold HasUniformSpectralGap HasAnomalyBound
  intro ⟨c₀, hc₀, h⟩
  exact ⟨c₀, hc₀, h⟩

/--
Anomaly bound implies nonzero anomalies have minimum energy.
-/
lemma anomalyBound_implies_minimumEnergy {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) (g : Metric) :
    HasAnomalyBound Γ g → HasMinimumAnomalyEnergy Γ g := by
  -- This requires bounding the infimum of ‖f‖ over nonzero f
  -- In finite dimension, nonzero vectors have minimum size
  sorry

end Coh.Spectral
