# running an autoregressive model (based on https://osf.io/zm6uw/)

###########################################
#########.   PANAS AR.  ###################
###########################################

AR_PANAS <- function(df, str) {
  
  # Ensure the dataframe is sorted by Prolific.Id and Trigger.Index
  df <- df %>% arrange(Prolific.Id, Trigger.Index)
  
  # Initialize
  idx1 <- 1:(nrow(df) - 1)
  idx2 <- 2:nrow(df)
  ui <- unique(df$Prolific.Id)
  S <- matrix(0, nrow = length(ui), ncol = length(str))
  L <- matrix(0, nrow = length(ui), ncol = length(str))
  names <- vector("list", length = length(str))
  
  # Center data by subject
  for (i in seq_along(ui)) {
    for (j in c("PA_sum", "NA_sum","PAminusNA_sum")) {
      idx <- which(df$Prolific.Id == ui[i] & !is.na(df[[j]]))
      temp <- mean(df[[j]][idx], na.rm = TRUE)
      df[[j]][idx] <- df[[j]][idx] - temp
    }
  }
  
  # Identify valid indices and fit AR model
  for (j in c("PA_sum", "NA_sum","PAminusNA_sum")) {
    for (i in seq_along(ui)) {
      idxUse <- which(!is.na(df[[j]][idx1]) & !is.na(df[[j]][idx2]) &
                        df$Prolific.Id[idx1] == ui[i] & df$Prolific.Id[idx2] == ui[i] &
                        df$Trigger.Index[idx2] == (df$Trigger.Index[idx1] + 1))
      L[i, which(c("PA_sum", "NA_sum","PAminusNA_sum") == j)] <- length(idxUse)
    }
    
    idx <- which(!is.na(df[[j]][idx1]) & !is.na(df[[j]][idx2]) &
                   df$Prolific.Id[idx1] == df$Prolific.Id[idx2] &
                   df$Trigger.Index[idx2] == (df$Trigger.Index[idx1] + 1))
    
    Xtrain <- cbind(1, df[[j]][idx1[idx]])
    Ytrain <- df[[j]][idx2[idx]]
    
    df_train <- data.frame(Y = Ytrain, X1 = Xtrain[, 1], X2 = Xtrain[, 2], subj = df$Prolific.Id[idx1[idx]]) #X1 is the intercept
    model <- lmer(Y ~ X2 + (X2 | subj), data = df_train)
    
    fixed_effects <- fixef(model)
    random_effects <- ranef(model)$subj[,2]
    params <- matrix(fixed_effects[2], nrow = length(ui), ncol = 1) + random_effects
    
    S[, which(c("PA_sum", "NA_sum","PAminusNA_sum") == j)] <- params
  }
  
  # Naming the coefficients
  base_str <- "AR_"
  for (j in 1:length(str)) {
    names[[j]] <- paste0(base_str, str[[j]])
  }
  
  list(S = S, names = names, ui = ui, L = L)
}

###########################################
#########.   task AR.  ####################
###########################################

AR_task <- function(df, str) {
  
  # Ensure the dataframe is sorted by Prolific.Id and Trigger.Index
  df <- df %>% arrange(Prolific.Id,Trigger.Index)
  
  # Initialize
  idx1 <- 1:(nrow(df) - 1)
  idx2 <- 2:nrow(df)
  ui <- unique(df$Prolific.Id)
  S <- matrix(0, nrow = length(ui), ncol = length(str))
  L <- matrix(0, nrow = length(ui), ncol = length(str))
  names <- vector("list", length = length(str))
  
  # Center data by subject
  for (i in seq_along(ui)) {
    for (j in c("day1_block1","day1_block2","day2_block1","day2_block2")) {
      idx <- which(df$Prolific.Id == ui[i] & !is.na(df[[j]]))
      temp <- mean(df[[j]][idx], na.rm = TRUE)
      df[[j]][idx] <- df[[j]][idx] - temp
    }
  }
  
  # Identify valid indices and fit AR model
  for (j in c("day1_block1","day1_block2","day2_block1","day2_block2")) {
    for (i in seq_along(ui)) {
      idxUse <- which(!is.na(df[[j]][idx1]) & !is.na(df[[j]][idx2]) &
                        df$Prolific.Id[idx1] == ui[i] & df$Prolific.Id[idx2] == ui[i] &
                        df$Trigger.Index[idx2] == (df$Trigger.Index[idx1] + 1))
      L[i, which(c("day1_block1","day1_block2","day2_block1","day2_block2") == j)] <- length(idxUse)
    }
    
    idx <- which(!is.na(df[[j]][idx1]) & !is.na(df[[j]][idx2]) &
                   df$Prolific.Id[idx1] == df$Prolific.Id[idx2] &
                   df$Trigger.Index[idx2] == (df$Trigger.Index[idx1] + 1))
    
    Xtrain <- cbind(1, df[[j]][idx1[idx]])
    Ytrain <- df[[j]][idx2[idx]]
    
    df_train <- data.frame(Y = Ytrain, X1 = Xtrain[, 1], X2 = Xtrain[, 2], subj = df$Prolific.Id[idx1[idx]]) #X1 is the intercept
    model <- lmer(Y ~ X2 + (X2 | subj), data = df_train)
    
    fixed_effects <- fixef(model)
    random_effects <- ranef(model)$subj[,2]
    params <- matrix(fixed_effects[2], nrow = length(ui), ncol = 1) + random_effects
    
    S[, which(c("day1_block1","day1_block2","day2_block1","day2_block2") == j)] <- params
  }
  
  # Naming the coefficients
  base_str <- "AR_"
  for (j in 1:length(str)) {
    names[[j]] <- paste0(base_str, str[[j]])
  }
  
  list(S = S, names = names, ui = ui, L = L)
}

