import Coh.Geometry.T6_Complexification
import Coh.Geometry.T6_PersistenceForcesRotation
import Coh.Kinematics.T3_Clifford

import Mathlib.LinearAlgebra.FiniteDimensional.Defs
import Mathlib.Data.Real.Basic

noncomputable section

namespace Coh.Geometry

open Coh.Kinematics

--------------------------------------------------------------------------------
-- T6 final bridge layer: complex-like structure compatible with Clifford data
--------------------------------------------------------------------------------

/-
This file isolates the last exposed T6 seam.

Already available from earlier files:
* HasComplexLikeStructure V packages the existence of a real endomorphism `J`
  with `J^2 = -I`,
* `GammaFamily V` packages the candidate spacetime generators.
-/

--------------------------------------------------------------------------------
-- Commutation with the gamma family
--------------------------------------------------------------------------------

variable (V : Type*)
variable [NormedAddCommGroup V] [NormedSpace ℝ V] [FiniteDimensional ℝ V]

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
def CliffordCompatibleComplexLike
    (Γ : GammaFamily V) : Prop :=
  ∃ C : ComplexLike V, CommutesWithGammaFamily V C.J Γ

/--
A stronger packaged version that keeps the witness data explicit.
-/
structure ComplexCliffordCarrier
    (Γ : GammaFamily V) where
  complexLike : ComplexLike V
  commutes : CommutesWithGammaFamily V complexLike.J Γ

--------------------------------------------------------------------------------
-- Basic consequences
--------------------------------------------------------------------------------

lemma CliffordCompatibleComplexLike.ofCarrier
    (Γ : GammaFamily V)
    (C : ComplexCliffordCarrier V Γ) :
    CliffordCompatibleComplexLike V Γ := by
  exact ⟨C.complexLike, C.commutes⟩

noncomputable def ComplexCliffordCarrier.ofCompatible
    (Γ : GammaFamily V)
    (h : CliffordCompatibleComplexLike V Γ) :
    ComplexCliffordCarrier V Γ := by
  choose C hC using h
  exact { complexLike := C, commutes := hC }

lemma hasComplexLike_of_compatible
    (Γ : GammaFamily V)
    (h : CliffordCompatibleComplexLike V Γ) :
    HasComplexLikeStructure V := by
  rcases h with ⟨C, _⟩
  exact ⟨C⟩

--------------------------------------------------------------------------------
-- Bridge interface
--------------------------------------------------------------------------------

/--
Bridge interface for the later T6 / representation stack:
if a carrier admits a complex-like structure, then for the given gamma family
there exists a complex-like witness commuting with that gamma family.
-/
def ComplexLikeCommutesBridge
    (Γ : GammaFamily V) : Prop :=
  HasComplexLikeStructure V → CliffordCompatibleComplexLike V Γ

/--
Once the bridge is supplied, any complex-like carrier upgrades to a
Clifford-compatible complex-like carrier.
-/
theorem compatible_of_bridge
    (Γ : GammaFamily V)
    (hBridge : ComplexLikeCommutesBridge V Γ)
    (hCx : HasComplexLikeStructure V) :
    CliffordCompatibleComplexLike V Γ := by
  exact hBridge hCx

/--
Combining the persistence bridge from `T6_PersistenceForcesRotation.lean`
with the commutation bridge yields a Clifford-compatible complex-like structure.
-/
theorem compatible_of_persistentCycle_and_bridge
    (Γ : GammaFamily V)
    (hPersist : PersistenceForcesComplexLike V)
    (hComm : ComplexLikeCommutesBridge V Γ)
    [AdmitsPersistentCycle V] :
    CliffordCompatibleComplexLike V Γ := by
  apply hComm
  exact hasComplexLike_of_persistentCycle (V := V) hPersist

--------------------------------------------------------------------------------
-- Real 2D specialization
--------------------------------------------------------------------------------

/--
A convenient specialization: if `ℝ²` has a gamma family and we can prove the
commutation bridge for it, then the canonical rotation-based complex-like
structure becomes Clifford-compatible.
-/
theorem real2_compatible_of_bridge
    (Γ : GammaFamily (ℝ × ℝ))
    (hComm : ComplexLikeCommutesBridge (V := ℝ × ℝ) Γ) :
    CliffordCompatibleComplexLike (V := ℝ × ℝ) Γ := by
  apply hComm
  exact R2_hasComplexLikeStructure

--------------------------------------------------------------------------------
-- Upgrade packaging
--------------------------------------------------------------------------------

/--
A carrier supports a complex Clifford phase if it admits a complex-like structure
that commutes with the gamma family.
-/
def SupportsComplexCliffordPhase
    (Γ : GammaFamily V) : Prop :=
  CliffordCompatibleComplexLike V Γ

/--
Persistent admissible cyclic evolution plus the commutation bridge is sufficient
for complex Clifford phase support.
-/
theorem supportsPhase_of_persistence_and_commutation
    (Γ : GammaFamily V)
    (hPersist : PersistenceForcesComplexLike V)
    (hComm : ComplexLikeCommutesBridge V Γ)
    [AdmitsPersistentCycle V] :
    SupportsComplexCliffordPhase V Γ := by
  exact compatible_of_persistentCycle_and_bridge
    (V := V) Γ hPersist hComm

--------------------------------------------------------------------------------
-- Honest boundary
--------------------------------------------------------------------------------

/-
This file isolates the final T6 bridge into one exact statement:

  ComplexLikeCommutesBridge V Γ :
    HasComplexLikeStructure V -> CliffordCompatibleComplexLike V Γ

What is still NOT proved here:
* that the complex-like structure forced by Coh persistence actually commutes with
  the concrete gamma family,
* that this compatibility promotes the real carrier canonically to a complex
  Clifford module,
* that the minimal such module is the Dirac carrier.
-/

end Coh.Geometry
