function out=run_model_PANAS(data,ncores,name)

% run the model on data from the online study. data should be a matrix
% with each row a separate participant. ncores is hte number of cores to
% use analysing the data

if nargin<3
    name=datestr(now);
end

if nargin<2
    ncores=10;
end

params=struct;
numsubs=size(data,1);
% default vmurange from moodzoom data
%params.vmurange=[0.0001 10];



delete(gcp('nocreate'));
parpool(ncores);
out=struct;
parfor sub=1:numsubs
    
    indata=data(sub,:);
    indata=(indata-5)./50; % the raw data is a number between 10 and 50, this scales it to be between 1/10 and 9/10
    
    out(sub).moddata=maglearn_func_vardiff_flat_miss(indata,params);
    
    
end

save([name,'_modeldata'],'out','data');
