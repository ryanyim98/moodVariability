% Purpose: step 1 of the parameter-recovery simulation. Samples starting parameters
% from real participants' last-5 fitted values, forward-simulates synthetic EMA and
% task rating time series (generate_data_learner.m), then fits the Bayesian filter
% (maglearn_func_vardiff_flat_miss.m) back to the synthetic data.
% Inputs: last5_parameters_from_participants.mat (same folder), and
% <pkg_root>/data/df_gor_Est_tc.csv / df_panas_Est_tc.csv (de-identified, shipped in
% this OSF package -- this script needs NO raw data and is fully reproducible).
% Outputs: recovered_params.mat (same folder) -> consumed by step2_assessgenrecvoer.m.
% Note: this simulation is computationally expensive (parfor filter fits over many
% simulated participants) and can take a long time to complete.

clear all; clc;
close all;

script_dir = "~/Desktop/MoodInstability/moodVariability/osf_data_and_scripts/scripts/03_parameter_recovery"; % EDIT: path to this folder on your machine
addpath(script_dir)
pkg_root = find_pkg_root(script_dir);
cd(script_dir)

measnames={'EMA', 'task'};

 %use these stable estimates as the starting value
load('last5_parameters_from_participants.mat');

% % %use all values to constrain the parameter drift
task_est=readtable(fullfile(pkg_root,"data","df_gor_Est_tc.csv"));
task_est = task_est(task_est.run =="d1r1",:);
ema_est=readtable(fullfile(pkg_root,"data","df_panas_Est_tc.csv"));
ema_est = ema_est(ema_est.panas_type =="posminusneg",:);

% % % % Bounds for generated parameter time series (param order: mu, vmu, kmu, s, vs)
% task_param_min = [inv_logit(min(task_est.mu)), min(task_est.vmu), min(task_est.kmu), min(task_est.s), min(task_est.vs)];
% task_param_max = [inv_logit(max(task_est.mu)), max(task_est.vmu), max(task_est.kmu), max(task_est.s), max(task_est.vs)];
% ema_param_min  = [inv_logit(min(ema_est.mu)),  min(ema_est.vmu),  min(ema_est.kmu),  min(ema_est.s),  min(ema_est.vs)];
% ema_param_max  = [inv_logit(max(ema_est.mu)),  max(ema_est.vmu),  max(ema_est.kmu),  max(ema_est.s),  max(ema_est.vs)];

%boundary in the maglearn function
param_min = [-5,log(0.001),log(5e-5),log(0.01),log(0.001)];
param_max = [5,log(100),log(100),log(10),log(100)];

ntrials_ema=120;
ntrials_task=41;
nparticipants=100; %simulate just 100 participants (more will take more time)


%% use the mean params to generate timeseries data
%Compute mean and std in the native sampling space
rng(789); 
k = 3; % truncation level (±SD)
%note that these are the starting values; they drift over time and their
%eventual M/SD will be different from that of the staring values

for participant=1:nparticipants
    disp(participant);

    %%EMA parameters
    % Work on the same (logit) scale as the fitted parameters in a.final5m
    mu_mean = mean(a.final5m(:,1));
    mu_sd   = std(a.final5m(:,1));
    params_ema(participant,1) = trunc_norm(mu_mean, mu_sd, k);

    vmu_mean = mean(a.final5model(:,1));
    vmu_sd   = std(a.final5model(:,1));
    params_ema(participant,2) = trunc_norm(vmu_mean, vmu_sd, k);

    kmu_mean = mean(a.final5modelhl(:,1));
    kmu_sd   = std(a.final5modelhl(:,1));
    params_ema(participant,3) = trunc_norm(kmu_mean, kmu_sd, k);

    s_mean = mean(a.final5model(:,3));
    s_sd   = std(a.final5model(:,3));
    params_ema(participant,4) = trunc_norm(s_mean, s_sd, k);

    vs_mean = mean(a.final5modelhl(:,3));
    vs_sd   = std(a.final5modelhl(:,3));
    params_ema(participant,5) = trunc_norm(vs_mean, vs_sd, k);


    % TASK parameters
    mu_mean = mean(a.final5m(:,2));
    mu_sd   = std(a.final5m(:,2));
    params_task(participant,1) = trunc_norm(mu_mean, mu_sd, k);

    vmu_mean = mean(a.final5model(:,2));
    vmu_sd   = std(a.final5model(:,2));
    params_task(participant,2) = trunc_norm(vmu_mean, vmu_sd, k);

    kmu_mean = mean(a.final5modelhl(:,2));
    kmu_sd   = std(a.final5modelhl(:,2));
    params_task(participant,3) = trunc_norm(kmu_mean, kmu_sd, k);

    s_mean = mean(a.final5model(:,4));
    s_sd   = std(a.final5model(:,4));
    params_task(participant,4) = trunc_norm(s_mean, s_sd, k);

    vs_mean = mean(a.final5modelhl(:,4));
    vs_sd   = std(a.final5modelhl(:,4));
    params_task(participant,5) = trunc_norm(vs_mean, vs_sd, k);


