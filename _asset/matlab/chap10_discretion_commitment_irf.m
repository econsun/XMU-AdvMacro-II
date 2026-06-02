% Chapter 10: Optimal monetary policy IRFs under discretion and commitment
% This script reproduces the data behind Figures 5.1 and 5.2 in the
% "Discretion vs Commitment" slides.
%
% Model:
%   pi_t = beta E_t pi_{t+1} + kappa x_t + u_t
%   loss  = sum beta^t (pi_t^2 + alpha_x x_t^2)
%
% Notes:
%   1. The slide text says rho_u = 0.5 for the persistent shock, but the
%      plotted shock path is rho_u = 0.8 because u_12 is about 0.8^12.
%      The script therefore uses rho_u = 0.8 to match the plotted data.
%   2. The shock is normalized to 1, i.e. a 1 percent cost-push shock.

clear;
close all;
clc;

set(groot, 'defaultTextInterpreter', 'latex');
set(groot, 'defaultAxesTickLabelInterpreter', 'latex');
set(groot, 'defaultLegendInterpreter', 'latex');

%% Calibration
beta = 0.99;
epsilon = 6.00;
kappa = 0.1275;
alpha_x = kappa / epsilon;

T = 12;
t = (0:T)';
shock_size = 1.0;

script_dir = fileparts(mfilename('fullpath'));
figure_dir = fullfile(script_dir, '..', 'figures');
if ~exist(figure_dir, 'dir')
    mkdir(figure_dir);
end

fprintf('Calibration:\n');
fprintf('  beta    = %.6f\n', beta);
fprintf('  epsilon = %.6f\n', epsilon);
fprintf('  kappa   = %.6f\n', kappa);
fprintf('  alpha_x = %.6f\n\n', alpha_x);

%% Figure 5.1: transitory cost-push shock
rho_u = 0.0;
fig51 = compute_irfs(beta, kappa, alpha_x, rho_u, shock_size, T);
print_irf_table('Figure 5.1: transitory shock', t, fig51);
plot_irf_figure( ...
    t, fig51, ...
    'IRFs to a Transitory Cost-push Shock', ...
    fullfile(figure_dir, 'chap10-discretion-commitment-irf-transitory'), ...
    [-3.5, 0.5], [-0.25, 0.60], [-0.10, 0.65], [-0.20, 1.10]);

%% Figure 5.2: persistent cost-push shock
rho_u = 0.8;
fig52 = compute_irfs(beta, kappa, alpha_x, rho_u, shock_size, T);
print_irf_table('Figure 5.2: persistent shock', t, fig52);
plot_irf_figure( ...
    t, fig52, ...
    'IRFs to a Persistent Cost-push Shock', ...
    fullfile(figure_dir, 'chap10-discretion-commitment-irf-persistent'), ...
    [-6.3, 0.6], [-0.15, 1.05], [0.0, 5.0], [-0.20, 1.10]);

%% Export the simulated data
write_irf_csv(fullfile(script_dir, 'chap10_irf_figure_5_1.csv'), t, fig51);
write_irf_csv(fullfile(script_dir, 'chap10_irf_figure_5_2.csv'), t, fig52);

%% Local functions
function irf = compute_irfs(beta, kappa, alpha_x, rho_u, shock_size, T)
    t = (0:T)';
    u = shock_size * rho_u .^ t;
    if rho_u == 0
        u(2:end) = 0;
    end

    % Discretion:
    %   pi_t = alpha_x * Psi * u_t
    %   x_t  = -kappa * Psi * u_t
    Psi = 1 / (kappa^2 + alpha_x * (1 - beta * rho_u));
    pi_d = alpha_x * Psi * u;
    x_d = -kappa * Psi * u;
    p_d = cumsum(pi_d);

    % Commitment:
    %   p_tilde_t = delta p_tilde_{t-1}
    %               + delta / (1 - delta beta rho_u) * u_t
    %   x_t = -(kappa / alpha_x) p_tilde_t
    a = alpha_x / (kappa^2 + alpha_x * (1 + beta));
    delta = (1 - sqrt(1 - 4 * beta * a^2)) / (2 * a * beta);
    p_coeff = delta / (1 - delta * beta * rho_u);

    p_c = zeros(T + 1, 1);
    p_lag = 0.0;
    for idx = 1:(T + 1)
        p_c(idx) = delta * p_lag + p_coeff * u(idx);
        p_lag = p_c(idx);
    end
    pi_c = [p_c(1); diff(p_c)];
    x_c = -(kappa / alpha_x) * p_c;

    irf = struct();
    irf.rho_u = rho_u;
    irf.Psi = Psi;
    irf.a = a;
    irf.delta = delta;
    irf.u = u;
    irf.x_discretion = x_d;
    irf.pi_discretion = pi_d;
    irf.p_discretion = p_d;
    irf.x_commitment = x_c;
    irf.pi_commitment = pi_c;
    irf.p_commitment = p_c;
