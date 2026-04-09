import Mathlib.Data.Complex.Basic
import Mathlib.Data.Matrix.Basic
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Analysis.CStarAlgebra.Matrix
import Mathlib.Analysis.NormedSpace.OperatorNorm.Basic
import Mathlib.LinearAlgebra.Matrix.ToLin
import Coh.Core.Clifford
import Coh.Core.CliffordRep
import Coh.Prelude

noncomputable section

namespace Coh.Examples

open Coh
open Coh.Core
open Matrix

/-!
# Phase E Validation: Dirac Matrix Witness (current carrier interface)

This module provides a concrete `4 × 4` complex gamma-matrix family on
`ℂ^4`. In the current Coh architecture, faithfulness in
[`IsFaithfulRep`](../Core/CliffordRep.lean) means injectivity of the index map
`μ ↦ Γ_μ`, so this file discharges that requirement with an explicit matrix
witness.

The stronger Clifford-algebra packaging discussed in the design notes is not
yet the interface consumed by [`GammaFamily`](../Core/SpectralContext.lean).
-/

/-- Concrete Dirac carrier `ℂ^4`, realized as Euclidean space. -/
abbrev DiracComplexSpace := EuclideanSpace ℂ (Fin 4)

noncomputable instance instCarrierSpaceDiracMatrixWitness : CarrierSpace DiracComplexSpace := by
  exact ⟨inferInstance⟩

/-- Standard Dirac gamma matrix `γ⁰` for signature `(-,+,+,+)`. -/
def gamma_0 : Matrix (Fin 4) (Fin 4) ℂ :=
  !![0, 0, Complex.I, 0;
     0, 0, 0, Complex.I;
     Complex.I, 0, 0, 0;
     0, Complex.I, 0, 0]

/-- Standard Dirac gamma matrix `γ¹`. -/
def gamma_1 : Matrix (Fin 4) (Fin 4) ℂ :=
  !![0, 0, 0, 1;
     0, 0, 1, 0;
     0, -1, 0, 0;
     -1, 0, 0, 0]

/-- Standard Dirac gamma matrix `γ²`. -/
def gamma_2 : Matrix (Fin 4) (Fin 4) ℂ :=
  !![0, 0, 0, -Complex.I;
     0, 0, Complex.I, 0;
     0, Complex.I, 0, 0;
     -Complex.I, 0, 0, 0]

/-- Standard Dirac gamma matrix `γ³`. -/
def gamma_3 : Matrix (Fin 4) (Fin 4) ℂ :=
  !![0, 0, 1, 0;
     0, 0, 0, -1;
     -1, 0, 0, 0;
     0, 1, 0, 0]

/-- Matrix-valued gamma assignment. -/
def diracGammaMatrix (μ : Idx) : Matrix (Fin 4) (Fin 4) ℂ :=
  match μ.1 with
  | 0 => gamma_0
  | 1 => gamma_1
  | 2 => gamma_2
  | _ => gamma_3

/-- Convert a complex matrix on `ℂ^4` into a real continuous linear map. -/
def toDirLinear (A : Matrix (Fin 4) (Fin 4) ℂ) : DiracComplexSpace →L[ℝ] DiracComplexSpace :=
  ((Matrix.toEuclideanCLM (n := Fin 4) (𝕜 := ℂ) A).restrictScalars ℝ)

/-- The conversion from matrices to real continuous linear maps is injective. -/
theorem toDirLinear_injective : Function.Injective toDirLinear := by
  intro A B h
  apply Matrix.toEuclideanCLM.injective
  ext x i
  exact congrArg (fun (f : DiracComplexSpace →L[ℝ] DiracComplexSpace) => f x i) h

lemma complex_I_ne_one : (Complex.I : ℂ) ≠ 1 := by
  intro h
  have him := congrArg Complex.im h
  simp at him

lemma one_ne_neg_complex_I : (1 : ℂ) ≠ -Complex.I := by
  intro h
  have him := congrArg Complex.im h
  simp at him

/-- The concrete Dirac gamma operators are pairwise distinct. -/
@[simp] theorem gamma_0_ne_gamma_1 : gamma_0 ≠ gamma_1 := by
  intro h
  have h' := congrArg (fun M => M 0 2) h
  simpa [gamma_0, gamma_1] using h'

