library(brms)

panas_model <- fit_ar1_model(
  data = df_PANAS,
  var = "PAminusNA_sum",
  scale_fn = function(x) (x + 50) / 100
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
    scale_fn = function(x) x / 7
  )
  
  extract_ar_results(
    fit = model_obj$fit,
    var = v,
    prefix = v
  )
})

# Join horizontally by Prolific.Id
mood_results <- reduce(mood_results_list, left_join, by = "Prolific.Id")

write_csv(panas_results,"~/Desktop/MoodInstability/moodVariability/data/var1_model_panas_results.csv")
write_csv(mood_results,"~/Desktop/MoodInstability/moodVariability/data/var1_model_task_results.csv")
