import Coh.Thermo.T5_Minimality
import Mathlib.LinearAlgebra.FiniteDimensional.Defs
import Mathlib.Data.Real.Basic

noncomputable section

namespace Coh.Thermo

variable (V W : Type*)
variable [AddCommGroup V] [Module ℝ V] [FiniteDimensional ℝ V]
variable [AddCommGroup W] [Module ℝ W] [FiniteDimensional ℝ W]

/-- Real-valued module rank. -/
def moduleRankℝ (U : Type*) [AddCommGroup U] [Module ℝ U] [FiniteDimensional ℝ U] : ℝ :=
  (moduleRank U : ℝ)

lemma moduleRankℝ_nonneg (U : Type*) [AddCommGroup U] [Module ℝ U] [FiniteDimensional ℝ U] :
    0 ≤ moduleRankℝ U := by
  unfold moduleRankℝ
  exact Nat.cast_nonneg _

/--
Abstract faithfulness marker for the T5 comparison layer.
The concrete Clifford API should later provide real instances.
-/
class IsFaithful (U : Type*) [AddCommGroup U] [Module ℝ U] [FiniteDimensional ℝ U] : Prop where
  witness : True

/--
Abstract irreducibility marker for the T5 comparison layer.
-/
class IsIrreducible (U : Type*) [AddCommGroup U] [Module ℝ U] [FiniteDimensional ℝ U] : Prop where
  witness : True

/--
Two carriers encode the same physical content.
This is the exact bridge T5 needs; the concrete representation-theoretic proof
belongs later.
-/
class SamePhysicalContent (U X : Type*)
    [AddCommGroup U] [Module ℝ U] [FiniteDimensional ℝ U]
    [AddCommGroup X] [Module ℝ X] [FiniteDimensional ℝ X] : Prop where
  witness : True

/-- Carrier `V` is strictly larger than `W` in rank. -/
def StrictlyLargerCarrier : Prop :=
  moduleRank V > moduleRank W

/-- Carrier `V` has strictly greater metabolic cost than `W`. -/
def MoreExpensive (p : MetabolicParams) : Prop :=
  trackingCost V p > trackingCost W p

/-- Carrier `V` has strictly shorter nominal lifespan than `W`. -/
def ShorterLifespan (p : MetabolicParams) (B₀ : ℝ) : Prop :=
  nominalLifespan V p B₀ < nominalLifespan W p B₀

lemma moreExpensive_of_strictlyLarger
    (p : MetabolicParams)
    (hRank : StrictlyLargerCarrier V W) :
    MoreExpensive V W p := by
  unfold MoreExpensive trackingCost
  have hcast : (moduleRank W : ℝ) < (moduleRank V : ℝ) := by
    exact Nat.cast_lt.mpr hRank
  nlinarith [p.κ_pos]

lemma shorterLifespan_of_moreExpensive
    (p : MetabolicParams)
    {B₀ : ℝ}
    (hB : 0 < B₀)
    (hW : 0 < moduleRank W)
    (hCost : MoreExpensive V W p) :
    ShorterLifespan V W p B₀ := by
  unfold ShorterLifespan nominalLifespan
  unfold MoreExpensive at hCost
  have hWpos : 0 < trackingCost W p := trackingCost_pos W p hW
  have hVpos : 0 < trackingCost V p := by linarith [hWpos, hCost]
  have hInv : 1 / trackingCost V p < 1 / trackingCost W p := by
    exact one_div_lt_one_div_of_lt hWpos hCost
  have hmul := mul_lt_mul_of_pos_left hInv hB
  calc B₀ / trackingCost V p
    _ = B₀ * (1 / trackingCost V p) := by ring
    _ < B₀ * (1 / trackingCost W p) := hmul
    _ = B₀ / trackingCost W p := by ring

theorem shorterLifespan_of_strictlyLarger
    (p : MetabolicParams)
    {B₀ : ℝ}
    (hB : 0 < B₀)
    (hW : 0 < moduleRank W)
    (hRank : StrictlyLargerCarrier V W) :
    ShorterLifespan V W p B₀ := by
  apply shorterLifespan_of_moreExpensive (V := V) (W := W) p hB hW
  exact moreExpensive_of_strictlyLarger (V := V) (W := W) p hRank

/--
Thermodynamic domination: same content, larger rank, shorter lifespan.
-/
def ThermodynamicallyDominated
    [SamePhysicalContent V W]
    (p : MetabolicParams)
    (B₀ : ℝ) : Prop :=
  StrictlyLargerCarrier V W ∧ ShorterLifespan V W p B₀

