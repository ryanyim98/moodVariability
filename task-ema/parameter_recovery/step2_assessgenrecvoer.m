clear
close all

% Figure save directory and dimensions (tweak as needed)
figdir = fullfile(fileparts(pwd), 'figures');
if ~isfolder(figdir), mkdir(figdir); end
% Dimensions in pixels [width height] for each figure
fig12_size = [700 500];  % combined: corr by time (row 1) + bar by window (row 2), 4 panels
fig3_size = [700 500];   % scatter EMA (2x2 subplots)
fig4_size = [700 600];   % scatter Task (2x2 subplots)
fig5_size = [400 400];   % single scatter task vmu

muColor    = [0.1333 0.5451 0.1333];  % forestgreen
vmuColor   = [1 0 0];                 % red
noiseColor = [0.2549 0.4118 0.8824]; % royalblue3


load('recovered_params_2026-02-27_04-38-03.mat');
% convert the scale of mu
outgenparams_ema(:,:,1)=inv_logit(outgenparams_ema(:,:,1),1);
outgenparams_task(:,:,1)=inv_logit(outgenparams_task(:,:,1),1);

nparticipants = size(learner, 2);  % use same as step1 (do not hardcode 100)
sdwindow = 5;  % window for averaging late-trial recovered vs generated params
ema_nt = size(learner(1).ema.muEst, 1);
task_nt = size(learner(1).task.muEst, 1);
ema_win = (ema_nt - sdwindow + 1) : ema_nt;   % last sdwindow trials for EMA
task_win = (task_nt - sdwindow + 1) : task_nt; % last sdwindow trials for task
% get all data

for pp=1:nparticipants
    emadata(pp,:,:)=[learner(pp).ema.muEst, learner(pp).ema.vmuEst, learner(pp).ema.kmuEst, learner(pp).ema.sEst, learner(pp).ema.vsEst];
    taskdata(pp,:,:)=[learner(pp).task.muEst, learner(pp).task.vmuEst, learner(pp).task.kmuEst, learner(pp).task.sEst, learner(pp).task.vsEst];
end

%shape of emadata and taksdata: sub*timepoints*params

% calculate corr by time
for tt=1:size(emadata,2)
   emacorr(tt,:)=[corr(squeeze(emadata(:,tt,1)),squeeze(outgenparams_ema(:,tt,1))), ...
   corr(squeeze(emadata(:,tt,2)),squeeze(outgenparams_ema(:,tt,2))),  ...
   corr(squeeze(emadata(:,tt,3)),squeeze(outgenparams_ema(:,tt,3))),  ...
   corr(squeeze(emadata(:,tt,4)),squeeze(outgenparams_ema(:,tt,4))),  ...
   corr(squeeze(emadata(:,tt,5)),squeeze(outgenparams_ema(:,tt,5)))];
end

for tt=1:size(taskdata,2)
  taskcorr(tt,:)=[corr(squeeze(taskdata(:,tt,1)),squeeze(outgenparams_task(:,tt,1))),...
  corr(squeeze(taskdata(:,tt,2)),squeeze(outgenparams_task(:,tt,2))),  ...
  corr(squeeze(taskdata(:,tt,3)),squeeze(outgenparams_task(:,tt,3))),  ...
  corr(squeeze(taskdata(:,tt,4)),squeeze(outgenparams_task(:,tt,4))),  ...
  corr(squeeze(taskdata(:,tt,5)),squeeze(outgenparams_task(:,tt,5)))];
end

%% Correlation by averaging window: all, 10_last, 5_last, 1_last
win_names = {'all', '10\_last', '5\_last', '1\_last'};
param_idx = [1 2 4];   % Mean, vmu, s
nparams = length(param_idx);
nwindows = 4;

% Window indices (same length for emadata and outgenparams over 1:ema_nt / 1:task_nt)
ema_win_all   = 1:ema_nt;
ema_win_10    = (ema_nt-9):ema_nt;
ema_win_5     = (ema_nt-4):ema_nt;
ema_win_1     = ema_nt;  % scalar
task_win_all  = 1:task_nt;
task_win_10   = (task_nt-9):task_nt;
task_win_5    = (task_nt-4):task_nt;
task_win_1    = task_nt;

ema_wins  = {ema_win_all, ema_win_10, ema_win_5, ema_win_1};
task_wins = {task_win_all, task_win_10, task_win_5, task_win_1};

R_ema  = NaN(nwindows, nparams);
SE_ema = NaN(nwindows, nparams);
R_task = NaN(nwindows, nparams);
SE_task = NaN(nwindows, nparams);

