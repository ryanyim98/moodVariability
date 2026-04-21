clear
close all
cd /Users/yanyan/Desktop/MoodInstability/moodVariability/bayesian_filter_matlab_code/
% Figure save directory and dimensions (tweak as needed)
figdir = fullfile(fileparts(pwd), './figures');
if ~isfolder(figdir), mkdir(figdir); end

muColor    = [0.1333 0.5451 0.1333];  % forestgreen
vmuColor   = [1 0 0];                 % red
noiseColor = [0.2549 0.4118 0.8824]; % royalblue3

tmp = load('../data/bayes_model_params.mat', 'Md_Inst_Struct');

clear learner
nparticipants = numel(tmp.Md_Inst_Struct);
learner(nparticipants).ema = tmp.Md_Inst_Struct(nparticipants).PANASMod_POSMINNEG.moddata;  % sets type to struct array
learner(nparticipants).task = tmp.Md_Inst_Struct(nparticipants).GorillaModel.d1r1.moddata;  % sets type to struct array

for i = 1:nparticipants-1
    learner(i).ema = tmp.Md_Inst_Struct(i).PANASMod_POSMINNEG.moddata;
    learner(i).task = tmp.Md_Inst_Struct(i).GorillaModel.d1r1.moddata;
end

clear tmp;
%% Posterior variance over time: mean variance (across participants) with SEM ribbons, one line per parameter. ESM and Task separately.
% Plot only Mean, Volatility, Noise (exclude kmu and vs)
param_idx_plot = [1 2 4];   % mu, vmu, s
param_names_var = {'Mean (\mu)', 'Volatility (vmu)', 'Noise (s)'};
grid_fields_ema  = {'muvec',  'vmulog', 'kmulog', 'slog',  'vslog'};
dist_fields_ema  = {'muDist', 'vmuDist', 'kmuDist', 'sDist', 'vsDist'};
nparams_var = 5;

% Compute posterior variance for each participant, time point, and parameter (ESM and Task)
ema_nt  = size(learner(1).ema.muEst, 1);
task_nt = size(learner(1).task.muEst, 1);
var_ema_pp  = NaN(nparticipants, ema_nt,  nparams_var);  % pp x time x param
var_task_pp = NaN(nparticipants, task_nt, nparams_var);

