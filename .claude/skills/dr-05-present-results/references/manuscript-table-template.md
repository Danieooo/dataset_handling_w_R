# Manuscript Result Table Template

Use this structure for `manuscript_results_table.md`.

```markdown
Table 2. Crude and adjusted association between [main predictor] and [outcome]

| Model | Effect estimate | 95% CI | p-value | Adjustment |
|---|---:|---:|---:|---|
| Crude | [estimate] | [lower, upper] | [p] | None |
| Adjusted | [estimate] | [lower, upper] | [p] | [covariates] |

Abbreviations: CI, confidence interval; [OR/HR/RR], [full term].
Note: The adjusted model included [covariates]. Estimates are from [model family].
```

## Formatting

- Use a specific title, not just "Regression results".
- Use the effect measure named in the Step 3/4 plans.
- Keep covariate list in the footnote if the table would become too wide.
- Use consistent decimals.
- Do not include raw R column names if cleaner labels are available.

## If Only Adjusted Results Are Available

Use:

```markdown
Table 2. Adjusted association between [main predictor] and [outcome]

| Predictor | Adjusted [effect measure] | 95% CI | p-value |
|---|---:|---:|---:|
| [main predictor] | [estimate] | [lower, upper] | [p] |

Note: Model adjusted for [covariates].
```
