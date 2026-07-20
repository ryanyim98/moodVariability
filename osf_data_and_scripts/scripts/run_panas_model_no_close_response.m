%% run model
% data = load('raw/raw_mat/PANASPosMinNegFrMod_noCloseResponse.mat').df_PANAS_out;
% modelout = run_model_PANASPosMinNeg(data,5);

%% load data
clear all; clc;
cd /Users/yanyan/Desktop/MoodInstability/moodVariability/data;
load('./PANASPosMinNeg_modeldata_noCloseResponse.mat')
sub_num=size(data,1);

Est_out = table('Size',[sub_num 18],'VariableTypes',{'string','string','double','double','double','double','double','double','double','double','double',...
    'double','double','double','double','double','double','double'} ,...
    'VariableNames',{'id','panas_type','mean_mu', 'mean_s', 'mean_vmu','mean5_mu', 'mean5_s', 'mean5_vmu','mean10_mu','mean10_s','mean10_vmu',...
    'mean5_kmu', 'mean10_kmu', 'mean5_vs', 'mean10_vs',...
    'last_mu','last_s','last_vmu'});

temp_panas_type = 'posminusneg_noCloseResponse';
for i = 1:sub_num %loop through N = 332 subjects
    temp_sub_dat = out(i).moddata;
        
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
    temp_run_out = {i,temp_panas_type,mean_mu, mean_s,mean_vmu,mean5_mu,mean5_s,mean5_vmu, mean10_mu,mean10_s,mean10_vmu, ...
        mean5_kmu, mean10_kmu, mean5_vs, mean10_vs,...
        temp_mu(42,1),temp_s(42,1),temp_vmu(42,1)};
    %         temp_run_out = array2table(temp_run_out,'VariableNames',{'ID','mean_mu', 'mean_s', 'mean10_vmu', 'mean5_kmu', 'mean10_kmu', 'mean5_vs', 'mean10_vs'});
    Est_out(i,1:18) = temp_run_out;
end
% 
writetable(Est_out,'./ema_panas_params_noCloseResponse.csv');