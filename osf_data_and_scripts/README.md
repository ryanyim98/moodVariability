# Task-EMA: data and analysis code

Data and analysis code for "Evaluating the ecological validity and mechanism of a
generative model-based decomposition of affective variability" (task-ema study;
currently in peer review at *Psychological Science*).

OSF project: <https://osf.io/cp2tg/>
Study materials (Gorilla): <https://app.gorilla.sc/openmaterials/1253281>

Participants completed a reinforcement-learning task (run twice, on two separate
days) and ~2 weeks of PANAS ecological momentary assessment (EMA). Both series are
decomposed into short-lived **affective noise** and longer-term **affective
volatility** using a hierarchical Bayesian Filter (the model itself, independent of
this study, is documented at <https://osf.io/j7md3/>).

## Two-tier reproducibility

Most raw per-subject data (survey/task CSV exports, demographics) is **not
shared**, for participant privacy. That splits this package's scripts into
two tiers:

- **Tier 1 — fully reproducible from what's in this package, no private data
  needed.** `scripts/03_parameter_recovery/` (MATLAB, synthetic data only),
  `scripts/04_main_analysis/main_analysis.Rmd` (R, runs on `data/` alone), and
  five of `scripts/01_bayesian_filter/`'s six MATLAB driver scripts
  (`step2`–`step6`; `step7` is the exception, see Tier 2). `step2_run_bayes_filter.m`
  reproduces the actual Bayesian Filter fits on the de-identified
  `data/raw_mat/*_anonymized.mat` files shipped here, then copies its raw
  output back into `data/raw_mat/<name>_modeldata_anonymized.mat` (safe, since
  every fit ran on already-anonymized input). `step3_assemble_bayes_model_params.m`
  merges those per-run fits into one `Md_Inst_Struct`, written to
  `data/raw_mat/Gor_PANAS_Mod_Data_anonymized.mat`. `step4`–`step6` just read
  that merged file.
- **Tier 2 — included for transparency/provenance, not runnable from this
  package alone.** `scripts/02_deidentify_raw_data/` and
  `scripts/01_bayesian_filter/step1_anonymize_raw_data.m` need raw per-subject
  `.csv`/`.mat` files that live outside this package. `step7_run_panas_model_no_close_response.m`
  is the one MATLAB driver script in `01_bayesian_filter/` that's still Tier 2
  (its raw fit is only ever saved to the private `data/raw/raw_mat/`, unlike
  `step2`, which copies its output into this package).

  This dependency reaches a bit further than it looks: `step4_data_org.m`'s
  output CSVs carry the *anonymized* subject number as their `id` column, but
  at the point `02_deidentify_raw_data/read_data_task_ema.Rmd` reads them,
  `df_master` is still keyed by the real `Prolific.Id` (anonymization happens
  later, in `write_anonymized_data.R`). Its `attach_prolific_id()` helper
  bridges this by joining those CSVs' `id` against the **private**
  `data/raw/subject_id_crosswalk.csv` (written by `step1_anonymize_raw_data.m`)
  to recover a real `Prolific.Id` before joining into `df_master`. So the R
  pipeline's Tier-2 status isn't just "needs raw CSVs" — it also transitively
  needs `Gor_PANAS_Mod_Data_anonymized.mat` and that private crosswalk.

You can read all of this code to see exactly how the shared data was derived;
you cannot re-run the Tier 2 scripts without the private data they depend on.

**`data/raw_mat/*_anonymized.mat` vs. the private originals:** `step1_anonymize_raw_data.m`
replaces the participant-identifier fields in `RawData.mat` with sequential
subject numbers and drops the raw per-response export tables entirely. All
actual rating/choice/timing data is untouched, so results are identical to the
private original. Subject numbers match the `subject` column in `data/*.csv`
via a private crosswalk (`data/raw/subject_id_crosswalk.csv`, *outside* this
package) that must never be shared — it's the literal Prolific-ID lookup key.

**Runtime warning:** `scripts/03_parameter_recovery/step1_wrap_genrecoverscale.m`
(parameter-recovery simulation) and `scripts/01_bayesian_filter/` (fitting the
Bayesian Filter to every participant) are both computationally expensive — grid-based
Bayesian filtering repeated over many simulated or real participants. Budget
significant runtime (well beyond a few minutes) for either.

**Note on this refactor:** MATLAB was not available in the environment used to
clean up this package, and the two MATLAB stages above are long-running even where
it is available. So the MATLAB code was fixed and documented (paths, dead code,
structure) but **not executed** to verify it runs — the R side (Tiers 1 and part of
2) was actually run end-to-end and verified; see "What was verified" below.

## Directory map

```
osf_data_and_scripts/
├── data/
│   ├── raw_mat/                 de-identified raw .mat data (see step1_anonymize_raw_data.m)
│   └── *.csv                    de-identified derived/analysis tables (Tier 1 input)
├── scripts/
│   ├── 00_setup/                shared R package loading
│   ├── 01_bayesian_filter/      anonymize raw .mat (Tier 2) -> Bayesian Filter fits
│   │                            (Tier 1 once anonymized, MATLAB)
│   ├── 02_deidentify_raw_data/  raw -> data/*.csv (Tier 2, R) -- consumes
│   │                            01_bayesian_filter's data_org.m output
│   ├── 03_parameter_recovery/   simulation study (Tier 1, MATLAB)
│   ├── 04_main_analysis/        main_analysis.Rmd (Tier 1, R) -- the results notebook
│   └── 05_figure2_schematic/    Figure 2 (model schematic) assembly (MATLAB)
└── figures/                     output figures (regenerated by the scripts above)
```

Run order within a stage follows its numeric prefix (`01_` before `02_`, etc.);
`00_setup` and `05_figure2_schematic` are independent of that ordering.

## Software requirements

### R
Developed and verified with **R 4.4.0**. Exact package versions used to verify this
package (from `packageVersion()` in that environment):

| Package | Version | | Package | Version |
|---|---|---|---|---|
| tidyverse | 2.0.0 | | ggpmisc | 0.5.6 |
| brms | 2.22.0 | | PerformanceAnalytics | 2.0.4 |
| rstan | 2.32.7 | | ppcor | 1.1 |
| StanHeaders | 2.32.10 | | nFactors | 2.4.1.1 |
| lme4 | 2.0.1 | | lm.beta | 1.7.2 |
| lmerTest | 3.1.3 | | ggpattern | 1.1.1 |
| here | 1.0.1 | | psych | 2.4.3 |
| knitr | 1.51 | | ltm | 1.2.0 |
| rmarkdown | 2.30 | | magick | 2.8.4 |
| ggplot2 | 4.0.2 | | tsibble | 1.1.5 |
| ggcorrplot | 0.1.4.1 | | ggpubr | 0.6.0 |
| MuMIn | 1.47.5 | | broom | 1.0.8 |
| bayestestR | 0.13.2 | | moments | 0.14.1 |
| patchwork | 1.3.2 | | sjPlot | 2.8.15 |

`brms` uses the `rstan` backend (not `cmdstanr`) in this environment.

To open `main_analysis.Rmd` or run any R script with correct relative paths,
open `task-ema-osf.Rproj` (at this package's root) in RStudio first, or otherwise
set your working directory inside this package before running — every script/Rmd
resolves `data/`/`figures/` paths via `here::here()`, anchored on the `.here` file
at this package's root.

### MATLAB
Version not pinned (MATLAB unavailable in the environment used for this refactor;
any reasonably recent release should work). Requires:

- **Parallel Computing Toolbox** (`parfor`/`parpool`), used by
  `01_bayesian_filter/run_model_Gorilla.m`, `run_model_PANASPosMinNeg.m`, and
  `03_parameter_recovery/step1_wrap_genrecoverscale.m`.
- **export_fig** (<https://github.com/altmany/export_fig>) and **makefigure** (a
  local plotting-size helper), used only by `05_figure2_schematic/`. Not vendored in
  this repo — edit the `addpath(...)` lines at the top of `figure_2_main_psci.m` and
  `plot_uncert_series.m` to point at your local install.

## Per-file reference

### `scripts/00_setup/`
| File | Purpose |
|---|---|
| `load_library.R` | Loads every R package used across the pipeline. Sourced first by every other R script/Rmd. |

### `scripts/01_bayesian_filter/` (mixed tiers — see each row)

The 7 runnable driver scripts are prefixed `step1_`-`step7_` for the order you'd
run them in (same convention as `03_parameter_recovery/step1_wrap_genrecoverscale.m`
/ `step2_assessgenrecvoer.m`) -- a leading digit alone (`01_...`) doesn't work for a
MATLAB script: `01_anonymize_raw_data` isn't a valid identifier, so MATLAB can't
run it by name from the command line (only via `run('01_anonymize_raw_data.m')`),
whereas `step1_anonymize_raw_data` can be typed directly. The remaining files are
helper functions, called by the numbered scripts rather than run directly, so
they're unprefixed.

| File | Purpose |
|---|---|
| `find_repo_root.m` | Helper: walks upward from a starting folder to find `moodVariability.Rproj` and locate the repo root. Uses a **hardcoded `script_dir`** rather than `mfilename('fullpath')`, which resolved to a temp copy of the script on at least one machine. **Edit `script_dir`** at the top of each script if this repo lives somewhere other than `~/Desktop/MoodInstability/moodVariability`. |
| `step1_anonymize_raw_data.m` | Tier 2 — needs the private `data/raw/raw_mat/` originals. De-identifies `RawData.mat` (scrubs the Prolific/participant ID fields; drops the identifying per-response export tables) and copies the other raw `.mat` files through unchanged. Also writes the private `data/raw/subject_id_crosswalk.csv`. Run before `write_anonymized_data.R`. |
| `maglearn_func_vardiff_flat_miss.m` | The Bayesian Filter engine itself: 5-parameter (mu, vmu, kmu, s, vs) grid-based recursive Bayesian update on a rating series. Vendored copy of `bayesian_filter_matlab_code/maglearn_func_vardiff_flat_miss.m` at the repo root. |
| `inv_logit.m` | Logit / inverse-logit transform used by the engine. Vendored copy, as above. |
| `step2_run_bayes_filter.m` | Tier 1, self-contained. **Top-level driver.** Loads the de-identified `.mat` files from `step1` and runs the filter on the PANAS pos-minus-neg series (twice, with two vmu ranges), the PANAS pos/neg subscales, each of the 4 individual task runs, and the 2 whole-day (both runs concatenated) task series — 10 fits total. Saves each fit's raw output to the private `data/raw/raw_mat/`, then copies it into `data/raw_mat/<name>_modeldata_anonymized.mat` in this package (safe: every fit ran on already-anonymized input). |
| `Gor_Md_mat_fr_Model.m` | Reshapes the raw task-mood-rating struct into 4 run matrices (one per day x block). |
| `run_model_Gorilla.m` | Runs the filter over the task mood-rating matrix (rescaled /10). Saves `[name]_modeldata.mat` to the private `data/raw/raw_mat/`. |
| `run_model_PANASPosMinNeg.m` | Runs the filter over a PANAS series. Optional args override the filter's vmu grid range and the raw-series rescale range (`step2_run_bayes_filter.m` uses both for the subscale/wide-variance fits). Despite the name, the filter itself is generic; only the rescaling is series-specific. |
| `step3_assemble_bayes_model_params.m` | Tier 1, reads only `data/raw_mat/` in this package. Merges the base `Md_Inst_Struct` (from `RawData_anonymized.mat`) with the 10 per-run fits from `step2` into one struct, dropping each fit's unused `.volnoise`/`.KLdiv` fields, and writes `data/raw_mat/Gor_PANAS_Mod_Data_anonymized.mat`. Its `PANAS.ProlifID` is the anonymized subject number, not the real Prolific ID — see `read_data_task_ema.Rmd`'s `attach_prolific_id()` for the bridge back. |
| `step4_data_org.m` | Tier 1 (needs `Gor_PANAS_Mod_Data_anonymized.mat` from `step3`). Bridges the assembled struct to the summary CSVs `02_deidentify_raw_data/read_data_task_ema.Rmd` reads: `apple_moodrate_params.csv`, `apple_moodrate_params_wholeday.csv`, `ema_panas_params.csv` (all carry the anonymized subject number as `id`). |
| `step5_make_bayes_timecourse.m` | Tier 1 (needs `step3`'s output). Builds long-format time-course CSVs (mu/vmu/kmu/s/vs per trial) for both arms. |
| `step6_posterior_variance_plot.m` | Tier 1 (needs `step3`'s output). Figure: posterior variance & entropy over time (ESM vs Task), mean ± SEM across participants. |
| `step7_run_panas_model_no_close_response.m` | Tier 2 — the one exception in this folder; needs raw model output not included in this package. Sensitivity analysis: same filter excluding "close" (rushed) EMA responses. Only depends on `step1`'s output (independent of `step3`–`step6`); its raw fit is saved to the private `data/raw/raw_mat/` only, then read back to write `ema_panas_params_noCloseResponse.csv`. |

Run with (in MATLAB, from this folder, in numeric order): `step1_anonymize_raw_data`
(once, needs the private raw data), then `step2_run_bayes_filter` and
`step3_assemble_bayes_model_params` (both fully reproducible from what's in
this package) to produce `data/raw_mat/Gor_PANAS_Mod_Data_anonymized.mat`.
That's enough to run `step4_data_org`, `step5_make_bayes_timecourse`, and
`step6_posterior_variance_plot`. `step7_run_panas_model_no_close_response` only
needs `step1`'s output, so it can run any time after that. `step4_data_org.m`'s
three output CSVs are needed by `02_deidentify_raw_data/read_data_task_ema.Rmd`,
via the `attach_prolific_id()` bridge described above.

### `scripts/02_deidentify_raw_data/` (Tier 2 — needs raw data, not included)
| File | Purpose | Reads | Writes |
|---|---|---|---|
| `read_data_task_ema.Rmd` | Loads and cleans every raw per-subject file (baseline questionnaires, PANAS EMA, 4 RL-task runs, 2 wheel-of-fortune runs) and the MATLAB filter-output CSVs; builds `df_master`, `df_days`, `df_mood_AR`, the no-affect-variance exclusion list `subj_exclude_novariance_rl`, etc. The MATLAB CSVs' `id` column is the anonymized subject number, so `attach_prolific_id()` bridges it back to a real `Prolific.Id` via the private crosswalk before joining into `df_master` (still real-ID-keyed until `write_anonymized_data.R` anonymizes it later). Near the end, fits (or loads a cache of) the Bayesian AR(1) models. | `<repo_root>/data/raw/raw_csv/*.csv`, `<repo_root>/data/*.csv` (MATLAB output), the private crosswalk, an external Prolific demographics export (path hardcoded — edit if re-running elsewhere) | Intermediate (non-anonymized) CSVs back into `<repo_root>/data/`, plus the AR(1) cache below |
| `AR.R` | `AR_PANAS()` / `AR_task()`: subject-mean-centered lag-1 autoregression (mixed-effects) on PANAS sums and on the 4 task mood-rating blocks. | in-memory data | — |
| `run_reg.R` | Per-subject regressions of task mood rating on the preceding 9 trial-back reward outcomes (binary, magnitude, and summed-triplet versions). | in-memory `df_reg`/`df_master` | — |
| `var1model_utils.R` | `fit_ar1_model()` / `extract_ar_results()`: Bayesian AR(1) model (via `brms`) with subject-varying residual, and the per-subject estimate extractor. | in-memory data | — |
| `run_var1model.R` | Fits the AR(1) model to PANAS and to each of the 4 task blocks (5 `brms` fits — slow); leaves `panas_results`/`mood_results` in the environment. Only runs when `read_data_task_ema.Rmd` can't or won't use the cache (see below). | in-memory `df_PANAS`, `df_mood_AR` | — (`read_data_task_ema.Rmd` caches the result) |
| `subject_flow.R` | Reports CONSORT-style participant counts (baseline completers -> PANAS responders -> RL completers -> final analytic sample), matching the manuscript's Participants section. | `<repo_root>/data/raw/raw_csv/*.csv`, renders `read_data_task_ema.Rmd` | console messages only |
| `write_anonymized_data.R` | **Entry point** for this whole stage. Renders `read_data_task_ema.Rmd`, sources `run_reg.R`/`AR.R`, replaces `Prolific.Id` with a sequential `subject` number everywhere, and writes every table below to `data/`. | (see above) | every file in `data/` except `ema_panas_params_noCloseResponse.csv` |

**Caching the slow AR(1) fits:** the 5 Bayesian model fits in `run_var1model.R` are
the slow part of this stage. `read_data_task_ema.Rmd` caches their result to
`<repo_root>/data/var1model_ar1_cache.rds` (gitignored — it still has `Prolific.Id`
in it, pre-anonymization) and, by default, reuses that cache instead of refitting.
Set `read_ar1_from_memory <- FALSE` at the top of `write_anonymized_data.R` (or
before rendering the Rmd yourself) to force a refit — needed if the raw data or the
AR(1) model itself changes. `subject_flow.R` doesn't set the flag at all, so it
just uses whatever cache already exists and never forces a refit.

Run with: `Rscript scripts/02_deidentify_raw_data/write_anonymized_data.R` (from the
`moodVariability` repo root — only meaningful if you have the raw data this
package doesn't include).

### `scripts/03_parameter_recovery/` (Tier 1 — fully reproducible, synthetic data only)
| File | Purpose |
|---|---|
| `find_pkg_root.m` | Same idea as `01_bayesian_filter/find_repo_root.m` (walks upward for `osf_data_and_scripts/.here`), also called with a **hardcoded `script_dir`** — EDIT it at the top of `step1_wrap_genrecoverscale.m`/`step2_assessgenrecvoer.m` if needed. |
| `step1_wrap_genrecoverscale.m` | **Step 1.** Samples starting parameters from real participants' last-5 fitted values (`last5_parameters_from_participants.mat`), forward-simulates 100 synthetic EMA + task rating series (`generate_data_learner.m`), fits the filter back to them, and saves `recovered_params.mat`. Reads only de-identified `data/df_gor_Est_tc.csv` / `df_panas_Est_tc.csv` — no raw data needed. Computationally expensive. |
| `step2_assessgenrecvoer.m` | **Step 2.** Loads `recovered_params.mat` and produces the recovery-quality figures (timeseries, sampled-parameter comparison, correlation by time/window, generated-vs-recovered scatter, example posterior heatmap). |
| `generate_data_learner.m` | Forward-simulates one synthetic rating series + latent parameter trajectory, with trajectory-bound rejection sampling. |
| `trunc_norm.m` | Truncated-normal sampler used to draw starting parameters. |
| `maglearn_func_vardiff_flat_miss.m`, `inv_logit.m` | Same filter engine as in `01_bayesian_filter/` (kept as a second, self-contained copy so this stage needs nothing outside its own folder + `data/`). |
| `last5_parameters_from_participants.mat` | Real participants' last-5 fitted parameters (model output, not raw responses) — seeds the simulation's starting distribution. |

Run with (in MATLAB, from this folder): `step1_wrap_genrecoverscale`, then
`step2_assessgenrecvoer`.

### `scripts/04_main_analysis/` (Tier 1 — fully reproducible from `data/`)
| File | Purpose |
|---|---|
| `main_analysis.Rmd` | **The results notebook.** Demographics, diurnal PANAS pattern, simulated-agent task-validity check, response-style (ARS/MRS) sensitivity, within/between-session reliability (ICC), reward-history -> variability regressions, task <-> EMA correlations, parameterization robustness (mean vs last-1/5/10), PANAS VAR(1)-with-innovation comparison, PA/NA factor structure. Writes every main, supplementary, and reviewer-response figure. Renamed from `affvar_clean_revision1.Rmd`. |

Run with: open `task-ema-osf.Rproj` in RStudio, then Knit `main_analysis.Rmd` (or
`rmarkdown::render()` from an R session with working directory anywhere inside this
package).

### `scripts/05_figure2_schematic/`
| File | Purpose |
|---|---|
| `find_pkg_root.m` | Same helper as in `03_parameter_recovery/` (separate copy, so each stage folder stays self-contained); also seeded with a hardcoded `script_dir` — EDIT it at the top of `figure_2_main_psci.m`/`plot_uncert_series.m` if needed. |
| `figure_2_main_psci.m` | Assembles the paper's Figure 2 (panel A: DAG via `draw_figure1a.m`; panel B: illustrative uncertainty example via `plot_example_uncert.m`; panels C/D: pre-rendered `fig1c.png`). Writes `figure_2.png`/`.pdf` to `figures/`. |
| `draw_figure1a.m` | Programmatically draws the model DAG (mu/vmu/kmu/S/vS/y_t nodes) for panel A. |
| `plot_example_uncert.m` | Draws the illustrative two-Gaussian "uncertainty" schematic for panel B. |
| `plot_uncert_series.m` | Regenerates `fig1c.png` from a cached example model fit (`7_bayes_mod.mat`, `out.mat`) — not run by default (see the commented-out call in `figure_2_main_psci.m`); `fig1c.png` is already included pre-rendered. |

Requires `export_fig` and `makefigure` (see Software requirements above).

## Data dictionary (`data/`)

All files use a de-identified `subject` integer id (no `Prolific.Id` anywhere).

`data/raw_mat/` contains the de-identified raw `.mat` structs consumed by
`scripts/01_bayesian_filter/step2_run_bayes_filter.m` (see `step1_anonymize_raw_data.m` for
exactly what was scrubbed): `RawData_anonymized.mat` (per-subject task + EMA
structs), `PANASPosMinNegFrMod_anonymized.mat`/`PANASfrBaysMod_anonymized.mat`
(EMA rating matrices), `PANASPosMinNegFrMod_noCloseResponse_anonymized.mat`
(sensitivity-analysis variant), and `d1r1/d1r2/d2r1/d2r2ModDat_anonymized.mat`
(per-run task data). `subject` numbers here match `data/*.csv` below.

| File | Contents |
|---|---|
| `df_master.csv` | One row per participant: demographics-linked baseline questionnaire sums (CESD, HPS, TEPS, STAI), PANAS summary stats, Bayesian Filter estimates (task + EMA, several parameterizations), AR(1)/VAR(1) estimates, reward-regression coefficients, wheel-of-fortune reactivity. The primary per-subject analysis table. |
| `demo_info.csv` | Age, sex, country of birth/residence, first language (Prolific demographics export). |
| `df_PANAS.csv` | Long-format PANAS EMA responses (one row per subject x survey trigger), with PA/NA/PA-minus-NA sums. |
| `df_PANAS_uniform_response.csv` | Subjects flagged as "flatline" (uniform) PANAS responders, with proportion of flatline responses. |
| `df_panas_Est_tc.csv` | Bayesian Filter time-course estimates (mu/vmu/kmu/s/vs per survey) for the PANAS EMA arm, joined to raw PA/NA/PA-minus-NA values. |
| `df_gor_Est_tc.csv`, `df_gor_Est_long.csv` | Bayesian Filter time-course / per-run summary estimates for the RL task arm. |
| `ema_panas_params_noCloseResponse.csv` | Sensitivity-analysis filter estimates excluding rushed ("close") EMA responses (MATLAB output — the one file in `data/` not produced by any R script here). |
| `df_all.csv` | Long-format raw RL-task trial data (choices, outcomes, mood ratings) across both days/blocks. |
| `df_days.csv` | Per-subject timing between the two task days (hours/calendar days), and days since enrollment. |
| `df_reg.csv` | Per-trial reward-history regressors (lagged binary/magnitude outcomes) joined to mood ratings, used for the reward -> variability regressions. |
| `df_Xs_scaled_all_long.csv`, `df_Xs_scaled_all2_long.csv`, `df_Xs_scaled_sum_all_long.csv` | Per-subject regression coefficients from `run_reg.R` (binary outcome model, magnitude model, summed-triplet model respectively), long format. |
| `df_wof.csv` | Wheel-of-fortune (win/lose) outcomes for both days. |
| `df_wof_react.csv` | Mood-rating reactivity around wheel-of-fortune outcomes. |
| `reward_sched.csv` | The fixed reward schedule (tree/outcome/magnitude by trial) used in the RL task. |
| `var1model_panas_results.csv`, `var1model_task_results.csv` | Per-subject Bayesian AR(1)/VAR(1) estimates (AR coefficient, innovation SD/variance, implied mean) for PANAS and for each task block, from `run_var1model.R`. |

## What was verified

- `scripts/02_deidentify_raw_data/write_anonymized_data.R` was fixed (it previously
  referenced `panas_results`/`mood_results` without ever computing them) and run
  end-to-end against the real raw data, confirming it regenerates every file in
  `data/` without error.
- `scripts/04_main_analysis/main_analysis.Rmd` was rendered end-to-end using only
  `data/` (no raw-data access), confirming the core reproducibility claim of this
  package.
- `scripts/02_deidentify_raw_data/subject_flow.R` was fixed (wrong raw-file paths,
  an undefined variable) and run, confirming it reports sensible participant counts.
- All hardcoded personal (`/Users/...`, `~/Desktop/...`) paths across the R scripts
  were replaced with `here::here()`-relative paths; MATLAB scripts were rewritten to
  resolve paths from the script's own location (`mfilename('fullpath')`) instead.
- **Not verified**: `scripts/01_bayesian_filter/` (including the new
  `step3_assemble_bayes_model_params.m` and the redirected `*_modeldata.mat` save
  location), `scripts/03_parameter_recovery/`, and `scripts/05_figure2_schematic/`
  (all MATLAB) were fixed and reviewed statically but not executed — MATLAB was
  unavailable in the environment used for this refactor, and (per above) these
  stages are long-running even where it is.
  If you run `03_parameter_recovery/step1_wrap_genrecoverscale.m` yourself, note
  that the `recovered_params.mat` cache previously bundled with this package was
  lost during the refactor (an unrecoverable accidental deletion of a gitignored
  simulation-output file, not raw data) — step 1 will need to be re-run once before
  step 2 will work.
