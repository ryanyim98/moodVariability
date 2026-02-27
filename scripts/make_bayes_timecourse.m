clear all; clc;
cd('/Users/yanyan/Desktop/MoodInstability/moodVariability');
load("./data/bayes_model_params.mat")
load('./data/PANASPosMinNeg_modeldata_-10-10.mat');  %load the model with vmu range 1e-10~10

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
Est_out = table('Size',[4*42*sub_num 7],'VariableTypes',{'string','string','double','double','double','double','double'} ,'VariableNames',{'id','run','mu', 's', 'vmu','kmu', 'vs'});

for i = 1:sub_num %loop through N = 353 subjects
    temp_sub = char(sub_id(i));
    temp_sub_dat = Md_Inst_Struct(i).GorillaModel;
    
    for j = 1:4 %run
        temp_run = char(run(j));
        run_id = (42*4*(i-1)+42*(j-1)+1):(42*4*(i-1)+42*j);
        temp_run_dat = temp_sub_dat.(temp_run).moddata;
        
        %mu and s
        Est_out.mu(run_id) = temp_run_dat.muEst;
        Est_out.s(run_id) = temp_run_dat.sEst;
        

        %vmu kmu and vs
        Est_out.vmu(run_id) = temp_run_dat.vmuEst;
        Est_out.kmu(run_id) = temp_run_dat.kmuEst;
        Est_out.vs(run_id) = temp_run_dat.vsEst;
        
        
        Est_out.id(run_id) = temp_sub;
        Est_out.run(run_id) = temp_run;
    end
end
        
writetable(Est_out,'./apple_moodrate_params_timecourse.csv');

%% PANAS
sub_num = numel(Md_Inst_Struct);

for i = 1:sub_num
    sub_id{i} = char(Md_Inst_Struct(i).PANAS.ProlifID);
end

%variables we need: 
%muEst, sEst:averaged across whole run
%vmuEst, kmuEst, vsEst: take average of last 5

panas_type = {'pos','neg','posminusneg','posminusneg_hr'};
Est_out = table('Size',[length(panas_type)*sub_num*121 7],'VariableTypes',{'string','string','double','double','double','double','double'} ,'VariableNames',{'id','panas_type','mu', 's', 'vmu','kmu', 'vs'});

for i = 1:sub_num %loop through N = 353 subjects
    temp_sub = char(sub_id(i));
    
    for j = 1:length(panas_type)
        if j == 1
            temp_sub_dat = Md_Inst_Struct(i).PANASMod_POS.moddata;
        elseif j == 2
            temp_sub_dat = Md_Inst_Struct(i).PANASMod_NEG.moddata;
        elseif j== 3
            temp_sub_dat = Md_Inst_Struct(i).PANASMod_POSMINNEG.moddata;
        else
            temp_sub_dat = Md_Inst_Struct(i).PANASMod_POSMINNEG_largeVar.moddata;
        end
        temp_panas_type = char(panas_type(j));
        run_id = (121*length(panas_type)*(i-1)+121*(j-1)+1):(121*length(panas_type)*(i-1)+121*j);
        
        %mu and s
        Est_out.mu(run_id) = temp_sub_dat.muEst;
        Est_out.s(run_id) = temp_sub_dat.sEst;
        
        Est_out.vmu(run_id) = temp_sub_dat.vmuEst;
        Est_out.kmu(run_id) = temp_sub_dat.kmuEst;
        Est_out.vs(run_id) = temp_sub_dat.vsEst;
        
        Est_out.id(run_id) = temp_sub;
        Est_out.panas_type(run_id) = temp_panas_type;
        
    end
end
        
writetable(Est_out,'./data/ema_panas_params_timecourse.csv');