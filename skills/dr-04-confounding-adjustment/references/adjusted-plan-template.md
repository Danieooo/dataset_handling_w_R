# Confounding Adjustment Plan Template

Write `plans/confounding_adjustment_plan.yaml` using this structure.

```yaml
dr_step: D4
plan_version: 2

inputs:
  analysis_plan: "plans/analysis_plan.yaml"
  inferential_analysis_plan: "plans/inferential_analysis_plan.yaml"
  synthetic_dataset: "data_synthetic/synthetic_dataset.csv"

link_to_d3:
  same_outcome_as_d3: true
  same_predictor_as_d3: true
  same_model_family_as_d3: true
  same_effect_measure_as_d3: true
  crude_model:
    formula: ""
    model_family: ""
    effect_measure: ""

variables:
  outcome:
    name: null
    type: "unknown"
  main_predictor:
    name: null
    type: "unknown"
  covariates:
    included: []
    excluded: []
    source: "analysis_plan / user_confirmation / assumed"
    rationale: ""

adjusted_model:
  formula: ""
  model_family: ""
  effect_measure: ""
  reason: ""

comparison:
  compare_crude_vs_adjusted: true
  main_question: "Does the estimate for the main predictor materially change after adjustment?"
  compare:
    - "estimate magnitude"
    - "estimate direction"
    - "95% CI"
    - "p-value as secondary information"

script:
  file: "scripts/infer.R"
  section: "adjusted"
  verified_on_synthetic: false

user_confirmation:
  status: "confirmed / assumed / needs_review"
  notes: ""

readiness:
  status: "ready / needs_review / not_ready"
  blocking_issues: []
  review_issues: []
  assumptions: []

reporting:
  table_title: "Crude and adjusted association between [predictor] and [outcome]"
  footnote: "Adjusted for [covariates]."
  causal_language_allowed: false

next_step:
  skill: "dr-05-present-results"
```

## Confirmation Status

Use:

- `confirmed`: user explicitly approved the covariate list
- `assumed`: user asked to proceed or did not know what to choose
- `needs_review`: covariate list is weak, unclear, or likely incomplete
