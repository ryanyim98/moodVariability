% Purpose: assembles the paper's Figure 2 (Bayesian filter schematic): panel A is
% the DAG drawn by draw_figure1a.m, panel B is the illustrative uncertainty example
% from plot_example_uncert.m, panels C/D are the pre-rendered fig1c.png (generated
% by plot_uncert_series.m from 7_bayes_mod.mat/out.mat -- not regenerated here, see
% the commented-out call below).
% Inputs (same folder): fig1c.png. Outputs: figure_2.png, figure_2.pdf (copy into
% <pkg_root>/figures/ to match figure_3/figure_4).
% Requires external MATLAB toolboxes not vendored in this repo -- EDIT the addpath
% lines below to point at your local install of each:
%   - makefigure (https://github.com/... or your local copy)
%   - export_fig (https://github.com/altmany/export_fig)
close all
clear
script_dir = "~/Desktop/MoodInstability/moodVariability/osf_data_and_scripts/scripts/05_figure2_schematic"; % EDIT: path to this folder on your machine
addpath(script_dir)
cd(script_dir)
addpath("~/Documents/MATLAB/makefigure/")   % EDIT: path to makefigure on your machine
addpath("~/Documents/MATLAB/export_fig/")   % EDIT: path to export_fig on your machine

% plot_uncert_series();
% close all;

green = [0 176 80]./255;
red   = [255 0 0]./255;
blue  = [0 112 192]./255;

% Figure dimensions match the portrait aspect ratio of the original figure1a.png
% Original figure1a was 3601x4513 px (~0.8 w:h ratio).
% Full figure (4 panels) is roughly square; 560 wide x 700 tall works well.
f1 = figure('Units', 'pixels', 'Position', [100 100 500 400]);
hold on;
set(gca, 'Layer', 'top', 'linewidth', 3);
set(f1, 'color', [1 1 1]);

% ── Panel A: DAG diagram (replaces imread / image of figure1a.png) ──────────
s1 = subplot(2, 2, 1);
s1.Position = [0.18 0.5 0.34 0.5];
draw_figure1a(s1);       

% ── Panel B: uncertainty example ────────────────────────────────────────────
s2 = subplot(2, 2, 2);
hold on;
plot_example_uncert();

xposvol  = [0.773 0.705];
yposvol  = 0.895;
xposnoise = [0.725 0.82];
yposnoise = 0.8;

annotation('line', [xposvol(1) xposvol(1)], [(yposvol-0.14) yposvol+0.05], ...
    'color', green, 'linewidth', 1.5, 'linestyle', '-');
annotation('textbox', 'linestyle', 'none', 'position', [0.755 0.71 0.05 0.05], ...
    'string', '\itmu_t', 'color', green, 'fontname', 'Times', ...
    'fontweight', 'bold', 'fontsize', 8);
annotation('textbox', 'linestyle', 'none', 'position', [0.68 0.71 0.05 0.05], ...
    'string', '\itmu_t_+_1', 'color', green, 'fontname', 'Times', ...
    'fontweight', 'bold', 'fontsize', 8);
annotation('line', [xposvol(2) xposvol(2)], [(yposvol-0.14) yposvol+0.05], ...
    'color', green, 'linewidth', 1.5, 'linestyle', '-');
annotation('arrow', [xposvol(1) xposvol(2)], [yposvol+0.02 yposvol+0.02], ...
    'color', red, 'linewidth', 1.5, 'linestyle', ':', 'HeadWidth', 5, 'HeadLength', 5);
annotation('textbox', 'linestyle', 'none', 'position', [0.77 0.89 0.05 0.05], ...
    'string', 'exp(\itvmu_t)', 'color', red, 'fontname', 'Times', ...
    'fontweight', 'bold', 'fontsize', 8);
annotation('doublearrow', [xposnoise(2) xposnoise(1)], [yposnoise yposnoise], ...
    'color', blue, 'linewidth', 1.5, 'linestyle', '--', ...
    'Head1Width', 5, 'Head1Length', 5, 'Head2Width', 5, 'Head2Length', 5);
annotation('textbox', 'linestyle', 'none', 'position', [0.82 0.77 0.05 0.05], ...
    'string', 'exp(\itS_t)', 'color', blue, 'fontname', 'Times', ...
    'fontweight', 'bold', 'fontsize', 8);

yt_loc = [0.84 0.67 0.05 0.05];
annotation('textbox', 'linestyle', 'none', 'position', yt_loc, ...
    'string', '\ity_t', 'color', 'k', 'fontname', 'Times', ...
    'fontweight', 'bold', 'fontsize', 8);
annotation('arrow', [yt_loc(1)+0.005 yt_loc(1)], ...
    [yt_loc(2)+0.035 yt_loc(2)+0.059], ...
    'color', 'k', 'linewidth', 1.5, 'HeadWidth', 5, 'HeadLength', 5);

% ── Panels C and D: fig1c image ──────────────────────────────────────────────
s2 = subplot(2, 2, 4);
s2.Position = [0.15 0.01 0.7 0.51];
image( imread('fig1c.png') );
axis off;

annotation('textbox', 'linestyle', 'none', 'position', [0.59 0.57 0.86 0.05], ...
    'string', '0', 'fontname', 'Arial', 'fontweight', 'bold', 'fontsize', 8);
annotation('textbox', 'linestyle', 'none', 'position', [0.715 0.57 0.85 0.05], ...
    'string', '0.5', 'fontname', 'Arial', 'fontweight', 'bold', 'fontsize', 8);
annotation('textbox', 'linestyle', 'none', 'position', [0.855 0.57 0.85 0.05], ...
    'string', '1', 'fontname', 'Arial', 'fontweight', 'bold', 'fontsize', 8);
annotation('textbox', 'linestyle', 'none', 'position', [0.62 0.55 0.85 0.05], ...
    'string', 'Standardised movement', 'fontname', 'Arial', ...
    'fontweight', 'bold', 'fontsize', 8);

% ── Panel labels ─────────────────────────────────────────────────────────────
annotation('textbox', 'linestyle', 'none', 'position', [0.13 0.93 0.05 0.05], ...
    'string', 'A', 'fontname', 'Arial', 'fontsize', 14);
annotation('textbox', 'linestyle', 'none', 'position', [0.53 0.93 0.05 0.05], ...
    'string', 'B', 'fontname', 'Arial', 'fontsize', 14);
annotation('textbox', 'linestyle', 'none', 'position', [0.13 0.5 0.05 0.05], ...
    'string', 'C', 'fontname', 'Arial', 'fontsize', 14);
annotation('textbox', 'linestyle', 'none', 'position', [0.13 0.25 0.05 0.05], ...
    'string', 'D', 'fontname', 'Arial', 'fontsize', 14);

pkg_root = find_pkg_root(script_dir);
figdir = fullfile(pkg_root, "figures");
if ~isfolder(figdir), mkdir(figdir); end
export_fig(f1, fullfile(figdir, 'figure_2.png'), '-r 300');
exportgraphics(f1, fullfile(figdir, 'figure_2.pdf'), 'Resolution', 300, 'ContentType', 'vector');