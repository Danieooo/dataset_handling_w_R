# DR Workflow Pack v2 — Agent Instructions

You are working inside the DR Workflow Pack: a skills-based toolkit for AI-assisted research data analysis where **the real dataset never reaches the AI**. The user is typically a Vietnamese researcher or student; reply in Vietnamese unless they use another language. Skill files are in English.

## Golden Rules (non-negotiable)

1. **The real dataset lives OUTSIDE this repo and stays there.** Never read it, never ask for its path, folder, or filename, and never tell the user to copy it into the repo. Scripts reach it only through `file.choose()` inside the user's RStudio session. If you notice real data inside the repo (e.g. a user-created `data_real/` folder), warn the user to move it out — and never read it, not with Read, not with shell commands, not "just the header".
2. **Never request real data, real summary statistics, or real row counts** from the user. If they try to paste raw data, stop them and point to the privacy gate. If pasted output contains a real file path, do not repeat it in any artifact.
2b. **Never open or accept a figure made from real data.** A boxplot or scatter is row-level data rendered as pixels — one outlier dot is one identifiable participant. Aggregate text (tables, estimates, CIs, fit indices) may be pasted; images from real data may not. Scripts must write real-run figures to `file.path(dirname(input_csv), "dr_figures")`, outside the repo. Figures under `outputs_synthetic/figures/` are synthetic and safe to open.
3. **All outputs of a research question go only inside its own `projects/<name>/` folder.** One research question = one project folder.
4. **Generated R code is base R only.** The single exception: `lavaan` in the SEM track. Never emit `install.packages()` inside scripts; mention installs as comments/notes.
5. **Final results use only user-provided real-run output.** Numbers computed on synthetic data are never findings — they only prove code runs.

## How To Work

Start every task through the skills in `skills/` (mirrored in `.claude/skills/`, `.opencode/skill/`, `.agents/skills/`). If your platform did not auto-load them, open `skills/<name>/SKILL.md` and follow it as instructions.

- Entry point and routing: `dr-workflow-orchestrator` (project creation, state, what's next).
- Stages A–C (pattern extraction, review gate, synthetic data): `dr-00-privacy-gate`.
- Stage D1: `dr-01-understand-dataset` (analysis plan + track decision).
- Stage D1b: `dr-01b-analysis-sap` (SAP + mode choice). **Required in both modes.** The user approves variable roles, Table 1 stratification, and plot variables once, then picks `all_steps` (generate every script in one pass) or `step_by_step` (one script at a time, user runs each locally on synthetic before the next). Both modes produce identical, separate script files.
- Stage D2: `dr-02-descriptive-analysis` (desc.R).
- Stage D2b (optional, both tracks): `dr-02b-visual-exploration` (plots.R — correlation heatmap + boxplot series). Never blocks progress to D3.
- Medical track D3/D4: `dr-03-inferential-analysis`, `dr-04-confounding-adjustment` (infer.R).
- SEM track D3/D4: `dr-sem-01-measurement-model`, `dr-sem-02-structural-model`.
- Stage E: `dr-05-present-results` (results_real/).
- Before advancing any stage: `dr-output-qa-gate`.

State lives in `projects/<name>/dr_workflow_state.yaml`. Read it when resuming; update it after every completed action. Always tell the user: current stage, QA status, next step, and what you need from them.

## Verification Duty

**The deliverable of every stage is a runnable script.** The user takes the code and runs it on their own machine; you are not the runtime. Most agents running this pack will not have R installed, and no stage may stall because of that.

Verification on the synthetic dataset is mandatory before the user moves a script to real data — but *who* runs it is flexible:

- R available to you: run `Rscript <script>` from the project folder, fix errors, rerun until it exits cleanly.
- R not available: say so plainly and hand the user the exact command to run locally. Their run is the verification.

Record who verified it (`agent` or `user`) in the state file. Never report a script as verified when it has not actually been run — loosen *who* runs it, never *whether* it ran.

Deliver every generated script with its SETTINGS block in **synthetic mode**, so the user can open it and hit Run immediately. Switching to real data must be a one-line comment change, never an edit the user has to make before the first run.

## Repo Map

```text
skills/           canonical skill definitions (dr-00 ... dr-05, dr-sem-*, orchestrator, qa-gate)
r-scripts/        pattern_extract.R, synthesize_data.R (local privacy-gate templates)
projects/         one folder per research question (_template to copy; two worked examples)
docs/             demo runbook (Vietnamese)
INSTALL.md        learner installation guide (Vietnamese)
```

## When Editing This Repo (maintainers)

`skills/` is the canonical copy; `.claude/skills/`, `.opencode/skill/`, and `.agents/skills/` are mirrors — apply any skill change to all of them. Keep skill files in English, learner docs in Vietnamese. Keep artifact filenames consistent everywhere (they are cross-referenced by the orchestrator, QA gate, and docs).
