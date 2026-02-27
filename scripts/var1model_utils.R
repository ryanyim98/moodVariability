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
  
  AR_df <- tibble(
    Prolific.Id = rownames(re),
    !!paste0(prefix, "_AR1") := fixef_ar + random_ar
  )
  
  # --- Innovation variance ---
  fixef_sigma <- fixef(fit, dpar = "sigma")["Intercept", "Estimate"]
  random_sigma <- re[, "Estimate", "sigma_Intercept"]
  
  sigma_df <- tibble(
    Prolific.Id = rownames(re),
    !!paste0(prefix, "_VAR") :=
      exp(fixef_sigma + random_sigma)^2
  )
  
  left_join(AR_df, sigma_df, by = "Prolific.Id")
}


extract_ar_results <- function(fit, var, prefix) {
  
  lag_var <- paste0(var, "_lag")
  re <- ranef(fit)$Prolific.Id
  
  # --- AR coefficient ---
  fixef_ar <- fixef(fit)[lag_var, "Estimate"]
  random_ar <- re[, "Estimate", lag_var]
  
  AR_df <- tibble(
    Prolific.Id = rownames(re),
    !!paste0(prefix, "_AR1") := fixef_ar + random_ar
  )
  
  # --- Innovation variance ---
  fixef_sigma <- fixef(fit, dpar = "sigma")["Intercept", "Estimate"]
  random_sigma <- re[, "Estimate", "sigma_Intercept"]
  
  sigma_df <- tibble(
    Prolific.Id = rownames(re),
    !!paste0(prefix, "_VAR") :=
      exp(fixef_sigma + random_sigma)^2
  )
  
  left_join(AR_df, sigma_df, by = "Prolific.Id")
}
