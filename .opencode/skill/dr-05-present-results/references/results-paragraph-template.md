# Results Paragraph Template

Write `results_paragraph.md` using this structure.

## Full Version

```text
To assess the association between [main predictor] and [outcome], we fit a crude [model family] followed by an adjusted model including [covariates]. In the crude analysis, [main predictor] was associated with [outcome] with a [effect measure] of [estimate] (95% CI: [lower] to [upper], p = [p]). After adjustment for [covariates], the [effect measure] was [estimate] (95% CI: [lower] to [upper], p = [p]). These results suggest that [plain-language interpretation], while accounting for the selected covariates. Because this analysis is observational, the findings should be interpreted as adjusted associations rather than causal effects.
```

## Short Version

```text
In an adjusted [model family] evaluating [outcome], [main predictor] was associated with [outcome] with a [effect measure] of [estimate] (95% CI: [lower] to [upper], p = [p]), after adjustment for [covariates].
```

## Placeholder Version

Use this only when numeric RStudio output is unavailable:

```text
To assess the association between [main predictor] and [outcome], we fit a crude [model family] followed by an adjusted model including [covariates]. The final numeric estimates should be inserted from the RStudio output: [effect measure] [estimate] (95% CI: [lower] to [upper], p = [p]).
```

## Writing Rules

- Keep Results factual and concise.
- Avoid long explanation of why the model was chosen; that belongs in Methods.
- Do not repeat every covariate estimate unless the covariate itself is a result of interest.
- Do not overinterpret p-values.
- Do not write a full Discussion section.
