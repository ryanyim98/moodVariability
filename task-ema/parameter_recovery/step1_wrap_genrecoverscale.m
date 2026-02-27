% generate and plot syn data.
clear all; clc;
close all;

cd("~/Desktop/MoodInstability/moodVariability/task-ema/parameter_recovery/")
addpath(pwd)

measnames={'EMA', 'task'};

 %use these stable estimates as the starting value
load('last5_parameters_from_participants.mat');

% %use all values to constrain the parameter drift
task_est=readtable("~/Desktop/MoodInstability/moodVariability/data/for_share/df_gor_Est_tc.csv");
task_est = task_est(task_est.run =="d1r1",:);
ema_est=readtable("~/Desktop/MoodInstability/moodVariability/data/for_share/df_panas_Est_tc.csv");
ema_est = ema_est(ema_est.panas_type =="posminusneg",:);

% Bounds for generated parameter time series (param order: mu, vmu, kmu, s, vs)
task_param_min = [inv_logit(min(task_est.mu)), min(task_est.vmu), min(task_est.kmu), min(task_est.s), min(task_est.vs)];
task_param_max = [inv_logit(max(task_est.mu)), max(task_est.vmu), max(task_est.kmu), max(task_est.s), max(task_est.vs)];
ema_param_min  = [inv_logit(min(ema_est.mu)),  min(ema_est.vmu),  min(ema_est.kmu),  min(ema_est.s),  min(ema_est.vs)];
ema_param_max  = [inv_logit(max(ema_est.mu)),  max(ema_est.vmu),  max(ema_est.kmu),  max(ema_est.s),  max(ema_est.vs)];

%boundary in the maglearn function
param_min = [-5,log(0.001),log(5e-5),log(0.01),log(0.001)];
param_max = [5,log(100),log(100),log(10),log(100)];

ntrials_ema=120;
ntrials_task=41;
nparticipants=100; %simulate just 100 participants (more will take more time)


%% use the mean params to generate timeseries data
%Compute mean and std in the native sampling space
rng(789); 
k = 2; % truncation level (±SD)
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
        generate_data_learner(params_ema(participant,:), ntrials_ema, ema_param_min, ema_param_max);
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
        generate_data_learner(params_task(participant,:), ntrials_task, task_param_min, task_param_max);
    if n_restarts_task > max_traj_restarts
        params_task(participant,1) = trunc_norm(mean(a.final5m(:,2)), std(a.final5m(:,2)), k);
        params_task(participant,2) = trunc_norm(mean(a.final5model(:,2)), std(a.final5model(:,2)), k);
        params_task(participant,3) = trunc_norm(mean(a.final5modelhl(:,2)), std(a.final5modelhl(:,2)), k);
        params_task(participant,4) = trunc_norm(mean(a.final5model(:,4)), std(a.final5model(:,4)), k);
        params_task(participant,5) = trunc_norm(mean(a.final5modelhl(:,4)), std(a.final5modelhl(:,4)), k);
    end
end

end
% spaghetti plot
titles = {'generated rating','mean (mu, logit)','volatility (vmu)','kmu','noise (s)','vs'};

% Figure: rating and latent parameters over time (Step 1)
figdir = fullfile(fileparts(pwd), 'figures');
if ~isfolder(figdir), mkdir(figdir); end

figure('Position', [80 80 700 500], 'Color', 'w');
set(groot, 'DefaultAxesFontSize', 11);
lineColor = [0.25 0.45 0.75 0.25];  % blue with transparency for many traces

% First subplot (rating)
subplot(2,3,1); hold on;
for pp = 1:nparticipants
    plot(squeeze(outrating_task(pp,:)), 'Color', lineColor);
end
title(titles{1});
ylabel('value');
xlabel('time point');
set(gca, 'Box', 'off');
xlim([1 ntrials_task]);
ylim([0,1]);

% Remaining 5 subplots (parameters)
for i = 1:5
    subplot(2,3,i+1); hold on;
    for pp = 1:nparticipants
        plot(squeeze(outgenparams_task(pp,:,i)), 'Color', lineColor);
    end
    title(titles{i+1});
    ylabel('value');
    xlabel('time point');
    set(gca, 'Box', 'off');
    xlim([1 ntrials_task]);
    ylim([min(outgenparams_task(:,:,i), [], 'all'), max(outgenparams_task(:,:,i), [], 'all')]);
end

%sgtitle('Step 1: Generated task ratings and latent parameters over time', 'FontWeight', 'normal', 'FontSize', 12);
print(gcf, fullfile(figdir, 'step1_timeseries.png'), '-dpng', '-r300');

% Summary statistics for task and EMA parameters based on last 5 time points
lastN = 5;

% Indices for the last N trials
last_idx_task = (ntrials_task - lastN + 1):ntrials_task;
last_idx_ema  = (ntrials_ema  - lastN + 1):ntrials_ema;

