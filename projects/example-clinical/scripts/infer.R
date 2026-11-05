# DR Stage D3/D4: Inferential analysis (crude + adjusted)  (example-clinical)
# Base R only. Run from the project folder.

# === USER SETTINGS ==========================================================
input_csv  <- "data_synthetic/synthetic_dataset.csv"
output_dir <- "outputs_synthetic"
# To run on REAL data in RStudio, change the two lines above to:
# input_csv  <- file.choose()   # cua so chon file se hien ra: chon file du lieu that cua ban
# output_dir <- "results_real"
# ============================================================================

dat <- read.csv(input_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
dir.create(output_dir, showWarnings = FALSE)

outcome_var   <- "mortality_30day"
predictor_var <- "treatment"
covariates    <- c("age", "sex", "bmi", "diabetes", "hypertension", "smoking", "egfr", "hba1c", "crp")

# Exact reference level (labels from the reviewed pattern file)
dat$treatment <- factor(dat$treatment, levels = c("Phác đồ A", "Phác đồ B"))
dat$sex       <- factor(dat$sex, levels = c("Nam", "Nữ"))

stopifnot(all(c(outcome_var, predictor_var, covariates) %in% names(dat)))
if (length(unique(dat[[outcome_var]][!is.na(dat[[outcome_var]])])) < 2)
  stop("Outcome has fewer than two classes.")

or_table <- function(model, term) {
  est <- coef(model); ci <- confint.default(model)
  p   <- summary(model)$coefficients[, 4]
  keep <- grepl(term, names(est))
  data.frame(term = names(est)[keep],
             OR = round(exp(est[keep]), 2),
             CI_low = round(exp(ci[keep, 1]), 2),
             CI_high = round(exp(ci[keep, 2]), 2),
             p_value = round(p[keep], 3), row.names = NULL)
}

# === SECTION 1: CRUDE MODEL (Stage D3) ======================================
crude <- glm(reformulate(predictor_var, outcome_var), data = dat, family = binomial())
crude_res <- or_table(crude, predictor_var)
crude_res$model <- "crude"; crude_res$covariates <- "None"
write.csv(crude_res, file.path(output_dir, "infer_crude.csv"), row.names = FALSE, fileEncoding = "UTF-8")
cat("Crude model, n =", nobs(crude), "\n"); print(crude_res, row.names = FALSE); cat("\n")

# === SECTION 2: ADJUSTED MODEL (Stage D4) ===================================
adj <- glm(reformulate(c(predictor_var, covariates), outcome_var), data = dat, family = binomial())
adj_res <- or_table(adj, predictor_var)
adj_res$model <- "adjusted"; adj_res$covariates <- paste(covariates, collapse = ", ")

comparison <- rbind(crude_res, adj_res)
write.csv(comparison, file.path(output_dir, "infer_crude_vs_adjusted.csv"), row.names = FALSE, fileEncoding = "UTF-8")
cat("Adjusted model, n =", nobs(adj), "\n"); print(comparison, row.names = FALSE)
