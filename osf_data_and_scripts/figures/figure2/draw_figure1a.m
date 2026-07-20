function draw_figure1a(ax)
% DRAW_FIGURE1A  Recreates the DAG diagram from figure1a.png programmatically.

if nargin < 1
    figure; ax = gca;
end

axes(ax);
cla(ax);
hold(ax, 'on');
axis(ax, 'equal');
axis(ax, 'off');
xlim(ax, [0 10]);
ylim(ax, [0 13]);

green = [0 176 80]./255;
red   = [255 0 0]./255;
blue  = [0 112 192]./255;
gray  = [0.82 0.82 0.82];

r = 1;   % circle radius

% --- Node centres (x, y) ---
pos.kmu = [3.8, 11.8];
pos.vS = [6.8, 10.5];
pos.vmu = [3.2,  8.8];
pos.S  = [6.2,  7.5];
pos.mu  = [3.2,  5.8];
pos.yt  = [4.8,  3.2];

% =========================================================
% Helper: draw arrowhead as a filled triangle in data coords
% hw = half-width, hl = head length
% =========================================================
    function draw_arrowhead(x_tip, y_tip, dx, dy, col, hw, hl)
        % Normalise direction
        d = sqrt(dx^2 + dy^2);
        ux = dx/d; uy = dy/d;
        % Perpendicular
        px = -uy; py = ux;
        % Three vertices: tip, left-base, right-base
        xv = [x_tip, x_tip - hl*ux + hw*px, x_tip - hl*ux - hw*px];
        yv = [y_tip, y_tip - hl*uy + hw*py, y_tip - hl*uy - hw*py];
        patch(ax, xv, yv, col, 'EdgeColor', col, 'LineWidth', 0.5);
    end

% =========================================================
% Helper: draw a filled circle
% =========================================================
    function draw_circle(cx, cy, radius, facecolor, edgecolor, linestyle, lw, pattern)
        if nargin < 8, pattern = 'none'; end
        theta = linspace(0, 2*pi, 360);
        xc = cx + radius*cos(theta);
        yc = cy + radius*sin(theta);
        fill(ax, xc, yc, facecolor, 'EdgeColor', edgecolor, ...
            'LineStyle', linestyle, 'LineWidth', lw);
        if strcmp(pattern, 'stipple')
            dot_spacing = 0.13;
            xs = cx - radius : dot_spacing : cx + radius;
            ys = cy - radius : dot_spacing : cy + radius;
            [gx, gy] = meshgrid(xs, ys);
            inside = (gx-cx).^2 + (gy-cy).^2 <= (radius*0.92)^2;
            scatter(ax, gx(inside), gy(inside), 3, [0.55 0.55 0.55], ...
                'filled', 'MarkerFaceAlpha', 0.7);
        end
    end

% =========================================================
% Draw nodes
% =========================================================

draw_circle(pos.kmu(1), pos.kmu(2), r, [1 1 1], [0 0 0], '-', 1.5);
text(ax, pos.kmu(1), pos.kmu(2), '\itkmu', ...
    'HorizontalAlignment','center','VerticalAlignment','middle', ...
    'FontName','Times','FontSize',10,'FontWeight','bold');

draw_circle(pos.vS(1), pos.vS(2), r, gray, [0 0 0], '-', 1.5);
text(ax, pos.vS(1), pos.vS(2), '\itvS', ...
    'HorizontalAlignment','center','VerticalAlignment','middle', ...
    'FontName','Times','FontSize',10,'FontWeight','bold');

draw_circle(pos.vmu(1), pos.vmu(2), r, [1 1 1], red, ':', 1.5);
text(ax, pos.vmu(1), pos.vmu(2), '\itvmu_t', ...
    'HorizontalAlignment','center','VerticalAlignment','middle', ...
    'FontName','Times','FontSize',10,'FontWeight','bold');

draw_circle(pos.S(1), pos.S(2), r, gray, blue, '--', 1.5);
text(ax, pos.S(1), pos.S(2), '\itS_t', ...
    'HorizontalAlignment','center','VerticalAlignment','middle', ...
    'FontName','Times','FontSize',10,'FontWeight','bold');

draw_circle(pos.mu(1), pos.mu(2), r, [1 1 1], green, '-', 1.5);
text(ax, pos.mu(1), pos.mu(2), '\itmu_t', ...
    'HorizontalAlignment','center','VerticalAlignment','middle', ...
    'FontName','Times','FontSize',10,'FontWeight','bold');

% y_t: stipple fill then redraw border on top
draw_circle(pos.yt(1), pos.yt(2), r, [1 1 1], [0 0 0], '-', 1.5, 'stipple');
theta = linspace(0,2*pi,360);
plot(ax, pos.yt(1)+r*cos(theta), pos.yt(2)+r*sin(theta), 'k-', 'LineWidth', 1.5);
text(ax, pos.yt(1), pos.yt(2), '\ity_t', ...
    'HorizontalAlignment','center','VerticalAlignment','middle', ...
    'FontName','Times','FontSize',10,'FontWeight','bold');

% =========================================================
% Helper: arrow between edges of two circles (all in data coords)
% =========================================================
    function edge_arrow(p1, p2, col, lw, lstyle, hw, hl)
        dx = p2(1)-p1(1); dy = p2(2)-p1(2);
        d  = sqrt(dx^2+dy^2);
        ux = dx/d; uy = dy/d;
        x1 = p1(1) + r*ux;  y1 = p1(2) + r*uy;
        x2 = p2(1) - r*ux;  y2 = p2(2) - r*uy;
        % Shorten shaft slightly so it doesn't overlap the arrowhead
        xs = x2 - hl*ux;    ys = y2 - hl*uy;
        plot(ax, [x1 xs], [y1 ys], 'Color', col, 'LineWidth', lw, 'LineStyle', lstyle);
        draw_arrowhead(x2, y2, dx, dy, col, hw, hl);
    end

    function dashed_arrow_right(px, py, x_end, col, lw, hw, hl)
        x_start = px + r;
        xs = x_end - hl;   % shorten shaft for arrowhead
        plot(ax, [x_start xs], [py py], 'Color', col, 'LineWidth', lw, 'LineStyle', '--');
        draw_arrowhead(x_end, py, 1, 0, col, hw, hl);
    end

% =========================================================
% Draw edges
% =========================================================
edge_arrow(pos.kmu, pos.vmu, [0 0 0], 2.0, '-',  0.18, 0.25);
edge_arrow(pos.vS, pos.S,  [0 0 0], 2.0, '-',  0.18, 0.25);
edge_arrow(pos.vmu, pos.mu,  red,     2.0, ':',   0.18, 0.25);
edge_arrow(pos.mu,  pos.yt,  [0 0 0], 2.0, '-',  0.18, 0.25);
edge_arrow(pos.S,  pos.yt,  blue,    2.0, '-',  0.18, 0.25);

% Three rightward dashed arrows, all ending at same x
x_end_common = max([pos.vmu(1), pos.S(1), pos.mu(1)]) + r + 2.5;
dashed_arrow_right(pos.vmu(1), pos.vmu(2), x_end_common, [0 0 0], 1.5, 0.15, 0.22);
dashed_arrow_right(pos.S(1),  pos.S(2),  x_end_common, [0 0 0], 1.5, 0.15, 0.22);
dashed_arrow_right(pos.mu(1),  pos.mu(2),  x_end_common, [0 0 0], 1.5, 0.15, 0.22);

hold(ax,'off');
end