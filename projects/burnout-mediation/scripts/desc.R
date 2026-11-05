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

# --- Variables ---
group_var       <- "turnover_intent"
continuous_vars <- c("age", "tenure_years", "job_satisfaction", "burnout_score")
categorical_vars <- c("gender", "education")
ordinal_vars    <- c("wlb", "js_q1", "js_q2", "js_q3", "js_q4", "js_q5",
                     "bo_q1", "bo_q2", "bo_q3", "bo_q4", "bo_q5")

all_vars <- c(continuous_vars, categorical_vars, ordinal_vars, group_var)
missing_cols <- all_vars[!all_vars %in% names(dat)]
if (length(missing_cols) > 0) {
  stop("Missing columns in data: ", paste(missing_cols, collapse = ", "))
}

# --- Helper: summarize continuous ---
summ_cont <- function(x) {
  m <- mean(x, na.rm = TRUE)
  s <- sd(x, na.rm = TRUE)
  sprintf("%.1f (%.1f)", m, s)
}

# --- Helper: summarize ordinal as median (IQR) ---
summ_ord <- function(x) {
  md <- median(x, na.rm = TRUE)
  q1 <- quantile(x, 0.25, na.rm = TRUE)
  q3 <- quantile(x, 0.75, na.rm = TRUE)
  sprintf("%.0f (%.0f-%.0f)", md, q1, q3)
}

# --- Helper: summarize categorical ---
summ_cat <- function(x) {
  tab <- table(x, useNA = "no")
  data.frame(level = names(tab),
             value = sprintf("%d (%.1f%%)", as.integer(tab),
                             100 * as.integer(tab) / sum(tab)),
             stringsAsFactors = FALSE)
}

# --- Helper: get group N label ---
group_N <- function(d, gv) {
  tab <- table(d[[gv]], useNA = "no")
  paste0(names(tab), " (N=", as.integer(tab), ")")
}

# --- Build Table 1 ---
groups <- sort(unique(dat[[group_var]]))
overall_N <- nrow(dat)
group_labels <- group_N(dat, group_var)

table1 <- data.frame(characteristic = character(),
                     level = character(),
                     Overall = character(),
                     stringsAsFactors = FALSE)
for (g in groups) {
  table1[[as.character(g)]] <- character()
}

add_continuous <- function(v, label) {
  overall <- summ_cont(dat[[v]])
  by_group <- sapply(groups, function(g) summ_cont(dat[[v]][dat[[group_var]] == g]))
  row <- data.frame(characteristic = label, level = "-",
                    Overall = overall, stringsAsFactors = FALSE)
  for (i in seq_along(groups)) row[[as.character(groups[i])]] <- by_group[i]
  table1 <<- rbind(table1, row)
}

add_ordinal <- function(v, label) {
  overall <- summ_ord(dat[[v]])
  by_group <- sapply(groups, function(g) summ_ord(dat[[v]][dat[[group_var]] == g]))
  row <- data.frame(characteristic = label, level = "-",
                    Overall = overall, stringsAsFactors = FALSE)
  for (i in seq_along(groups)) row[[as.character(groups[i])]] <- by_group[i]
  table1 <<- rbind(table1, row)
}

add_categorical <- function(v, label) {
  overall_tab <- summ_cat(dat[[v]])
  if (nrow(overall_tab) == 0) return()
  first <- TRUE
  for (i in seq_len(nrow(overall_tab))) {
    lev <- overall_tab$level[i]
    overall_val <- overall_tab$value[i]
    by_group <- sapply(groups, function(g) {
      sub <- dat[[v]][dat[[group_var]] == g]
      sub_tab <- summ_cat(sub)
      match_idx <- which(sub_tab$level == lev)
      if (length(match_idx) > 0) sub_tab$value[match_idx[1]] else "0 (0.0%)"
    })
    row <- data.frame(
      characteristic = if (first) label else "",
      level = lev,
      Overall = overall_val,
      stringsAsFactors = FALSE
    )
    for (j in seq_along(groups)) row[[as.character(groups[j])]] <- by_group[j]
    table1 <<- rbind(table1, row)
    first <- FALSE
  }
}

add_continuous("age", "Age, years")
add_continuous("tenure_years", "Tenure, years")
add_continuous("job_satisfaction", "Job satisfaction score")
add_continuous("burnout_score", "Burnout score")
add_ordinal("wlb", "Work-life balance")
add_categorical("gender", "Gender")
add_categorical("education", "Education")

names(table1)[names(table1) == "Overall"] <- paste0("Overall (N=", overall_N, ")")
names(table1)[names(table1) %in% as.character(groups)] <- group_labels

# --- Add footnote ---
footnote <- paste(
  "Continuous variables are presented as mean (SD);",
  "ordinal/Likert variables as median (IQR);",
  "categorical variables as n (%)."
)

# --- Save ---
dir.create(output_dir, showWarnings = FALSE)
write.csv(table1, file.path(output_dir, "table1.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
cat("Table 1 written to", file.path(output_dir, "table1.csv"), "\n\n")
print(table1, row.names = FALSE)
cat("\n", footnote, "\n")

# --- Missing summary ---
miss_rows <- data.frame(variable = all_vars,
                        n_missing = sapply(dat[all_vars], function(x) sum(is.na(x))),
                        pct_missing = sapply(dat[all_vars], function(x) round(100 * mean(is.na(x)), 1)),
                        stringsAsFactors = FALSE)
write.csv(miss_rows, file.path(output_dir, "missing_summary.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
cat("\nMissing summary written to", file.path(output_dir, "missing_summary.csv"), "\n")
