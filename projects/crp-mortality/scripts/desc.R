# DR Stage D2: Descriptive analysis / Table 1
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

# --- Variables from plans/analysis_plan.yaml ---
group_var       <- "mortality_30day"
continuous_vars <- c("age", "bmi", "sbp", "egfr", "hba1c", "crp")
categorical_vars <- c("sex", "treatment", "diabetes", "hypertension", "smoking", "complication")

stopifnot(all(c(continuous_vars, categorical_vars, group_var) %in% names(dat)))

# --- Helper: summarize one continuous variable ---
summ_cont <- function(x) {
  sprintf("%.1f (%.1f)", mean(x, na.rm = TRUE), sd(x, na.rm = TRUE))
}

# --- Build Table 1 ---
group_vals <- sort(unique(dat[[group_var]]))
group_labels <- paste0("Group_", group_vals)
# Maps label -> actual value for filtering
group_map <- setNames(as.list(group_vals), group_labels)

all_cols <- c("Overall", group_labels)

table1 <- data.frame(characteristic = character(),
                     level = character(),
                     stringsAsFactors = FALSE)
for (cname in all_cols) table1[[cname]] <- character()

# --- N per group ---
n_row <- data.frame(characteristic = "N", level = "-", stringsAsFactors = FALSE)
n_row[["Overall"]] <- nrow(dat)
for (glab in group_labels) {
  n_row[[glab]] <- sum(dat[[group_var]] == group_map[[glab]], na.rm = TRUE)
}
table1 <- rbind(table1, n_row)

# --- Continuous variables ---
for (var in continuous_vars) {
  row <- data.frame(characteristic = var, level = "-", stringsAsFactors = FALSE)
  row[["Overall"]] <- if (sum(!is.na(dat[[var]])) > 0) summ_cont(dat[[var]]) else "NA"
  for (glab in group_labels) {
    idx <- dat[[group_var]] == group_map[[glab]]
    x <- dat[[var]][idx & !is.na(idx)]
    row[[glab]] <- if (sum(!is.na(x)) > 0) summ_cont(x) else "NA"
  }
  table1 <- rbind(table1, row)
}

# --- Categorical variables ---
for (var in categorical_vars) {
  levels_tab <- table(dat[[var]], useNA = "no")
  for (lev in names(levels_tab)) {
    row <- data.frame(characteristic = var, level = lev, stringsAsFactors = FALSE)
    # Overall
    n_total <- sum(dat[[var]] == lev, na.rm = TRUE)
    total_n <- sum(!is.na(dat[[var]]))
    row[["Overall"]] <- sprintf("%d (%.1f%%)", n_total, 100 * n_total / max(total_n, 1))
    # Per group
    for (glab in group_labels) {
      idx <- dat[[group_var]] == group_map[[glab]]
      idx[is.na(idx)] <- FALSE
      grp_dat <- dat[[var]][idx]
      n_grp <- sum(grp_dat == lev, na.rm = TRUE)
      grp_total <- sum(!is.na(grp_dat))
      row[[glab]] <- sprintf("%d (%.1f%%)", n_grp, 100 * n_grp / max(grp_total, 1))
    }
    table1 <- rbind(table1, row)
  }
}

# --- Save outputs ---
dir.create(output_dir, showWarnings = FALSE)
write.csv(table1, file.path(output_dir, "table1.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
cat("Table 1 written to", file.path(output_dir, "table1.csv"), "\n")
print(table1, row.names = FALSE)
