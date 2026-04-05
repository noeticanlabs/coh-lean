# PHASE 2: T5 Representation-Theoretic Minimality Bridge

## Overview

**Phase 2 Target**: Prove `FaithfulIrreducibleBridge` in [`Coh/Thermo/T5_RepresentationMinimality.lean`](../Coh/Thermo/T5_RepresentationMinimality.lean)

This is the **representation-theoretic filter** of the Dirac Inevitability pipeline. It establishes that faithful, irreducible representations are thermodynamically dominant (higher cost, shorter lifespan) over any larger representation with the same physical content.

---

## Problem Statement

### The Obligation
```lean
class FaithfulIrreducibleBridge
    [IsFaithful V] [IsFaithful W] [IsIrreducible W] where
  sameContent : SamePhysicalContent V W
  largerRank : StrictlyLargerCarrier V W
```

### What This Means Physically

**Three conditions must be satisfied**:

1. **Faithfulness of Both**: 
   - V and W each faithfully represent the Clifford algebra
   - Distinct algebra elements map to distinct operators

2. **Irreducibility of W**:
   - W cannot be decomposed into invariant submodules
   - W is the "smallest indivisible representation" of its algebra

3. **Same Physical Content**:
   - V and W encode the same physical information
   - But V has strictly larger dimension (more redundancy)

**Consequence**: By Phase 0.5d thermodynamic minimality:
- V has higher cost κ × rankV > κ × rankW
- V has shorter lifespan B₀ / costV < B₀ / costW
- Therefore, **W survives longer under metabolic filtering**

---

## Technical Strategy

### Step 1: Establish Representation-Theoretic Instances
**Location**: Definitions in `Coh/Thermo/T5_RepresentationMinimality.lean`

**Goal**: Show that Clifford algebras and their representations satisfy `IsFaithful`, `IsIrreducible`, `SamePhysicalContent`.

**Key Tasks**:
1. Prove `IsFaithful (Fin 4 → ℂ)` for Dirac spinors
   - Distinct gamma matrices map to distinct linear operators
   - Use injectivity of representation action

2. Prove `IsIrreducible (Fin 4 → ℂ)` under Clifford action
   - Cannot decompose into Clifford-invariant subspaces
   - Schur's lemma: endomorphism ring is ℂ (division algebra)

3. Establish `SamePhysicalContent (Fin 4 → ℂ) (Fin 8 → ℝ)`
   - Both represent the same Clifford algebra
   - Isomorphism of representation structures

**Lean Tactics**:
- `constructor` / `intro` for class instantiation
- `simp` with representation lemmas
- `omega` for rank comparisons
- Direct applications of `StrictlyLargerCarrier` definition

---

### Step 2: Apply Thermodynamic Filtering
**Location**: Composition lemmas

**Goal**: Use Phase 0.5d results to show cost and lifespan ordering.

**Key Lemmas**:
- `cost_increases_with_rank` — rank V > rank W ⟹ cost V > cost W
- `shorter_lifespan_of_higher_cost` — cost V > cost W ⟹ lifespan V < lifespan W

**Proof Structure**:
```lean
theorem FaithfulIrreducibleBridge_implies_Dominated
    [IsFaithful V] [IsFaithful W] [IsIrreducible W]
    [hBridge : FaithfulIrreducibleBridge (V := V) (W := W)]
    (p : MetabolicParams) (B₀ : ℝ) (hB : 0 < B₀) (hW : 0 < moduleRank W) :
    ThermodynamicallyDominated V W p B₀ := by
  -- Step 1: Extract bridge properties
  have h_same := hBridge.sameContent
  have h_larger := hBridge.largerRank
  -- Step 2: Apply thermodynamic ordering
  have h_cost := cost_increases_with_rank V W p h_larger
  have h_life := shorter_lifespan_of_higher_cost V W p hB hW h_cost
  -- Step 3: Construct domination proof
  exact ⟨h_larger, h_life⟩
```

---

### Step 3: Discharge the Bridge
**Location**: Main theorem

**Goal**: Compose all representation facts into bridge class.

**Proof**:
1. Assume V is faithful and larger than irreducible W
2. Show V and W encode same Clifford algebra
3. Invoke thermodynamic filtering from Step 2
4. Return bridge structure

---

## Dependencies & Available Infrastructure

### From Phase 0.5d (Minimality.lean)
✅ `moduleRank` — Dimension extraction  
✅ `trackingCost` — Cost computation  
✅ `nominalLifespan` — Lifespan calculation  
✅ `cost_increases_with_rank` — Cost monotonicity  
✅ `shorter_lifespan_of_higher_cost` — Lifespan ordering  

### From Phase 0.5e (Complexification.lean)
✅ `HasComplexLikeStructure` — Structure preservation  
✅ Complex dimension calculations  

### Already in T5 Module
✅ `StrictlyLargerCarrier` — Rank comparison  
✅ `MoreExpensive` — Cost comparison  
✅ `ShorterLifespan` — Lifespan comparison  
✅ `ThermodynamicallyDominated` — Full dominance property  
✅ `dominated_of_sameContent_and_larger` — Composition lemma  

### From Mathlib
✅ `Module.finrank` — Dimension in Lean  
✅ Representation theory (if needed)  

---

## Implementation Sub-tasks

### Sub-task 1: Clifford Faithfulness (~15–20 lines)
**What**: Prove Clifford matrices on Fin 4 → ℂ form a faithful action

**Reference**: Clifford anticommutation relations + linear independence

```lean
instance isFaithful_diracSpinor : 
    IsFaithful (Fin 4 → ℂ) :=
  ⟨fun γ γ' eq => by
    -- Use injectivity from Clifford anticommutation
    sorry⟩
```

