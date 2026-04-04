import Lean

namespace Coh.Tactics

/-!
# Custom Tactics for Coh

Placeholder for domain-specific automation (e.g., Clifford algebra simplification, 
index matching, metabolic cost bounds).
-/

syntax "coh_simps" : tactic

macro_rules
  | `(tactic| coh_simps) => `(tactic| simp [anticommutator, symbol, anomaly, metricOperator])

end Coh.Tactics
