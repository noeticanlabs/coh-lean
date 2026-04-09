import Coh.Geometry.T6_Complexification
import Coh.Geometry.T6_PersistenceForcesRotation
import Coh.Core.Clifford
import Coh.Core.CliffordRep

import Mathlib.LinearAlgebra.FiniteDimensional.Defs
import Mathlib.Data.Real.Basic

noncomputable section

namespace Coh.Geometry

open Coh Coh.Core

--------------------------------------------------------------------------------
-- T6 final bridge layer: complex-like structure compatible with Clifford data
--------------------------------------------------------------------------------

variable {V : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V] [InnerProductSpace ℝ V] [CarrierSpace V]
variable (g : Metric)

/--
A real linear endomorphism `J` commutes with the gamma family `Γ`
if it commutes pointwise with each spacetime generator.
-/
def CommutesWithGammaFamily
    (J : V →L[ℝ] V)
    (Γ : GammaFamily V) : Prop :=
  ∀ μ : Idx, J.comp (Γ.Γ μ) = (Γ.Γ μ).comp J

/--
A complex-like structure is Clifford-compatible if its distinguished `J`
commutes with the entire gamma family.
-/
def CliffordCompatibleComplexLike (Γ : GammaFamily V) : Prop :=
  ∃ C : ComplexLike V, CommutesWithGammaFamily C.J Γ

/--
[HYPOTHESIS] The metabolic penalty bridge:
Noncommuting Clifford and phase structures force a redundant enlargement 
that violates metabolic minimality.
-/
def NoncommutingGammaCostsExtra (Γ : GammaFamily V) (C : ComplexLike V) : Prop :=
  ¬ CommutesWithGammaFamily C.J Γ → ¬ MetabolicallyMinimal V Γ g

--------------------------------------------------------------------------------
-- Bridge Implementation: Constructive Universal Commutation
--------------------------------------------------------------------------------

/--
Theorem 2.1 — `gamma_commutes_with_J`
[DERIVED under penalty hypothesis]
A minimal faithful carrier forces the Clifford action to commute with the internal
phase structure.
-/
theorem universal_commutation_necessity
    (Γ : GammaFamily V)
    (hMin : MetabolicallyMinimal V Γ g)
    (C : ComplexLike V)
    (hPenalty : NoncommutingGammaCostsExtra g Γ C) :
    CommutesWithGammaFamily C.J Γ := by
  -- [PROVED] via metabolic contradiction.
  by_contra h_not
  have h_not_min := hPenalty h_not
  exact h_not_min hMin

/--
A bridge version that operates on the existence Prop.
-/
theorem clifford_compatible_of_minimal
    (Γ : GammaFamily V)
    (hMin : MetabolicallyMinimal V Γ g)
    (hCx : HasComplexLikeStructure V)
    (hPenalty : ∀ C : ComplexLike V, NoncommutingGammaCostsExtra g Γ C) :
    CliffordCompatibleComplexLike Γ := by
  obtain ⟨C⟩ := hCx
  use C
  exact universal_commutation_necessity g Γ hMin C (hPenalty C)

--------------------------------------------------------------------------------
-- Main composition for Phase 3
--------------------------------------------------------------------------------

/--
Combining geometric persistence with the universal commutation necessity.
-/
theorem Phase3_Closure_Verified
    (Γ : GammaFamily V)
    [AdmitsPersistentCycle V]
    (hPersist : PersistenceForcesComplexLike V)
    (hMin : MetabolicallyMinimal V Γ g)
    (hPenalty : ∀ C : ComplexLike V, NoncommutingGammaCostsExtra g Γ C) :
    CliffordCompatibleComplexLike Γ := by
  have hCx := hasComplexLike_of_persistentCycle V hPersist
  exact clifford_compatible_of_minimal g Γ hMin hCx hPenalty

end Coh.Geometry
