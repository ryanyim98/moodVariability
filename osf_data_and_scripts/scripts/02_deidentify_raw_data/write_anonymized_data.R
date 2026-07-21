# Rebuild every anonymized CSV under osf_data_and_scripts/data/ from raw + derived
# data, without knitting the full main_analysis.Rmd notebook.
#
# Pipeline: read_data_task_ema.Rmd (raw -> df_master/df_days/df_mood_AR/..., and,
# internally near the end, var1model_utils.R + run_var1model.R once df_PANAS/
# df_mood_AR exist -> panas_results/mood_results) -> run_reg.R (reward-history
# regressions) -> AR joins / exclusions -> reward_sched -> anonymized writes.
#
# Needs raw per-subject data (data/raw/) that is not included in this OSF package --
# included here for transparency/provenance only. It also expects
# osf_data_and_scripts/data/ema_panas_params_noCloseResponse.csv to already exist
# (a MATLAB-pipeline output copied in by hand; this script does not produce it),
# and data/raw/subject_id_crosswalk.csv to already exist (produced by MATLAB's
# scripts/01_bayesian_filter/step1_anonymize_raw_data.m) so subject numbers here match
# those in RawData_anonymized.mat -- see the anonymization_list block below.
#
# Run with: Rscript osf_data_and_scripts/scripts/02_deidentify_raw_data/write_anonymized_data.R
# (from the moodVariability repo root, or anywhere inside it).

# ---- Config -----------------------------------------------------------------
# The 5 Bayesian AR(1) model fits (1 PANAS + 4 task blocks; brms, 4 chains x 2000
# iter each) are slow. TRUE reuses the cached fit at data/var1model_ar1_cache.rds
# from a prior run (fast); FALSE always refits and overwrites the cache (slow, but
# necessary if the raw data or the AR(1) model itself has changed).
read_ar1_from_memory <- FALSE
# -------------------------------------------------------------------------------

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
        "  Rscript osf_data_and_scripts/scripts/02_deidentify_raw_data/write_anonymized_data.R",
        call. = FALSE
      )
    }
    p <- parent
  }
}

repo_root <- find_repo_root()
pkg_root <- file.path(repo_root, "osf_data_and_scripts")
stage_dir <- file.path(pkg_root, "scripts/02_deidentify_raw_data")
setwd(repo_root)

source(file.path(pkg_root, "scripts/00_setup/load_library.R"))
source(file.path(stage_dir, "AR.R"))

rmarkdown::render(
  file.path(stage_dir, "read_data_task_ema.Rmd"),
  envir = globalenv(),
  knit_root_dir = repo_root,
  quiet = TRUE
)
# read_data_task_ema.Rmd itself sources var1model_utils.R + run_var1model.R near its
# end (once df_PANAS/df_mood_AR exist), leaving panas_results/mood_results here.

source(file.path(stage_dir, "run_reg.R"))

str <- c("PA_sum", "NA_sum", "PAminusNA_sum")
result <- AR_PANAS(df_PANAS, str)
df_AR_PANAS <- data.frame(cbind(result$S, result$ui))
names(df_AR_PANAS) <- c(result$names, "Prolific.Id")
df_AR_PANAS <- df_AR_PANAS %>%
  mutate_at(vars(AR_PA_sum:AR_PAminusNA_sum), ~ as.numeric(.x))

str <- c("day1_block1", "day1_block2", "day2_block1", "day2_block2")
result <- AR_task(df_mood_AR, str)
df_AR_task <- data.frame(cbind(result$S, result$ui))
names(df_AR_task) <- c(result$names, "Prolific.Id")

subj_exclude_novariance_ <- subj_exclude_novariance_rl %>%
  filter(day_block %in% c("day1_block1", "day2_block1")) %>%
  group_by(Participant.Public.ID) %>%
  count() %>%
  filter(n > 1)

df_master <- df_master %>%
  left_join(df_AR_task, by = "Prolific.Id") %>%
  left_join(df_AR_PANAS, by = "Prolific.Id") %>%
  filter(!Prolific.Id %in% subj_exclude_novariance_$Participant.Public.ID)

demo_info <- demo_info %>%
  filter(
    !participant_id %in% subj_exclude_novariance_$Participant.Public.ID,
    participant_id %in% df_master$Prolific.Id
  )

df_master[is.nan(as.matrix(df_master))] <- NA

df_master <- df_master %>%
  mutate(
    across(
      c(
        AR_PA_sum, AR_NA_sum, AR_PAminusNA_sum,
        AR_day1_block1, AR_day1_block2,
        AR_day2_block1, AR_day2_block2
      ),
      as.numeric
    )
  ) %>%
  mutate(
    AR_task = rowMeans(
      dplyr::select(., AR_day1_block1, AR_day2_block1),
      na.rm = TRUE
    )
  )