for w = 1:nwindows
    for p = 1:nparams
        k = param_idx(p);
        % EMA
        x_ema = mean(emadata(:, ema_wins{w}, k), 2);
        y_ema = mean(outgenparams_ema(:, ema_wins{w}, k), 2);
        if k == 1
            y_ema = inv_logit(y_ema, 1);
        end
        r = corr(x_ema, y_ema);
        R_ema(w,p) = r;
        SE_ema(w,p) = sqrt((1 - r^2) / (nparticipants - 2));
        % Task
        x_task = mean(taskdata(:, task_wins{w}, k), 2);
        y_task = mean(outgenparams_task(:, task_wins{w}, k), 2);
        if k == 1
            y_task = inv_logit(y_task, 1);
        end
        r = corr(x_task, y_task);
        R_task(w,p) = r;
        SE_task(w,p) = sqrt((1 - r^2) / (nparticipants - 2));
    end
end

% Combined figure: row 1 = corr by time, row 2 = bar by window (4 panels)
figure('Position', [100 100 fig12_size(1) fig12_size(2)]);

subplot(2,2,1);
h1 = plot(emacorr(:,[1 2 4]),'LineWidth',2);
text(-0.15, 1.08, 'A', 'Units', 'normalized', ...
    'FontSize', 14, 'FontWeight', 'bold');
h1(1).Color = muColor;
h1(2).Color = vmuColor;
h1(3).Color = noiseColor;
title('EMA: correlation by time')
ylabel('Correlation (gen vs rec)')
xlabel('Time point')
legend({'Mean (mu)', 'Volatility (vmu)', 'Noise (s)'},'Location','southeast');
box off


subplot(2,2,2);
h2 = plot(taskcorr(:,[1 2 4]),'LineWidth',2);
h2(1).Color = muColor;
h2(2).Color = vmuColor;
h2(3).Color = noiseColor;
title('Task: correlation by time')
ylabel('Correlation (gen vs rec)')
xlabel('Time point')
text(-0.15, 1.08, 'B', 'Units', 'normalized', ...
    'FontSize', 14, 'FontWeight', 'bold');
box off

subplot(2,2,3);
b_ema = bar(R_ema);
b_ema(1).FaceColor = muColor;
b_ema(2).FaceColor = vmuColor;
b_ema(3).FaceColor = noiseColor;
for k = 1:nparams
    b_ema(k).LineWidth = 1;
end
text(-0.15, 1.08, 'C', 'Units', 'normalized', ...
    'FontSize', 14, 'FontWeight', 'bold');
