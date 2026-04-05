import Mathlib.Data.Real.Basic
import Mathlib.Analysis.NormedSpace.OperatorNorm.Basic
import Mathlib.LinearAlgebra.FiniteDimensional.Defs

namespace Coh

universe u v

abbrev End (V : Type u) := V → V

-- Dimension of spacetime (Cl(1,3) context)
def dim : ℕ := 4

-- Index type
abbrev Idx := Fin dim

--------------------------------------------------------------------------------
-- Metric signature types (Euclidean vs Lorentzian)
--------------------------------------------------------------------------------

/--
Metric signature enumeration:
- Euclidean: (+,+,+,+) — all timelike indices have positive norm
- Lorentzian: (-,+,+,+) — standard Minkowski signature (1 timelike, 3 spacelike)
-/
inductive MetricSignature
  | euclidean   : MetricSignature
  | lorentzian  : MetricSignature

/--
Check if a metric has predominantly positive-definite signature.
This is the signature for physical carriers in Euclidean spacetime.
-/
def MetricSignature.isEuclidean : MetricSignature → Prop
  | MetricSignature.euclidean => true
  | MetricSignature.lorentzian => false

/--
Check if a metric has Minkowski signature.
This is the signature for relativistic carriers.
-/
def MetricSignature.isLorentzian : MetricSignature → Prop
  | MetricSignature.euclidean => false
  | MetricSignature.lorentzian => true

/--
Formal real-valued metric tensor with symmetry and signature.
The signature field explicitly distinguishes between Euclidean and Lorentzian metrics,
enabling context-dependent representation theory.
-/
structure Metric where
  g : Idx → Idx → ℝ
  symm : ∀ i j, g i j = g j i
  signature : MetricSignature

/--
A Euclidean metric (positive-definite).
Example: g(μ,ν) = δ_μν (Kronecker delta).
-/
def euclideanMetric : Metric where
  g μ ν := if μ = ν then 1 else 0
  symm := fun μ ν => by
    by_cases h : μ = ν
    · simp [h]
    · have h' : ¬ν = μ := mt (·.symm) h
      simp [h, h']
  signature := MetricSignature.euclidean

/--
The standard Minkowski metric (Lorentzian signature).
Signature (-,+,+,+): g = diag(-1,+1,+1,+1).
-/
def minkowskiMetric : Metric where
  g μ ν :=
    if μ = ν then
      if μ.val = 0 then -1 else 1
    else
      0
  symm := fun μ ν => by
    by_cases h : μ = ν
    · simp [h]
    · have h' : ¬ν = μ := mt (·.symm) h
      simp [h, h']
  signature := MetricSignature.lorentzian

/-- Abstract frequency probe / hostile audit mode. -/
abbrev FrequencyProbe := Idx → ℝ

-- Budget-like scalar
abbrev Budget := ℝ

-- Lifespan-like scalar
abbrev Lifespan := ℝ

-- Tracking cost
abbrev Cost := ℝ

/-- Abstract carrier space with normed and finite-dimensional structure.
This is the foundational class for all representation carriers in the Coh framework.
-/
class CarrierSpace (V : Type*) extends
  NormedAddCommGroup V,
  NormedSpace ℝ V,
  FiniteDimensional ℝ V

noncomputable instance : CarrierSpace ℝ where
noncomputable instance : CarrierSpace (ℝ × ℝ) where

end Coh