for pp = 1:nparticipants
    for k = 1:nparams_var
        g_ema  = learner(pp).ema.(grid_fields_ema{k})(:);
        d_ema  = learner(pp).ema.(dist_fields_ema{k});   % (time x grid)
        for t = 1:ema_nt
            p = d_ema(t,:); p = p(:)' / sum(p(:));
            m1 = sum(p .* g_ema');
            m2 = sum(p .* (g_ema.^2)');
            var_ema_pp(pp, t, k) = m2 - m1^2;
        end
        g_task = learner(pp).task.(grid_fields_ema{k})(:);
        d_task = learner(pp).task.(dist_fields_ema{k});
        for t = 1:task_nt
            p = d_task(t,:); p = p(:)' / sum(p(:));
            m1 = sum(p .* g_task');
            m2 = sum(p .* (g_task.^2)');
            var_task_pp(pp, t, k) = m2 - m1^2;
        end
    end
end

% Mean and SEM across participants at each time point
mean_var_ema  = squeeze(mean(var_ema_pp,  1));  % (time x param)
sem_var_ema   = squeeze(std(var_ema_pp, [], 1) / sqrt(nparticipants));
mean_var_task = squeeze(mean(var_task_pp, 1));
sem_var_task  = squeeze(std(var_task_pp, [], 1) / sqrt(nparticipants));

% Entropy over time: collect across participants, then mean and SEM
entropy_ema_pp  = NaN(nparticipants, ema_nt);   % pp x time
entropy_task_pp = NaN(nparticipants, task_nt);
for pp = 1:nparticipants
    entropy_ema_pp(pp,:)  = learner(pp).ema.entropy(:)';
    entropy_task_pp(pp,:) = learner(pp).task.entropy(:)';
end
mean_entropy_ema  = mean(entropy_ema_pp,  1);
sem_entropy_ema   = std(entropy_ema_pp, [], 1) / sqrt(nparticipants);
mean_entropy_task = mean(entropy_task_pp, 1);
sem_entropy_task  = std(entropy_task_pp, [], 1) / sqrt(nparticipants);

% Colors for the 3 plotted parameters (Mean, Volatility, Noise)
paramColors_var = [muColor; vmuColor; noiseColor];
ribbonAlpha = 0.28;

% Figure: row 1 = posterior variance (ESM, Task), row 2 = entropy (ESM, Task)
figure('Position', [100 100 600 600], 'Color', 'w');
x_ema  = 1:ema_nt;
x_task = 1:task_nt;

% Panel 1: ESM posterior variance (mean ± SEM as ribbons, mean line on top)
subplot(2,2,1); hold on;
for ik = 1:length(param_idx_plot)
    k = param_idx_plot(ik);
    col = paramColors_var(ik,:);
    mu = mean_var_ema(:,k)';
    se = sem_var_ema(:,k)';
    yu = mu + se;
    yl = max(0, mu - se);
    xf = [x_ema, fliplr(x_ema)];
    yf = [yu, fliplr(yl)];
    fill(xf, yf, col, 'FaceAlpha', ribbonAlpha, 'EdgeColor', 'none', 'HandleVisibility', 'off');
end
for ik = 1:length(param_idx_plot)
    k = param_idx_plot(ik);
    plot(x_ema, mean_var_ema(:,k), 'Color', paramColors_var(ik,:), 'LineWidth', 2.2);
end
text(-0.12, 1.04, 'A', 'Units', 'normalized', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Time point', 'FontSize', 11);
ylabel('Mean posterior variance', 'FontSize', 11);
title('ESM: posterior variance over time', 'FontWeight', 'normal', 'FontSize', 12);
legend(param_names_var, 'Location', 'northeast', 'FontSize', 10, 'Box', 'off');
xlim([1 ema_nt]);
ymax_ema = max(mean_var_ema(:,param_idx_plot) + sem_var_ema(:,param_idx_plot), [], 'all');
ylim([0 (ymax_ema * 1.08 + 1e-10)]);
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 11, 'LineWidth', 1);

% Panel 2: Task posterior variance
subplot(2,2,2); hold on;
for ik = 1:length(param_idx_plot)
    k = param_idx_plot(ik);
    col = paramColors_var(ik,:);
    mu = mean_var_task(:,k)';
    se = sem_var_task(:,k)';
    yu = mu + se;
    yl = max(0, mu - se);
    xf = [x_task, fliplr(x_task)];
    yf = [yu, fliplr(yl)];
    fill(xf, yf, col, 'FaceAlpha', ribbonAlpha, 'EdgeColor', 'none', 'HandleVisibility', 'off');
end
for ik = 1:length(param_idx_plot)
    k = param_idx_plot(ik);
    plot(x_task, mean_var_task(:,k), 'Color', paramColors_var(ik,:), 'LineWidth', 2.2);
end
text(-0.12, 1.04, 'B', 'Units', 'normalized', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Time point', 'FontSize', 11);
ylabel('Mean posterior variance', 'FontSize', 11);
title('Task: posterior variance over time', 'FontWeight', 'normal', 'FontSize', 12);
legend(param_names_var, 'Location', 'northeast', 'FontSize', 10, 'Box', 'off');
xlim([1 task_nt]);
ymax_task = max(mean_var_task(:,param_idx_plot) + sem_var_task(:,param_idx_plot), [], 'all');
ylim([0 (ymax_task * 1.08 + 1e-10)]);
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 11, 'LineWidth', 1);

% Panel 3: ESM entropy (faint participants, ribbon + bold mean on top)
subplot(2,2,3); hold on;
ppLineColor = [0.90 0.91 0.93];
meanFillRGB = [0.20 0.42 0.62];
meanLineRGB = [0.02 0.12 0.28];
for pp = 1:nparticipants
    plot(x_ema, entropy_ema_pp(pp,:), 'Color', ppLineColor, 'LineWidth', 0.35);
end
muE = mean_entropy_ema(:)';
seE = sem_entropy_ema(:)';
xfE = [x_ema, fliplr(x_ema)];
yfE = [muE + seE, fliplr(muE - seE)];
fill(xfE, yfE, meanFillRGB, 'FaceAlpha', 0.4, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(x_ema, mean_entropy_ema, 'Color', meanLineRGB, 'LineWidth', 3);
text(-0.12, 1.04, 'C', 'Units', 'normalized', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Time point', 'FontSize', 11);
ylabel('Mean entropy (bits)', 'FontSize', 11);
title('ESM: posterior entropy over time', 'FontWeight', 'normal', 'FontSize', 12);
xlim([1 ema_nt]);
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 11, 'LineWidth', 1);

% Panel 4: Task entropy
subplot(2,2,4); hold on;
for pp = 1:nparticipants
    plot(x_task, entropy_task_pp(pp,:), 'Color', ppLineColor, 'LineWidth', 0.35);
end
muT = mean_entropy_task(:)';
seT = sem_entropy_task(:)';
xfT = [x_task, fliplr(x_task)];
yfT = [muT + seT, fliplr(muT - seT)];
fill(xfT, yfT, meanFillRGB, 'FaceAlpha', 0.4, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(x_task, mean_entropy_task, 'Color', meanLineRGB, 'LineWidth', 3);
text(-0.12, 1.04, 'D', 'Units', 'normalized', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Time point', 'FontSize', 11);
ylabel('Mean entropy (bits)', 'FontSize', 11);
title('Task: posterior entropy over time', 'FontWeight', 'normal', 'FontSize', 12);
xlim([1 task_nt]);
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 11, 'LineWidth', 1);

print(gcf, fullfile(figdir, 'posterior_variance_over_time.png'), '-dpng', '-r300');