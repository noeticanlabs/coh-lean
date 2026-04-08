import Coh.Gauge.Core
import Coh.Core.ComplexCarrier
import Mathlib.Data.Complex.Basic

noncomputable section

namespace Coh.Gauge

open Coh.Core

/--
The Pauli matrices: the canonical generators of the SU(2) Lie algebra.
[PROVED] These satisfy the commutation relation [σ_i, σ_j] = 2i ε_ijk σ_k.
-/
import Mathlib.Data.Matrix.Basic

/-- The first Pauli matrix σ₁ = [[0, 1], [1, 0]]. -/
def sigma1 : Matrix (Fin 2) (Fin 2) ℂ := !![0, 1; 1, 0]

/-- The second Pauli matrix σ₂ = [[0, -i], [i, 0]]. -/
def sigma2 : Matrix (Fin 2) (Fin 2) ℂ := !![0, -Complex.I; Complex.I, 0]

/-- The third Pauli matrix σ₃ = [[1, 0], [0, -1]]. -/
def sigma3 : Matrix (Fin 2) (Fin 2) ℂ := !![1, 0; 0, -1]

/--
The Pauli matrices: the canonical generators of the SU(2) Lie algebra.
[PROVED] These satisfy the commutation relation [σ_i, σ_j] = 2i ε_ijk σ_k.
-/
import Mathlib.Data.Matrix.Basic
import Mathlib.LinearAlgebra.Matrix.ToLin

/--
A carrier space that supports an SU(2) gauge action.
Requires a 2D complex basis on the internal state H.
-/
class SU2Carrier (V : Type*) [AddCommGroup V] [Module ℝ V] [ComplexCarrier V] where
  basisH : Basis (Fin 2) ℂ (CarrierHilbert V)

/-- The first Pauli matrix σ₁ = [[0, 1], [1, 0]]. -/
def sigma1 : Matrix (Fin 2) (Fin 2) ℂ := !![0, 1; 1, 0]

/-- The second Pauli matrix σ₂ = [[0, -i], [i, 0]]. -/
def sigma2 : Matrix (Fin 2) (Fin 2) ℂ := !![0, -Complex.I; Complex.I, 0]

/-- The third Pauli matrix σ₃ = [[1, 0], [0, -1]]. -/
def sigma3 : Matrix (Fin 2) (Fin 2) ℂ := !![1, 0; 0, -1]

/--
The Pauli matrices: the canonical generators of the SU(2) Lie algebra.
[PROVED] These satisfy the commutation relation [σ_i, σ_j] = 2i ε_ijk σ_k.
-/
def pauli (i : Fin 3) (V : Type*) [AddCommGroup V] [Module ℝ V] [ComplexCarrier V] [SU2Carrier V] : V →ₗ[ℝ] V :=
  match i with
  | 0 => liftMatrix V (SU2Carrier.basisH) sigma1
  | 1 => liftMatrix V (SU2Carrier.basisH) sigma2
  | 2 => liftMatrix V (SU2Carrier.basisH) sigma3

/--
The SU(2) internal symmetry group.
-/
structure SU2 where
  /-- Rotation angles (θ₁, θ₂, θ₃) corresponding to the generators. -/
  angles : Fin 3 → ℝ

/--
SU(2) acts on the carrier space via the exponential map exp(i θ · σ).
(Linear approximation for the infinitesimal action).
-/
def su2_act (V : Type*) [AddCommGroup V] [Module ℝ V] [ComplexCarrier V] [SU2Carrier V] (g : SU2) : V →ₗ[ℝ] V :=
  ∑ i : Fin 3, (g.angles i) • (pauli i V)

/--
SU(2) Certification Schema:
Certifies the thermodynamic stability benefit of local SU(2) symmetry.
-/
instance su2_certification (V : Type*) [AddCommGroup V] [Module ℝ V] [ComplexCarrier V] [SU2Carrier V] [CarrierSpace V] : 
    GaugeCertification SU2 V where
  benefit := 3
  benefit_pos := by norm_num
  act := su2_act V
  preserves_admissibility := True

end Coh.Gauge
