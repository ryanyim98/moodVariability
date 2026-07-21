function out=run_model_Gorilla(data,ncores,name)

% run the model on data from the online study. data should be a matrix
% with each row a separate participant. ncores is hte number of cores to
% use analysing the data
%
% Saves [name '_modeldata.mat'] to <repo_root>/data/raw/raw_mat/ (the
% private raw-data folder, not the OSF package) -- see find_repo_root.m.

if nargin<3
    name=datestr(now);
end

if nargin<2
    ncores=10;
end

params=struct;
numsubs=size(data,1);
% default vmurange from moodzoom data was 1e-5
params.vmurange=[1e-7 10]; %10e-7



delete(gcp('nocreate'));
parpool(ncores);
out=struct;
parfor sub=1:numsubs
    
    indata=data(sub,:);
    indata=(indata)./10; % the raw data is a number between 1 and 9. this scales it to between 1/9 and 9/10
    
    out(sub).moddata=maglearn_func_vardiff_flat_miss(indata,params);
    
    
end

script_dir = fileparts(mfilename('fullpath'));
repo_root = find_repo_root(script_dir);
out_dir = fullfile(repo_root,"data","raw","raw_mat");
if ~isfolder(out_dir), mkdir(out_dir); end
save(fullfile(out_dir,[name,'_modeldata']),'out','data');
