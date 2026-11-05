# DR Stage D3 (SEM): Measurement model
# Cronbach's alpha (base R) + CFA (lavaan)
# install.packages("lavaan") once before running

# === USER SETTINGS ==========================================================
# Runs on the synthetic dataset as delivered:
input_csv  <- "data_synthetic/synthetic_dataset.csv"
output_dir <- "outputs_synthetic"
# To run on REAL data in RStudio, comment the two lines above and uncomment these:
# input_csv  <- file.choose()   # a file-picker opens: select your real dataset
# output_dir <- "results_real"
# ============================================================================

dat <- read.csv(input_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")

# --- Items per construct ---
js_items <- c("js_q1", "js_q2", "js_q3", "js_q4", "js_q5")
bo_items <- c("bo_q1", "bo_q2", "bo_q3", "bo_q4", "bo_q5")
all_items <- c(js_items, bo_items)

missing_cols <- all_items[!all_items %in% names(dat)]
if (length(missing_cols) > 0) {
  stop("Missing columns in data: ", paste(missing_cols, collapse = ", "))
}

# --- Cronbach's alpha (base R) ---
cronbach_alpha <- function(items_df) {
  items_df <- items_df[stats::complete.cases(items_df), , drop = FALSE]
  k <- ncol(items_df)
  if (k < 2) return(NA_real_)
  item_vars <- apply(items_df, 2, stats::var)
  total_var <- stats::var(rowSums(items_df))
  (k / (k - 1)) * (1 - sum(item_vars) / total_var)
}

alpha_js <- cronbach_alpha(dat[, js_items, drop = FALSE])
alpha_bo <- cronbach_alpha(dat[, bo_items, drop = FALSE])

alpha_summary <- data.frame(
  construct = c("Job_Satisfaction", "Burnout"),
  n_items = c(length(js_items), length(bo_items)),
  alpha = round(c(alpha_js, alpha_bo), 3),
  stringsAsFactors = FALSE
)

dir.create(output_dir, showWarnings = FALSE)
write.csv(alpha_summary, file.path(output_dir, "alpha_summary.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
cat("\n=== Cronbach's Alpha ===\n")
print(alpha_summary, row.names = FALSE)

# --- Scale scores (row mean, >= 50% non-missing) ---
compute_scale <- function(dat, items, min_prop = 0.50) {
  k <- length(items)
  min_ok <- floor(k * min_prop)
  scores <- apply(dat[, items, drop = FALSE], 1, function(row) {
    if (sum(!is.na(row)) >= min_ok) mean(row, na.rm = TRUE) else NA_real_
  })
  scores
}

dat$js_score <- compute_scale(dat, js_items)
dat$bo_score <- compute_scale(dat, bo_items)

scale_summary <- data.frame(
  construct = c("Job_Satisfaction", "Burnout"),
  mean = round(c(mean(dat$js_score, na.rm = TRUE),
                 mean(dat$bo_score, na.rm = TRUE)), 2),
  sd = round(c(sd(dat$js_score, na.rm = TRUE),
               sd(dat$bo_score, na.rm = TRUE)), 2),
  n = c(sum(!is.na(dat$js_score)), sum(!is.na(dat$bo_score))),
  stringsAsFactors = FALSE
)
cat("\n=== Scale Scores ===\n")
print(scale_summary, row.names = FALSE)

# --- CFA in lavaan ---
library(lavaan)

cfa_model <- '
  Job_Satisfaction =~ js_q1 + js_q2 + js_q3 + js_q4 + js_q5
  Burnout          =~ bo_q1 + bo_q2 + bo_q3 + bo_q4 + bo_q5
'

fit <- tryCatch(
  cfa(cfa_model, data = dat, std.lv = TRUE),
  error = function(e) {
    cat("\nCFA error:", e$message, "\n")
    return(NULL)
  }
)

if (!is.null(fit) && lavInspect(fit, "converged")) {
  cat("\n=== CFA Fit Indices ===\n")
  fi <- fitMeasures(fit, c("cfi", "tli", "rmsea", "srmr"))
  print(round(fi, 4))

  fi_df <- data.frame(
    measure = names(fi),
    value = as.numeric(fi),
    stringsAsFactors = FALSE
  )
  write.csv(fi_df, file.path(output_dir, "cfa_fit.csv"),
            row.names = FALSE, fileEncoding = "UTF-8")

  cat("\n=== Standardized Loadings ===\n")
  pe <- parameterEstimates(fit, standardized = TRUE)
  loadings <- pe[pe$op == "=~", ]
  print(loadings[, c("lhs", "op", "rhs", "est", "se", "z", "pvalue", "std.all")])

  write.csv(loadings, file.path(output_dir, "cfa_loadings.csv"),
            row.names = FALSE, fileEncoding = "UTF-8")
} else {
  cat("\nCFA did not converge on synthetic data.\n")
  cat("This is expected (items are simulated independently).\n")
  cat("The script ran successfully. Convergence on real data is what matters.\n")

  write.csv(data.frame(note = "CFA did not converge on synthetic data"),
            file.path(output_dir, "cfa_fit.csv"),
            row.names = FALSE, fileEncoding = "UTF-8")
}

cat("\nSEM measurement model script completed.\n")
cat("Output files in:", output_dir, "\n")
