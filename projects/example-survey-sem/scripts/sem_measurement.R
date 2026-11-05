# DR Stage D3 (SEM): Measurement model  (example-survey-sem)
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

constructs <- list(
  jobsat  = c("js_q1", "js_q2", "js_q3", "js_q4", "js_q5"),
  burnout = c("bo_q1", "bo_q2", "bo_q3", "bo_q4", "bo_q5")
)
stopifnot(all(unlist(constructs) %in% names(dat)))

# --- Cronbach's alpha in base R (no psych) ---
cronbach_alpha <- function(items_df) {
  items_df <- items_df[stats::complete.cases(items_df), , drop = FALSE]
  k <- ncol(items_df)
  if (k < 2) return(NA_real_)
  item_vars <- apply(items_df, 2, stats::var)
  total_var <- stats::var(rowSums(items_df))
  (k / (k - 1)) * (1 - sum(item_vars) / total_var)
}
alpha_summary <- data.frame(
  construct = names(constructs),
  n_items   = vapply(constructs, length, integer(1)),
  alpha     = round(vapply(constructs, function(it) cronbach_alpha(dat[, it]), numeric(1)), 3),
  row.names = NULL)
write.csv(alpha_summary, file.path(output_dir, "alpha_summary.csv"), row.names = FALSE, fileEncoding = "UTF-8")
cat("Cronbach's alpha (base R):\n"); print(alpha_summary, row.names = FALSE); cat("\n")

# --- Scale scores (row mean, >=50% items non-missing) ---
for (cn in names(constructs)) {
  it <- constructs[[cn]]
  n_ok <- rowSums(!is.na(dat[, it]))
  dat[[paste0(cn, "_score")]] <- ifelse(n_ok >= ceiling(length(it) * 0.5),
                                        rowMeans(dat[, it], na.rm = TRUE), NA_real_)
}

# --- CFA in lavaan ---
library(lavaan)  # install.packages("lavaan") once, before first use
model <- '
  jobsat  =~ js_q1 + js_q2 + js_q3 + js_q4 + js_q5
  burnout =~ bo_q1 + bo_q2 + bo_q3 + bo_q4 + bo_q5
'
fit <- tryCatch(cfa(model, data = dat, std.lv = TRUE),
                error = function(e) { message("CFA did not fit: ", conditionMessage(e)); NULL })
if (!is.null(fit)) {
  print(fitMeasures(fit, c("cfi", "tli", "rmsea", "srmr")))
  write.csv(parameterEstimates(fit, standardized = TRUE),
            file.path(output_dir, "cfa_estimates.csv"), row.names = FALSE, fileEncoding = "UTF-8")
  cat("\nCFA summary written. NOTE: fit on synthetic data is meaningless by design.\n")
}
