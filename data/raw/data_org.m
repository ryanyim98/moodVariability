clc;
clear;
cd ~/Desktop/MoodInstability/moodVariability/data;
%% load the param matrix (this takes a few min)
load('./bayes_model_params.mat'); 
load('./PANASPosMinNeg_modeldata_-10-10.mat'); %% PANAS model with a larger vmu range

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
Est_out = table('Size',[4*353 18],'VariableTypes',{'string','string','double','double','double','double','double','double','double','double','double',...
    'double','double','double','double','double','double','double'} ,...
    'VariableNames',{'id','run','mean_mu', 'mean_s', 'mean_vmu','mean5_mu', 'mean5_s', 'mean5_vmu','mean10_mu','mean10_s','mean10_vmu',...
    'mean5_kmu', 'mean10_kmu', 'mean5_vs', 'mean10_vs',...
    'last_mu','last_s','last_vmu'});

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
        mean_vmu = mean(temp_run_dat.vmuEst);

        mean5_s = mean(temp_run_dat.sEst(38:42,1));
        mean10_s = mean(temp_run_dat.sEst(33:42,1));

        %vmu kmu and vs
        temp_vmu = temp_run_dat.vmuEst;
        temp_kmu = temp_run_dat.kmuEst;
        temp_vs = temp_run_dat.vsEst;

        mean5_mu = mean(temp_mu(38:42,1));
        mean10_mu = mean(temp_mu(33:42,1));

        mean5_vmu = mean(temp_vmu(38:42,1));
        mean10_vmu = mean(temp_vmu(33:42,1));
        
        mean5_kmu = mean(temp_kmu(38:42,1));
        mean10_kmu = mean(temp_kmu(33:42,1));
        
        mean5_vs = mean(temp_vs(38:42,1));
        mean10_vs = mean(temp_vs(33:42,1));
        
        %make table
        temp_run_out = {temp_sub,temp_run,mean_mu, mean_s,mean_vmu,mean5_mu,mean5_s,mean5_vmu, mean10_mu,mean10_s,mean10_vmu, ...
            mean5_kmu, mean10_kmu, mean5_vs, mean10_vs,...
            temp_mu(42,1),temp_s(42,1),temp_vmu(42,1)};
%         temp_run_out = array2table(temp_run_out,'VariableNames',{'ID','mean_mu', 'mean_s', 'mean10_vmu', 'mean5_kmu', 'mean10_kmu', 'mean5_vs', 'mean10_vs'});
        Est_out(4*(i-1)+j,1:18) = temp_run_out;
    end
end
        
writetable(Est_out,'./apple_moodrate_params.csv');

%% PANAS

%variables we need: 
%muEst, sEst:averaged across whole run
%vmuEst, kmuEst, vsEst: take average of last 5

panas_type = {'pos','neg','posminusneg','posminusneg_hr'};
Est_out = table('Size',[length(panas_type)*sub_num 18],'VariableTypes',{'string','string','double','double','double','double','double','double','double','double','double',...
    'double','double','double','double','double','double','double'} ,...
    'VariableNames',{'id','panas_type','mean_mu', 'mean_s', 'mean_vmu','mean5_mu', 'mean5_s', 'mean5_vmu','mean10_mu','mean10_s','mean10_vmu',...
    'mean5_kmu', 'mean10_kmu', 'mean5_vs', 'mean10_vs',...
    'last_mu','last_s','last_vmu'});

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
        mean_vmu = mean(temp_sub_dat.vmuEst);

        mean5_s = mean(temp_sub_dat.sEst(38:42,1));
        mean10_s = mean(temp_sub_dat.sEst(33:42,1));

        %vmu kmu and vs
        temp_vmu = temp_sub_dat.vmuEst;
        temp_kmu = temp_sub_dat.kmuEst;
        temp_vs = temp_sub_dat.vsEst;

        mean5_mu = mean(temp_mu(38:42,1));
        mean10_mu = mean(temp_mu(33:42,1));

        mean5_vmu = mean(temp_vmu(38:42,1));
        mean10_vmu = mean(temp_vmu(33:42,1));
        
        mean5_kmu = mean(temp_kmu(38:42,1));
        mean10_kmu = mean(temp_kmu(33:42,1));
        
        mean5_vs = mean(temp_vs(38:42,1));
        mean10_vs = mean(temp_vs(33:42,1));
        
        %make table
        temp_run_out = {temp_sub,temp_panas_type,mean_mu, mean_s,mean_vmu,mean5_mu,mean5_s,mean5_vmu, mean10_mu,mean10_s,mean10_vmu, ...
            mean5_kmu, mean10_kmu, mean5_vs, mean10_vs,...
            temp_mu(42,1),temp_s(42,1),temp_vmu(42,1)};
%         temp_run_out = array2table(temp_run_out,'VariableNames',{'ID','mean_mu', 'mean_s', 'mean10_vmu', 'mean5_kmu', 'mean10_kmu', 'mean5_vs', 'mean10_vs'});
        Est_out(4*(i-1)+j,1:18) = temp_run_out;
    end
end
        
writetable(Est_out,'./ema_panas_params.csv');