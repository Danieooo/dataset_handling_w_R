# desc.R Script Template

Generate `scripts/desc.R` as a plain base R script with this structure. The same script runs on synthetic data (agent verification) and on real data (user, in RStudio) by editing only the settings block.

```r
# DR Stage D2: Descriptive analysis / Table 1
# Base R only. Run from the project folder.

# === USER SETTINGS ==========================================================
# Agent verification (synthetic):
input_csv  <- "data_synthetic/synthetic_dataset.csv"
output_dir <- "outputs_synthetic"
# To run on REAL data in RStudio, change the two lines above to:
# input_csv  <- file.choose()   # a file-picker window opens: select your real dataset
# output_dir <- "results_real"
# ============================================================================

dat <- read.csv(input_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")

# --- Variables (from plans/analysis_plan.yaml) ---
group_var       <- "..."                      # or NA for ungrouped table
continuous_vars <- c("...")
categorical_vars <- c("...")

# --- Helper: summarize one continuous variable ---
summ_cont <- function(x) {
  sprintf("%.1f (%.1f)", mean(x, na.rm = TRUE), sd(x, na.rm = TRUE))
  # or median (IQR) for skewed variables:
  # sprintf("%.1f (%.1f-%.1f)", median(x, na.rm=TRUE),
  #         quantile(x, .25, na.rm=TRUE), quantile(x, .75, na.rm=TRUE))
}

# --- Helper: summarize one categorical variable (returns one row per level) ---
summ_cat <- function(x) {
  tab <- table(x, useNA = "no")
  data.frame(level = names(tab),
             value = sprintf("%d (%.1f%%)", as.integer(tab),
                             100 * as.integer(tab) / sum(tab)))
}

# --- Build Table 1 (overall + by group when group_var is set) ---
# Assemble a data.frame `table1` with columns:
#   characteristic | level | Overall | <Group A> | <Group B> | ...
# using summ_cont / summ_cat per variable, per group subset.

# --- Save outputs ---
dir.create(output_dir, showWarnings = FALSE)
write.csv(table1, file.path(output_dir, "table1.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
cat("Table 1 written to", file.path(output_dir, "table1.csv"), "\n")
print(table1)
```

## Requirements for the generated script

- Every variable name and level label must come from the pattern file / analysis plan, spelled exactly.
- Check that all selected columns exist in the loaded data; `stop()` with a clear message if not.
- Handle NA explicitly (`na.rm = TRUE`; report missing counts per variable in a `missing_summary.csv` when missingness is nontrivial).
- If p-values were requested, add a `p_value` column using the tests from the rules file.
- Optional figures: histograms/barplots via `png(file.path(output_dir, "fig_<var>.png")); ...; dev.off()`.
- Print a readable version of the table with `print()` so console output is useful in RStudio.
- No packages. No `install.packages()`. No `setwd()`.

## Table 1 Shape

```text
Table 1. Characteristics of the study sample by [group variable]

Characteristic   Level      Overall (N=...)   Group A (N=...)   Group B (N=...)
Age, years       -          mean (SD)         ...               ...
Sex              Nữ         n (%)             ...               ...
                 Nam        n (%)             ...               ...
...

Footnote: Continuous variables are summarized as mean (SD) or median (IQR)
as appropriate. Categorical variables are summarized as n (%).
```

N in headers is the N of the dataset the script was run on (synthetic N during verification; real N when the user runs it in RStudio).