end

function print_irf_table(title_text, t, irf)
    fprintf('%s\n', title_text);
    fprintf('  rho_u = %.6f, Psi = %.6f, delta = %.6f\n', ...
        irf.rho_u, irf.Psi, irf.delta);

    data_table = table( ...
        t, ...
        irf.u, ...
        irf.x_discretion, ...
        irf.pi_discretion, ...
        irf.p_discretion, ...
        irf.x_commitment, ...
        irf.pi_commitment, ...
        irf.p_commitment, ...
        'VariableNames', { ...
            't', ...
            'cost_push_shock', ...
            'output_gap_discretion', ...
            'inflation_discretion', ...
            'price_level_discretion', ...
            'output_gap_commitment', ...
            'inflation_commitment', ...
            'price_level_commitment'});
    disp(data_table);
end

function write_irf_csv(filename, t, irf)
    data_table = table( ...
        t, ...
        irf.u, ...
        irf.x_discretion, ...
        irf.pi_discretion, ...
        irf.p_discretion, ...
        irf.x_commitment, ...
        irf.pi_commitment, ...
        irf.p_commitment, ...
        'VariableNames', { ...
            't', ...
            'cost_push_shock', ...
            'output_gap_discretion', ...
            'inflation_discretion', ...
            'price_level_discretion', ...
            'output_gap_commitment', ...
            'inflation_commitment', ...
            'price_level_commitment'});
    writetable(data_table, filename);
end

function plot_irf_figure(t, irf, title_text, output_base, ylim_x, ylim_pi, ylim_p, ylim_u)
    fig = figure('Color', 'w', 'Name', title_text, 'Position', [100, 100, 1180, 760]);
    tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'loose');

    discretion_color = [0.10, 0.35, 0.70];
    commitment_color = [0.80, 0.25, 0.18];
    discretion_style = {'-', 'LineWidth', 2.0, 'Color', discretion_color};
    commitment_style = {'--', 'LineWidth', 2.0, 'Color', commitment_color};

    series = {
        irf.x_discretion,  irf.x_commitment,  'Output Gap',        ylim_x;
        irf.pi_discretion, irf.pi_commitment, 'Inflation',         ylim_pi;
        irf.p_discretion,  irf.p_commitment,  'Price Level',       ylim_p;
        irf.u,             [],                'Cost Push Shock',   ylim_u
    };

    for j = 1:size(series, 1)
        nexttile;
        hold on;
        yline(0, '--', 'Color', [0.45, 0.45, 0.45], 'LineWidth', 0.9);
        h1 = plot(t, series{j, 1}, discretion_style{:});
        if ~isempty(series{j, 2})
            h2 = plot(t, series{j, 2}, commitment_style{:});
        end
        format_chap04_axes(t, series{j, 4});
        title(series{j, 3}, 'Interpreter', 'latex', 'FontSize', 20);

        if j == 1
            legend([h1, h2], {'discretion', 'commitment'}, 'Location', 'southeast');
        end
    end

    exportgraphics(fig, [output_base, '.png'], 'Resolution', 300);
    exportgraphics(fig, [output_base, '.pdf'], 'ContentType', 'vector');
end

function format_chap04_axes(t, y_limits)
    box on;
    grid on;
    xlim([t(1), t(end)]);
    ylim(y_limits);
    xticks(0:2:t(end));
    yl = ylim;
    yticks(linspace(yl(1), yl(2), 7));
    ytickformat('%.2g');
    ax = gca;
    ax.FontSize = 16;
end
