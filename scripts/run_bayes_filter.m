%running the bayesian filter for the RL task and the EMA data
%raw data was already reformatted in matlab structure

clear; clc;
cd('~/Desktop/MoodInstability/moodVariability/');
addpath(genpath(pwd))
data_path = '~/MoodInstability/moodVariability/data/';
load("./data/raw/raw_mat/RawData.mat","Md_Inst_Struct");
%% run filter on PANAS data - PAminusNA
panas_data=load("./data/raw/raw_mat/PANASPosMinNegFrMod.mat");

run_model_PANASPosMinNeg(panas_data.PANASPosMinNegFrMod);%grid inputs from Mike

%% run filter on RL task data
runs = {'d1r1','d1r2','d2r1','d2r2'};

[d1r1,d1r2,d2r1,d2r2] = Gor_Md_mat_fr_Model(Md_Inst_Struct);

for r = 1:4
    if r == 1
        run_model_Gorilla(d1r1);
    elseif r == 2
        run_model_Gorilla(d1r2);
    elseif r == 3
        run_model_Gorilla(d2r1);
    else
        run_model_Gorilla(d2r2);
    end
end