% Participant-wise averages over the last 5 time points for each parameter
last5_avg_task = squeeze(mean(outgenparams_task(:, last_idx_task, :), 2)); % [nparticipants x 5]
last5_avg_ema  = squeeze(mean(outgenparams_ema(:,  last_idx_ema,  :), 2)); % [nparticipants x 5]

% Mean and SD across participants for each parameter (using last-5 averages)
param_mean_last5_task = mean(last5_avg_task, 1);
param_sd_last5_task   = std(last5_avg_task, [], 1);
param_mean_last5_ema  = mean(last5_avg_ema, 1);
param_sd_last5_ema    = std(last5_avg_ema, [], 1);

%% plot simulated data in comparison with actual data

param_names = {'mu (logit)','vmu','kmu','s','vs'};

% Color scheme (match step2: mu, vmu, s colored; kmu, vs grey)
muColor    = [0.1333 0.5451 0.1333];  % forestgreen
vmuColor   = [1 0 0];                 % red
noiseColor = [0.2549 0.4118 0.8824];  % royalblue3
greyColor  = [0.5 0.5 0.5];           % grey for kmu, vs
paramColors = [muColor; vmuColor; greyColor; noiseColor; greyColor];

% Mean and SD from participant data (same mapping as param sampling above)
% All parameters (including mu) are on the native fitted scale in a.final5* (mu on logit scale).
data_mu_task   = [mean(inv_logit(a.final5m(:,2))), std(inv_logit(a.final5m(:,2)))];
data_mu_ema    = [mean(inv_logit(a.final5m(:,1))), std(inv_logit(a.final5m(:,1)))];
data_mean_task = [data_mu_task(1), mean(a.final5model(:,2)), mean(a.final5modelhl(:,2)), mean(a.final5model(:,4)), mean(a.final5modelhl(:,4))];
data_sd_task   = [data_mu_task(2), std(a.final5model(:,2)), std(a.final5modelhl(:,2)), std(a.final5model(:,4)), std(a.final5modelhl(:,4))];
data_mean_ema  = [data_mu_ema(1), mean(a.final5model(:,1)), mean(a.final5modelhl(:,1)), mean(a.final5model(:,3)), mean(a.final5modelhl(:,3))];
data_sd_ema    = [data_mu_ema(2), std(a.final5model(:,1)), std(a.final5modelhl(:,1)), std(a.final5model(:,3)), std(a.final5modelhl(:,3))];

% Individual participant values for plotting (same mapping as above)
mu_vals_task = inv_logit(a.final5m(:,2));
mu_vals_ema  = inv_logit(a.final5m(:,1));
data_vals_task = [mu_vals_task,  a.final5model(:,2),  a.final5modelhl(:,2),  a.final5model(:,4),  a.final5modelhl(:,4)];
data_vals_ema  = [mu_vals_ema,   a.final5model(:,1),  a.final5modelhl(:,1),  a.final5model(:,3),  a.final5modelhl(:,3)];

% Mean and SD of starting (sampled) parameters across simulated participants
params_ema_plot=params_ema;
params_ema_plot(:,1)=inv_logit(params_ema_plot(:,1));
params_task_plot=params_task;
params_task_plot(:,1)=inv_logit(params_task_plot(:,1));
start_mean_ema  = mean(params_ema, 1);
start_sd_ema    = std(params_ema, [], 1);
start_mean_task = mean(params_task, 1);
start_sd_task   = std(params_task, [], 1);

% Figure: EMA first (left), then Task (right). Dimensions for saving.
figdir = fullfile(fileparts(pwd), 'figures');
if ~isfolder(figdir), mkdir(figdir); end
fig_params_size = [900 360];  % [width height] in pixels

figure('Position', [100 100 fig_params_size(1) fig_params_size(2)], 'Color', 'w');

% Panel 1: EMA (front/left)
subplot(1,2,1); hold on;
hline_ema = yline(0, ':', 'Color', [0.85 0.85 0.85]);
h_start_ema = [];
h_data_ema  = [];
h_end_ema   = [];
n_sim_ema   = size(params_ema,1);
n_data_ema  = size(data_vals_ema,1);
for i = 1:5
    % Jittered x-positions for start, real participants, and end (last 5) per subject
    x_start = i - 0.3 + 0.03*randn(n_sim_ema,1);
    x_data  = i       + 0.03*randn(n_data_ema,1);
    x_end   = i + 0.3 + 0.03*randn(n_sim_ema,1);

    % Starting sampled parameters: filled markers
    h_start_ema(i) = scatter(x_start, params_ema_plot(:,i), 18, paramColors(i,:), ...
                             'filled', 'MarkerEdgeColor', [0.1 0.1 0.1]);

    % Real participant values: centered marker with distinct shape
    h_data_ema(i) = scatter(x_data, data_vals_ema(:,i), 16, [0.7 0.7 0.7], ...
                            'filled', 'MarkerEdgeColor', 'none', 'Marker', 's');

    % Ending parameters: average of last 5 values, hollow markers
    h_end_ema(i) = scatter(x_end, last5_avg_ema(:,i), 22, paramColors(i,:), ...
                           'MarkerFaceColor', 'none', 'MarkerEdgeColor', paramColors(i,:), ...
                           'LineWidth', 1.2);
