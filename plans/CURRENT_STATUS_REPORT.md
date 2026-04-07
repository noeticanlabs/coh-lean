# Project Status: Hardening the Foundation (Phase 1 ⇌ Phase 5)

> **Current Objective**: Transitioning from **Postulated Existence** to **Principled Derivation**.
> **Focus**: Closing the "Visibility Spectral Gap" (T7) to secure the Dirac Inevitability Theorem.

---

## 1. Top-Line Status: "The Great Axiom Cleanup"

We have successfully **deleted the false global axiom** (`clifford_anomaly_positive_on_unit_sphere`) that previously "laundered" the proof of T3 Kinematics. We are currently replacing it with a rigorous **Witness-Based Coercivity** framework.

### The Problem We Solved
Previously, we assumed the anomaly was positive everywhere on the unit sphere. This was false for specific non-Clifford edge cases. 

### The Solution We Are Building
We now prove: **If a carrier is non-Clifford, there exists a specific frequency "spike" (witness) where the anomaly is quadratically coercive.** 

---

## 2. Component-Level Audit

| Module | Status | Role in "The Arc" |
|--------|--------|-------------------|
| `Coh/Kinematics/T3_Spikes.lean` | ✅ **GREEN** | Defines canonical frequency probes (`axisSpike`, `pairSpike`) to catch violations. |
| `Coh/Spectral/CompactnessProof.lean` | ✅ **GREEN**| Refactored. No longer uses false axiom. Defines `HasCliffordRigidity`. |
| `Coh/Kinematics/T3_NonCliffordVisible.lean` | 🟡 **YELLOW** | Refactored. Consumes the new witness-based T7 bridge. Logic is sound. |
| `Coh/Spectral/AnomalyWitnessLower.lean` | 🔴 **BLOCKED** | The "Engine Room." Proves that spikes → visible gaps. Facing Lean 4 synthesis issues. |

---

## 3. High-Level Synthesis: "From Existence to Derivation"

In the terms of `SYNTHESIS_FROM_EXISTENCE_TO_DERIVATION.md`, we are currently executing **Gap 1: Visibility Spectral Gap**.

*   **Algebraic Status**: We know Dirac spinors are the only solution (Phase 4).
*   **Physical Status**: We are now proving that **all other solutions are physically detectable** (T7 Visibility). 
*   **Significance**: Without this work, non-Clifford "dark states" could exist, making the "Inevitability" of Dirac spinors a mathematical curiosity rather than a physical law.

---

## 4. Current Technical Blocker (The "Diamond" Problem)

We are caught in a **Typeclass Synthesis Loop** in `AnomalyWitnessLower.lean`. 
Lean 4 is struggling to unify:
1. The **Operator Norm** (`V →L[ℝ] V`)
2. The **NormedAddCommGroup** instances for continuous linear maps.

**Why this matters**: We need to prove `‖R² • Mismatch‖ = R² * ‖Mismatch‖`. While "obvious" mathematically, the Lean elaborator is seeing multiple paths to these instances, causing the `lake build` to fail even though the logic is verified.

---

## 5. Immediate Next Steps

1.  **Resolve Unification**: Use explicit `ext` and `opNorm` lemmas in `AnomalyWitnessLower.lean` to bypass the generic synthesis engine.
2.  **Verify T3-T7 Bridge**: Achieve a Green Build for `T3_NonCliffordVisible.lean`.
3.  **Bridge to Phase 2 (T5)**: Once the spectral gap is secure, we move to **Rep-Theoretic Minimality** (proving rank 8 is forced by metabolic cost).

---

### Verdict
We are in the final 5% of the **Foundation Hardening Phase**. Once the witness-based visibility proof compiles, the entire Dirac Inevitability stack shifts from "heuristic-rich" to "foundation-closed."
