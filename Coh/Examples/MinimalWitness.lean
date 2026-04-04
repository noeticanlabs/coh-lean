import Coh.Physics.DiracInevitable
import Coh.Geometry.T6_Complexification
import Coh.Thermo.T5_Minimality

import Mathlib.Data.Real.Basic
import Mathlib.LinearAlgebra.LinearMap

noncomputable section

namespace Coh.Examples

open Coh.Physics
open Coh.Kinematics
open Coh.Thermo
open Coh.Geometry

instance : CarrierSpace (ℝ × ℝ) where
  toNormedAddCommGroup := inferInstance
  toNormedSpace := inferInstance
  toFiniteDimensional := inferInstance

def toyMetric : Metric where
  g := fun i j => if i = j then 0 else 0
  symm := by
    intro i j
    by_cases h : i = j <;> simp [h, eq_comm]

def toyGamma : GammaFamily (ℝ × ℝ) where
  Γ := fun _ => 0

def toyThermo : MetabolicParams where
  κ := 1
  κ_pos := by norm_num

def toyCarrier : LawfulCarrier (ℝ × ℝ) where
  metric := toyMetric
  gamma := toyGamma
  thermo := toyThermo

lemma toyCarrier_kinematically_lawful :
    KinematicallyLawful toyCarrier := by
  intro μ ν
  ext v <;> simp [KinematicallyLawful, toyCarrier, toyGamma, anticommutator, idOp, toyMetric]

lemma toyCarrier_geometrically_cyclic :
    GeometricallyCyclic toyCarrier := by
  exact R2_hasComplexLikeStructure

theorem dirac_target_inhabited : DiracInevitableTarget := by
  refine ⟨ℝ × ℝ, inferInstance, toyCarrier, ?_⟩
  exact survivingCarrier_of_components toyCarrier
    toyCarrier_kinematically_lawful
    toyCarrier_geometrically_cyclic

end Coh.Examples
