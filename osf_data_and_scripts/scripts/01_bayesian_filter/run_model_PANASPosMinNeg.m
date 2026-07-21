function out=run_model_PANASPosMinNeg(data,ncores,name,vmurange,rescale_range)

% run the model on data from the online study. data should be a matrix
% with each row a separate participant. ncores is hte number of cores to
% use analysing the data. vmurange optionally overrides the filter's default
% vmu grid range (params.vmurange); omit/leave empty to use the engine's
% default ([0.001 100], see maglearn_func_vardiff_flat_miss.m). Passing
% [1e-10 10] reproduces the "-10-10" / largeVar PANAS fit that
% step4_data_org.m/step5_make_bayes_timecourse.m expect as
% Md_Inst_Struct(i).PANASMod_POSMINNEG_largeVar.
%
% rescale_range optionally overrides the [min max] the raw data is assumed to
% span before being linearly rescaled to [0.1 0.9] for the filter; omit/leave
% empty for the default [-40 40] (the PANAS pos-minus-neg range). Pass [10 50]
% (the PANAS pos-only/neg-only subscale range) to fit PANASposFrMod/PANASnegFrMod
% -- despite the function name, the filter itself is generic; only the input
% rescaling is series-specific. Feeds Md_Inst_Struct(i).PANASMod_POS/.PANASMod_NEG.
%
% Saves [name '_modeldata.mat'] to <repo_root>/data/raw/raw_mat/ (the
% private raw-data folder, not the OSF package) -- see find_repo_root.m.

if nargin<5
    rescale_range=[];
end

if nargin<4
    vmurange=[];
end

if nargin<3
    name=datestr(now);
end

if nargin<2
    ncores=10;
end

if isempty(rescale_range)
    rescale_range=[-40 40];
end

params=struct;
numsubs=size(data,1);
if ~isempty(vmurange)
    params.vmurange=vmurange;
end


delete(gcp('nocreate'));
parpool(ncores);
out=struct;
parfor sub=1:numsubs
    disp(sub);
    indata=data(sub,:);
    indata=(indata-rescale_range(1))./(rescale_range(2)-rescale_range(1)).*0.8+0.1; % rescales [rescale_range(1) rescale_range(2)] to [0.1 0.9]

    out(sub).moddata=maglearn_func_vardiff_flat_miss(indata,params);


end

script_dir = fileparts(mfilename('fullpath'));
repo_root = find_repo_root(script_dir);
out_dir = fullfile(repo_root,"data","raw","raw_mat");
if ~isfolder(out_dir), mkdir(out_dir); end
save(fullfile(out_dir,[name,'_modeldata']),'out','data');
