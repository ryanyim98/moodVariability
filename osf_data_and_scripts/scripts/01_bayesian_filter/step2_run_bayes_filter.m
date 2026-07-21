% Purpose: top-level driver for the Bayesian filter fit -- runs the filter on the
% EMA (PANAS pos-minus-neg series, twice -- default vmu range, and again with a
% wider vmu lower bound; plus the PANAS pos-only and neg-only series), on each
% of the 4 individual RL-task runs, and on the 2 whole-day RL-task series (each
% day's 2 runs concatenated end-to-end, then filtered as one series -- matching
% the original pipeline's ParseGorillaModel.m/GorillaModelStruct(i).d1/.d2,
% found in "Paper Material for Ryan"/AppleTask_scripts_1/).
% Inputs: osf_data_and_scripts/data/raw_mat/RawData_anonymized.mat,
%   .../PANASPosMinNegFrMod_anonymized.mat, .../PANASfrBaysMod_anonymized.mat --
%   de-identified copies produced by step1_anonymize_raw_data.m, shipped inside
%   this OSF package. Only the participant-identifier fields differ from the
%   private originals (data/raw/raw_mat/RawData.mat etc.); all rating/choice/timing
%   data is untouched, so results are identical either way. This step is now
%   fully self-contained within osf_data_and_scripts/ -- no access to the
%   private data/raw/ folder needed.
% Calls: Gor_Md_mat_fr_Model.m, run_model_PANASPosMinNeg.m, run_model_Gorilla.m
%   (-> maglearn_func_vardiff_flat_miss.m). Saving of *_modeldata.mat output is
%   delegated to those functions, which write to
%   <repo_root>/data/raw/raw_mat/<name>_modeldata.mat (the private raw-data
%   folder, outside this OSF package). Names are passed explicitly below
%   (PANASMod_POSMINNEG, PANASMod_POSMINNEG_largeVar, PANASMod_POS,
%   PANASMod_NEG, GorillaModel_d1r1/d1r2/d2r1/d2r2/d1/d2) rather than left to
%   default to a timestamp, so this script can find each file deterministically
%   afterward. At the end, this script copies all 10 of those raw outputs into
%   osf_data_and_scripts/data/raw_mat/<name>_modeldata_anonymized.mat too --
%   safe to do since every fit above ran on already-anonymized input, so these
%   contain no identifiers either. That's what lets
%   step3_assemble_bayes_model_params.m run entirely from what's shipped in
%   this package, without touching the private repo at all.

clear; clc;
script_dir = "~/Desktop/MoodInstability/moodVariability/osf_data_and_scripts/scripts/01_bayesian_filter";
addpath(script_dir);
pkg_root = fullfile(fileparts(fileparts(script_dir))); % .../scripts/01_bayesian_filter -> osf_data_and_scripts
raw_mat_dir = fullfile(pkg_root, "data", "raw_mat");
cd(pkg_root);

load(fullfile(raw_mat_dir,"RawData_anonymized.mat"),"Md_Inst_Struct");
%% run filter on PANAS data - PAminusNA
panas_data=load(fullfile(raw_mat_dir,"PANASPosMinNegFrMod_anonymized.mat"));

run_model_PANASPosMinNeg(panas_data.PANASPosMinNegFrMod,10,'PANASMod_POSMINNEG');%grid inputs from Mike
run_model_PANASPosMinNeg(panas_data.PANASPosMinNegFrMod,10,'PANASMod_POSMINNEG_largeVar',[1e-10 10]);%same series, wider vmu lower bound -- feeds Md_Inst_Struct(i).PANASMod_POSMINNEG_largeVar

%% run filter on PANAS data - pos-only and neg-only subscales
panas_posneg_data=load(fullfile(raw_mat_dir,"PANASfrBaysMod_anonymized.mat"));

run_model_PANASPosMinNeg(panas_posneg_data.PANASposFrMod,10,'PANASMod_POS',[],[10 50]);%pos subscale, range [10 50] not [-40 40] -- feeds Md_Inst_Struct(i).PANASMod_POS
run_model_PANASPosMinNeg(panas_posneg_data.PANASnegFrMod,10,'PANASMod_NEG',[],[10 50]);%neg subscale, same range -- feeds Md_Inst_Struct(i).PANASMod_NEG

%% run filter on RL task data
runs = {'d1r1','d1r2','d2r1','d2r2'};

[d1r1,d1r2,d2r1,d2r2] = Gor_Md_mat_fr_Model(Md_Inst_Struct);

for r = 1:4
    if r == 1
        run_model_Gorilla(d1r1,10,'GorillaModel_d1r1');
    elseif r == 2
        run_model_Gorilla(d1r2,10,'GorillaModel_d1r2');
    elseif r == 3
        run_model_Gorilla(d2r1,10,'GorillaModel_d2r1');
    else
        run_model_Gorilla(d2r2,10,'GorillaModel_d2r2');
    end
end

%% run filter on the 2 whole-day RL task series (both runs of a day, concatenated)
d1_whole = [d1r1, d1r2]; % day 1: run 1 then run 2, end-to-end
d2_whole = [d2r1, d2r2]; % day 2: run 1 then run 2, end-to-end

run_model_Gorilla(d1_whole,10,'GorillaModel_d1');
run_model_Gorilla(d2_whole,10,'GorillaModel_d2');

%% copy the raw model output into this OSF package too
% Every fit above ran on already-anonymized input (loaded from raw_mat_dir
% above), so these outputs carry no identifiers either -- copying them here
% is what lets step3_assemble_bayes_model_params.m run entirely from this
% package, instead of reaching into the private repo.
private_raw_mat_dir = fullfile(fileparts(pkg_root),"data","raw","raw_mat"); % .../osf_data_and_scripts -> repo_root, then data/raw/raw_mat
fit_names = {'PANASMod_POSMINNEG','PANASMod_POSMINNEG_largeVar','PANASMod_POS','PANASMod_NEG', ...
    'GorillaModel_d1r1','GorillaModel_d1r2','GorillaModel_d2r1','GorillaModel_d2r2', ...
    'GorillaModel_d1','GorillaModel_d2'};
for k = 1:numel(fit_names)
    src = fullfile(private_raw_mat_dir,[fit_names{k},'_modeldata.mat']);
    dst = fullfile(raw_mat_dir,[fit_names{k},'_modeldata_anonymized.mat']);
    copyfile(src,dst);
end