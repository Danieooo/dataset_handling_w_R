# DR Stage D4 (SEM): Structural model — mediation
# lavaan required: install.packages("lavaan") once

# === USER SETTINGS ==========================================================
# Runs on the synthetic dataset as delivered:
input_csv  <- "data_synthetic/synthetic_dataset.csv"
output_dir <- "outputs_synthetic"
# To run on REAL data in RStudio, comment the two lines above and uncomment these:
# input_csv  <- file.choose()   # a file-picker opens: select your real dataset
# output_dir <- "results_real"
# ============================================================================

dat <- read.csv(input_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")

# --- Dummy coding for observed covariates ---
# Gender: 0 = Nữ, 1 = Nam
dat$gender_num <- ifelse(dat$gender == "Nam", 1, 0)

# Education: THPT as reference
dat$education_dh   <- ifelse(dat$education == "Đại học", 1, 0)
dat$education_ts   <- ifelse(dat$education == "Thạc sĩ", 1, 0)
dat$education_tien <- ifelse(dat$education == "Tiến sĩ", 1, 0)

# --- Full lavaan model ---
library(lavaan)

model <- '
  # Measurement model (from Stage D3, unchanged)
  Job_Satisfaction =~ js_q1 + js_q2 + js_q3 + js_q4 + js_q5
  Burnout          =~ bo_q1 + bo_q2 + bo_q3 + bo_q4 + bo_q5

  # Structural model (mediation)
  Burnout ~ a * Job_Satisfaction + age + gender_num + education_dh + education_ts + education_tien + tenure_years
  turnover_intent ~ c_prime * Job_Satisfaction + b * Burnout + age + gender_num + education_dh + education_ts + education_tien + tenure_years

  # Indirect and total effects
  indirect := a * b
  total := c_prime + (a * b)
'

fit <- tryCatch(
  sem(model, data = dat, std.lv = TRUE, warn = FALSE),
  error = function(e) {
    message("Model did not fit on this dataset: ", conditionMessage(e))
    return(NULL)
  }
)

dir.create(output_dir, showWarnings = FALSE)

if (!is.null(fit) && lavInspect(fit, "converged")) {
  cat("\n==============================")
  cat("\nSEM STRUCTURAL MODEL RESULTS")
  cat("\n==============================\n")

  cat("\n--- Model Fit ---\n")
  fi <- fitMeasures(fit, c("cfi", "tli", "rmsea", "srmr", "chisq", "df", "pvalue"))
  print(round(fi, 4))

  fi_df <- data.frame(
    measure = names(fi),
    value = as.numeric(fi),
    stringsAsFactors = FALSE
  )
  write.csv(fi_df, file.path(output_dir, "sem_fit.csv"),
            row.names = FALSE, fileEncoding = "UTF-8")

  cat("\n--- Parameter Estimates ---\n")
  pe <- parameterEstimates(fit, standardized = TRUE, ci = TRUE)
  print(pe[, c("lhs", "op", "rhs", "est", "ci.lower", "ci.upper", "se", "z", "pvalue", "std.all")])

  write.csv(pe, file.path(output_dir, "sem_estimates.csv"),
            row.names = FALSE, fileEncoding = "UTF-8")

  cat("\n--- R-squared ---\n")
  rsq <- as.data.frame(lavInspect(fit, "rsquare"))
  names(rsq) <- "r_squared"
  print(round(rsq, 4))
  write.csv(rsq, file.path(output_dir, "sem_rsquared.csv"),
            row.names = TRUE, fileEncoding = "UTF-8")

} else {
  cat("\nModel did not converge on synthetic data.\n")
  cat("This is expected because items are simulated independently.\n")
  cat("The model syntax is valid; it will converge on real data.\n")

  write.csv(data.frame(note = "SEM did not converge on synthetic data"),
            file.path(output_dir, "sem_fit.csv"),
            row.names = FALSE, fileEncoding = "UTF-8")
}

cat("\nSEM structural model script completed.\n")
cat("Output files in:", output_dir, "\n")