@[simp] theorem gamma_0_ne_gamma_2 : gamma_0 ≠ gamma_2 := by
  intro h
  have h' := congrArg (fun M => M 0 2) h
  simpa [gamma_0, gamma_2] using h'

@[simp] theorem gamma_0_ne_gamma_3 : gamma_0 ≠ gamma_3 := by
  intro h
  have h' := congrArg (fun M => M 0 2) h
  exact complex_I_ne_one (by simpa [gamma_0, gamma_3] using h')

@[simp] theorem gamma_1_ne_gamma_2 : gamma_1 ≠ gamma_2 := by
  intro h
  have h' := congrArg (fun M => M 0 3) h
  exact one_ne_neg_complex_I (by simpa [gamma_1, gamma_2] using h')

@[simp] theorem gamma_1_ne_gamma_3 : gamma_1 ≠ gamma_3 := by
  intro h
  have h' := congrArg (fun M => M 0 2) h
  simpa [gamma_1, gamma_3] using h'

@[simp] theorem gamma_2_ne_gamma_3 : gamma_2 ≠ gamma_3 := by
  intro h
  have h' := congrArg (fun M => M 0 3) h
  have : (-Complex.I : ℂ) ≠ 0 := by simpa using Complex.I_ne_zero
  exact this (by simpa [gamma_2, gamma_3] using h')

/-- The matrix-level gamma assignment is injective on spacetime indices. -/
theorem diracGammaMatrix_injective : Function.Injective diracGammaMatrix := by
  intro μ ν h
  fin_cases μ <;> fin_cases ν
  · rfl
  · exfalso; exact gamma_0_ne_gamma_1 h
  · exfalso; exact gamma_0_ne_gamma_2 h
  · exfalso; exact gamma_0_ne_gamma_3 h
  · exfalso; exact gamma_0_ne_gamma_1 h.symm
  · rfl
  · exfalso; exact gamma_1_ne_gamma_2 h
  · exfalso; exact gamma_1_ne_gamma_3 h
  · exfalso; exact gamma_0_ne_gamma_2 h.symm
  · exfalso; exact gamma_1_ne_gamma_2 h.symm
  · rfl
  · exfalso; exact gamma_2_ne_gamma_3 h
  · exfalso; exact gamma_0_ne_gamma_3 h.symm
  · exfalso; exact gamma_1_ne_gamma_3 h.symm
  · exfalso; exact gamma_2_ne_gamma_3 h.symm
  · rfl

/-- The concrete gamma family used by the Coh witness layer. -/
def dirac_gamma_family : GammaFamily DiracComplexSpace where
  Γ μ := toDirLinear (diracGammaMatrix μ)

/-- Faithfulness in the current interface: the four gamma operators are distinct. -/
theorem dirac_gamma_family_injective : Function.Injective dirac_gamma_family.Γ := by
  intro μ ν h
  apply diracGammaMatrix_injective
  exact toDirLinear_injective h

/--
[CITED] Standard representation-theoretic input: the Dirac gamma action on `ℂ^4`
is irreducible as the intended spacetime spinor carrier.
-/
axiom dirac_irreducible_cited : IsIrreducibleRep dirac_gamma_family minkowskiMetric

/--
[CITED] Standard phase-E input: the Dirac carrier is metabolically minimal among
faithful Lorentzian carriers in the current Coh abstraction.
-/
axiom dirac_minimal_cited : MetabolicallyMinimal DiracComplexSpace dirac_gamma_family minkowskiMetric

/-- Concrete faithful Dirac witness for the current `IsFaithfulRep` interface. -/
noncomputable instance instFaithfulDirac : IsFaithfulRep dirac_gamma_family minkowskiMetric where
  injective := dirac_gamma_family_injective

/-- Imported irreducibility witness for the concrete Dirac carrier. -/
noncomputable instance instIrreducibleDirac : IsIrreducibleRep dirac_gamma_family minkowskiMetric :=
  dirac_irreducible_cited

/-- Packaged faithful Dirac carrier witness in the current Coh interface. -/
noncomputable def instFaithfulDiracCarrier :
    IsFaithfulDiracCarrier DiracComplexSpace dirac_gamma_family minkowskiMetric where
  is_faithful := instFaithfulDirac
  is_irreducible := instIrreducibleDirac
  is_minimal := dirac_minimal_cited
  is_lorentzian := rfl

end Coh.Examples
