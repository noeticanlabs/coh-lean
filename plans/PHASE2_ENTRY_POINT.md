# PHASE 2 ENTRY POINT

**Status**: Ready for implementation  
**Mode**: Code  
**Target File**: [`Coh/Thermo/T5_RepresentationMinimality.lean`](../Coh/Thermo/T5_RepresentationMinimality.lean)

---

## Quick Start (5 minutes)

### What We're Proving

**Class**: `FaithfulIrreducibleBridge`

```lean
class FaithfulIrreducibleBridge
    [IsFaithful V] [IsFaithful W] [IsIrreducible W] where
  sameContent : SamePhysicalContent V W
  largerRank : StrictlyLargerCarrier V W
```

### Plain English

**"Larger, faithful representations with the same physical content are thermodynamically dominated by irreducible ones."**

If two representations (V and W) encode the same Clifford algebra, but V is strictly larger and W is irreducible, then V must be filtered out by metabolic constraints (higher cost, shorter lifespan).

---

## 5-Step Implementation

### STEP 1: Dirac Spinor Faithfulness
**Instance**: `isFaithful_diracSpinor`

Prove `IsFaithful (Fin 4 → ℂ)` for Dirac spinors.

```lean
instance isFaithful_diracSpinor : IsFaithful (Fin 4 → ℂ) :=
  ⟨fun γ γ' eq => by
    -- Use Clifford anticommutation + linear independence
    sorry⟩
```

**Difficulty**: Medium  
**Key Idea**: Distinct gamma matrices are linearly independent

---

### STEP 2: Dirac Spinor Irreducibility
**Instance**: `isIrreducible_diracSpinor`

Prove `IsIrreducible (Fin 4 → ℂ)` under Clifford action.

```lean
instance isIrreducible_diracSpinor : IsIrreducible (Fin 4 → ℂ) :=
  ⟨fun W hW => by
    -- Schur's lemma: no proper invariant subspace
    sorry⟩
```

**Difficulty**: Medium–Hard  
**Key Idea**: Schur's lemma + endomorphism ring structure

---

### STEP 3: Physical Content Equivalence
**Instance**: `samePhysicalContent_spinors`

Prove `SamePhysicalContent (Fin 4 → ℂ) (Fin 8 → ℝ)`.

```lean
instance samePhysicalContent_spinors :
    SamePhysicalContent (Fin 4 → ℂ) (Fin 8 → ℝ) :=
  ⟨fun iso => by
    -- Complexification/realization isomorphism
    sorry⟩
```

**Difficulty**: Medium  
**Key Idea**: Complex (4) ↔ Real (8) spinor conversion

---

### STEP 4: Rank Comparison
**Lemma**: `largerRank_spinors`

Prove `StrictlyLargerCarrier (Fin 8 → ℝ) (Fin 4 → ℂ)`.

```lean
lemma largerRank_spinors : 
    StrictlyLargerCarrier (Fin 8 → ℝ) (Fin 4 → ℂ) :=
  ⟨by norm_num⟩  -- 8 > 4
```

**Difficulty**: Easy  
**Key Idea**: Arithmetic (8 > 4)

---

### STEP 5: Bridge Assembly
**Class Instance**: `faithfulIrreducibleBridge_dirac`

Assemble all three properties into the bridge.

```lean
instance faithfulIrreducibleBridge_dirac :
    FaithfulIrreducibleBridge (Fin 8 → ℝ) (Fin 4 → ℂ) where
  sameContent := samePhysicalContent_spinors
  largerRank := largerRank_spinors
```

**Difficulty**: Easy (composition)  
**Key Tactic**: `exact`, instance application

---

## Implementation Checklist

- [ ] **Step 1**: `isFaithful_diracSpinor` (~15–20 lines)
- [ ] **Step 2**: `isIrreducible_diracSpinor` (~20–25 lines)
- [ ] **Step 3**: `samePhysicalContent_spinors` (~10–15 lines)
- [ ] **Step 4**: `largerRank_spinors` (~5–10 lines)
- [ ] **Step 5**: `faithfulIrreducibleBridge_dirac` (~5–10 lines)
- [ ] **Optional**: Compose with thermodynamic dominance (~15–20 lines)
- [ ] **Testing**: Run `lake build` → verify zero errors
- [ ] **Documentation**: Add docstrings to all instances

---

## Key Files & Dependencies

### Read First
- [`Coh/Thermo/T5_RepresentationMinimality.lean`](../Coh/Thermo/T5_RepresentationMinimality.lean) — Target file + existing framework
- [`Coh/Core/Minimality.lean`](../Coh/Core/Minimality.lean) — Thermodynamic cost lemmas (imported)
- [`Coh/Kinematics/T3_Clifford.lean`](../Coh/Kinematics/T3_Clifford.lean) — Clifford algebra background

### Modify
- [`Coh/Thermo/T5_RepresentationMinimality.lean`](../Coh/Thermo/T5_RepresentationMinimality.lean) — Add 5 instances (after line 125)

---

## Quick Tactics Reference

| Tactic | Use | Example |
|--------|-----|---------|
| `constructor` | Instantiate class | FaithfulIrreducibleBridge |
| `simp` | Simplify | Definition unfolding |
| `norm_num` | Arithmetic | 8 > 4 |
| `omega` | Integer logic | Rank comparison |
| `exact` | Apply lemma | Inject existing property |
| `contrapose` | By contradiction | No proper subspace |
| `cases` | Case split | Submodule analysis |

---

## Common Pitfalls

1. **Real vs Complex Dimensions**: Real 8 = Complex 4 (factor of 2)
2. **Class vs Instance**: Classes (IsFaithful) vs instances (specific spinors)
3. **Witness Terms**: Classes may require witness terms (dummy `⟨⟩` is okay for abstract properties)

---

## Success Criteria

✅ All must pass:
1. **Syntax**: No parse errors
2. **Types**: All well-typed
3. **Instances**: Properly instantiated
4. **Build**: `lake build` exits with code 0
5. **Integration**: Thermodynamic lemmas compose correctly

---

## Estimated Timeline

| Step | Lines | Time |
|------|-------|------|
| 1. Faithfulness | 15–20 | 15 min |
| 2. Irreducibility | 20–25 | 25 min |
| 3. Content | 10–15 | 15 min |
| 4. Rank | 5–10 | 5 min |
| 5. Bridge | 5–10 | 5 min |
| **Total** | **55–80** | **65 min** |

---

## Reference Docs

- **Full Strategy**: [`plans/PHASE2_T5_BRIDGE_PLAN.md`](PHASE2_T5_BRIDGE_PLAN.md)
- **Project Status**: [`plans/PROJECT_STATUS.md`](PROJECT_STATUS.md)

---

**Ready to implement Phase 2?** 🚀

Start with **Step 1** (Faithfulness) — conceptually cleanest, builds confidence.
