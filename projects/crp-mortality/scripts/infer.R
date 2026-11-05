# DR Stage D3/D4: Inferential analysis (crude + adjusted)
# Base R only. Run from the project folder.

# === USER SETTINGS ==========================================================
# Runs on the synthetic dataset as delivered:
input_csv  <- "data_synthetic/synthetic_dataset.csv"
output_dir <- "outputs_synthetic"
# To run on REAL data in RStudio, comment the two lines above and uncomment these:
# input_csv  <- file.choose()   # a file-picker opens: select your real dataset
# output_dir <- "results_real"
# ============================================================================

dat <- read.csv(input_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
dir.create(output_dir, showWarnings = FALSE)

# --- Variable definitions ---
outcome_var   <- "mortality_30day"
predictor_var <- "crp"

# --- Pre-fit checks ---
stopifnot(outcome_var %in% names(dat))
stopifnot(predictor_var %in% names(dat))

# Check outcome variation
outcome_tab <- table(dat[[outcome_var]], useNA = "ifany")
cat("Outcome distribution:\n")
print(outcome_tab)
if (length(outcome_tab) < 2) {
  stop("Outcome has fewer than 2 observed classes.")
}
if (any(is.na(dat[[outcome_var]]))) {
  stop("Missing values in outcome. Please handle before fitting.")
}

# Check predictor variation
pred_non_na <- dat[[predictor_var]][!is.na(dat[[predictor_var]])]
if (length(unique(pred_non_na)) < 2) {
  stop("Predictor has < 2 unique values after removing NAs.")
}

complete_cases <- sum(stats::complete.cases(dat[, c(outcome_var, predictor_var)]))
cat(sprintf("Complete cases for crude model: %d / %d\n", complete_cases, nrow(dat)))

# === SECTION 1: CRUDE MODEL (Stage D3) ======================================
crude_model <- glm(reformulate(predictor_var, outcome_var),
                   data = dat, family = binomial())

est  <- coef(summary(crude_model))
ci   <- confint.default(crude_model)

# Exponentiate for OR (except intercept)
or <- exp(est[, "Estimate"])
or_ci_low <- exp(ci[, 1])
or_ci_high <- exp(ci[, 2])

crude_results <- data.frame(
  term = rownames(est),
  estimate = round(est[, "Estimate"], 4),
  or = round(or, 4),
  ci_low = round(or_ci_low, 4),
  ci_high = round(or_ci_high, 4),
  p_value = round(est[, "Pr(>|z|)"], 4),
  row.names = NULL
)

cat("\n=== CRUDE MODEL ===\n")
cat("Model: mortality_30day ~ crp (logistic regression)\n")
cat(sprintf("N used: %d\n", nobs(crude_model)))
print(crude_results)

write.csv(crude_results, file.path(output_dir, "infer_crude.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
cat("\nCrude results written to", file.path(output_dir, "infer_crude.csv"), "\n")

# === SECTION 2: ADJUSTED MODEL (Stage D4) ====================================
covariate_vars <- c("age", "sex", "bmi", "treatment", "sbp",
                    "diabetes", "hypertension", "smoking",
                    "egfr", "hba1c", "complication")

# Factor handling with exact level labels from pattern file
dat$sex <- factor(dat$sex, levels = c("Nữ", "Nam"))
dat$treatment <- factor(dat$treatment, levels = c("Phác đồ A", "Phác đồ B"))

adjusted_formula <- reformulate(c(predictor_var, covariate_vars), outcome_var)
cat("\nAdjusted formula:", deparse(adjusted_formula), "\n")

adjusted_model <- glm(adjusted_formula, data = dat, family = binomial())

adj_est  <- coef(summary(adjusted_model))
adj_ci   <- confint.default(adjusted_model)

adj_or <- exp(adj_est[, "Estimate"])
adj_or_ci_low <- exp(adj_ci[, 1])
adj_or_ci_high <- exp(adj_ci[, 2])

adjusted_results <- data.frame(
  term = rownames(adj_est),
  estimate = round(adj_est[, "Estimate"], 4),
  or = round(adj_or, 4),
  ci_low = round(adj_or_ci_low, 4),
  ci_high = round(adj_or_ci_high, 4),
  p_value = round(adj_est[, "Pr(>|z|)"], 4),
  row.names = NULL
)

cat("\n=== ADJUSTED MODEL ===\n")
cat(sprintf("N used: %d\n", nobs(adjusted_model)))
print(adjusted_results)

write.csv(adjusted_results, file.path(output_dir, "infer_adjusted.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
cat("\nAdjusted results written to", file.path(output_dir, "infer_adjusted.csv"), "\n")

# --- Crude vs Adjusted comparison table (main predictor only) ---
cmp <- data.frame(
  model = c("Crude", "Adjusted"),
  or = c(or[2], adj_or[2]),
  ci_low = c(or_ci_low[2], adj_or_ci_low[2]),
  ci_high = c(or_ci_high[2], adj_or_ci_high[2]),
  p_value = c(est[, "Pr(>|z|)"][2], adj_est[, "Pr(>|z|)"][2]),
  covariates = c("None", paste(covariate_vars, collapse = ", ")),
  stringsAsFactors = FALSE
)

cat("\n=== CRUDE VS ADJUSTED (crp) ===\n")
print(cmp)

write.csv(cmp, file.path(output_dir, "infer_crude_vs_adjusted.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
cat("Crude vs adjusted comparison written to",
    file.path(output_dir, "infer_crude_vs_adjusted.csv"), "\n")
