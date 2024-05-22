clc;
clear;
cd /Users/rh/Desktop/MoodInstability/moodVariability/data;
%% load the param matrix (this takes a few min)
load('./raw/bayes_model_params.mat'); %orig mat with the smaller range of PANAS vmu
load('./raw/PANASPosMinNeg_modeldata_-10-10.mat');  %load the model with vmu range 1e-7~10

%%
for i=1:length(Md_Inst_Struct)
    Md_Inst_Struct(i).PANASMod_POSMINNEG_largeVar=out(i);  
end
%% The gorilla part
sub_num = numel(Md_Inst_Struct);

for i = 1:sub_num
    sub_id{i} = char(Md_Inst_Struct(i).PANAS.ProlifID);
end

%
%variables we need: 
%muEst, sEst:averaged across whole run
%vmuEst, kmuEst, vsEst: take average of last 5

run = {'d1r1','d1r2','d2r1','d2r2'};
Est_out = table('Size',[4*353 11],'VariableTypes',{'string','string','double','double','double','double','double','double','double','double','double'} ,'VariableNames',{'id','run','mean_mu', 'mean_s', 'mean5_s', 'mean5_vmu','mean10_vmu','mean5_kmu', 'mean10_kmu', 'mean5_vs', 'mean10_vs'});

for i = 1:sub_num %loop through N = 353 subjects
    temp_sub = char(sub_id(i));
    temp_sub_dat = Md_Inst_Struct(i).GorillaModel;
    
    for j = 1:4
        temp_run = char(run(j));
        temp_run_dat = temp_sub_dat.(temp_run).moddata;
        
        %mu and s
        temp_mu = temp_run_dat.muEst;
        temp_s = temp_run_dat.sEst;
        
        mean_mu = mean(temp_run_dat.muEst);
        mean_s = mean(temp_run_dat.sEst);
        mean5_s = mean(temp_run_dat.sEst(38:42,1));
        
        %vmu kmu and vs
        temp_vmu = temp_run_dat.vmuEst;
        temp_kmu = temp_run_dat.kmuEst;
        temp_vs = temp_run_dat.vsEst;
        
        mean5_vmu = mean(temp_vmu(38:42,1));
        mean10_vmu = mean(temp_vmu(33:42,1));
        
        mean5_kmu = mean(temp_kmu(38:42,1));
        mean10_kmu = mean(temp_kmu(33:42,1));
        
        mean5_vs = mean(temp_vs(38:42,1));
        mean10_vs = mean(temp_vs(33:42,1));
        
        %make table
        temp_run_out = {temp_sub,temp_run,mean_mu, mean_s,mean5_s,mean5_vmu, mean10_vmu, mean5_kmu, mean10_kmu, mean5_vs, mean10_vs};
%         temp_run_out = array2table(temp_run_out,'VariableNames',{'ID','mean_mu', 'mean_s', 'mean10_vmu', 'mean5_kmu', 'mean10_kmu', 'mean5_vs', 'mean10_vs'});
        Est_out(4*(i-1)+j,1:11) = temp_run_out;
    end
end
        
writetable(Est_out,'./apple_moodrate_params.csv');

%% PANAS

%variables we need: 
%muEst, sEst:averaged across whole run
%vmuEst, kmuEst, vsEst: take average of last 5

panas_type = {'pos','neg','posminusneg','posminusneg_hr'};
Est_out = table('Size',[length(panas_type)*sub_num 11],'VariableTypes',{'string','string','double','double','double','double','double','double','double','double','double'} ,'VariableNames',{'id','panas_type','mean_mu', 'mean_s','mean5_s', 'mean5_vmu','mean10_vmu', 'mean5_kmu', 'mean10_kmu', 'mean5_vs', 'mean10_vs'});

for i = 1:sub_num %loop through N = 353 subjects
    temp_sub = char(sub_id(i));
    
    for j = 1:length(panas_type)
        if j == 1
            temp_sub_dat = Md_Inst_Struct(i).PANASMod_POS.moddata;
        elseif j == 2
            temp_sub_dat = Md_Inst_Struct(i).PANASMod_NEG.moddata;
        elseif j == 3
            temp_sub_dat = Md_Inst_Struct(i).PANASMod_POSMINNEG.moddata;
        elseif j == 4
            temp_sub_dat = Md_Inst_Struct(i).PANASMod_POSMINNEG_largeVar.moddata;
        end
        temp_panas_type = char(panas_type(j));
        
        %mu and s
        temp_mu = temp_sub_dat.muEst;
        temp_s = temp_sub_dat.sEst;
        
        mean_mu = mean(temp_sub_dat.muEst);
        mean_s = mean(temp_sub_dat.sEst);
        mean5_s = mean(temp_sub_dat.sEst((length(temp_vmu)-4):length(temp_vmu),1));
        
        %vmu kmu and vs
        temp_vmu = temp_sub_dat.vmuEst;
        temp_kmu = temp_sub_dat.kmuEst;
        temp_vs = temp_sub_dat.vsEst;
        
        mean5_vmu = mean(temp_vmu((length(temp_vmu)-4):length(temp_vmu),1));
        mean10_vmu = mean(temp_vmu((length(temp_vmu)-9):length(temp_vmu),1));
        
        mean5_kmu = mean(temp_kmu((length(temp_kmu)-4):length(temp_kmu),1));
        mean10_kmu = mean(temp_kmu((length(temp_kmu)-9):length(temp_kmu),1));
        
        mean5_vs = mean(temp_vs((length(temp_vs)-4):length(temp_vs),1));
        mean10_vs = mean(temp_vs((length(temp_vs)-9):length(temp_vs),1));
        
        %make table
        temp_run_out = {temp_sub,temp_panas_type,mean_mu, mean_s,mean5_s,mean5_vmu, mean10_vmu, mean5_kmu, mean10_kmu, mean5_vs, mean10_vs};
%         temp_run_out = array2table(temp_run_out,'VariableNames',{'ID','mean_mu', 'mean_s', 'mean10_vmu', 'mean5_kmu', 'mean10_kmu', 'mean5_vs', 'mean10_vs'});
        Est_out(length(panas_type)*(i-1)+j,1:11) = temp_run_out;
    end
end
        
writetable(Est_out,'./ema_panas_params.csv');