df_days <- df_days %>%
  filter(!Participant.Public.ID %in% subj_exclude_novariance_$Participant.Public.ID)

out_dir <- file.path(pkg_root, "data")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

df_reward_sched <- df_d1b1 %>%
  dplyr::select(Trial.Index, tree1info, tree2info, tree1mag, tree2mag) %>%
  filter(!is.na(tree1info)) %>%
  unique()

write_csv(df_reward_sched, file.path(out_dir, "reward_sched.csv"))

# The subject numbers here come from data/raw/subject_id_crosswalk.csv (built by
# osf_data_and_scripts/scripts/01_bayesian_filter/step1_anonymize_raw_data.m from
# RawData.mat's own subject order), NOT an independently-generated sequence --
# this is what makes "subject 5" here the same person as "subject 5" in
# RawData_anonymized.mat. Run that MATLAB script first if this file is missing.
crosswalk_path <- file.path(repo_root, "data", "raw", "subject_id_crosswalk.csv")
if (!file.exists(crosswalk_path)) {
  stop(
    "Missing ", crosswalk_path, ". Run ",
    "osf_data_and_scripts/scripts/01_bayesian_filter/step1_anonymize_raw_data.m in MATLAB ",
    "first -- it writes this Prolific.Id -> subject crosswalk so subject numbers ",
    "here match those in RawData_anonymized.mat.",
    call. = FALSE
  )
}
crosswalk <- read_csv(crosswalk_path, show_col_types = FALSE) %>%
  rename(Prolific.Id = Prolific_Id)

anonymization_list <- df_master %>%
  dplyr::select(Prolific.Id) %>%
  left_join(crosswalk, by = "Prolific.Id")

unmatched <- anonymization_list %>% filter(is.na(subject))
if (nrow(unmatched) > 0) {
  stop(
    nrow(unmatched), " Prolific.Id(s) in df_master have no matching entry in ",
    crosswalk_path, " -- every analytic-sample participant should be present in ",
    "the RawData.mat-derived crosswalk. Investigate before proceeding.",
    call. = FALSE
  )
}

df_master <- df_master %>%
  filter(Prolific.Id %in% anonymization_list$Prolific.Id) %>%
  left_join(anonymization_list, by = "Prolific.Id") %>%
  dplyr::select(-Prolific.Id) %>%
  relocate(subject)
write_csv(df_master, file.path(out_dir, "df_master.csv"))

demo_info <- demo_info %>%
  filter(participant_id %in% anonymization_list$Prolific.Id) %>%
  ungroup() %>%
  rename(Prolific.Id = participant_id) %>%
  left_join(anonymization_list, by = "Prolific.Id") %>%
  dplyr::select(-Prolific.Id) %>%
  relocate(subject)
write_csv(demo_info, file.path(out_dir, "demo_info.csv"))

df_PANAS <- df_PANAS %>%
  filter(Prolific.Id %in% anonymization_list$Prolific.Id) %>%
  ungroup() %>%
  dplyr::select(Prolific.Id, Survey.Name:min_PAminusNA) %>%
  left_join(anonymization_list, by = "Prolific.Id") %>%
  dplyr::select(-Prolific.Id) %>%
  relocate(subject)
write_csv(df_PANAS, file.path(out_dir, "df_PANAS.csv"))

df_panas_Est_tc <- df_panas_Est_tc %>%
  ungroup() %>%
  rename(Prolific.Id = id) %>%
  filter(Prolific.Id %in% anonymization_list$Prolific.Id) %>%
  left_join(anonymization_list, by = "Prolific.Id") %>%
  dplyr::select(-Prolific.Id) %>%
  relocate(subject)
write_csv(df_panas_Est_tc, file.path(out_dir, "df_panas_Est_tc.csv"))

df_all <- df_all %>%
  ungroup() %>%
  rename(Prolific.Id = Participant.Public.ID) %>%
  filter(Prolific.Id %in% anonymization_list$Prolific.Id) %>%
  left_join(anonymization_list, by = "Prolific.Id") %>%
  dplyr::select(-Prolific.Id) %>%
  relocate(subject)
write_csv(df_all, file.path(out_dir, "df_all.csv"))

df_Xs_scaled_all2_long <- df_Xs_scaled_all2_long %>%
  ungroup() %>%
  rename(Prolific.Id = Participant.Public.ID) %>%
  filter(Prolific.Id %in% anonymization_list$Prolific.Id) %>%
  left_join(anonymization_list, by = "Prolific.Id") %>%
  dplyr::select(-Prolific.Id) %>%
  relocate(subject)
write_csv(df_Xs_scaled_all2_long, file.path(out_dir, "df_Xs_scaled_all2_long.csv"))

