import Mathlib.Algebra.Module.Basic
import Mathlib.Data.Complex.Module
import Mathlib.LinearAlgebra.FiniteDimensional.Defs
import Mathlib.LinearAlgebra.Matrix.ToLin
import Coh.Core.Complexification

noncomputable section

namespace Coh.Core

/--
A ComplexCarrier is a real vector space V paired with a complex state space H
and a real-linear equivalence between them. 
Refactored to synchronize with the CarrierSpace parameter requirements.
-/
class ComplexCarrier (V : Type*) 
    [NormedAddCommGroup V] [NormedSpace ℝ V] [InnerProductSpace ℝ V] [CarrierSpace V] where
  /-- The equivalent complex Hilbert space footprint. -/
  H : Type*
  [instHGroup : AddCommGroup H]
  [instHModuleComplex : Module ℂ H]
  /-- Real-linear equivalence between the geometric carrier V and complex state H. -/
  equiv : V ≃ₗ[ℝ] (RestrictScalars ℝ ℂ H)

/-- Access to the complex Hilbert space from a geometric carrier. -/
abbrev CarrierHilbert (V : Type*) 
    [NormedAddCommGroup V] [NormedSpace ℝ V] [InnerProductSpace ℝ V] [CarrierSpace V] 
    [ComplexCarrier V] : Type* :=
  ComplexCarrier.H V

instance (V : Type*) 
    [NormedAddCommGroup V] [NormedSpace ℝ V] [InnerProductSpace ℝ V] [CarrierSpace V] 
    [ComplexCarrier V] : 
    AddCommGroup (CarrierHilbert V) := ComplexCarrier.instHGroup

instance (V : Type*) 
    [NormedAddCommGroup V] [NormedSpace ℝ V] [InnerProductSpace ℝ V] [CarrierSpace V] 
    [ComplexCarrier V] : 
    Module ℂ (CarrierHilbert V) := ComplexCarrier.instHModuleComplex

/-- Helper to access the real-equivalence from the typeclass. -/
def carrierEquiv (V : Type*) 
    [NormedAddCommGroup V] [NormedSpace ℝ V] [InnerProductSpace ℝ V] [CarrierSpace V] 
    [ComplexCarrier V] :
    V ≃ₗ[ℝ] (RestrictScalars ℝ ℂ (CarrierHilbert V)) :=
  ComplexCarrier.equiv

/--
Lifting a complex-linear operator from H back to a real-linear operator on V.
-/
def liftFromComplex (V : Type*) 
    [NormedAddCommGroup V] [NormedSpace ℝ V] [InnerProductSpace ℝ V] [CarrierSpace V] 
    [ComplexCarrier V]
    (f : (CarrierHilbert V) →ₗ[ℂ] (CarrierHilbert V)) : V →ₗ[ℝ] V :=
  let e := carrierEquiv V
  let f_restr : (RestrictScalars ℝ ℂ (CarrierHilbert V)) →ₗ[ℝ] (RestrictScalars ℝ ℂ (CarrierHilbert V)) :=
    { f.toAddMonoidHom with
      map_smul' := fun r x => by
        simp only [AddMonoidHom.toFun_eq_coe, LinearMap.coe_toAddMonoidHom]
        let r_c : ℂ := r
        have h1 : r • x = r_c • x := rfl
        have h2 : r • (f x) = r_c • (f x) := rfl
        rw [h1, h2, f.map_smul]
    }
  e.symm.toLinearMap.comp (f_restr.comp e.toLinearMap)

/--
Lifting a matrix action to the geometric carrier V given a basis on H.
-/
def liftMatrix {n : ℕ} (V : Type*) 
    [NormedAddCommGroup V] [NormedSpace ℝ V] [InnerProductSpace ℝ V] [CarrierSpace V] 
    [ComplexCarrier V]
    (basis : Basis (Fin n) ℂ (CarrierHilbert V)) (M : Matrix (Fin n) (Fin n) ℂ) : V →ₗ[ℝ] V :=
  liftFromComplex V (Matrix.toLin basis basis M)

/--
Automatic complex structure instance for V given a ComplexCarrier bridge.
-/
instance hasComplexLikeStructure_of_complexCarrier (V : Type*) 
    [NormedAddCommGroup V] [NormedSpace ℝ V] [InnerProductSpace ℝ V] [CarrierSpace V] 
    [ComplexCarrier V] : HasComplexLikeStructure V where
  J := fun v => 
    let e := carrierEquiv V
    let h : CarrierHilbert V := e v
    let ih : CarrierHilbert V := Complex.I • h
    let ih_res : RestrictScalars ℝ ℂ (CarrierHilbert V) := ih
    e.symm ih_res
  J_squared_eq_neg_id := by
    intro v
    let e := carrierEquiv V
    simp only [e.symm_apply_apply, smul_smul, Complex.I_sq, neg_smul, one_smul, e.apply_symm_apply]
    exact e.symm.map_neg (e v)

end Coh.Core
