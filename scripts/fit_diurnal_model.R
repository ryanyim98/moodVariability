# fitting diurnal model to PANAS data
df_PANAS_forlm <- df_PANAS%>%
  dplyr::select(Prolific.Id, PA_sum, NA_sum, day_index, time_index) %>%
  group_by(Prolific.Id) %>%
  mutate(PA_sum_scaled = as.numeric(scale(PA_sum)),
         NA_sum_scaled = as.numeric(scale(NA_sum)),
         NA_sum_scaled = ifelse(is.na(NA_sum_scaled),
                                0, NA_sum_scaled)) #1 participant has all 10s

#-----------the essential lmer loop-----------
df_lm_sum <- data.frame()

for (k in 1:length(unique(df_PANAS_forlm$Prolific.Id))){
  if (k == floor(length(unique(df_PANAS_forlm$Prolific.Id))/2)){
    print("=====50%======")
  } else if (k == length(unique(df_PANAS_forlm$Prolific.Id))){
    print("=====100%======")
  }
  temp_id = unique(df_PANAS_forlm$Prolific.Id)[k]
  df_lm_temp <- df_PANAS_forlm%>%
    filter(Prolific.Id == temp_id)
  #fit a mixed effect model to a single participant's data
  ##  PA
  #According to past literature, use quadratic term
  # mixed.lme_PA_temp <-lmer(PA_sum_scaled ~ I(time_index^2) + time_index +(1|day_index),data=df_lm_temp)
  mixed.lme_PA_temp <-lm(PA_sum_scaled ~ I(time_index^2) + time_index,data=df_lm_temp)
  lmPA <-  summary(mixed.lme_PA_temp)
  
  # #predicted value
  # df_lm_temp1 <- df_lm_temp %>%
  # mutate(PA_pred_val = fitted(mixed.lme_PA_temp), PA_res = lmPA$residuals)
  
  # df_lmPA_sum_temp <- as.data.frame.array(lmPA$coefficients[,c(1,5)])
  df_lmPA_sum_temp <- as.data.frame.array(lmPA$coefficients[,c(1,4)])
  rownames(df_lmPA_sum_temp) <- c('Intercept','t^2','t')
  colnames(df_lmPA_sum_temp) <- c('Estimate','pValue')
  df_lmPA_sum_temp <- tibble::rownames_to_column(df_lmPA_sum_temp, "TERM")%>%
    pivot_wider(names_from = TERM, names_glue = "{TERM}_{.value}", values_from = c('Estimate','pValue'))%>%
    mutate(Prolific.Id = temp_id,
           model = "PA") %>%
    relocate(Prolific.Id)
  df_lmPA_sum_temp <- cbind(df_lmPA_sum_temp,r.squaredGLMM(mixed.lme_PA_temp))
  
  # p1 <- ggplot(data=df_lm_temp)+
  #   geom_line(aes(x=time_index, y=PA_pred_val,
  #               group=day_index)) +
  #   theme_classic()+
  #   stat_summary(aes(x=time_index, y=PA_pred_val,group = 1), color = "red")+
  #   labs(title = paste0('predicted PA value for participant ',temp_id),
  #        y = 'PA (predicted)', x = 'time of day')
  # p1
  # # ggsave(paste0(pic_outdir,'predicted_PA_',temp_id,'.png'), plot = p1)
  #
  # #residual
  # p2 <- ggplot(data=df_lm_temp, aes(x=time_index, y=abs(PA_res),
  #                  group=day_index)) +
  #   geom_line()+
  #   stat_summary(aes(group = 1), color = "red")+
  #   theme_classic()+
  #   labs(title = paste0('Absolute residual PA for participant ',temp_id),
  #        y = 'PA residual', x = 'time of day')
  # p2
  # # ggsave(paste0(pic_outdir,'residual_PA_',temp_id,'.png'), plot = p2)
  
  #intercept
  # p3 <- ggplot(data=df_lm_temp%>%filter(time_index==3), aes(x=day_index, y=PA_pred_val,group=1)) +
  #   geom_line(linetype = "dashed")+
  #   theme_classic()+
  # labs(title = paste0('PA intercept at time 3 for participant ',temp_id),
  #      y = 'PA intercept', x = 'day index')
  # ggsave(paste0(pic_outdir,'intercept3_PA_',temp_id,'.png'), plot = p3)
  #
  #
  ##  NA
  if (temp_id != "5cb20f2d7c917b00172dfef5"){
    #According to past literature, use quadratic term
    # mixed.lme_NA_temp <-lmer(NA_sum_scaled ~ I(time_index^2) + time_index +(1|day_index),data=df_lm_temp) 
    mixed.lme_NA_temp <-lm(NA_sum_scaled ~ I(time_index^2) + time_index,data=df_lm_temp) 
    lmNA <- summary(mixed.lme_NA_temp)
    
    #store model output in a data frame
    df_lmNA_sum_temp <- as.data.frame.array(lmNA$coefficients[,c(1,4)])
    rownames(df_lmNA_sum_temp) <- c('Intercept','t^2','t')
    colnames(df_lmNA_sum_temp) <- c('Estimate','pValue')
    df_lmNA_sum_temp <- tibble::rownames_to_column(df_lmNA_sum_temp, "TERM")%>%
      pivot_wider(names_from = TERM, names_glue = "{TERM}_{.value}", values_from = c('Estimate','pValue'))%>%
      mutate(Prolific.Id = temp_id,
             model = "NA")%>%
      relocate(Prolific.Id)
    df_lmNA_sum_temp <- cbind(df_lmNA_sum_temp,r.squaredGLMM(mixed.lme_NA_temp))
    #update df_lm_sum
    df_lm_sum_temp <- rbind(df_lmPA_sum_temp, df_lmNA_sum_temp)
  } else {
    #update df_lm_sum
    df_lm_sum_temp <- df_lmPA_sum_temp
  }
  
  # p4 <- ggplot(data=df_lm_temp)+
  #   geom_line(aes(x=time_index, y=NA_pred_val,
  #               group=day_index, color=as.factor(day_index))) +
  #   theme_classic()+
  #   labs(title = paste0('predicted NA value for participant ',temp_id),
  #        y = 'NA (predicted)', x = 'time of day')
  # # ggsave(paste0(pic_outdir,'predicted_NA_',temp_id,'.png'), plot = p4)
  #
  # #residual
  # p5 <- ggplot(data=df_lm_temp, aes(x=time_index, y=abs(NA_res),
  #                  group=day_index, color=as.factor(day_index))) +
  #   geom_line()+
  #   stat_smooth(aes(group = 1))+
  #   stat_summary(aes(group = 1), geom = "point", fun.y = mean,
  #                shape = 17, size = 3)+
  #   theme_classic()+
  #   labs(title = paste0('Absolute residual NA for participant ',temp_id),
  #        y = 'NA residual', x = 'time of day')
  # ggsave(paste0(pic_outdir,'residual_NA_',temp_id,'.png'), plot = p5)
  #
  # #intercept
  # p6 <- ggplot(data=df_lm_temp%>%filter(time_index==3), aes(x=day_index, y=NA_pred_val,group=1)) +
  #   geom_line(linetype = "dashed")+
  #   theme_classic()+
  # labs(title = paste0('NA intercept at time 3 for participant ',temp_id),
  #      y = 'NA intercept', x = 'day index')
  # # ggsave(paste0(pic_outdir,'intercept3_NA_',temp_id,'.png'), plot = p6)
  
  # #update df_lm_PANAS
  # df_lm_PANAS <- rbind(df_lm_PANAS,df_lm_temp)
  #
  df_lm_sum <- rbind(df_lm_sum, df_lm_sum_temp)
}

# write documents
write.csv(df_lm_sum,paste(outdir, 'panas_lm_params.csv'))