### Sub-task 2: Clifford Irreducibility (~20–25 lines)
**What**: Prove Fin 4 → ℂ is irreducible under Clifford action

**Reference**: Schur's lemma, representation theory

```lean
instance isIrreducible_diracSpinor :
    IsIrreducible (Fin 4 → ℂ) :=
  ⟨fun W hW => by
    -- Show no proper invariant subspace
    sorry⟩
```

### Sub-task 3: Same Physical Content (~10–15 lines)
**What**: Establish isomorphism between Fin 4 → ℂ and Fin 8 → ℝ representations

**Reference**: Real/complex conversion of spinor spaces

```lean
instance samePhysicalContent_spinors :
    SamePhysicalContent (Fin 4 → ℂ) (Fin 8 → ℝ) :=
  ⟨fun iso => by
    -- Map via complexification/realization
    sorry⟩
```

### Sub-task 4: Bridge Assembly (~10–15 lines)
**What**: Wrap instances into FaithfulIrreducibleBridge

```lean
instance faithfulIrreducibleBridge_dirac :
    FaithfulIrreducibleBridge (Fin 4 → ℂ) (Fin 8 → ℝ) where
  sameContent := samePhysicalContent_spinors
  largerRank := by
    unfold StrictlyLargerCarrier
    norm_num  -- 8 > 4
```

### Sub-task 5: Integration with Thermodynamics (~15–20 lines)
**What**: Compose bridge with cost/lifespan lemmas

```lean
theorem diracSpinor_thermodynamicallyDominant
    (p : MetabolicParams) (B₀ : ℝ) (hB : 0 < B₀) :
    ThermodynamicallyDominated (Fin 4 → ℂ) (Fin 8 → ℝ) p B₀ := by
  apply dominated_of_sameContent_and_larger
  exact faithfulIrreducibleBridge_dirac.largerRank
```

---

## Estimated Effort

| Sub-task | Lines | Complexity | Est. Time |
|----------|-------|-----------|-----------|
| Faithfulness | 15–20 | Medium | 15 min |
| Irreducibility | 20–25 | Medium–Hard | 25 min |
| Physical Content | 10–15 | Medium | 15 min |
| Bridge Assembly | 10–15 | Easy | 10 min |
| Thermodynamic Integration | 15–20 | Easy–Medium | 15 min |
| **Total** | **70–95** | — | **80 min** |

---

## Key Proof Tactics

| Tactic | Use Case | Context |
|--------|----------|---------|
| `constructor` | Instantiate classes | Faithfulness, irreducibility |
| `simp` | Simplify with algebra lemmas | Definition unfolding |
| `omega` | Integer arithmetic | Rank comparisons (8 > 4) |
| `norm_num` | Numeric constants | Dimension checks |
| `exact` | Apply existing lemmas | Thermodynamic composition |
| `contrapose` | Proof by contradiction | Irreducibility (no proper subspace) |
| `cases` / `rcases` | Case analysis | Invariant subspace decomposition |

---

## Common Pitfalls to Avoid

1. **Real vs. Complex Dimensions**: Keep track of whether you're counting real or complex dimensions (8 real = 4 complex for spinors)
2. **Faithfulness vs. Irreducibility**: Faithfulness = kernel is trivial; Irreducibility = no proper invariant subspaces
3. **Module Rank Extraction**: Use `Module.finrank ℝ V` for real rank consistently
4. **Hypothesis Order**: Ensure all hypotheses (IsFaithful, IsIrreducible) are available before using them

---

## Success Criteria

✅ **All must pass**:

1. **Syntax**: No parse errors in T5_RepresentationMinimality.lean
2. **Types**: All terms well-typed (no unsolved metavariables)
3. **Instances**: All class instances properly instantiated
4. **Theorems**: FaithfulIrreducibleBridge proved (no sorry)
5. **Build**: `lake build` exits with code 0
6. **Integration**: Existing T5 tests still pass

---

## After Phase 2 Completes

1. ✅ Update [`plans/MINERALIZATION_PLAN.md`](MINERALIZATION_PLAN.md) — Mark T5 bridge as complete
2. ✅ Create [`plans/PHASE3_T6_BRIDGES_PLAN.md`](PHASE3_T6_BRIDGES_PLAN.md) — Persistence + Commutativity
3. ✅ Move to **Phase 3: T6 Geometric Bridges**

---

## Key References

- **Thermodynamic Lemmas**: [`Coh/Core/Minimality.lean`](../Coh/Core/Minimality.lean) (cost, lifespan)
- **T5 Framework**: [`Coh/Thermo/T5_RepresentationMinimality.lean`](../Coh/Thermo/T5_RepresentationMinimality.lean)
- **Clifford Algebra**: [`Coh/Kinematics/T3_Clifford.lean`](../Coh/Kinematics/T3_Clifford.lean)
- **Representation Theory**: Mathlib `LinearAlgebra.Representation`

---

## Quick Reference: File Locations

| Item | Location |
|------|----------|
| **Target File** | [`Coh/Thermo/T5_RepresentationMinimality.lean`](../Coh/Thermo/T5_RepresentationMinimality.lean) |
| **Class Definition** | Lines 120–123 (FaithfulIrreducibleBridge) |
| **Related Lemmas** | Lines 57–170 (cost, lifespan, dominance) |
| **Cost Lemmas** | [`Coh/Core/Minimality.lean`](../Coh/Core/Minimality.lean) (imported) |

---

**Ready to implement Phase 2?** 🚀

Start with **Sub-task 1** (Faithfulness) — conceptually simplest, builds momentum.
