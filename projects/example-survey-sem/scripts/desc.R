# DR Stage D2: Descriptive analysis  (example-survey-sem, SEM track)
# Base R only. Run from the project folder.

# === USER SETTINGS ==========================================================
input_csv  <- "data_synthetic/synthetic_dataset.csv"
output_dir <- "outputs_synthetic"
# To run on REAL data in RStudio, change the two lines above to:
# input_csv  <- file.choose()   # cua so chon file se hien ra: chon file du lieu that cua ban
# output_dir <- "results_real"
# ============================================================================

dat <- read.csv(input_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")

group_var        <- "work_mode"
continuous_vars  <- c("age", "income", "work_hours", "tenure_years")
categorical_vars <- c("gender", "education", "turnover_intent")

all_vars <- c(group_var, continuous_vars, categorical_vars)
if (length(setdiff(all_vars, names(dat))) > 0)
  stop("Missing columns: ", paste(setdiff(all_vars, names(dat)), collapse = ", "))

groups <- sort(unique(dat[[group_var]][!is.na(dat[[group_var]])]))
summ_cont <- function(x) sprintf("%.1f (%.1f)", mean(x, na.rm = TRUE), sd(x, na.rm = TRUE))
summ_cat_level <- function(x, lvl) { x <- x[!is.na(x)]; sprintf("%d (%.1f%%)", sum(x == lvl), 100 * mean(x == lvl)) }

rows <- list()
add_row <- function(char, level, overall, per_group) {
  rows[[length(rows) + 1]] <<- data.frame(
    characteristic = char, level = level, Overall = overall,
    setNames(as.list(per_group), paste0(group_var, "=", groups)),
    check.names = FALSE, stringsAsFactors = FALSE)
}
for (v in continuous_vars)
  add_row(v, "mean (SD)", summ_cont(dat[[v]]),
          vapply(groups, function(g) summ_cont(dat[[v]][dat[[group_var]] == g]), character(1)))
for (v in categorical_vars)
  for (lvl in sort(unique(dat[[v]][!is.na(dat[[v]])])))
    add_row(v, as.character(lvl), summ_cat_level(dat[[v]], lvl),
            vapply(groups, function(g) summ_cat_level(dat[[v]][dat[[group_var]] == g], lvl), character(1)))

table1 <- do.call(rbind, rows)
dir.create(output_dir, showWarnings = FALSE)
write.csv(table1, file.path(output_dir, "table1.csv"), row.names = FALSE, fileEncoding = "UTF-8")
cat("N =", nrow(dat), "| Table 1 written to", file.path(output_dir, "table1.csv"), "\n\n")
print(table1, row.names = FALSE)
