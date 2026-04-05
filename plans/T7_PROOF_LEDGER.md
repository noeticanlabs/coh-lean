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

## Obstruction map

- The load-bearing core is Placeholder 1.
- The original linear-gap strategy helpers in [`Coh/Spectral/VisibilityGap.lean`](../Coh/Spectral/VisibilityGap.lean) were stronger than the proved quadratic theorem and should not remain as theorem placeholders.
- The safe closure path is:
  1. prove Placeholder 1,
  2. prove Placeholder 2 in quadratic form,
  3. prove Placeholder 5 and Placeholder 6 in quadratic form,
  4. demote Placeholder 3 and Placeholder 4 to explicit doc-only helpers.
