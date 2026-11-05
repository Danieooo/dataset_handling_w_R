---
name: dr-05-present-results
description: "Stage E of the DR workflow: turn prior DR plans and real RStudio output into traceable manuscript-ready result tables and Results text in results_real/. Use when the user has run the project's scripts on the real dataset locally and pastes the output, for either the medical track (crude/adjusted models) or the SEM track (measurement + structural models)."
---

# DR Stage E: Present Results

Use this skill after Stage D is complete and the user has run the project's scripts on the real dataset in RStudio.

The goal is to present results clearly without changing the analysis. Every number and claim must trace back to prior plans or user-provided RStudio output.

## Coordination Contract

When called by `dr-workflow-orchestrator`, follow the project's plan files and `dr_workflow_state.yaml`.

After producing outputs:

- Report the exact files created.
- Do not mark the workflow complete yourself unless `results_real/results_traceability_check.yaml` is ready.
- Say that `dr-output-qa-gate` should check Stage E before the workflow is considered complete.

## Required Inputs

Medical track:

- `plans/analysis_plan.yaml`, `plans/inferential_analysis_plan.yaml`, `plans/confounding_adjustment_plan.yaml`
- RStudio output pasted by the user (or CSVs the user copied into `results_real/` from their real run: `table1.csv`, `infer_crude.csv`, `infer_crude_vs_adjusted.csv`)

SEM track:

- `plans/analysis_plan.yaml`, `plans/sem_measurement_plan.yaml`, `plans/sem_structural_plan.yaml`
- User-provided real output: alpha summary, CFA fit, `sem_estimates.csv`, `sem_fit.csv`, or pasted console output

Real data lives outside the repo; never read it, never ask for its path or filename. Never invent results from synthetic data or from `outputs_synthetic/`.

If pasted output contains the real dataset's file path or filename, do not repeat it in any artifact, and remind the user they can trim such lines before pasting.

**Text output only.** What the user pastes at this stage must be aggregate text: tables, estimates, CIs, p-values, fit indices. Never accept, request, or open a figure generated from real data — a boxplot or scatter is row-level data rendered as pixels, and one outlier dot is one identifiable participant. If the user offers a figure from their real run, decline, explain in one sentence why, and offer the alternative: describe the pattern in words, or paste the correlation matrix as numbers. Real-run figures produced by `scripts/plots.R` live outside the repo by design; leave them there.

## Workflow

1. Read the project's plan files for the active track.
2. Extract the research question, variables/constructs, model families, and effect measures.
3. Parse the user-provided RStudio output.
4. Create `results_real/results_traceability_check.yaml`.
5. If key numbers are missing or outputs conflict with the plans, stop and ask.
6. Format the manuscript result table(s).
7. Write the Results paragraph.
8. Write `results_real/present_results.md` with table, paragraph, footnote, and limitations.

## Required Outputs

Always produce, inside `results_real/`:

- `results_traceability_check.yaml`
- `manuscript_results_table.md`
- `results_paragraph.md`
- `present_results.md`

Use `references/traceability-check-template.md`.
Use `references/results-reporting-rules.md`.
Use `references/manuscript-table-template.md`.
Use `references/results-paragraph-template.md`.

For the SEM track, the manuscript table reports fit indices and structural path estimates (unstandardized + standardized, 95% CI, p-value); adapt the templates accordingly and include a brief measurement sentence (alpha / CFA fit) before the structural results.

## Traceability Rule

Every reported number must come from user-provided real-run output. Every interpretation must match the plans from Stages D1-D4.

If the user has not provided real output, create placeholders only and label them as placeholders. Do not fill numeric values from the synthetic run.

## Stop Conditions

Stop and ask the user for clarification when:

- Real output is absent and the user expects final numeric results.
- Output uses a different outcome, predictor, construct, or effect measure than the plans.
- Adjusted covariates or structural paths in the output conflict with the plans.
- A required estimate, CI, p-value, or fit index is missing.

## Formatting Defaults

- Estimates and CIs: 2 decimal places; p-values: 3 decimals or `<0.001`; fit indices: 2-3 decimals.
- Effect size first, confidence interval second, p-value last.

## Boundaries

Do not run new analysis.
Do not change models, covariates, items, or paths.
Do not write a full Discussion section.
Do not claim the result is guaranteed publication-ready.
Do not make causal claims unless the study design and prior plans explicitly support causal language.

## Teaching Line

Publication-ready means the reader can understand, check, and trust the result at a reasonable level.
