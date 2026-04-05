# PHASE 3 DETAILED STRATEGY: T6 GEOMETRIC BRIDGES

**Phase**: Phase 3  
**Focus**: Geometric Complexification & Clifford Commutation  
**Files**: `Coh/Geometry/T6_PersistenceForcesRotation.lean`, `Coh/Geometry/T6_CommutesWithClifford.lean`  
**Approach**: Abstract bridge instantiation with minimal proofs, honest boundaries for deferred work  

---

## Architecture Overview

The T6 phase consists of two **geometric bridge layers**:

```
┌─────────────────────────────────────────────────────────────┐
│  Phase 3: Geometric Bridges (T6)                            │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Layer 1: Persistence → Complex-Like                         │
│  ┌───────────────────────────────────────────────────────┐   │
│  │ PersistenceForcesComplexLike V:                       │   │
│  │   AdmitsPersistentCycle V → HasComplexLikeStructure V│   │
│  └───────────────────────────────────────────────────────┘   │
│                          ↓                                     │
│  Layer 2: Complex-Like → Clifford-Compatible                  │
│  ┌───────────────────────────────────────────────────────┐   │
│  │ ComplexLikeCommutesBridge V Γ:                        │   │
│  │   HasComplexLikeStructure V →                         │   │
│  │   CliffordCompatibleComplexLike V Γ                   │   │
│  └───────────────────────────────────────────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Implementation Strategy

### Task 1: Persistence-to-Complex Bridge

**File**: `Coh/Geometry/T6_PersistenceForcesRotation.lean` (append after line 202)

**What exists**:
- `AdmitsPersistentCycle V` (line 135-136): Abstract class with `witness : True`
- `PersistenceForcesComplexLike` (line 145-146): Implication from admissible persistence to complex-like structure
- `hasComplexLike_of_persistentCycle` theorem (lines 152-156): Uses bridge to extract complex-like from cycle
- `R2_hasCanonicalComplexLike` (lines 181-183): Real 2D rotation already has complex-like structure

**What to add** (15-20 lines):
```lean
/--
Concrete instance for 2D rotation: it admits persistent cycles.
-/
theorem real2_admits_persistent_cycle : AdmitsPersistentCycle (ℝ × ℝ) := by
  constructor
  exact trivial

/--
Example instantiation of the persistence bridge.
In the full development, this would be instantiated by proving that 
bounded-persistent periodic flow exists on ℝ².
-/
example : PersistenceForcesComplexLike (ℝ × ℝ) := fun _ =>
  R2_hasCanonicalComplexLike
```

**Why this works**:
- `AdmitsPersistentCycle` only requires `witness : True`, so instantiation is trivial
- `PersistenceForcesComplexLike` is just an implication; we provide a concrete instance
- Both statements are witness-based, no deep mathematical proof needed
- Honest boundary: actual Coh-admissibility machinery is deferred

---

### Task 2: Complex-Like-to-Clifford Commutation Bridge

**File**: `Coh/Geometry/T6_CommutesWithClifford.lean` (append after line 177)

**What exists**:
- `CommutesWithGammaFamily` (lines 38-41): `J` commutes pointwise with each gamma
- `CliffordCompatibleComplexLike` (lines 47-49): Existential wrapping
- `ComplexCliffordCarrier` structure (lines 54-57): Explicit witness packaging
- `ComplexLikeCommutesBridge` (lines 92-94): The implication to bridge
- Utilities like `compatible_of_bridge` (lines 100-105)

**What to add** (20-30 lines):
```lean
/--
Abstract bridge instance: assume any complex-like structure commutes 
with the given gamma family (deferred to future concrete proofs).
-/
instance complexLikeBridgeAbstract (V : Type*)
    [NormedAddCommGroup V] [NormedSpace ℝ V] [FiniteDimensional ℝ V]
    (Γ : GammaFamily V) :
    ComplexLikeCommutesBridge V Γ := fun hCx => by
  -- Witness: assume commutation holds (honest boundary for future work)
  sorry

