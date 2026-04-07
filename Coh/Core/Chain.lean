import Coh.Prelude
import Coh.Core.Carriers
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.Order.Ring.Abs

namespace Coh.Core

/-!
# Phase C: Receipt Chains (Compositional Discrete Trace Layer)

This module implements the trace-audit logic for governed systems. 
It follows the "Geometric Governance" strategy:
1. **Metabolic Cost** is strictly non-negative.
2. **Objects** are anchored to the Kinematic CarrierSpace.
3. **Chains** allow for deterministic, compositional audit of system trajectories.

[PROVED] Compositional lawfulness for potential-reduction transitions.
-/

/-- 
Atomic unit of a verifiable state transition.
[INVARIANT] all fields are strictly non-negative.
-/
structure Receipt where
  spend : ℝ
  defect : ℝ
  authority : ℝ
  h_spend : 0 ≤ spend := by linarith
  h_defect : 0 ≤ defect := by linarith
  h_authority : 0 ≤ authority := by linarith

/--
A CohObject is a governed wrapper around a state space V.
It encapsulates the potential functional and the current state.
-/
structure CohObject (V : Type*) [CarrierSpace V] where
  state : V
  potential : V → ℝ
  budget : ℝ

/--
Lawfulness Predicate for a Receipt (Phase C audit).
The governance law: V(x') + Spend(r) ≤ V(x) + Defect(r) + Authority(r).
-/
def IsLawful {V : Type*} [CarrierSpace V] 
    (r : Receipt) (obj obj' : CohObject V) : Prop :=
  obj'.potential obj'.state + r.spend ≤ obj.potential obj.state + r.defect + r.authority

--------------------------------------------------------------------------------
-- Chain Logic: Compositional Traces
--------------------------------------------------------------------------------

/--
Inductive type for a sequence of lawful receipts.
A Chain from `obj_start` to `obj_end` represents a sequence of transitions
where each step is verified by the kernel.
-/
inductive Chain {V : Type*} [CarrierSpace V] : CohObject V → CohObject V → Prop where
  | id (obj : CohObject V) : Chain obj obj
  | step (obj₁ obj₂ obj₃ : CohObject V) (r : Receipt) :
      IsLawful r obj₁ obj₂ → Chain obj₂ obj₃ → Chain obj₁ obj₃

/--
Aggregate two Receipts into a single effective Receipt.
- Total Spend = Σ spend
- Total Defect = Σ defect
- Total Authority = Σ authority
-/
def combineReceipts (r₁ r₂ : Receipt) : Receipt where
  spend := r₁.spend + r₂.spend
  defect := r₁.defect + r₂.defect
  authority := r₁.authority + r₂.authority
  h_spend := add_nonneg r₁.h_spend r₂.h_spend
  h_defect := add_nonneg r₁.h_defect r₂.h_defect
  h_authority := add_nonneg r₁.h_authority r₂.h_authority

/--
The composition of two lawful transitions is a lawful transition
under the aggregate receipt.
[PROVED] Deterministic composition of potential-reduction bounds.
-/
theorem lawful_composition {V : Type*} [CarrierSpace V]
    (r₁ r₂ : Receipt) (obj₁ obj₂ obj₃ : CohObject V)
    (h₁ : IsLawful r₁ obj₁ obj₂)
    (h₂ : IsLawful r₂ obj₂ obj₃) :
    IsLawful (combineReceipts r₁ r₂) obj₁ obj₃ := by
  unfold IsLawful combineReceipts
  dsimp
  -- Given: 
  --   P(obj₂) + r₁.spend ≤ P(obj₁) + r₁.defect + r₁.authority
  --   P(obj₃) + r₂.spend ≤ P(obj₂) + r₂.defect + r₂.authority
  -- Goal: 
  --   P(obj₃) + (r₁.spend + r₂.spend) ≤ P(obj₁) + (r₁.defect + r₂.defect) + (r₁.authority + r₂.authority)
  linarith

/--
A terminal aggregation function for chains (Proof of Concept).
Recursively collapses a chain of receipts into a single proof-equivalent receipt.
-/
def Chain.toReceipt {V : Type*} [CarrierSpace V]
    {obj₁ obj₂ : CohObject V} (c : @Chain V _ obj₁ obj₂) : Receipt :=
  match c with
  | .id _ => { spend := 0, defect := 0, authority := 0 }
  | .step _ obj₂ _ r _ next => combineReceipts r (toReceipt next)

end Coh.Core
