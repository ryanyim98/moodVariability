# Purpose: reports CONSORT-style participant counts through the study pipeline
# (baseline questionnaires -> PANAS EMA responders -> RL task completers -> final
# analytic sample), matching the exclusion criteria described in the manuscript's
# Participants section (behavioral screening + zero-affect-variance exclusion).
#
# Tier 2 script: needs raw per-subject data that is NOT included in this OSF package.
# Run with: Rscript scripts/02_deidentify_raw_data/subject_flow.R (from the
# moodVariability repo root, or anywhere inside it).

find_repo_root <- function() {
  p <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  repeat {
    if (file.exists(file.path(p, "moodVariability.Rproj"))) {
      return(p)
    }
    parent <- dirname(p)
    if (parent == p) {
      stop(
        "Could not find moodVariability.Rproj above getwd(). ",
        "cd to the moodVariability repository, then run:\n",
        "  Rscript osf_data_and_scripts/scripts/02_deidentify_raw_data/subject_flow.R",
        call. = FALSE
      )
    }
    p <- parent
  }
}

repo_root <- find_repo_root()
pkg_root <- file.path(repo_root, "osf_data_and_scripts")

source(file.path(pkg_root, "scripts/00_setup/load_library.R"))

# Render the data-loading notebook to get subj_exclude_novariance_rl (and everything
# else it builds) into this session. This script doesn't need the Bayesian AR(1)
# fits (panas_results/mood_results) at all, so read_data_task_ema.Rmd's default
# (read_ar1_from_memory = TRUE, i.e. reuse the cache) applies -- it won't trigger a
# slow refit unless data/var1model_ar1_cache.rds doesn't exist yet.
rmarkdown::render(
  file.path(pkg_root, "scripts/02_deidentify_raw_data/read_data_task_ema.Rmd"),
  envir = globalenv(),
  knit_root_dir = repo_root,
  quiet = TRUE
)

raw_csv_dir <- file.path(repo_root, "data/raw/raw_csv")

subj_baseline_q <- read_csv(file.path(raw_csv_dir, "baseline_questionnaires.csv"))$Last.Name
n_subj_baseline_q <- length(unique(subj_baseline_q))

subj_panas_q <- read_csv(file.path(raw_csv_dir, "ema_panas_sf.csv"))
subj_panas_q <- subj_panas_q %>%
  group_by(`Last Name`) %>%
  count() %>% drop_na()

subj_panas <- subj_panas_q$`Last Name`

n_subj_panas_q <- length(unique(subj_panas_q$`Last Name`))
n_subj_panas_q_included <- length(unique(subj_panas_q$`Last Name`[subj_panas_q$n >= 90]))
subj_panas_q_included <- unique(subj_panas_q$`Last Name`[subj_panas_q$n >= 90])

subj_rl1 <- read_csv(file.path(raw_csv_dir, "apple_d1b2.csv"))
subj_rl2 <- read_csv(file.path(raw_csv_dir, "apple_d2b2.csv"))

n_subj_rl1 <- length(unique(subj_rl1$`Participant Private ID`))
n_subj_rl2 <- length(unique(subj_rl2$`Participant Private ID`))

subj_rl <- intersect(unique(subj_rl1$`Participant Public ID`), unique(subj_rl2$`Participant Public ID`))

subj_rl_panas <- Reduce(intersect, list(subj_rl, subj_panas_q_included))

# Same "no affect variance in day1_block1 & day2_block1" exclusion used in
# write_anonymized_data.R, for a consistent reported N across scripts.
subj_rl_exclude <- subj_exclude_novariance_rl %>%
  filter(day_block %in% c("day1_block1", "day2_block1")) %>%
  group_by(Participant.Public.ID) %>%
  count() %>%
  filter(n > 1)
subj_rl_exclude <- subj_rl_exclude$Participant.Public.ID

subj_rl_panas_included <- setdiff(subj_rl_panas, subj_rl_exclude)

message("Baseline questionnaire completers: ", n_subj_baseline_q)
message("PANAS EMA responders (>=90 responses): ", n_subj_panas_q_included)
message("RL task completers (both days): ", length(subj_rl))
message("RL task + PANAS EMA: ", length(subj_rl_panas))
message("Final analytic sample (after no-variance exclusion): ", length(subj_rl_panas_included))
