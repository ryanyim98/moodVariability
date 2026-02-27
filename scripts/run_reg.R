db_list <- c("day1_block1","day1_block2","day2_block1","day2_block2")

#This is the part with only binary outcome
df_Xs_scaled_all <-  data.frame() #standardized coefs
df_betas_scaled_all <- data.frame() #raw coefs

#make the df
for (l in 1:4){
  db <- db_list[l]
  print(paste0("printing ",db))
  df_all_subs_scaled <- data.frame()
  
  df_Xs_scaled <- matrix(NA,nsub,5)
  colnames(df_Xs_scaled) <- c('day_block','Participant.Public.ID','X1','X2','X3')
  
  df_betas_scaled <- matrix(NA,nsub,12)
  colnames(df_betas_scaled) <- c('day_block','Participant.Public.ID',
                                 'beta_intercept',paste0('beta_outcome_',1:9))
  
  for (m in 1:nsub){
    temp_participant_id <- sub_list[m]
    
    df_Xs_scaled[m,1] <- db
    df_betas_scaled[m,1] <- db
    df_Xs_scaled[m,2] <- temp_participant_id
    df_betas_scaled[m,2] <- temp_participant_id
    
    temp_df = df_reg%>%
      filter(Participant.Public.ID == temp_participant_id, day_block == db,
             Mood.Index!=0)
 
    #fit linear model to this participant's data
    if(nrow(temp_df) > 0 & prod(is.na(temp_df$moodrate_scaled)) != 1 #not all NAs
       & length(unique(temp_df$moodrate_scaled)) > 1){
      # temp_mod <- lm(scale(moodrate) ~ scale(outcome1b) + scale(outcome2b) + scale(outcome3b) + scale(outcome4b) + scale(outcome5b) + scale(outcome6b) + scale(outcome7b) + scale(outcome8b) + scale(outcome9b),data = temp_df)
      temp_mod <- lm(moodrate ~ outcome1b + outcome2b + outcome3b + outcome4b + outcome5b + outcome6b + outcome7b + outcome8b + outcome9b,data = temp_df)
      
      df_coeff = as.data.frame(temp_mod$coefficients) #standardized coefficients but it does not matter
      df_betas_scaled[m, 3:ncol(df_betas_scaled)] <- t(df_coeff)
      #update df_Xs_scaled
      for (k in 1:3){ #X1-X7, each is the average of 3 betas
        temp_outcome = df_coeff[(3*k-1):(3*k+1),1]
        df_Xs_scaled[m, k+2] <- mean(temp_outcome)
      } #else just leave it as NAs in df_Xs_scaled
    }else{
      print(paste0("subject ",temp_participant_id," has only 1 rating value, ",unique(temp_df$moodrate)))
    }
  }
  
  #write files for each block
  df_Xs_scaled <- as.data.frame(df_Xs_scaled)
  df_Xs_scaled[, 3:ncol(df_Xs_scaled)] <- sapply(df_Xs_scaled[, 3:ncol(df_Xs_scaled)], as.numeric)
  df_Xs_scaled_all <- rbind(df_Xs_scaled_all,df_Xs_scaled)
  
  df_betas_scaled <- as.data.frame(df_betas_scaled)
  df_betas_scaled[, 3:ncol(df_betas_scaled)] <- sapply(df_betas_scaled[, 3:ncol(df_betas_scaled)], as.numeric)
  df_betas_scaled_all <- rbind(df_betas_scaled_all,df_betas_scaled)
  
}

df_Xs_scaled_all <- df_Xs_scaled_all %>% 
  filter(day_block %in% c("day1_block1","day2_block1")) %>% 
  group_by(Participant.Public.ID) %>% 
  summarise(X1 = mean(X1,na.rm = T),
            X2 = mean(X2,na.rm = T),
            X3 = mean(X3,na.rm = T)) 

df_Xs_scaled_all_long <- df_Xs_scaled_all%>% 
  pivot_longer(X1:X3,names_to = "regression_coef", values_to = "value")