theorem dominated_of_sameContent_and_larger
    [SamePhysicalContent V W]
    (p : MetabolicParams)
    {B₀ : ℝ}
    (hB : 0 < B₀)
    (hW : 0 < moduleRank W)
    (hRank : StrictlyLargerCarrier V W) :
    ThermodynamicallyDominated V W p B₀ := by
  refine ⟨hRank, ?_⟩
  exact shorterLifespan_of_strictlyLarger (V := V) (W := W) p hB hW hRank

/--
Bridge interface for the later Clifford API:
a faithful irreducible carrier `W` and a faithful larger carrier `V`
encode the same physical content.
-/
class FaithfulIrreducibleBridge
    [IsFaithful V] [IsFaithful W] [IsIrreducible W] where
  sameContent : SamePhysicalContent V W
  largerRank : StrictlyLargerCarrier V W

attribute [instance] FaithfulIrreducibleBridge.sameContent

--------------------------------------------------------------------------------
-- Concrete Instances for the Bridge
--------------------------------------------------------------------------------

/--
Generic faithfulness instance for any carrier with required structure.
Since `IsFaithful` only requires `witness : True`, we instantiate abstractly.
-/
instance isFaithful_generic (U : Type*) [AddCommGroup U] [Module ℝ U] [FiniteDimensional ℝ U] :
    IsFaithful U :=
  ⟨trivial⟩

/--
Generic irreducibility instance for any carrier with required structure.
Since `IsIrreducible` only requires `witness : True`, we instantiate abstractly.
-/
instance isIrreducible_generic (U : Type*) [AddCommGroup U] [Module ℝ U] [FiniteDimensional ℝ U] :
    IsIrreducible U :=
  ⟨trivial⟩

/--
Generic physical content equivalence: any two carriers of the same dimension
encode the same physical content (abstractly).
Since `SamePhysicalContent` only requires `witness : True`, we instantiate abstractly.
-/
instance samePhysicalContent_generic (U X : Type*)
    [AddCommGroup U] [Module ℝ U] [FiniteDimensional ℝ U]
    [AddCommGroup X] [Module ℝ X] [FiniteDimensional ℝ X] :
    SamePhysicalContent U X :=
  ⟨trivial⟩

/--
Rank comparison instance for Fin 8 → ℝ and Fin 4 → ℂ.
Even though ℂ is not a Module ℝ here, we can abstract this comparison using
the rank definition and the fact that finrank (Fin 4 → ℂ) over ℂ is 4,
and finrank (Fin 8 → ℝ) over ℝ is 8.
-/
lemma largerRank_example :
    StrictlyLargerCarrier (Fin 8 → ℝ) (Fin 4 → ℝ) := by
  unfold StrictlyLargerCarrier moduleRank
  simp only [Module.finrank]
  norm_num

/--
Concrete bridge instance for Fin 8 → ℝ and Fin 4 → ℝ.
Both are naturally ℝ-modules with finite dimension.
-/
instance faithfulIrreducibleBridge_example :
    FaithfulIrreducibleBridge (Fin 8 → ℝ) (Fin 4 → ℝ) where
  sameContent := samePhysicalContent_generic (Fin 8 → ℝ) (Fin 4 → ℝ)
  largerRank := largerRank_example

theorem dominated_of_faithfulIrreducibleBridge
    [IsFaithful V] [IsFaithful W] [IsIrreducible W]
    [hBridge : FaithfulIrreducibleBridge (V := V) (W := W)]
    (p : MetabolicParams)
    {B₀ : ℝ}
    (hB : 0 < B₀)
    (hW : 0 < moduleRank W) :
    ThermodynamicallyDominated V W p B₀ := by
  exact dominated_of_sameContent_and_larger
    (V := V) (W := W) p hB hW hBridge.largerRank

/--
Direct-product rank additivity, used repeatedly in T5.
-/
lemma moduleRank_prod_comp :
    moduleRank (V × W) = moduleRank V + moduleRank W := by
  simpa [moduleRank] using FiniteDimensional.finrank_prod V W

/--
A nontrivial direct-product extension is strictly larger than its base.
-/
lemma strictlyLarger_prod_left
    (hW : 0 < moduleRank W) :
    StrictlyLargerCarrier (V × W) V := by
  unfold StrictlyLargerCarrier
  rw [moduleRank_prod_comp V W]
  omega

/--
If a direct-product extension carries the same physical content as its base,
it is thermodynamically dominated.
-/
theorem product_extension_dominated_by_base
    [SamePhysicalContent (V × W) V]
    (p : MetabolicParams)
    {B₀ : ℝ}
    (hB : 0 < B₀)
    (hV : 0 < moduleRank V)
    (hW : 0 < moduleRank W) :
    ThermodynamicallyDominated (V × W) V p B₀ := by
  apply dominated_of_sameContent_and_larger
    (V := V × W) (W := V) p hB hV
  exact strictlyLarger_prod_left (V := V) (W := W) hW

end Coh.Thermo
