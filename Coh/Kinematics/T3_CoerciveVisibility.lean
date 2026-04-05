import Coh.Core.Clifford

import Mathlib.Analysis.NormedSpace.OperatorNorm.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

noncomputable section

namespace Coh.Kinematics

open Coh Coh.Core

--------------------------------------------------------------------------------
-- Coercive visibility layer for the converse T3 direction
--------------------------------------------------------------------------------

variable (V : Type*) [CarrierSpace V]

/--
The measurement defect Δ(f) is subquadratic if it grows slower than ‖f‖²
as |f| goes to infinity.
-/
def SubquadraticDefectBound (Δ : (Idx → ℝ) → ℝ) : Prop :=
  ∀ ε : ℝ, 0 < ε → ∃ S : ℝ, ∀ f : Idx → ℝ, S ≤ frequencyNorm f →
    Δ f ≤ ε * (frequencyNorm f)^2

/--
Coercively Oplax Soundness: The measurement anomaly norm is bounded by the defect Δ.
‖anomaly(f)‖ ≤ Δ(f)
-/
def CoercivelyOplaxSound
    (Γ : GammaFamily V)
    (g : Metric)
    (Δ : (Idx → ℝ) → ℝ) : Prop :=
  ∀ f : Idx → ℝ, ‖anomaly Γ g f‖ ≤ Δ f

/--
A specific gamma family has "visible quadratic anomaly" if its anomaly norm
admits a quadratic lower bound at large frequencies.
-/
def QuadraticAnomalyVisible
    (Γ : GammaFamily V)
    (g : Metric) : Prop :=
  ∃ c : ℝ, 0 < c ∧ ∀ S : ℝ, ∃ f : Idx → ℝ, S ≤ frequencyNorm f ∧
    c * (frequencyNorm f)^2 ≤ ‖anomaly Γ g f‖

--------------------------------------------------------------------------------
-- Core Contradiction Lemma
--------------------------------------------------------------------------------

/--
Theorem: Visible quadratic anomaly contradicts a subquadratic defect bound
under the soundness assumption.
-/
theorem anomaly_contradicts_subquadratic_defect
    (Γ : GammaFamily V)
    (g : Metric)
    (Δ : (Idx → ℝ) → ℝ)
    (hVis : QuadraticAnomalyVisible V Γ g)
    (hSub : SubquadraticDefectBound Δ) :
    ¬ CoercivelyOplaxSound V Γ g Δ := by
  intro hSound
  rcases hVis with ⟨c, hc_pos, hVis⟩
  -- Pick ε = c/2 in the subquadratic bound
  rcases hSub (c / 2) (by linarith) with ⟨S₁, hSubS⟩
  -- Take a threshold S₂ larger than both S₁ and 1 to ensure frequencyNorm f > 0.
  let S₂ := max S₁ 1
  rcases hVis S₂ with ⟨f, hfS, hf_low⟩
  -- Apply soundness and subquadratic bound
  have hf_norm_pos : 0 < frequencyNorm f := by
    have : 1 ≤ S₂ := le_max_right S₁ 1
    exact lt_of_lt_of_le (by norm_num) (le_trans this hfS)
  have hAnom := hSound f
  have hfS₁ : S₁ ≤ frequencyNorm f := le_trans (le_max_left S₁ 1) hfS
  have hSubf := hSubS f hfS₁
  -- Chain: c * ‖f‖² ≤ ‖A_f‖ ≤ Δ(f) ≤ (c/2) * ‖f‖²
  have hContra : c * (frequencyNorm f)^2 ≤ (c / 2) * (frequencyNorm f)^2 :=
    le_trans hf_low (le_trans hAnom hSubf)
  -- Since ‖f‖ > 0 and c > 0, this is a contradiction.
  have hf_sq_pos : 0 < (frequencyNorm f)^2 := pow_pos hf_norm_pos 2
  have : c ≤ c / 2 := (mul_le_mul_right hf_sq_pos).mp hContra
  linarith

--------------------------------------------------------------------------------
-- Bridge to Necessity
--------------------------------------------------------------------------------

/--
Visibility Bridge: Non-Clifford families are visible.
-/
def NonCliffordVisibilityBridge
    (Γ : GammaFamily V)
    (g : Metric) : Prop :=
  ¬ IsClifford V Γ g → QuadraticAnomalyVisible V Γ g

theorem clifford_of_coercive_soundness
    (Γ : GammaFamily V)
    (g : Metric)
    (Δ : (Idx → ℝ) → ℝ)
    (hSub : SubquadraticDefectBound Δ)
    (hSound : CoercivelyOplaxSound V Γ g Δ)
    (hBridge : NonCliffordVisibilityBridge V Γ g) :
    IsClifford V Γ g := by
  by_contra hNot
  have hVis := hBridge hNot
  exact anomaly_contradicts_subquadratic_defect V Γ g Δ hVis hSub hSound

end Coh.Kinematics
