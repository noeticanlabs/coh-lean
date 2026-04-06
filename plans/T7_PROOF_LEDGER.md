# T7 Proof Ledger

## Scope lock

- Target chain: [`Coh/Spectral/CompactnessProof.lean`](Coh/Spectral/CompactnessProof.lean) -> [`Coh/Spectral/VisibilityGap.lean`](Coh/Spectral/VisibilityGap.lean)
- Success condition: no proof-bearing `sorry` remains in this chain
- Allowed fallback: demote unused speculative statements to explicit doc-only helpers

## Placeholder 1 — `anomalyStrength_positive_min_on_sphere`

- Statement: existence of `ε > 0` uniformly bounding [`anomalyStrength_positive_min_on_sphere`](../Coh/Spectral/CompactnessProof.lean) from below on the unit frequency sphere
- Trying to prove: a continuous positive function on a compact sphere attains a strictly positive minimum
- Exact imported lemmas available:
  - [`anomalyStrength_continuous`](../Coh/Spectral/CompactnessProof.lean)
  - [`unitSphere_compact`](../Coh/Spectral/CompactnessProof.lean)
  - [`clifford_anomaly_positive_on_unit_sphere`](../Coh/Spectral/CompactnessProof.lean)
  - [`unitFrequencySphere_eq_metricSphere`](../Coh/Spectral/NormEquivalence.lean)
  - `IsCompact.exists_isMinOn`
  - `NormedSpace.sphere_nonempty`
- Classification: compactness

## Placeholder 2 — `T7_Proof_Via_Compactness`

- Statement: compactness strategy bridge in [`Coh/Spectral/VisibilityGap.lean`](../Coh/Spectral/VisibilityGap.lean)
- Trying to prove: package the compactness core into the exported quadratic gap form
- Exact imported lemmas available:
  - [`T7_Quadratic_Spectral_Gap`](../Coh/Spectral/CompactnessProof.lean)
- Classification: bridge packaging

## Placeholder 3 — `T7_MetricDependence`

- Statement: metric-dependent linear gap export in [`Coh/Spectral/VisibilityGap.lean`](../Coh/Spectral/VisibilityGap.lean)
- Trying to prove: compare gap constants across metrics
- Exact imported lemmas available:
  - [`T7_Quadratic_Spectral_Gap`](../Coh/Spectral/CompactnessProof.lean)
  - [`T7_Visibility_Spectral_Gap`](../Coh/Spectral/VisibilityGap.lean)
- Classification: bridge packaging
- Closure decision: demote to doc-only helper; no metric comparison lemma exists in the chain

## Placeholder 4 — `T7_Universal`

- Statement: universal linear gap over all carriers in [`Coh/Spectral/VisibilityGap.lean`](../Coh/Spectral/VisibilityGap.lean)
- Trying to prove: a carrier-uniform lower bound independent of representation details
- Exact imported lemmas available:
  - [`T7_Quadratic_Spectral_Gap`](../Coh/Spectral/CompactnessProof.lean)
- Classification: bridge packaging
- Closure decision: demote to doc-only helper; current chain has no uniform-in-carrier comparison theorem

## Placeholder 5 — `T7_Proof_Via_Coercivity`

- Statement: coercivity strategy bridge in [`Coh/Spectral/VisibilityGap.lean`](../Coh/Spectral/VisibilityGap.lean)
- Trying to prove: repackage an assumed coercive quadratic bound into the canonical T7 output shape
- Exact imported lemmas available:
  - [`T7_Quadratic_Spectral_Gap`](../Coh/Spectral/CompactnessProof.lean)
- Classification: rescaling

## Placeholder 6 — `T7_Proof_Via_Rigidity`

- Statement: rigidity strategy bridge in [`Coh/Spectral/VisibilityGap.lean`](../Coh/Spectral/VisibilityGap.lean)
- Trying to prove: turn unit-sphere positivity into the canonical T7 quadratic gap
- Exact imported lemmas available:
  - [`clifford_anomaly_positive_on_unit_sphere`](../Coh/Spectral/CompactnessProof.lean)
  - [`T7_Quadratic_Spectral_Gap`](../Coh/Spectral/CompactnessProof.lean)
- Classification: positivity

## T3 Analytic Visibility Bridge — Implementation Checklist

### Scope lock
- Target: close the T3 bridge by consuming the proved T7 quadratic spectral gap
- Strategy: local kinematics bridge (keep core interface witness-local vs global decision in kinematics layer)
- Entry point: [`Coh.Kinematics.T7_Quadratic_Spectral_Gap`](Coh/Spectral/CompactnessProof.lean:87)

### Implementation Checklist

- [ ] **1. Rebase bridge on T7 machinery**
  - [ ] Import [`Coh.Spectral.T7_Quadratic_Spectral_Gap`](Coh/Spectral/CompactnessProof.lean:87) into the kinematics layer
  - [ ] Replace ad hoc coupling axiom references with the proved quadratic bound

- [ ] **2. Refactor witness visibility definitions**
  - [ ] Verify [`Coh.Kinematics.WitnessCoercivelyVisible`](Coh/Kinematics/T3_NonCliffordVisible.lean:150) can be expressed in terms of the global quadratic bound
  - [ ] Verify [`Coh.Kinematics.AllMismatchWitnessesVisible`](Coh/Kinematics/T3_NonCliffordVisible.lean:160) structure still holds

- [ ] **3. Add bridge lemma**
  - [ ] Prove: if global quadratic bound holds, then witness-local coercivity holds on [`pairSpike`](Coh/Kinematics/T3_NonCliffordVisible.lean:90)
  - [ ] Lemma form: `∀ μ ν, WitnessCoercivelyVisible V Γ g μ ν` from `T7_Quadratic_Spectral_Gap`

- [ ] **4. Route through existing packaging**
  - [ ] Fix [`Coh.Kinematics.nonCliffordVisibilityBridge_of_witnessVisibility`](Coh/Kinematics/T3_NonCliffordVisible.lean:208)
  - [ ] Fix [`Coh.Kinematics.nonCliffordVisibilityBridge_of_uniformAmplification`](Coh/Kinematics/T3_WitnessAmplification.lean:75)
  - [ ] Fix [`Coh.Kinematics.clifford_of_coercive_soundness_composition`](Coh/Kinematics/T3_Necessity.lean:25)

- [ ] **5. Decide local vs global interface**
  - [ ] Keep core interface in kinematics layer (witness-local)
  - [ ] Optionally upgrade to global anomaly-bound theorem in [`Coh.Core/Oplax.lean`](Coh/Core/Oplax.lean:64) as separate task

- [ ] **6. Rebuild and audit**
  - [ ] Run `lake build` to verify compilation
  - [ ] `grep sorry` in kinematics files to confirm no proof-bearing sorry remains
  - [ ] Document any remaining gaps in a new T3 ledger if needed
