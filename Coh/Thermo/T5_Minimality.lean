import Mathlib.LinearAlgebra.FiniteDimensional.Defs
import Mathlib.Data.Real.Basic

noncomputable section

namespace Coh.Thermo

--------------------------------------------------------------------------------
-- Basic carrier setup
--------------------------------------------------------------------------------

variable (V : Type*)
variable [AddCommGroup V] [Module ℝ V] [FiniteDimensional ℝ V]

--------------------------------------------------------------------------------
-- Module rank and baseline metabolic cost
--------------------------------------------------------------------------------

/--
`moduleRank V` is the finite dimension of the carrier module.
This is the thermodynamic proxy for the number of independently tracked degrees of freedom.
-/
def moduleRank : ℕ := Module.finrank ℝ V

/--
Baseline metabolic coefficient.
This is the thermodynamic cost per degree of freedom per unit proper time.
-/
structure MetabolicParams where
  κ : ℝ
  κ_pos : 0 < κ

/--
Metabolic tracking cost of a carrier module.
Defined as κ times the module rank.
-/
def trackingCost (p : MetabolicParams) : ℝ :=
  p.κ * (moduleRank V : ℝ)

--------------------------------------------------------------------------------
-- Budget evolution
--------------------------------------------------------------------------------

/--
Budget after a proper-time interval `dt`, assuming constant baseline cost.
-/
def budgetAfter (p : MetabolicParams) (B₀ dt : ℝ) : ℝ :=
  B₀ - trackingCost V p * dt

/--
A module is viable up to time `dt` if the budget remains nonnegative.
-/
def viableUntil (p : MetabolicParams) (B₀ dt : ℝ) : Prop :=
  0 ≤ budgetAfter V p B₀ dt

/--
Nominal lifespan under constant metabolic cost.
This is the proper time at which the budget reaches zero.
-/
def nominalLifespan (p : MetabolicParams) (B₀ : ℝ) : ℝ :=
  B₀ / trackingCost V p

--------------------------------------------------------------------------------
-- Basic algebraic lemmas
--------------------------------------------------------------------------------

lemma moduleRank_nonneg : 0 ≤ (moduleRank V : ℝ) := by
  exact Nat.cast_nonneg _

lemma trackingCost_nonneg (p : MetabolicParams) : 0 ≤ trackingCost V p := by
  unfold trackingCost
  have h1 : 0 ≤ p.κ := le_of_lt p.κ_pos
  have h2 : 0 ≤ (moduleRank V : ℝ) := moduleRank_nonneg V
  exact mul_nonneg h1 h2

lemma trackingCost_pos (p : MetabolicParams) (hV : 0 < moduleRank V) : 0 < trackingCost V p := by
  unfold trackingCost
  have hRank : 0 < (moduleRank V : ℝ) := Nat.cast_pos.mpr hV
  exact mul_pos p.κ_pos hRank

lemma budgetAfter_zero (p : MetabolicParams) (B₀ : ℝ) :
    budgetAfter V p B₀ 0 = B₀ := by
  unfold budgetAfter
  ring

lemma budgetAfter_at_lifespan (p : MetabolicParams) (B₀ : ℝ) (hV : 0 < moduleRank V) :
    budgetAfter V p B₀ (nominalLifespan V p B₀) = 0 := by
  unfold budgetAfter nominalLifespan
  rw [mul_div_cancel₀ B₀ (trackingCost_pos V p hV).ne']
  ring

end Coh.Thermo
