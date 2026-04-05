import Mathlib.LinearAlgebra.FiniteDimensional.Defs
import Mathlib.Data.Real.Basic

noncomputable section

namespace Coh.Core

universe u

variable (V : Type u)
variable [AddCommGroup V] [Module ℝ V] [FiniteDimensional ℝ V]

--------------------------------------------------------------------------------
-- Module rank and metabolic cost foundations
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
This measures the total energy expenditure to maintain the algebraic structure.
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
-- Thermodynamic dominance: core definition
--------------------------------------------------------------------------------

/--
Carrier `V` is strictly larger than `W` in module rank.
This is the first condition for thermodynamic filtering.
-/
def StrictlyLargerCarrier (W : Type u) [AddCommGroup W] [Module ℝ W] [FiniteDimensional ℝ W] : Prop :=
  moduleRank V > moduleRank W

/--
Carrier `V` has strictly greater metabolic cost than `W` under parameters `p`.
-/
def MoreExpensive (W : Type u) [AddCommGroup W] [Module ℝ W] [FiniteDimensional ℝ W]
    (p : MetabolicParams) : Prop :=
  trackingCost V p > trackingCost W p

/--
Carrier `V` has strictly shorter nominal lifespan than `W` under `p` and budget `B₀`.
-/
def ShorterLifespan (W : Type u) [AddCommGroup W] [Module ℝ W] [FiniteDimensional ℝ W]
    (p : MetabolicParams) (B₀ : ℝ) : Prop :=
  nominalLifespan V p B₀ < nominalLifespan W p B₀

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

/--
Cost increases monotonically with rank under positive metabolic coefficient.
-/
lemma cost_increases_with_rank (W : Type u) [AddCommGroup W] [Module ℝ W] [FiniteDimensional ℝ W]
    (p : MetabolicParams)
    (h : moduleRank V > moduleRank W) :
    trackingCost V p > trackingCost W p := by
  unfold trackingCost
  have hcast : (moduleRank W : ℝ) < (moduleRank V : ℝ) := by
    exact Nat.cast_lt.mpr h
  nlinarith [p.κ_pos]

/--
Higher cost implies shorter lifespan.
-/
lemma shorter_lifespan_of_higher_cost (W : Type u) [AddCommGroup W] [Module ℝ W] [FiniteDimensional ℝ W]
    (p : MetabolicParams)
    {B₀ : ℝ}
    (hB : 0 < B₀)
    (hW : 0 < moduleRank W)
    (hCost : trackingCost V p > trackingCost W p) :
    nominalLifespan V p B₀ < nominalLifespan W p B₀ := by
  unfold nominalLifespan
  have hWpos : 0 < trackingCost W p := trackingCost_pos W p hW
  have hVpos : 0 < trackingCost V p := by linarith
  have hInv : 1 / trackingCost V p < 1 / trackingCost W p := by
    exact one_div_lt_one_div_of_lt hWpos hCost
  have hmul := mul_lt_mul_of_pos_left hInv hB
  calc B₀ / trackingCost V p
    _ = B₀ * (1 / trackingCost V p) := by ring
    _ < B₀ * (1 / trackingCost W p) := hmul
    _ = B₀ / trackingCost W p := by ring

end Coh.Core