#This is the part with outcome magnitude
df_Xs_scaled_all2 <-  data.frame()
df_betas_scaled_all2 <- data.frame()

for (l in 1:4){
  db <- db_list[l]
  print(paste0("printing ",db))
  df_all_subs_scaled <- data.frame()
  
  df_Xs_scaled <- matrix(NA,nsub,8)
  colnames(df_Xs_scaled) <- c('day_block','Participant.Public.ID','X1','X2','X3','X1m','X2m','X3m')
  
  for (m in 1:nsub){
    temp_participant_id <- sub_list[m]
    
    df_Xs_scaled[m,1] <- db
    df_betas_scaled[m,1] <- db
    df_Xs_scaled[m,2] <- temp_participant_id
    df_betas_scaled[m,2] <- temp_participant_id
    
    temp_df = df_reg%>%
      filter(Participant.Public.ID == temp_participant_id, day_block == db,
             Mood.Index!=0)
    
    #fit linear model to this participant's data
    if(nrow(temp_df) > 0 & prod(is.na(temp_df$moodrate_scaled)) != 1# are all NAs
       & length(unique(temp_df$moodrate_scaled)) > 1){
      temp_mod <- lm(moodrate ~  outcome1bo + outcome2bo + outcome3bo + outcome4bo + outcome5bo + outcome6bo + outcome7bo + outcome8bo + outcome9bo + outcome_mag1b + outcome_mag2b + outcome_mag3b + outcome_mag4b + outcome_mag5b + outcome_mag6b + outcome_mag7b + outcome_mag8b + outcome_mag9b,data = temp_df)
      
      df_coeff = as.data.frame(temp_mod$coefficients) #standardized coefficients but it does not matter
      #update df_Xs_scaled
      for (k in 1:6){ #X1-X9, each is the average of 3 betas
        temp_outcome = df_coeff[(3*k-1):(3*k+1),1]
        df_Xs_scaled[m, k+2] <- mean(temp_outcome)
      } #else just leave it as NAs in df_Xs_scaled
    } else{
      print(paste0("subject ",temp_participant_id," has only 1 rating value, ",unique(temp_df$moodrate)))
    }
  }
  
  #write files for each block
  df_Xs_scaled <- as.data.frame(df_Xs_scaled)
  df_Xs_scaled[, 3:ncol(df_Xs_scaled)] <- sapply(df_Xs_scaled[, 3:ncol(df_Xs_scaled)], as.numeric)
  df_Xs_scaled_all2 <- rbind(df_Xs_scaled_all2,df_Xs_scaled)
  
  df_betas_scaled <- as.data.frame(df_betas_scaled)
  df_betas_scaled[, 3:ncol(df_betas_scaled)] <- sapply(df_betas_scaled[, 3:ncol(df_betas_scaled)], as.numeric)
  df_betas_scaled_all2 <- rbind(df_betas_scaled_all2,df_betas_scaled)
  
}

#take the average between two days -- this will increase the # of obs because some people have 1 rating across the entire block
df_Xs_scaled_all2 <- df_Xs_scaled_all2 %>% 
  filter(day_block %in% c("day1_block1","day2_block1")) %>% 
  group_by(Participant.Public.ID) %>% 
  summarise(X1o = mean(X1,na.rm = T),
            X2o = mean(X2,na.rm = T),
            X3o = mean(X3,na.rm = T),
            X1mo = mean(X1m,na.rm = T),
            X2mo = mean(X2m,na.rm = T),
            X3mo = mean(X3m,na.rm = T)) 

df_Xs_scaled_all2_long <- df_Xs_scaled_all2%>% 
  pivot_longer(X1o:X3mo,names_to = "regression_coef", values_to = "value")

df_master <- left_join(df_master,df_Xs_scaled_all %>% 
                         rename(Prolific.Id = Participant.Public.ID), by = "Prolific.Id")

df_master <- left_join(df_master,df_Xs_scaled_all2 %>% 
                         rename(Prolific.Id = Participant.Public.ID), by = "Prolific.Id")