% Generate synthetic data with full-trajectory rejection. If trajectory
% hits bound more than max_traj_restarts (10000) times, resample starting
% params and regenerate. If that resample->regenerate loop fails
% max_start_attempts (50) times, error.
max_traj_restarts = 10000;
max_start_attempts = 50;

n_restarts_ema = inf;
attempt_ema = 0;
while n_restarts_ema > max_traj_restarts
    attempt_ema = attempt_ema + 1;
    if attempt_ema > max_start_attempts
        error('Participant %d EMA: resample->regenerate failed %d times (trajectory exceeded %d restarts each time).', ...
              participant, max_start_attempts, max_traj_restarts);
    end
    [outrating_ema(participant,:), outgenparams_ema(participant,:,:), n_restarts_ema] = ...
        generate_data_learner(params_ema(participant,:), ntrials_ema, param_min, param_max);
    if n_restarts_ema > max_traj_restarts
        params_ema(participant,1) = trunc_norm(mean(a.final5m(:,1)), std(a.final5m(:,1)), k);
        params_ema(participant,2) = trunc_norm(mean(a.final5model(:,1)), std(a.final5model(:,1)), k);
        params_ema(participant,3) = trunc_norm(mean(a.final5modelhl(:,1)), std(a.final5modelhl(:,1)), k);
        params_ema(participant,4) = trunc_norm(mean(a.final5model(:,3)), std(a.final5model(:,3)), k);
        params_ema(participant,5) = trunc_norm(mean(a.final5modelhl(:,3)), std(a.final5modelhl(:,3)), k);
    end
end

n_restarts_task = inf;
attempt_task = 0;
while n_restarts_task > max_traj_restarts
    attempt_task = attempt_task + 1;
    if attempt_task > max_start_attempts
        error('Participant %d Task: resample->regenerate failed %d times (trajectory exceeded %d restarts each time).', ...
              participant, max_start_attempts, max_traj_restarts);
    end
    [outrating_task(participant,:), outgenparams_task(participant,:,:), n_restarts_task] = ...
        generate_data_learner(params_task(participant,:), ntrials_task, param_min, param_max);
    if n_restarts_task > max_traj_restarts
        params_task(participant,1) = trunc_norm(mean(a.final5m(:,2)), std(a.final5m(:,2)), k);
        params_task(participant,2) = trunc_norm(mean(a.final5model(:,2)), std(a.final5model(:,2)), k);
        params_task(participant,3) = trunc_norm(mean(a.final5modelhl(:,2)), std(a.final5modelhl(:,2)), k);
        params_task(participant,4) = trunc_norm(mean(a.final5model(:,4)), std(a.final5model(:,4)), k);
        params_task(participant,5) = trunc_norm(mean(a.final5modelhl(:,4)), std(a.final5modelhl(:,4)), k);
    end
end

end

titles_ts = {'generated rating','mean (mu, logit)','volatility (vmu)','kmu','noise (s)','vs'};
lineColor = [0.25 0.45 0.75 0.25];

figure('Position', [80 80 700 500], 'Color', 'w');
set(groot, 'DefaultAxesFontSize', 11);
subplot(2,3,1); hold on;
for pp = 1:nparticipants
    plot(squeeze(outrating_ema(pp,:)), 'Color', lineColor);
end
title(titles_ts{1}); ylabel('value'); xlabel('time point');
set(gca, 'Box', 'off'); xlim([1 ntrials_ema]); ylim([0,1]);
for i = 1:5
    subplot(2,3,i+1); hold on;
    for pp = 1:nparticipants
        plot(squeeze(outgenparams_ema(pp,:,i)), 'Color', lineColor);
    end
    title(titles_ts{i+1}); ylabel('value'); xlabel('time point');
    set(gca, 'Box', 'off'); xlim([1 ntrials_ema]);
    ylim([min(outgenparams_ema(:,:,i), [], 'all'), max(outgenparams_ema(:,:,i), [], 'all')]);
end
%% parameter recovery
delete(gcp('nocreate'));
parpool(10);
sdtruncate=k;

parfor pp=1:nparticipants
    disp(pp);
    learner(pp).ema = maglearn_func_vardiff_flat_miss(squeeze(outrating_ema(pp,:)));
    learner(pp).task = maglearn_func_vardiff_flat_miss(squeeze(outrating_task(pp,:)));
end

% Stable filename (not timestamped) so step2_assessgenrecvoer.m always reads the
% most recent run without needing to be edited.
filename = 'recovered_params.mat';

% Save full workspace variables
save(filename, 'learner','sdtruncate','outgenparams_ema', 'outgenparams_task', ...
    'params_ema', 'params_task', 'nparticipants', ...
    'outrating_ema', 'outrating_task');

disp(['Saved file: ' filename]);