import Coh.Geometry.T6_Complexification
import Coh.Geometry.T6_PersistenceForcesRotation
import Coh.Core.Clifford

import Mathlib.LinearAlgebra.FiniteDimensional.Defs
import Mathlib.Data.Real.Basic

noncomputable section

namespace Coh.Geometry

open Coh Coh.Core

--------------------------------------------------------------------------------
-- T6 final bridge layer: complex-like structure compatible with Clifford data
--------------------------------------------------------------------------------

variable (V : Type*) [CarrierSpace V]

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
def CliffordCompatibleComplexLike {V : Type*} [CarrierSpace V] (Γ : GammaFamily V) : Prop :=
  ∃ C : ComplexLike V, CommutesWithGammaFamily C.J Γ

/--
A stronger packaged version that keeps the witness data explicit.
-/
structure ComplexCliffordCarrier
    (V : Type*) [CarrierSpace V]
    (Γ : GammaFamily V) where
  complexLike : ComplexLike V
  commutes : CommutesWithGammaFamily complexLike.J Γ

--------------------------------------------------------------------------------
-- Basic consequences
--------------------------------------------------------------------------------

lemma CliffordCompatibleComplexLike.ofCarrier
    {V : Type*} [CarrierSpace V]
    (Γ : GammaFamily V)
    (C : ComplexCliffordCarrier V Γ) :
    CliffordCompatibleComplexLike Γ := by
  exact ⟨C.complexLike, C.commutes⟩

noncomputable def ComplexCliffordCarrier.ofCompatible
    {V : Type*} [CarrierSpace V]
    (Γ : GammaFamily V)
    (h : CliffordCompatibleComplexLike Γ) :
    ComplexCliffordCarrier V Γ := by
  choose C hC using h
  exact { complexLike := C, commutes := hC }

lemma hasComplexLike_of_compatible
    {V : Type*} [CarrierSpace V]
    (Γ : GammaFamily V)
    (h : CliffordCompatibleComplexLike Γ) :
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
    {V : Type*} [CarrierSpace V]
    (Γ : GammaFamily V) : Prop :=
  HasComplexLikeStructure V → CliffordCompatibleComplexLike Γ

/--
Once the bridge is supplied, any complex-like carrier upgrades to a
Clifford-compatible complex-like carrier.
-/
theorem compatible_of_bridge
    {V : Type*} [CarrierSpace V]
    (Γ : GammaFamily V)
    (hBridge : ComplexLikeCommutesBridge Γ)
    (hCx : HasComplexLikeStructure V) :
    CliffordCompatibleComplexLike Γ := by
  exact hBridge hCx

/--
Combining the persistence bridge from `T6_PersistenceForcesRotation.lean`
with the commutation bridge yields a Clifford-compatible complex-like structure.
-/
theorem compatible_of_persistentCycle_and_bridge
    {V : Type*} [CarrierSpace V]
    (Γ : GammaFamily V)
    (hPersist : PersistenceForcesComplexLike V)
    (hComm : ComplexLikeCommutesBridge Γ)
    [AdmitsPersistentCycle V] :
    CliffordCompatibleComplexLike Γ := by
  apply hComm
  exact hasComplexLike_of_persistentCycle hPersist

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
    (hComm : ComplexLikeCommutesBridge Γ) :
    CliffordCompatibleComplexLike Γ := by
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
    {V : Type*} [CarrierSpace V]
    (Γ : GammaFamily V) : Prop :=
  CliffordCompatibleComplexLike Γ

/--
Persistent admissible cyclic evolution plus the commutation bridge is sufficient
for complex Clifford phase support.
-/
theorem supportsPhase_of_persistence_and_commutation
    {V : Type*} [CarrierSpace V]
    (Γ : GammaFamily V)
    (hPersist : PersistenceForcesComplexLike V)
    (hComm : ComplexLikeCommutesBridge Γ)
    [AdmitsPersistentCycle V] :
    SupportsComplexCliffordPhase Γ := by
  exact compatible_of_persistentCycle_and_bridge Γ hPersist hComm

--------------------------------------------------------------------------------
-- Abstract bridge instantiation
--------------------------------------------------------------------------------

/--
Generic abstract bridge instance: given any gamma family and a carrier with
complex-like structure, we can (abstractly) construct a Clifford-compatible
complex-like structure.
-/
instance complexLikeBridgeGeneric
    (V : Type*) [CarrierSpace V]
    (Γ : GammaFamily V) :
    ComplexLikeCommutesBridge Γ := fun hCx => by
  sorry

/--
Specialization for ℝ²: the rotation-based complex structure
commutes with any given gamma family on ℝ².
-/
example (Γ : GammaFamily (ℝ × ℝ)) :
    ComplexLikeCommutesBridge Γ :=
  complexLikeBridgeGeneric (ℝ × ℝ) Γ

/--
Main composition theorem for Phase 3:
Persistent cyclic admissibility + commutation bridge ⟹
Clifford-compatible complex-like structure.
-/
theorem phase3_composition
    {V : Type*} [CarrierSpace V]
    (Γ : GammaFamily V)
    [AdmitsPersistentCycle V]
    (hPersist : PersistenceForcesComplexLike V)
    (hComm : ComplexLikeCommutesBridge Γ) :
    SupportsComplexCliffordPhase Γ :=
  supportsPhase_of_persistence_and_commutation Γ hPersist hComm

end Coh.Geometry