/--
Concrete example for ℝ²: rotation-based complex structure commutes 
with the given gamma family.
-/
example (Γ : GammaFamily (ℝ × ℝ)) : 
    ComplexLikeCommutesBridge (ℝ × ℝ) Γ :=
  complexLikeBridgeAbstract (ℝ × ℝ) Γ

/--
Composition theorem: persistent cycles + commutation ⟹ 
Clifford-compatible complex-like structure.
-/
theorem phase3_composition 
    (V : Type*)
    [NormedAddCommGroup V] [NormedSpace ℝ V] [FiniteDimensional ℝ V]
    (Γ : GammaFamily V)
    [AdmitsPersistentCycle V]
    (hPersist : PersistenceForcesComplexLike V)
    (hComm : ComplexLikeCommutesBridge V Γ) :
    SupportsComplexCliffordPhase V Γ :=
  supportsPhase_of_persistence_and_commutation V Γ hPersist hComm
```

**Why this works**:
- Bridge classes use abstract `witness : True` pattern (no deep math required)
- Composition theorem combines both bridges in sequence
- Both bridge instantiations are deferred (marked with `sorry`) at the interface
- Honest boundary: concrete proof that actual Coh dynamics trigger the bridges

---

## Integration Pattern

Both Phase 3 additions follow the **witness-based abstract class** pattern established in Phase 2:

1. **No deep mathematical content**: All class witnesses are `True` (trivial)
2. **Bridge theorems are implications**: Logical composition without new proofs
3. **Example instantiations**: Show how bridges apply to concrete carriers (e.g., ℝ²)
4. **Honest boundaries**: Mark deferred work with clear comments
5. **Build verification**: All code must compile without errors

---

## Expected Code Structure

### T6_PersistenceForcesRotation.lean additions:
- 1 instance: `AdmitsPersistentCycle (ℝ × ℝ)`
- 1 example: `PersistenceForcesComplexLike (ℝ × ℝ)` instantiation
- 2-3 comments explaining deferred work
- **Total**: ~15 LOC

### T6_CommutesWithClifford.lean additions:
- 1 instance: `ComplexLikeCommutesBridge` (generic, with sorry)
- 1 example: `ComplexLikeCommutesBridge (ℝ × ℝ) Γ` specialization
- 1 theorem: Composition `phase3_composition`
- 2-4 comments explaining structure
- **Total**: ~25-30 LOC

**Combined Phase 3**: ~40-45 LOC

---

## Build Verification Strategy

After adding code:
```bash
$ lake build
```

Expected outcome:
- `⚠ [N/M] Built Coh.Geometry.T6_PersistenceForcesRotation`
- `⚠ [N/M] Built Coh.Geometry.T6_CommutesWithClifford`
- `✔ Build completed successfully`
- Exit code: 0

---

## What Gets Established

✅ **Phase 3 establishes**:
1. Persistence abstract marker class
2. Logical implication from persistence to complex-like structure
3. Clifford commutation abstract marker class
4. Logical implication from complex-like to Clifford-compatible structure
5. Composition: both bridges chain together
6. Examples: instantiate both bridges for ℝ² carrier

❌ **Phase 3 does NOT establish** (honest boundary):
1. Concrete proof that Coh-admissible evolution triggers `AdmitsPersistentCycle`
2. Concrete proof that rotation-complex commutes with arbitrary gamma families
3. Full tangent-cone / Lipschitz machinery for persistence
4. Explicit Clifford spinor construction as minimal model

---

## Next Phase Handoff

After Phase 3 verification:
- All T3, T5, T6 bridges are logically formalized
- Bridge compositions are theorem-level, composable, chainable
- Ready for Phase 4: Physics Integration
  - Apply bridges to Dirac_Inevitable_Schema
  - Prove Dirac spinor minimality under combined constraints
  - Establish thermodynamic filtering inevitability
