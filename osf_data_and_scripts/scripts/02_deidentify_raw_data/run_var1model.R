# Purpose: fit per-subject Bayesian AR(1) models (via var1model_utils.R's fit_ar1_model())
# to the PANAS EMA series and to each of the 4 task mood-rating blocks, and extract
# per-subject AR/variance/mean estimates.
# Inputs (must already be in scope): df_PANAS, df_mood_AR, df_master (all built by
# read_data_task_ema.Rmd) and fit_ar1_model()/extract_ar_results() (var1model_utils.R).
# Outputs: leaves `panas_results` and `mood_results` in the calling environment --
# it does not write files itself; write_anonymized_data.R anonymizes and writes them.
library(brms)

panas_model <- fit_ar1_model(
  data = df_PANAS,
  var = "PAminusNA_sum",
  scale_fn = function(x) (x + 50) / 100 #same scaling as the bayesian filter
)

panas_results <- extract_ar_results(
  fit = panas_model$fit,
  var = "PAminusNA_sum",
  prefix = "PANAS"
)


vars <- c("day1_block1",
          "day1_block2",
          "day2_block1",
          "day2_block2")

mood_results_list <- map(vars, function(v) {
  
  model_obj <- fit_ar1_model(
    data = df_mood_AR,
    var = v,
    scale_fn = function(x) x / 10 #same scaling as the bayesian filter
  )
  
  extract_ar_results(
    fit = model_obj$fit,
    var = v,
    prefix = v
  )
})

# Join horizontally by Prolific.Id
mood_results <- reduce(mood_results_list, left_join, by = "Prolific.Id")
