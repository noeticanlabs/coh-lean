---
trigger: always_on
---

build as we go do not use sorry's or placeholder's etc. to reduce false finish point or finish quick work hard and truthful. when you encounter a sorry or placeholder, you must replace it with a working implementation.Invariants to preserve while solving

1. Do not replace a missing mathematical bridge with a string theorem.
2. Do not hide axioms such as [`Coh.Spectral.clifford_anomaly_positive_on_unit_sphere`](../Coh/Spectral/CompactnessProof.lean#L27); keep them explicit in the ledger.
3. Any theorem that quantifies over arbitrary sets such as `S : Set (V →L[ℝ] V)` must be backed by actual membership data, not narrative intent.
4. Dynamics claims in [`Coh/Spectral/T10_DiracDynamics.lean`](../Coh/Spectral/T10_DiracDynamics.lean) should only compose already formalized objects from upstream files.
5. The solve order is dependency-first, not aspiration-first.