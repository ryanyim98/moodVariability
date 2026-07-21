%% run model
% Purpose: sensitivity-analysis summary for the EMA filter fit that excludes
% "close" (rushed) survey responses -- builds mean/mean5/mean10/last summary stats
% per subject from an already-fitted model.
% Inputs (raw model output, not shared):
%   <repo_root>/data/raw/raw_mat/PANASPosMinNeg_noCloseResponse_modeldata.mat
%   (written automatically by run_model_PANASPosMinNeg.m below -- no manual
%   save/rename step needed anymore).
% Outputs: <repo_root>/data/ema_panas_params_noCloseResponse.csv (also copied by hand
%   into osf_data_and_scripts/data/ -- this is the one shared-data file not produced
%   by any script in this OSF package)
%
% Needs raw model output that is not included in this package -- see the README.

data = load('~/Desktop/MoodInstability/moodVariability/osf_data_and_scripts/data/raw_mat/PANASPosMinNegFrMod_noCloseResponse_anonymized.mat').df_PANAS_out;
modelout = run_model_PANASPosMinNeg(data,5,'PANASPosMinNeg_noCloseResponse');
%% load data
clear all; clc;
script_dir = "~/Desktop/MoodInstability/moodVariability/osf_data_and_scripts/scripts/01_bayesian_filter"; % EDIT: path to this folder on your machine
addpath(script_dir);
repo_root = find_repo_root(script_dir);
data_dir = fullfile(repo_root,"data");
raw_mat_dir = fullfile(repo_root,"data","raw","raw_mat");
cd(data_dir);
load(fullfile(raw_mat_dir,'PANASPosMinNeg_noCloseResponse_modeldata.mat'))
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
writetable(Est_out,fullfile(data_dir,'ema_panas_params_noCloseResponse.csv'));