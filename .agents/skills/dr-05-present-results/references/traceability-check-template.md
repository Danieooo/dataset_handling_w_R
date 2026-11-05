# Results Traceability Check Template

Write `results_traceability_check.yaml` before writing final results.

```yaml
dr_step: 5
plan_version: 1

inputs:
  analysis_plan: "analysis_plan.yaml"
  inferential_analysis_plan: "inferential_analysis_plan.yaml"
  confounding_adjustment_plan: "confounding_adjustment_plan.yaml"
  rstudio_output_source: "pasted_output / file / missing"

traceability_check:
  research_question_from_step1: ""
  crude_model_from_step3:
    formula: ""
    model_family: ""
    effect_measure: ""
  adjusted_model_from_step4:
    formula: ""
    model_family: ""
    effect_measure: ""
    covariates: []
  rstudio_output_available: false
  all_required_numbers_found: false
  mismatches: []
  status: "ready / needs_clarification / placeholder_only"

numbers_extracted:
  crude:
    estimate: null
    ci_lower: null
    ci_upper: null
    p_value: null
  adjusted:
    estimate: null
    ci_lower: null
    ci_upper: null
    p_value: null

reporting_decisions:
  table_type: "crude_and_adjusted"
  decimal_places:
    estimate: 2
    ci: 2
    p_value: 3
  causal_language_allowed: false
```

## Status Values

Use:

- `ready`: plans and RStudio output align, and required numbers are available.
- `needs_clarification`: mismatch or missing values prevent final writing.
- `placeholder_only`: no numeric output is available, so only templates can be written.

## Mismatch Examples

Record mismatches clearly:

- `Outcome in RStudio output differs from analysis_plan.yaml.`
- `Adjusted covariates in R output differ from Step 4 plan.`
- `Effect measure is OR in plan but HR in output.`
- `p-value missing for adjusted model.`
