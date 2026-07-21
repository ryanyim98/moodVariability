% Purpose: the missing "assembly" step called out in the OSF README's
% "Two-tier reproducibility" section -- merges the per-run Bayesian Filter
% fits that step2_run_bayes_filter.m copies into this package
% (PANASMod_POSMINNEG_modeldata_anonymized.mat,
% PANASMod_POSMINNEG_largeVar_modeldata_anonymized.mat,
% PANASMod_POS_modeldata_anonymized.mat, PANASMod_NEG_modeldata_anonymized.mat,
% GorillaModel_d1r1/d1r2/d2r1/d2r2_modeldata_anonymized.mat, and
% GorillaModel_d1/d2_modeldata_anonymized.mat -- the two whole-day fits, each
% day's 2 runs concatenated then filtered as one series, matching the
% original pipeline's ParseGorillaModel.m/GorillaModelStruct(i).d1/.d2) back
% into one consolidated Md_Inst_Struct, keyed the same way step4_data_org.m /
% step5_make_bayes_timecourse.m / step6_posterior_variance_plot.m expect:
% Md_Inst_Struct(i).PANASMod_POSMINNEG, .PANASMod_POSMINNEG_largeVar,
% .PANASMod_POS, .PANASMod_NEG, and .GorillaModel.<run>. The .GorillaModel.d1/.d2
% fields specifically are what step4_data_org.m's "gorilla (concatenated runs)"
% section needs to write apple_moodrate_params_wholeday.csv.
%
% Inputs: everything comes from osf_data_and_scripts/data/raw_mat/ (shipped in
%   this package) -- RawData_anonymized.mat (produced by
%   step1_anonymize_raw_data.m) for the base Md_Inst_Struct with
%   PANAS/Gorilla/InitQStruct, plus the 10 *_modeldata_anonymized.mat files
%   step2_run_bayes_filter.m copies here. No private data required: this
%   script never touches data/raw/raw_mat/ (the private repo's raw-data
%   folder) at all.
% Outputs: osf_data_and_scripts/data/raw_mat/Gor_PANAS_Mod_Data_anonymized.mat
%   -- inside this package, so it can be shared. (Renamed from
%   bayes_model_params.mat to match the original pipeline's naming; suffixed
%   "_anonymized" like everything else in this folder, since
%   Md_Inst_Struct(i).PANAS.ProlifID here is the anonymized sequential subject
%   number, not the real Prolific ID.)
%
% IMPORTANT downstream consequence: step4_data_org.m uses
% Md_Inst_Struct(i).PANAS.ProlifID as the "id" column in
% apple_moodrate_params.csv/ema_panas_params.csv, so those CSVs now carry the
% anonymized subject number too. 02_deidentify_raw_data/read_data_task_ema.Rmd
% needs those joined against real Prolific IDs at that stage of the R
% pipeline (anonymization there happens later, in write_anonymized_data.R) --
% it does this via the private data/raw/subject_id_crosswalk.csv (subject ->
% Prolific_Id) that step1_anonymize_raw_data.m writes, translating the
% anonymized "id" back to a real Prolific.Id right before the join. See
% read_data_task_ema.Rmd's attach_prolific_id() helper. Do not revert this
% script back to reading the private RawData.mat to "fix" that join -- it's
% already handled on the R side, and doing so would put real Prolific IDs
% back into this shared package's Gor_PANAS_Mod_Data_anonymized.mat.
%
% Storage: drops each fit's .volnoise and .KLdiv fields before merging --
% nothing in step4_data_org.m/step5_make_bayes_timecourse.m/step6_posterior_variance_plot.m
% reads either (grep confirms), and .volnoise alone (a per-trial vmu-by-s grid,
% e.g. 27x27x121 doubles per subject for the PANAS series) is the large majority
% of each fit's size. Also saves without "-v7.3": per anonymize_raw_data.m's
% note elsewhere in this folder, -v7.3's HDF5 format has heavy per-dataset
% overhead that dominates when a struct has many small/medium fields across
% hundreds of subjects -- the default (compressed) format doesn't pay that tax.
%
% Tier 1: fully reproducible from what's in this package, once
% step2_run_bayes_filter.m has been run (which is itself Tier 1).

clear; clc;
script_dir = "~/Desktop/MoodInstability/moodVariability/osf_data_and_scripts/scripts/01_bayesian_filter"; % EDIT: path to this folder on your machine
addpath(script_dir);
repo_root = find_repo_root(script_dir);
pkg_root = fullfile(repo_root,"osf_data_and_scripts");
anonymized_raw_mat_dir = fullfile(pkg_root,"data","raw_mat");

load(fullfile(anonymized_raw_mat_dir,"RawData_anonymized.mat"),"Md_Inst_Struct");
nsub = numel(Md_Inst_Struct);

DROP_FIELDS = {'volnoise','KLdiv'};

%% merge in the 4 flat (non-Gorilla) PANAS fits
flat_fits = {
    'PANASMod_POSMINNEG_modeldata_anonymized.mat',         'PANASMod_POSMINNEG';
    'PANASMod_POSMINNEG_largeVar_modeldata_anonymized.mat','PANASMod_POSMINNEG_largeVar';
    'PANASMod_POS_modeldata_anonymized.mat',                'PANASMod_POS';
    'PANASMod_NEG_modeldata_anonymized.mat',                'PANASMod_NEG';
};
for f = 1:size(flat_fits,1)
    fit_file = fullfile(anonymized_raw_mat_dir,flat_fits{f,1});
    fit_field = flat_fits{f,2};
    fit_data = load(fit_file,"out");
    if numel(fit_data.out) ~= nsub
        error("assemble_bayes_model_params:sizeMismatch", ...
            "%s has %d subjects, RawData_anonymized.mat has %d.", ...
            flat_fits{f,1}, numel(fit_data.out), nsub);
    end
    for i = 1:nsub
        fit_i = fit_data.out(i);
        fit_i.moddata = rmfield(fit_i.moddata, DROP_FIELDS);
        Md_Inst_Struct(i).(fit_field) = fit_i;
    end
end

%% merge in the 4 RL-task runs, plus the 2 whole-day (both runs concatenated) fits
runs = {'d1r1','d1r2','d2r1','d2r2','d1','d2'};
for r = 1:numel(runs)
    run_name = runs{r};
    run_file = fullfile(anonymized_raw_mat_dir,['GorillaModel_',run_name,'_modeldata_anonymized.mat']);
    run_data = load(run_file,"out");
    if numel(run_data.out) ~= nsub
        error("assemble_bayes_model_params:sizeMismatch", ...
            "%s has %d subjects, RawData_anonymized.mat has %d.", ...
            run_file, numel(run_data.out), nsub);
    end
    for i = 1:nsub
        run_i = run_data.out(i);
        run_i.moddata = rmfield(run_i.moddata, DROP_FIELDS);
        Md_Inst_Struct(i).GorillaModel.(run_name) = run_i;
    end
end

%% save the consolidated struct
save(fullfile(anonymized_raw_mat_dir,"Gor_PANAS_Mod_Data_anonymized.mat"),"Md_Inst_Struct");
