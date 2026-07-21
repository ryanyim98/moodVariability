# Purpose: helper functions for run_var1model.R.
# fit_ar1_model(): fits a per-subject Bayesian AR(1) model with random slopes and a
#   subject-varying residual (sigma) via brms, on a single mood/affect variable.
# extract_ar_results(): pulls per-subject AR(1) coefficient, innovation SD/variance,
#   and implied stationary mean out of a fitted model, named with a `prefix`.
# No file I/O -- both operate purely on in-memory data/model objects.

fit_ar1_model <- function(data, var, scale_fn = NULL) {
  
  lag_var <- paste0(var, "_lag")
  
  df <- data %>%
    filter(Prolific.Id %in% df_master$Prolific.Id) %>%
    arrange(Prolific.Id, Trigger.Index) %>%
    group_by(Prolific.Id) %>%
    {
      if (!is.null(scale_fn)) mutate(., !!var := scale_fn(.data[[var]]))
      else .
    } %>%
    mutate(!!lag_var := lag(.data[[var]])) %>%
    ungroup() %>%
    drop_na(all_of(c(var, lag_var)))
  
  model_formula <- bf(
    as.formula(
      paste0(var,
             " ~ 1 + ", lag_var,
             " + (1 + ", lag_var, " | Prolific.Id)")
    ),
    sigma ~ 1 + (1 | Prolific.Id)
  )
  
  fit <- brm(
    formula = model_formula,
    data = df,
    family = gaussian(),
    prior = c(
      prior(normal(0, 1), class = "b"),
      prior(cauchy(0, 1), class = "sd")
    ),
    chains = 4,
    iter = 2000,
    warmup = 1000,
    cores = 4,
    control = list(adapt_delta = 0.95),
    seed = 996
  )
  
  list(fit = fit, data = df)
}


extract_ar_results <- function(fit, var, prefix) {
  
  lag_var <- paste0(var, "_lag")
  re <- ranef(fit)$Prolific.Id
  
  # --- AR coefficient ---
  fixef_ar <- fixef(fit)[lag_var, "Estimate"]
  random_ar <- re[, "Estimate", lag_var]
  
  AR1_subject <- fixef_ar + random_ar
  
  AR_df <- tibble(
    Prolific.Id = rownames(re),
    !!paste0(prefix, "_AR1") := AR1_subject
  )
  
  # --- Innovation scale (sigma) and variance ---
  # In brms, sigma is modeled on the log scale by default (log-link),
  # so the linear predictor is log(sigma).
  fixef_sigma <- fixef(fit, dpar = "sigma")["Intercept", "Estimate"]
  random_sigma <- re[, "Estimate", "sigma_Intercept"]
  
  log_sigma_subject <- fixef_sigma + random_sigma
  sigma_subject <- exp(log_sigma_subject)
  var_subject <- sigma_subject^2
  log_var_subject <- 2 * log_sigma_subject
  
  sigma_df <- tibble(
    Prolific.Id = rownames(re),
    !!paste0(prefix, "_LOGSIGMA") := log_sigma_subject,
    !!paste0(prefix, "_SIGMA") := sigma_subject,
    !!paste0(prefix, "_LOGVAR") := log_var_subject,
    !!paste0(prefix, "_VAR") := var_subject
  )

  # --- Subject-specific mean of the AR(1) process ---
  fixef_intercept <- fixef(fit)["Intercept", "Estimate"]
  random_intercept <- re[, "Estimate", "Intercept"]
  
  intercept_subject <- fixef_intercept + random_intercept
  mean_subject <- intercept_subject / (1 - AR1_subject)
  
  mean_df <- tibble(
    Prolific.Id = rownames(re),
    !!paste0(prefix, "_MEAN") := mean_subject
  )
  
  AR_df %>%
    left_join(sigma_df, by = "Prolific.Id") %>%
    left_join(mean_df, by = "Prolific.Id")
}
