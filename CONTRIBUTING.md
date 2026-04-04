# Contributing to coh-lean

Thank you for your interest in contributing to the `coh-lean` formalization!

## How to Contribute

1.  **Drafting Definitions**: Start by adding abstract definitions (e.g., using `axiom` or `True` placeholders) in the appropriate module under `Coh/`.
2.  **Formalizing Proofs**: Move from abstract placeholders to concrete Mathlib-based definitions.
3.  **Namespace Convention**: All files should reside under the `Coh` namespace.
4.  **Documentation**: Use docstrings (`/-- ... -/`) for all major definitions and theorems.

## Directory Structure

- `Coh/Prelude.lean`: Foundation types and global structures.
- `Coh/Kinematics/`: Spacetime and Clifford algebra formalizations.
- `Coh/Thermo/`: Thermodynamic constraints and tracking costs.
- `Coh/Geometry/`: Complexification and persistence logic.
- `Coh/Physics/`: High-level capstone theorems.

## Style Guide

- Follow the [Lean 4 Style Guide](https://leanprover-community.github.io/contribute/style.html).
- Use descriptive names for theorems and hypotheses.