hold on
for k = 1:nparams
    errorbar(b_ema(k).XEndPoints, b_ema(k).YEndPoints, SE_ema(:,k)', 'k', 'LineStyle', 'none', 'CapSize', 6, 'LineWidth', 1);
end
set(gca, 'XTickLabel', win_names);
xlabel('Averaging window');
ylabel('Correlation (generated vs recovered)');
legend({'Mean (mu)', 'Volatility (vmu)', 'Noise (s)'}, 'Location', 'southeast');
title('EMA: correlation by window');
ylim([0 1.1]);
box off

subplot(2,2,4);
b_task = bar(R_task);
b_task(1).FaceColor = muColor;
b_task(2).FaceColor = vmuColor;
b_task(3).FaceColor = noiseColor;
for k = 1:nparams
    b_task(k).LineWidth = 1;
end
text(-0.15, 1.08, 'D', 'Units', 'normalized', ...
    'FontSize', 14, 'FontWeight', 'bold');
hold on
for k = 1:nparams
    errorbar(b_task(k).XEndPoints, b_task(k).YEndPoints, SE_task(:,k)', 'k', 'LineStyle', 'none', 'CapSize', 6, 'LineWidth', 1);
end
set(gca, 'XTickLabel', win_names);
xlabel('Averaging window');
ylabel('Correlation (generated vs recovered)');
legend({'Mean', 'Volatility (vmu)', 'Noise (s)'}, 'Location', 'best');
title('Task: correlation by window');
ylim([0 1.1]);
box off
print(gcf, fullfile(figdir, 'step2_corr_by_time_and_window.png'), '-dpng', '-r300');

%%

% Combined EMA + Task scatter figure (2x3 panels)
figure('Position', [100 100 fig3_size(1) fig3_size(2)]);

titles = {'Mean','Volatility','Noise'};
ylabels_rec = {'Recovered Mean (\mu)', ...
               'Recovered Volatility (vmu)',...
               'Recovered Noise (SD)'};
xlabels_gen = {'Generated Mean (\mu)', ...
               'Generated Volatility (vmu)',...
               'Generated Noise (SD)'};
param_idx   = [1 2 4];   % actual parameter indices
paramColors_scatter = [muColor; vmuColor; noiseColor];  % color per parameter

% Row 1: EMA
for i = 1:3
    k = param_idx(i);      % real parameter index
    % x = generated (true), y = recovered (filter); both mu already in 0-1 (gen converted at top, rec from filter)
    x = mean(outgenparams_ema(:,ema_win,k),2);
    y = mean(emadata(:,ema_win,k),2);
    % No extra conversion for mu: generated was inv_logit at top; recovered muEst is already 0-1

    subplot(2,3,i)
    hold on

    % Perfect recovery line (grey dashed diagonal)
    lims = [min([x(:); y(:)])-0.1, max([x(:); y(:)])+0.1];
    plot(lims, lims, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.5);

    % Scatter with specified colors
    scatter(x,y,60,'.','MarkerEdgeColor',paramColors_scatter(i,:), ...
                    'MarkerFaceColor','none', ...
                    'LineWidth',1.2);


    % Regression line (y on x)
    p = polyfit(x,y,1);
    xx = linspace(min(x),max(x),100);
    yy = polyval(p,xx);
    plot(xx,yy,'k','LineWidth',3);

    % Correlation
    r = corr(x,y);
    text(min(x)+0.1*(range(x)), ...
         max(y)-0.1*(range(y)), ...
         ['r = ' num2str(r,2)], ...
         'FontSize',12);

    xlabel(xlabels_gen{i})
    ylabel(ylabels_rec{i})
    title(['EMA ' titles{i}])
    xlim(lims);
    ylim(lims);

    % Panel label A-C
    text(-0.15, 1.08, char('A' + (i-1)), 'Units', 'normalized', ...
         'FontSize', 14, 'FontWeight', 'bold');

    axis square
    box off
    set(gca,'FontSize',10,'LineWidth',1.5)

end

% Row 2: Task
for i = 1:3
    k = param_idx(i);      % real parameter index
    % x = generated (true), y = recovered (filter); both mu already in 0-1
    x = mean(outgenparams_task(:,task_win,k),2);
    y = mean(taskdata(:,task_win,k),2);
    % No extra conversion for mu (same as EMA)

    subplot(2,3,3+i)
    hold on

    % Perfect recovery line (grey dashed diagonal)
    lims = [min([x(:); y(:)])-0.1, max([x(:); y(:)])+0.1];
    plot(lims, lims, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.5);

    % Scatter (open circles) with specified colors
    scatter(x,y,60,'.','MarkerEdgeColor',paramColors_scatter(i,:), ...
                    'MarkerFaceColor','none', ...
                    'LineWidth',1.2);

    % Regression line (y on x)
    p = polyfit(x,y,1);
    xx = linspace(min(x),max(x),100);
    yy = polyval(p,xx);
    plot(xx,yy,'k','LineWidth',3);

    % Correlation
    r = corr(x,y);
    text(min(x)+0.1*(range(x)), ...
         max(y)-0.1*(range(y)), ...
         ['r = ' num2str(r,2)], ...
         'FontSize',12);

    xlabel(xlabels_gen{i})
    ylabel(ylabels_rec{i})
    title(['Task ' titles{i}])

    % Panel label D-F
    text(-0.15, 1.08, char('D' + (i-1)), 'Units', 'normalized', ...
         'FontSize', 14, 'FontWeight', 'bold');
    xlim(lims);
    ylim(lims);

    axis square
    box off
    set(gca,'FontSize',10,'LineWidth',1.5)

end

print(gcf, fullfile(figdir, 'step2_scatter_ema_task.png'), '-dpng', '-r300');

%% Heatmaps: filter posterior over time, participant 1 (EMA)
% Three heatmaps (mu, vmu, noise): x = time, y = learner grid, color = learner(1).ema.*Dist; red line = true for pp1.
pp1 = 6;
L = learner(pp1).ema;
ema_nt_hm = size(L.muDist, 1);

% Grids and distributions for mu, vmu, s
y_grids = { L.muvec(:)', L.vmulog(:)', L.slog(:)' };
H_mats  = { L.muDist, L.vmuDist, L.sDist };
titles_hm = {'Mean (\mu)', 'Volatility (vmu)', 'Noise (s)'};

% True underlying values for pp1 (same space as grids: mu normal, vmu/s log)
true_mu  = inv_logit(outgenparams_ema(pp1,:,1));  % 0-1 -> normal
true_vmu = squeeze(outgenparams_ema(pp1,:,2));
true_s   = squeeze(outgenparams_ema(pp1,:,4));
true_vals_hm = { true_mu, true_vmu, true_s };

figure('Position', [100 100 900 380], 'Color', 'w');
for i = 1:3
    y_grid = y_grids{i};
    H = H_mats{i};   % (time x grid)
    subplot(1,3,i);
    imagesc(1:ema_nt_hm, y_grid, H');
    set(gca, 'YDir', 'normal');
    colormap(gca, parula);
    cb = colorbar;
    cb.Label.String = 'density';
    hold on;
    plot(1:ema_nt_hm, true_vals_hm{i}, 'r', 'LineWidth', 2.5);
    xlabel('Time point');
    ylabel('Parameter value');
    title(titles_hm{i});
    xlim([1 ema_nt_hm]);
    ylim([y_grid(1) y_grid(end)]);
    box off;
    set(gca, 'FontSize', 10);
end
sgtitle('EMA (participant 1): filter posterior over time (red = true)', 'FontWeight', 'normal', 'FontSize', 11);
print(gcf, fullfile(figdir, 'step2_heatmap_pp1_mu_vmu_noise.png'), '-dpng', '-r300');
