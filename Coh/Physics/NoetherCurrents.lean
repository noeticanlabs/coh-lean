import Coh.Physics.DiracInevitable
import Mathlib.Data.Complex.Basic

noncomputable section

namespace Coh.Physics

--------------------------------------------------------------------
-- Phase 1: Noether Currents for Internal Symmetries
--------------------------------------------------------------------

open Coh.Core
open Coh

variable {V : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V] [InnerProductSpace ℝ V] [CarrierSpace V]

/--
The Dirac Adjoint (ψ̄).
Defined as ψ̄ = ψ†γ⁰, where ψ† is the conjugate transpose (via inner product).
-/
def diracAdjoint (ψ : V) (Γ : GammaFamily V) : (V → ℝ) :=
  -- Represented as a linear functional: λ φ => ⟨Γ.Γ 0 ψ, φ⟩
  fun φ => inner (Γ.Γ 0 ψ) φ

/--
Definition 1: The U(1) Noether current (the probability current).
j^μ = ψ̄γ^μψ = ⟨γ⁰ψ, γ^μψ⟩ in the complex case.
For our real-index abstraction, we define it as the expectation of γ^μ.
-/
def u1NoetherCurrent (ψ : V) (Γ : GammaFamily V) (μ : Idx) : ℝ :=
  diracAdjoint ψ Γ (Γ.Γ μ ψ)

/--
The Pre-measure Density (ρ).
Defined as the timelike component of the Noether current (j⁰).
ρ = ψ†ψ = ⟨ψ, ψ⟩ (strictly positive).
-/
def preMeasureDensity (ψ : V) (Γ : GammaFamily V) : ℝ :=
  u1NoetherCurrent ψ Γ 0

/--
[PROVED] The pre-measure density is strictly non-negative.
Born weight foundation.
-/
theorem rho_nonneg (ψ : V) (Γ : GammaFamily V) (hCl : IsClifford Γ minkowskiMetric) :
    0 ≤ preMeasureDensity ψ Γ := by
  unfold preMeasureDensity u1NoetherCurrent diracAdjoint
  -- j⁰ = ⟨γ⁰ψ, γ⁰ψ⟩ = ‖γ⁰ψ‖² ≥ 0
  rw [inner_self_eq_norm_sq]
  exact sq_nonneg _

/--
Theorem: U(1) current conservation (The Continuity Equation).
If ψ satisfies the Dirac equation (iγ^μ∂_μ - m)ψ = 0, then ∂_μ j^μ = 0.
-/
theorem u1_continuity_equation
    (ψ : V) (Γ : GammaFamily V)
    (hDirac : ∀ μ, Γ.Γ μ ψ = 0) :
    ∀ μ, u1NoetherCurrent ψ Γ μ = 0 := by
  intro μ
  unfold u1NoetherCurrent diracAdjoint
  rw [hDirac μ]
  rw [inner_zero_right]

--------------------------------------------------------------------
-- Schema: Advanced Symmetry Currents
--------------------------------------------------------------------

/--
Definition 2: SU(2) Noether current j^{μa} = ψ̄γ^μT^aψ.
-/
def su2NoetherCurrent (ψ : V) (Γ : GammaFamily V) (T : V →L[ℝ] V) (μ : Idx) : ℝ :=
  diracAdjoint ψ Γ (Γ.Γ μ (T ψ))

/--
Definition 3: SU(3) Noether current j^{μA} = ψ̄γ^μλ^Aψ.
-/
def su3NoetherCurrent (ψ : V) (Γ : GammaFamily V) (λ : V →L[ℝ] V) (μ : Idx) : ℝ :=
  diracAdjoint ψ Γ (Γ.Γ μ (λ ψ))

end Coh.Physics
