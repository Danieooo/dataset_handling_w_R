---
name: dr-00-privacy-gate
description: "Stages A-C of the DR workflow: set up local pattern extraction from the real dataset, walk the user through reviewing dataset_pattern.csv, and generate the local synthesis script that creates the synthetic dataset. Use when a DR project has no reviewed dataset_pattern.csv or no synthetic_dataset.csv yet, or when the user asks how to prepare data for AI-assisted analysis without uploading real data."
---

# DR Stage A-C: Privacy Gate

Use this skill at the start of every DR project. It produces the two local R scripts that let the user extract a structural pattern from the real dataset and generate a fully synthetic dataset — without the agent ever seeing real data.

**The real dataset lives OUTSIDE this repo**, wherever the user keeps it on their machine. You never see it, never ask where it is, and never write its path or filename into any file. Whenever a script needs the real data, the user selects it interactively in RStudio with `file.choose()` — the path exists only inside their RStudio session.

## Stage A: Pattern Extraction

1. Copy `r-scripts/pattern_extract.R` into the project's `scripts/` folder.
2. Give the user these exact commands to run in RStudio (working directory = project folder, set via Session > Set Working Directory > Choose Directory):

```r
source("scripts/pattern_extract.R")
original <- read.csv(file.choose())   # a file-picker window opens: select your real dataset
extract_pattern(original, output_csv = "pattern/dataset_pattern.csv")
```

3. Tell the user what the script does and does not export: variable names, types, categorical levels (rare levels masked as "Other"), missing percentage — and nothing else. No row counts, no statistics, no raw values, no file path.

## Review Gate (mandatory)

Before you read `pattern/dataset_pattern.csv`:

1. Ask the user to open the file and check every entry in the `levels` column.
2. Ask explicitly: "Have you reviewed dataset_pattern.csv and confirmed that no level label is sensitive or identifying?"
3. Only after an explicit yes, read the pattern file, print its content back in a compact table, and record `pattern_reviewed_by_user: true` in the state file.

If the user finds a sensitive label, tell them to edit or delete that label in the CSV (and later map it manually when running analysis code on real data), then review again.

## Stage B: Synthesis Script

After the review gate passes:

1. Copy `r-scripts/synthesize_data.R` into `scripts/`.
2. Give the user these commands:

```r
source("scripts/synthesize_data.R")
original <- read.csv(file.choose())   # select the real dataset again
synthesize_data(
  pattern_csv = "pattern/dataset_pattern.csv",
  data = original,
  output_csv = "data_synthetic/synthetic_dataset.csv",
  n = 200,
  seed = 2026
)
```

Explain: passing `data = original` only lets the script pick plausible numeric ranges locally at runtime; ranges are never written to any shared file. `n` is chosen freely and unrelated to the real sample size. For a SEM project, suggest `n = 300` so lavaan is comfortable.

If the pattern file describes variables the generic function cannot handle, write a project-specific `scripts/synthesize_data.R` instead — base R only, same privacy rules.

## Stage C: Synthetic Dataset

When the user confirms `data_synthetic/synthetic_dataset.csv` exists, read it, confirm the columns match the pattern file, and update the state file. Then hand back to `dr-workflow-orchestrator`, which routes to `dr-01-understand-dataset`.

See `references/pattern-file-spec.md` for the pattern file format.

## Boundaries

Never ask for the real dataset, its file path, its folder, or its filename; the user selects it with `file.choose()` and that knowledge stays in RStudio.
Never tell the user to copy real data into the repo. If you notice real data inside the repo (e.g. a `data_real/` folder someone created), warn the user to move it back out; never read it.
Never write real statistics of any kind into pattern or plan files.
Generated scripts must never print the real data path or filename to the console.
Never skip the review gate, even if the user seems in a hurry.
Do not clean, recode, or wrangle data in this skill; it prepares structure only.
Base R only in generated scripts; no package installation.

## Teaching Line

The AI only ever knows what you deliberately typed or reviewed. The real data — and even its location — never leaves your machine.