end
% Error bar for participant mean ± SD
h_eb_ema = errorbar(1:5, data_mean_ema, data_sd_ema, 'ko', 'LineWidth', 1.8, 'MarkerSize', 7, 'CapSize', 6);
% Tight y-limits based on all EMA values (with small padding)
all_vals_ema = [params_ema(:); last5_avg_ema(:); data_vals_ema(:)];
pad_ema = 0.3 * range(all_vals_ema);
if pad_ema == 0, pad_ema = 0.5; end
ymin_ema = min(all_vals_ema) - pad_ema;
ymax_ema = max(all_vals_ema) + pad_ema;
xlim([0.5 5.5]);
set(gca,'XTick',1:5,'XTickLabel',param_names);
title("Simulated participants (EMA): start vs end", 'FontWeight', 'normal');
ylabel('Parameter value');
ylim([ymin_ema, ymax_ema]);
lg_ema = legend([h_start_ema(1), h_data_ema(1), h_end_ema(1), h_eb_ema], ...
       {'Start values (simulated)', 'Real participants mean', 'End values (last 5 simulated)', 'Data mean \pm SD'}, ...
       'Location', 'northeast');
set(lg_ema, 'Box', 'off');
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 11);

% Panel 2: Task (right)
subplot(1,2,2); hold on;
hline_task = yline(0, ':', 'Color', [0.85 0.85 0.85]);
h_start_task = [];
h_data_task  = [];
h_end_task   = [];
n_sim_task   = size(params_task,1);
n_data_task  = size(data_vals_task,1);
for i = 1:5
    % Jittered x-positions for start, real participants, and end (last 5) per subject
    x_start = i - 0.3 + 0.03*randn(n_sim_task,1);
    x_data  = i       + 0.03*randn(n_data_task,1);
    x_end   = i + 0.3 + 0.03*randn(n_sim_task,1);

    % Starting sampled parameters: filled markers
    h_start_task(i) = scatter(x_start, params_task_plot(:,i), 18, paramColors(i,:), ...
                              'filled', 'MarkerEdgeColor', [0.1 0.1 0.1]);

    % Real participant values: centered marker with distinct shape
    h_data_task(i) = scatter(x_data, data_vals_task(:,i), 16, [0.7 0.7 0.7], ...
                             'filled', 'MarkerEdgeColor', 'none', 'Marker', 's');

    % Ending parameters: average of last 5 values, hollow markers
    h_end_task(i) = scatter(x_end, last5_avg_task(:,i), 22, paramColors(i,:), ...
                            'MarkerFaceColor', 'none', 'MarkerEdgeColor', paramColors(i,:), ...
                            'LineWidth', 1.2);
end
% Error bar for participant mean ± SD
h_eb_task = errorbar(1:5, data_mean_task, data_sd_task, 'ko', 'LineWidth', 1.8, 'MarkerSize', 7, 'CapSize', 6);
% Tight y-limits based on all Task values (with small padding)
all_vals_task = [params_task(:); last5_avg_task(:); data_vals_task(:)];
pad_task = 0.3 * range(all_vals_task);
if pad_task == 0, pad_task = 0.5; end
ymin_task = min(all_vals_task) - pad_task;
ymax_task = max(all_vals_task) + pad_task;
xlim([0.5 5.5]);
set(gca,'XTick',1:5,'XTickLabel',param_names);
title("Simulated participants (Task): start vs end", 'FontWeight', 'normal');
ylabel('Parameter value');
ylim([ymin_task, ymax_task]);
% No separate legend here: shared legend is shown for the EMA panel
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 11);

print(gcf, fullfile(figdir, 'step1_sampled_params.png'), '-dpng', '-r300');

%% parameter recovery
delete(gcp('nocreate'));
parpool(5);
sdtruncate=k;

parfor pp=1:nparticipants
    disp(pp);
    learner(pp).ema = maglearn_func_vardiff_flat_miss(squeeze(outrating_ema(pp,:)));
    learner(pp).task = maglearn_func_vardiff_flat_miss(squeeze(outrating_task(pp,:)));
end

% Create timestamp (e.g., 2026-02-25_14-30-05)
timestamp = datestr(datetime('now'), 'yyyy-mm-dd_HH-MM-SS');

% Create filename with timestamp
filename = ['recovered_params_' timestamp '.mat'];

% Save full workspace variables
save(filename, 'learner','sdtruncate','outgenparams_ema', 'outgenparams_task', ...
    'params_ema', 'params_task', 'nparticipants', ...
    'outrating_ema', 'outrating_task');

disp(['Saved file: ' filename]);