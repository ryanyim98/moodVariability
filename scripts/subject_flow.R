subj_baseline_q<-read_csv("./data/raw/baseline_questionnaires.csv")$Last.Name
n_subj_baseline_q <- length(unique(subj_baseline_q))

subj_panas_q<-read_csv("./data/raw/ema_panas_sf.csv")
subj_panas_q <- subj_panas_q %>% 
  group_by(`Last Name`) %>% 
  count()%>% drop_na()

subj_panas <- subj_panas_q$`Last Name` 

n_subj_panas_q <- length(unique(subj_panas_q$`Last Name`))
n_subj_panas_q_included <- length(unique(subj_panas_q$`Last Name`[subj_panas_q$n >= 90]))
subj_panas_q_included <- unique(subj_panas_q$`Last Name`[subj_panas_q$n >= 90])

subj_rl1<-read_csv("./data/raw/apple_d1b2.csv")
subj_rl2<-read_csv("./data/raw/apple_d2b2.csv")

n_subj_rl1 <- length(unique(subj_rl1$`Participant Private ID`))
n_subj_rl2 <- length(unique(subj_rl2$`Participant Private ID`))

subj_rl <- intersect(unique(subj_rl1$`Participant Public ID`),unique(subj_rl2$`Participant Public ID`))


subj_rl_panas<-Reduce(intersect, list(subj_rl,subj_panas_q_included))

subj_rl_exclude <- subj_exclude_novariance %>% group_by(Participant.Public.ID) %>% 
  count() %>% 
  filter(n>1)
subj_rl_exclude <- subj_rl_exclude$Participant.Public.ID

subj_rl_panas_included<-setdiff(subj_rl_panas,subj_rl_exclude)