df_days <- df_days %>%
  ungroup() %>%
  rename(Prolific.Id = Participant.Public.ID) %>%
  left_join(anonymization_list, by = "Prolific.Id") %>%
  dplyr::select(-Prolific.Id) %>%
  relocate(subject)
write_csv(df_days, file.path(out_dir, "df_days.csv"))

df_reg <- df_reg %>%
  ungroup() %>%
  rename(Prolific.Id = Participant.Public.ID) %>%
  filter(Prolific.Id %in% anonymization_list$Prolific.Id) %>%
  left_join(anonymization_list, by = "Prolific.Id") %>%
  dplyr::select(-Prolific.Id) %>%
  relocate(subject)
write_csv(df_reg, file.path(out_dir, "df_reg.csv"))

df_gor_Est_tc <- df_gor_Est_tc %>%
  ungroup() %>%
  rename(Prolific.Id = id) %>%
  filter(Prolific.Id %in% anonymization_list$Prolific.Id) %>%
  left_join(anonymization_list, by = "Prolific.Id") %>%
  dplyr::select(-Prolific.Id) %>%
  relocate(subject)
write_csv(df_gor_Est_tc, file.path(out_dir, "df_gor_Est_tc.csv"))

df_Xs_scaled_sum_all_long <- df_Xs_scaled_sum_all_long %>%
  ungroup() %>%
  rename(Prolific.Id = Participant.Public.ID) %>%
  filter(Prolific.Id %in% anonymization_list$Prolific.Id) %>%
  left_join(anonymization_list, by = "Prolific.Id") %>%
  dplyr::select(-Prolific.Id) %>%
  relocate(subject)
write_csv(df_Xs_scaled_sum_all_long, file.path(out_dir, "df_Xs_scaled_sum_all_long.csv"))

df_Xs_scaled_all_long <- df_Xs_scaled_all_long %>%
  ungroup() %>%
  rename(Prolific.Id = Participant.Public.ID) %>%
  filter(Prolific.Id %in% anonymization_list$Prolific.Id) %>%
  left_join(anonymization_list, by = "Prolific.Id") %>%
  dplyr::select(-Prolific.Id) %>%
  relocate(subject)
write_csv(df_Xs_scaled_all_long, file.path(out_dir, "df_Xs_scaled_all_long.csv"))

panas_results <- panas_results %>%
  left_join(anonymization_list, by = "Prolific.Id") %>%
  dplyr::select(-Prolific.Id) %>%
  relocate(subject)
write_csv(panas_results, file.path(out_dir, "var1model_panas_results.csv"))

mood_results <- mood_results %>%
  filter(Prolific.Id %in% anonymization_list$Prolific.Id) %>%
  left_join(anonymization_list, by = "Prolific.Id") %>%
  dplyr::select(-Prolific.Id) %>%
  relocate(subject)
write_csv(mood_results, file.path(out_dir, "var1model_task_results.csv"))

df_PANAS_uniform_response <- df_PANAS_uniform_response %>%
  filter(Prolific.Id %in% anonymization_list$Prolific.Id) %>%
  left_join(anonymization_list, by = "Prolific.Id") %>%
  ungroup() %>%
  dplyr::select(-Prolific.Id) %>%
  relocate(subject)
write_csv(df_PANAS_uniform_response, file.path(out_dir, "df_PANAS_uniform_response.csv"))

df_gor_Est_long <- df_gor_Est_long %>%
  ungroup() %>%
  rename(Prolific.Id = id) %>%
  filter(Prolific.Id %in% anonymization_list$Prolific.Id) %>%
  left_join(anonymization_list, by = "Prolific.Id") %>%
  dplyr::select(-Prolific.Id) %>%
  relocate(subject)
write_csv(df_gor_Est_long, file.path(out_dir, "df_gor_Est_long.csv"))

df_wof <- df_wof %>%
  ungroup() %>%
  rename(Prolific.Id = Participant.Public.ID) %>%
  filter(Prolific.Id %in% anonymization_list$Prolific.Id) %>%
  left_join(anonymization_list, by = "Prolific.Id") %>%
  dplyr::select(-Prolific.Id) %>%
  relocate(subject)
write_csv(df_wof, file.path(out_dir, "df_wof.csv"))

df_wof_react <- df_wof_react %>%
  ungroup() %>%
  rename(Prolific.Id = Participant.Public.ID) %>%
  filter(Prolific.Id %in% anonymization_list$Prolific.Id) %>%
  left_join(anonymization_list, by = "Prolific.Id") %>%
  dplyr::select(-Prolific.Id) %>%
  relocate(subject)
write_csv(df_wof_react, file.path(out_dir, "df_wof_react.csv"))

message("Wrote anonymized tables to ", out_dir)
