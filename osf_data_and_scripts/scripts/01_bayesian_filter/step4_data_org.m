% Purpose: bridges the assembled, per-subject Md_Inst_Struct (all Bayesian Filter
% fits merged in by step3_assemble_bayes_model_params.m) to the summary CSVs that
% scripts/02_deidentify_raw_data/read_data_task_ema.Rmd actually reads:
% apple_moodrate_params.csv, apple_moodrate_params_wholeday.csv, ema_panas_params.csv.
% This is a REAL, currently-active dependency of the already-migrated R pipeline --
% it was previously undocumented and left at the repo's data/raw/ (a script,
% oddly filed among data).
% Inputs: osf_data_and_scripts/data/raw_mat/Gor_PANAS_Mod_Data_anonymized.mat
%   (produced by step3_assemble_bayes_model_params.m, which includes
%   .PANASMod_POS/.PANASMod_NEG as of step2_run_bayes_filter.m fitting those
%   two series).
% Outputs: <repo_root>/data/apple_moodrate_params.csv,
%   .../apple_moodrate_params_wholeday.csv, .../ema_panas_params.csv -- these
%   carry the ANONYMIZED subject number as their "id" column (matching
%   Gor_PANAS_Mod_Data_anonymized.mat's Md_Inst_Struct(i).PANAS.ProlifID).
%   read_data_task_ema.Rmd bridges that back to a real Prolific.Id via the
%   private data/raw/subject_id_crosswalk.csv before joining (see its
%   attach_prolific_id() helper) -- do not "fix" that by reverting this
%   script's input back to the private RawData.mat.
% Tier 1: fully reproducible from what's in this package, once
% step2_run_bayes_filter.m and step3_assemble_bayes_model_params.m have run.

clc;
clear;
script_dir = "~/Desktop/MoodInstability/moodVariability/osf_data_and_scripts/scripts/01_bayesian_filter"; % EDIT: path to this folder on your machine
addpath(script_dir);
repo_root = find_repo_root(script_dir);
pkg_root = fullfile(repo_root, "osf_data_and_scripts");
anonymized_raw_mat_dir = fullfile(pkg_root, "data", "raw_mat");
data_dir = fullfile(repo_root, "data");
cd(data_dir);

%% load the param matrix (this takes a few min)
% Includes PANASMod_POSMINNEG_largeVar, PANASMod_POS, and PANASMod_NEG already --
% assembled by step3_assemble_bayes_model_params.m from step2_run_bayes_filter.m's
% PANAS fits.
load(fullfile(anonymized_raw_mat_dir, "Gor_PANAS_Mod_Data_anonymized.mat"));

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
Est_out = table('Size',[4*sub_num 18],'VariableTypes',{'string','string','double','double','double','double','double','double','double','double','double',...
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
        
writetable(Est_out,fullfile(data_dir,'apple_moodrate_params.csv'));

%% gorilla (concatenated runs)
sub_num = numel(Md_Inst_Struct);

for i = 1:sub_num
    sub_id{i} = char(Md_Inst_Struct(i).PANAS.ProlifID);
end

%
%variables we need: 
%muEst, sEst:averaged across whole run
%vmuEst, kmuEst, vsEst: take average of last 5

run = {'d1','d2'};
Est_out = table('Size',[2*sub_num 18],'VariableTypes',{'string','string','double','double','double','double','double','double','double','double','double',...
    'double','double','double','double','double','double','double'} ,...
    'VariableNames',{'id','run','mean_mu', 'mean_s', 'mean_vmu','mean5_mu', 'mean5_s', 'mean5_vmu','mean10_mu','mean10_s','mean10_vmu',...
    'mean5_kmu', 'mean10_kmu', 'mean5_vs', 'mean10_vs',...
    'last_mu','last_s','last_vmu'});

for i = 1:sub_num %loop through N = 353 subjects
    temp_sub = char(sub_id(i));
    temp_sub_dat = Md_Inst_Struct(i).GorillaModel;
    
    for j = 1:2
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

        mean5_mu = mean(temp_mu(78:83,1));
        mean10_mu = mean(temp_mu(74:83,1));

        mean5_vmu = mean(temp_vmu(78:83,1));
        mean10_vmu = mean(temp_vmu(74:83,1));
        
        mean5_kmu = mean(temp_kmu(78:83,1));
        mean10_kmu = mean(temp_kmu(74:83,1));
        
        mean5_vs = mean(temp_vs(78:83,1));
        mean10_vs = mean(temp_vs(74:83,1));
        
        %make table
        temp_run_out = {temp_sub,temp_run,mean_mu, mean_s,mean_vmu,mean5_mu,mean5_s,mean5_vmu, mean10_mu,mean10_s,mean10_vmu, ...
            mean5_kmu, mean10_kmu, mean5_vs, mean10_vs,...
            temp_mu(83,1),temp_s(83,1),temp_vmu(83,1)};
%         temp_run_out = array2table(temp_run_out,'VariableNames',{'ID','mean_mu', 'mean_s', 'mean10_vmu', 'mean5_kmu', 'mean10_kmu', 'mean5_vs', 'mean10_vs'});
        Est_out(2*(i-1)+j,1:18) = temp_run_out;
    end
end
        
writetable(Est_out,fullfile(data_dir,'apple_moodrate_params_wholeday.csv'));

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
        
writetable(Est_out,fullfile(data_dir,'ema_panas_params.csv'));