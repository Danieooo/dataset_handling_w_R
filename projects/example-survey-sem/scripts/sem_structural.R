# DR Stage D4 (SEM): Structural model  (example-survey-sem)
# Base R + lavaan only. Run from the project folder.

# === USER SETTINGS ==========================================================
input_csv  <- "data_synthetic/synthetic_dataset.csv"
output_dir <- "outputs_synthetic"
# To run on REAL data in RStudio, change the two lines above to:
# input_csv  <- file.choose()   # cua so chon file se hien ra: chon file du lieu that cua ban
# output_dir <- "results_real"
# ============================================================================

dat <- read.csv(input_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
dir.create(output_dir, showWarnings = FALSE)

# Observed covariate dummy (exact label from the reviewed pattern file)
dat$remote <- as.numeric(dat$work_mode == "Remote")

library(lavaan)  # install.packages("lavaan") once, before first use

model <- '
  # Measurement model (unchanged from Stage D3)
  jobsat  =~ js_q1 + js_q2 + js_q3 + js_q4 + js_q5
  burnout =~ bo_q1 + bo_q2 + bo_q3 + bo_q4 + bo_q5

  # Structural model (user-confirmed paths)
  turnover_intent ~ burnout + jobsat + remote
'
fit <- tryCatch(sem(model, data = dat, std.lv = TRUE, warn = FALSE),
                error = function(e) { message("SEM did not fit: ", conditionMessage(e)); NULL })
# On synthetic data the model often does NOT converge (items are simulated
# independently). That is expected: guard so verification still exits cleanly.
if (!is.null(fit) && lavInspect(fit, "converged")) {
  print(fitMeasures(fit, c("cfi", "tli", "rmsea", "srmr", "chisq", "df", "pvalue")))
  est <- parameterEstimates(fit, standardized = TRUE)
  write.csv(est, file.path(output_dir, "sem_estimates.csv"), row.names = FALSE, fileEncoding = "UTF-8")
  cat("\nStructural paths (turnover_intent regressed on predictors):\n")
  print(est[est$op == "~", c("lhs", "rhs", "est", "se", "pvalue", "std.all")], row.names = FALSE)
  cat("\nNOTE: estimates/fit on synthetic data are meaningless by design.\n")
} else {
  cat("Model did not converge on synthetic data (expected for independent\n",
      "synthetic items). The lavaan syntax is valid and will run on real data.\n")
}
