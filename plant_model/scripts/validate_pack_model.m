% validate_pack_model.m
% Validates pack_96s.slx against all measurement trips.
%
% For each trip:
%   1. Builds a Simulink.SimulationData.Dataset with per-inport timeseries
%   2. Simulates pack_96s
%   3. Compares V_pack and mean SoC against measured data
%   4. Saves per-trip plot to plant_model/plots/trips/
%
% After all trips:
%   5. Saves validation_results.csv
%   6. Saves summary plots (RMSE histogram, RMSE vs temperature)
%
% Usage:
%   >> run('plant_model/scripts/init_plant_model.m')   % if not already loaded
%   >> run('plant_model/scripts/validate_pack_model.m')

%% ======================================================================
%  Configuration
%  ======================================================================
CAMPAIGN     = 'all';      % 'A', 'B', or 'all'
SAVE_PLOTS   = true;
CLOSE_FIGS   = true;       % close figures after saving (saves memory)
VERBOSE      = true;
T_DISP_STD   = 1.0;        % [°C] std-dev of cell-to-cell initial temperature dispersion

%% ======================================================================
%  Paths
%  ======================================================================
scriptDir = fileparts(mfilename('fullpath'));
dataDir   = fullfile(scriptDir, '..', 'data');
plotDir   = fullfile(scriptDir, '..', 'plots', 'trips');
summDir   = fullfile(scriptDir, '..', 'plots');
modelDir  = fullfile(scriptDir, '..', 'models');

if ~exist(plotDir, 'dir'), mkdir(plotDir); end
if ~exist(summDir, 'dir'), mkdir(summDir); end

%% ======================================================================
%  Load parameters and data
%  ======================================================================
% Ensure workspace is initialized
if ~exist('OCV_data', 'var')
    run(fullfile(scriptDir, 'init_plant_model.m'));
end

% Load measurement drive-cycle data
measMat = fullfile(dataDir, 'drivecycles_meas.mat');
if ~isfile(measMat)
    error('validate_pack_model:noData', ...
        'drivecycles_meas.mat not found. Run export_drivecycles.m first.');
end
allTrips = load(measMat);
tripNames = sort(fieldnames(allTrips));
fprintf('Loaded %d measurement trips.\n', numel(tripNames));

% Filter by campaign
if ~strcmpi(CAMPAIGN, 'all')
    prefix = ['Trip' upper(CAMPAIGN)];
    tripNames = tripNames(startsWith(tripNames, prefix));
    fprintf('Filtered to campaign %s: %d trips.\n', upper(CAMPAIGN), numel(tripNames));
end

%% ======================================================================
%  Load model & fix algebraic loop (idempotent)
%  ======================================================================
% Close any previously loaded models to ensure clean state from disk
bdclose('all');

% Add models directory to path so referenced models (module_12s,
% cell_ecm_2rc) can be found during load and simulation.
addpath(modelDir);

mdl = 'pack_96s';
modelPath = fullfile(modelDir, mdl);
load_system(modelPath);
fprintf('Model %s loaded.\n', mdl);

% Ensure referenced models are loaded for simulation.
refModels = find_mdlrefs(mdl, 'AllLevels', true);
for i = 1:numel(refModels)
    load_system(refModels{i});
end
fprintf('Loaded %d referenced models.\n', numel(refModels));

% Suppress algebraic loop diagnostic in model hierarchy
run(fullfile(scriptDir, 'fix_soc_algebraic_loop.m'));
fprintf('\n');

%% ======================================================================
%  Validate each trip
%  ======================================================================
nTrips  = numel(tripNames);
results = table('Size', [nTrips, 18], ...
    'VariableTypes', repmat({'double'}, 1, 18), ...
    'VariableNames', {'duration_s', 'n_samples', ...
                      'T_mean', 'T_min', 'T_max', ...
                      'T_amb_mean', ...
                      'soc_start', 'soc_end_meas', 'soc_end_sim', ...
                      'rmse_V_mV', 'mae_V_mV', 'max_err_V_mV', 'bias_V_mV', ...
                      'rmse_SoC_pct', ...
                      'rmse_T_C', 'mae_T_C', 'max_err_T_C', 'bias_T_C'});
results.trip_id  = tripNames;
results.campaign = repmat({''}, nTrips, 1);

for k = 1:nTrips
    tid  = tripNames{k};
    trip = allTrips.(tid);

    % --- Extract trip data ---
    t_raw  = double(trip.time_s(:));
    t_s    = t_raw - t_raw(1);               % zero-referenced time
    I_A    = double(trip.I_A(:));             % positive = discharge
    V_meas = double(trip.V_pack_V(:));        % pack voltage [V]
    SoC_m  = double(trip.SoC_pct(:));         % measured SoC [%]
    T_cell = double(trip.T_cell_C(:));        % battery temperature [deg C]

    % Ambient temperature
    if isfield(trip, 'T_amb_C')
        T_amb_trip = double(trip.T_amb_C(:));
    else
        T_amb_trip = T_cell;  % fallback: use battery temp if no ambient
    end

    N_samp = numel(t_s);
    dur    = t_s(end);
    camp   = trip.campaign;

    % SoC initial condition
    soc0 = SoC_m(1);

    % % Coolant initial condition
    % if isfield(trip, 'T_cool_C') && trip.T_cool_C(1) ~= 0
    %     T_cool0 = double(trip.T_cool_C(1));  % use measured coolant inlet temp
    % else
    %     % No coolant data: set T_cool_init so that TMS drives T_pack to
    %     % the optimal window [15, 25] deg C.  If T_cell is already warm
    %     % enough, just track it; if cold, pretend coolant is pre-heated.
    %     Tc1 = T_cell(1);
    %     if Tc1 < 15
    %         T_cool0 = Tc1 + 10;   % moderate pre-heat offset
    %     else
    %         T_cool0 = Tc1;        % already in range, no TMS action needed
    %     end
    % end

    %% --- Coolant initial condition -----------------------------------------
    % On utilise une fonction plus robuste pour le capteur
    if isfield(trip, 'T_cool_C') && ~isnan(trip.T_cool_C(1)) && trip.T_cool_C(1) ~= 0
        T_cool0 = double(trip.T_cool_C(1)); 
    else
        Tc1 = T_cell(1);
        if Tc1 < T_heat_on
            % Si on est sous le seuil d'allumage, on simule un pré-chauffage fort
            T_cool0 = Tc1 + 15; % Aligné sur vos observations Campaign B
        elseif Tc1 < T_heat_off
            % Si on est entre le seuil ON et OFF, le TMS est probablement déjà actif
            T_cool0 = Tc1 + 10;
        else
            % Équilibre thermique par défaut
            T_cool0 = Tc1;
        end
    end

    % --- Per-trip initial cell temperatures with dispersion ---
    % Each cell gets a slightly different T_init; mean equals this trip's T_cell(1).
    rng(k, 'twister');                          % reproducible per trip
    dT = randn(12, 8);
    dT = dT - mean(dT(:));                       % force exact zero mean
    T_cells_init = T_cell(1) + T_DISP_STD * dT; %#ok<NASGU> workspace var for Constant

    if VERBOSE
        fprintf('[%d/%d] %s | camp=%s | dur=%.0fs | SoC0=%.1f%% | T_mean=%.1f C\n', ...
            k, nTrips, tid, camp, dur, soc0, mean(T_cell));
    end

    % --- Passive balancing algorithm ---
    % For each module (12 cells), bleed cells whose SoC exceeds the
    % module minimum by more than BAL_THRESHOLD.
    BAL_THRESHOLD = 1.0;   % [%]  SoC difference to activate balancing
    I_BLEED       = 0.1;   % [A]  passive bleed current per cell

    soc_12x8  = soc0 + cell_dSoC_pct;           % 12x8 initial SoC per cell
    I_bal     = zeros(12, 8);
    for m = 1:8
        soc_mod     = soc_12x8(:, m);
        soc_min_mod = min(soc_mod);
        need_bal    = soc_mod - soc_min_mod > BAL_THRESHOLD;
        I_bal(need_bal, m) = I_BLEED;
    end
    I_bal_default = I_bal;  %#ok<NASGU>  set workspace var for Constant4

    % --- Build input dataset (6 inports) ---
    % pack_96s inports:
    %   [1] I_pack       — timeseries [A]
    %   [2] T_amb        — timeseries [deg C]
    %   [3] SoC_init     — constant   [%]
    %   [4] T_cool_init  — constant   [deg C]
    %   [5] V_RC1_init   — constant   [V]
    %   [6] V_RC2_init   — constant   [V]

    ds = Simulink.SimulationData.Dataset;

    ts_I    = timeseries(I_A,        t_s, 'Name', 'I_pack');
    ts_Tamb = timeseries(T_amb_trip, t_s, 'Name', 'T_amb');

    t_const = [0; dur];
    ts_soc0   = timeseries(soc0    * [1; 1], t_const, 'Name', 'SoC_init');
    ts_Tcool0 = timeseries(T_cool0 * [1; 1], t_const, 'Name', 'T_cool_init');

    % V_RC_init: steady-state approximation VRCi = Ri(SoC0, T0) * I0
    I0 = I_A(1);  T0 = T_cell(1);
    % Clamp to LUT breakpoint range to avoid NaN from interp2
    T0_c   = max(min(T0,   T_bp(end)),   T_bp(1));
    soc0_c = max(min(soc0, SoC_bp_ecm(end)), SoC_bp_ecm(1));
    R1_init = interp2(T_bp, SoC_bp_ecm, R1_data, T0_c, soc0_c, 'linear');
    R2_init = interp2(T_bp, SoC_bp_ecm, R2_data, T0_c, soc0_c, 'linear');
    ts_vrc1 = timeseries(R1_init * I0 * [1; 1], t_const, 'Name', 'V_RC1_init');
    ts_vrc2 = timeseries(R2_init * I0 * [1; 1], t_const, 'Name', 'V_RC2_init');

    ds = ds.addElement(ts_I);
    ds = ds.addElement(ts_Tamb);
    ds = ds.addElement(ts_soc0);
    ds = ds.addElement(ts_Tcool0);
    ds = ds.addElement(ts_vrc1);
    ds = ds.addElement(ts_vrc2);

    % --- Configure and run simulation ---
    simIn = Simulink.SimulationInput(mdl);
    simIn = simIn.setModelParameter('StopTime',  num2str(dur));
    simIn = simIn.setModelParameter('SaveTime',  'on');
    simIn = simIn.setModelParameter('SaveOutput','on');
    simIn = simIn.setModelParameter('SaveFormat','Dataset');
    simIn = simIn.setModelParameter('ReturnWorkspaceOutputs', 'on');
    simIn = simIn.setModelParameter('ReturnWorkspaceOutputsName', 'out');
    simIn = simIn.setExternalInput(ds);

    try
        simOut = sim(simIn);
    catch ME
        warning('Trip %s failed: %s', tid, ME.message);
        if ~isempty(ME.cause)
            for ci = 1:numel(ME.cause)
                fprintf('  Cause %d: %s\n', ci, ME.cause{ci}.message);
            end
        end
        continue;
    end

    % --- Extract simulation outputs ---
    yout = simOut.yout;  % Simulink.SimulationData.Dataset

    % Helper: extract timeseries data from a Dataset element
    getTS = @(el) el.Values;

    % V_pack: outport [1]
    V_el = yout.getElement(1);
    if isa(V_el, 'Simulink.SimulationData.Signal'), V_el = getTS(V_el); end
    t_sim      = V_el.Time;
    V_pack_sim = squeeze(double(V_el.Data));

    % SoC_pack: outport [3] is SoC_cells_96 (96x1) — compute mean
    SoC_el = yout.getElement(3);
    if isa(SoC_el, 'Simulink.SimulationData.Signal'), SoC_el = getTS(SoC_el); end
    SoC_all = squeeze(double(SoC_el.Data));
    if size(SoC_all, 1) == 96
        SoC_sim = mean(SoC_all, 1)';
    else
        SoC_sim = mean(SoC_all, 2);
    end

    % T_pack: outport [8] — scalar mean cell temperature
    T_el = yout.getElement(8);
    if isa(T_el, 'Simulink.SimulationData.Signal'), T_el = getTS(T_el); end
    T_sim = squeeze(double(T_el.Data));

    % --- Interpolate measured data to simulation time grid ---
    V_meas_interp   = interp1(t_s, V_meas, t_sim, 'linear', 'extrap');
    SoC_meas_interp = interp1(t_s, SoC_m,  t_sim, 'linear', 'extrap');
    T_meas_interp   = interp1(t_s, T_cell, t_sim, 'linear', 'extrap');

    % --- Compute error metrics ---
    errV      = V_pack_sim - V_meas_interp;           % [V]
    errV_mV   = errV * 1e3;
    rmseV     = sqrt(mean(errV.^2)) * 1e3;            % [mV]
    maeV      = mean(abs(errV)) * 1e3;
    maxErrV   = max(abs(errV)) * 1e3;
    biasV     = mean(errV) * 1e3;

    errSoC    = SoC_sim - SoC_meas_interp;
    rmseSoC   = sqrt(mean(errSoC.^2));

    errT    = T_sim - T_meas_interp;
    rmseT   = sqrt(mean(errT.^2));
    maeT    = mean(abs(errT));
    maxErrT = max(abs(errT));
    biasT   = mean(errT);

    % --- Store results ---
    results.duration_s(k)    = dur;
    results.n_samples(k)     = N_samp;
    results.T_mean(k)        = mean(T_cell);
    results.T_min(k)         = min(T_cell);
    results.T_max(k)         = max(T_cell);
    results.T_amb_mean(k)    = mean(T_amb_trip);
    results.soc_start(k)     = soc0;
    results.soc_end_meas(k)  = SoC_m(end);
    results.soc_end_sim(k)   = SoC_sim(end);
    results.rmse_V_mV(k)     = rmseV;
    results.mae_V_mV(k)      = maeV;
    results.max_err_V_mV(k)  = maxErrV;
    results.bias_V_mV(k)     = biasV;
    results.rmse_SoC_pct(k)  = rmseSoC;
    results.rmse_T_C(k)      = rmseT;
    results.mae_T_C(k)       = maeT;
    results.max_err_T_C(k)   = maxErrT;
    results.bias_T_C(k)      = biasT;
    results.campaign{k}      = camp;

    if VERBOSE
        fprintf('  RMSE=%.1f mV | MAE=%.1f mV | Max=%.1f mV | Bias=%+.1f mV | SoC RMSE=%.2f%% | T RMSE=%.2f C\n', ...
            rmseV, maeV, maxErrV, biasV, rmseSoC, rmseT);
    end

    % --- Per-trip plot (V_pack, SoC_pack, T_pack only) ---
    if SAVE_PLOTS
        fig = figure('Position', [50 50 1200 800], 'Visible', 'off');

        % V_pack
        subplot(3,1,1);
        plot(t_sim, V_meas_interp, 'k', 'LineWidth', 0.7); hold on;
        plot(t_sim, V_pack_sim, 'r--', 'LineWidth', 0.7);
        ylabel('V_{pack} [V]');
        title(sprintf('%s  |  Campaign %s  |  V RMSE=%.1f mV  |  SoC RMSE=%.2f%%  |  T RMSE=%.2f °C', ...
            tid, camp, rmseV, rmseSoC, rmseT));
        legend('Measured', 'Simulated', 'Location', 'best');
        grid on;

        % SoC_pack
        subplot(3,1,2);
        plot(t_sim, SoC_meas_interp, 'k', 'LineWidth', 0.7); hold on;
        plot(t_sim, SoC_sim, 'r--', 'LineWidth', 0.7);
        ylabel('SoC_{pack} [%]');
        legend('Measured', 'Simulated', 'Location', 'best');
        grid on;

        % T_pack
        subplot(3,1,3);
        plot(t_sim, T_meas_interp, 'k', 'LineWidth', 0.7); hold on;
        plot(t_sim, T_sim, 'r--', 'LineWidth', 0.7);
        ylabel('T_{pack} [°C]');
        xlabel('Time [s]');
        legend('Measured', 'Simulated', 'Location', 'best');
        grid on;

        fig.PaperPositionMode = 'auto';
        saveas(fig, fullfile(plotDir, sprintf('val_pack_%s.png', tid)));
        if CLOSE_FIGS, close(fig); end
    end
end

close_system(mdl, 0);

%% ======================================================================
%  Save results to CSV
%  ======================================================================
csvPath = fullfile(dataDir, 'validation_results.csv');
writetable(results, csvPath);
fprintf('\nResults saved: %s\n', csvPath);

%% ======================================================================
%  Print summary
%  ======================================================================
valid = results.rmse_V_mV > 0;  % skip failed trips
res   = results(valid, :);

fprintf('\n========================================\n');
fprintf('  PACK-LEVEL VALIDATION SUMMARY\n');
fprintf('========================================\n');
fprintf('  Trips evaluated : %d / %d\n', height(res), nTrips);
fprintf('  V_pack RMSE:\n');
fprintf('    Median : %.1f mV\n', median(res.rmse_V_mV));
fprintf('    Mean   : %.1f mV\n', mean(res.rmse_V_mV));
fprintf('    Max    : %.1f mV  (%s)\n', max(res.rmse_V_mV), ...
    res.trip_id{res.rmse_V_mV == max(res.rmse_V_mV)});
fprintf('    < 500 mV : %d / %d\n', sum(res.rmse_V_mV < 500), height(res));
fprintf('    < 1000 mV: %d / %d\n', sum(res.rmse_V_mV < 1000), height(res));
fprintf('  SoC RMSE:\n');
fprintf('    Median : %.2f %%\n', median(res.rmse_SoC_pct));
fprintf('    Mean   : %.2f %%\n', mean(res.rmse_SoC_pct));
fprintf('  Temperature RMSE:\n');
fprintf('    Median : %.2f °C\n', median(res.rmse_T_C, 'omitnan'));
fprintf('    Mean   : %.2f °C\n', mean(res.rmse_T_C, 'omitnan'));
fprintf('    Max    : %.2f °C\n', max(res.rmse_T_C));

for camp = {'A', 'B'}
    c = camp{1};
    sub = res(strcmp(res.campaign, c), :);
    if isempty(sub), continue; end
    fprintf('\n  Campaign %s (%d trips):\n', c, height(sub));
    fprintf('    V RMSE : median=%.1f mV, mean=%.1f mV\n', ...
        median(sub.rmse_V_mV), mean(sub.rmse_V_mV));
    fprintf('    Bias   : mean=%+.1f mV\n', mean(sub.bias_V_mV));
    fprintf('    SoC RMSE: median=%.2f%%, mean=%.2f%%\n', ...
        median(sub.rmse_SoC_pct), mean(sub.rmse_SoC_pct));
    fprintf('    T RMSE : median=%.2f °C, mean=%.2f °C\n', ...
        median(sub.rmse_T_C, 'omitnan'), mean(sub.rmse_T_C, 'omitnan'));
    fprintf('    T range: [%.0f, %.0f] °C\n', min(sub.T_mean), max(sub.T_mean));
end

%% ======================================================================
%  Summary plots
%  ======================================================================

% --- RMSE Histogram by campaign ---
fig1 = figure('Position', [50 50 900 500], 'Visible', 'off');
hold on;
campA = res(strcmp(res.campaign, 'A'), :);
campB = res(strcmp(res.campaign, 'B'), :);
if ~isempty(campA)
    histogram(campA.rmse_V_mV, 20, 'FaceColor', [0.2 0.4 0.8], 'FaceAlpha', 0.6, ...
        'EdgeColor', 'k', 'DisplayName', sprintf('Campaign A (n=%d)', height(campA)));
end
if ~isempty(campB)
    histogram(campB.rmse_V_mV, 20, 'FaceColor', [0.9 0.5 0.1], 'FaceAlpha', 0.6, ...
        'EdgeColor', 'k', 'DisplayName', sprintf('Campaign B (n=%d)', height(campB)));
end
med = median(res.rmse_V_mV);
xline(med, 'r--', 'LineWidth', 1.5, 'DisplayName', sprintf('Median = %.1f mV', med));
xlabel('V_{pack} RMSE [mV]');
ylabel('Trip count');
title(sprintf('Pack Validation — RMSE Distribution (%d trips)', height(res)));
legend('Location', 'best');
grid on;
saveas(fig1, fullfile(summDir, 'validation_pack_rmse_hist.png'));
if CLOSE_FIGS, close(fig1); end

% --- RMSE vs Temperature ---
fig2 = figure('Position', [50 50 900 500], 'Visible', 'off');
hold on;
if ~isempty(campA)
    scatter(campA.T_mean, campA.rmse_V_mV, 50, [0.2 0.4 0.8], 'o', 'filled', ...
        'MarkerFaceAlpha', 0.7, 'DisplayName', 'Campaign A');
end
if ~isempty(campB)
    scatter(campB.T_mean, campB.rmse_V_mV, 50, [0.9 0.5 0.1], 's', 'filled', ...
        'MarkerFaceAlpha', 0.7, 'DisplayName', 'Campaign B');
end
xlabel('Mean Battery Temperature [°C]');
ylabel('V_{pack} RMSE [mV]');
title('Per-Trip Pack RMSE vs Temperature');
legend('Location', 'best');
grid on;
saveas(fig2, fullfile(summDir, 'validation_pack_rmse_vs_temp.png'));
if CLOSE_FIGS, close(fig2); end

% --- SoC RMSE vs Temperature ---
fig3 = figure('Position', [50 50 900 500], 'Visible', 'off');
hold on;
if ~isempty(campA)
    scatter(campA.T_mean, campA.rmse_SoC_pct, 50, [0.2 0.4 0.8], 'o', 'filled', ...
        'MarkerFaceAlpha', 0.7, 'DisplayName', 'Campaign A');
end
if ~isempty(campB)
    scatter(campB.T_mean, campB.rmse_SoC_pct, 50, [0.9 0.5 0.1], 's', 'filled', ...
        'MarkerFaceAlpha', 0.7, 'DisplayName', 'Campaign B');
end
xlabel('Mean Battery Temperature [°C]');
ylabel('SoC RMSE [%]');
title('Per-Trip SoC RMSE vs Temperature');
legend('Location', 'best');
grid on;
saveas(fig3, fullfile(summDir, 'validation_pack_soc_vs_temp.png'));
if CLOSE_FIGS, close(fig3); end

% --- Temperature RMSE vs Mean Temperature ---
fig3b = figure('Position', [50 50 900 500], 'Visible', 'off');
hold on;
if ~isempty(campA)
    scatter(campA.T_mean, campA.rmse_T_C, 50, [0.2 0.4 0.8], 'o', 'filled', ...
        'MarkerFaceAlpha', 0.7, 'DisplayName', 'Campaign A');
end
if ~isempty(campB)
    scatter(campB.T_mean, campB.rmse_T_C, 50, [0.9 0.5 0.1], 's', 'filled', ...
        'MarkerFaceAlpha', 0.7, 'DisplayName', 'Campaign B');
end
xlabel('Mean Battery Temperature [°C]');
ylabel('Temperature RMSE [°C]');
title('Per-Trip Temperature RMSE vs Mean Temperature');
legend('Location', 'best');
grid on;
saveas(fig3b, fullfile(summDir, 'validation_pack_temp_rmse_vs_temp.png'));
if CLOSE_FIGS, close(fig3b); end

% --- Temperature RMSE Histogram ---
fig3c = figure('Position', [50 50 900 500], 'Visible', 'off');
hold on;
if ~isempty(campA)
    histogram(campA.rmse_T_C, 20, 'FaceColor', [0.2 0.4 0.8], 'FaceAlpha', 0.6, ...
        'EdgeColor', 'k', 'DisplayName', sprintf('Campaign A (n=%d)', height(campA)));
end
if ~isempty(campB)
    histogram(campB.rmse_T_C, 20, 'FaceColor', [0.9 0.5 0.1], 'FaceAlpha', 0.6, ...
        'EdgeColor', 'k', 'DisplayName', sprintf('Campaign B (n=%d)', height(campB)));
end
medT = median(res.rmse_T_C, 'omitnan');
xline(medT, 'r--', 'LineWidth', 1.5, 'DisplayName', sprintf('Median = %.2f °C', medT));
xlabel('Temperature RMSE [°C]');
ylabel('Trip count');
title(sprintf('Pack Validation — Temperature RMSE Distribution (%d trips)', height(res)));
legend('Location', 'best');
grid on;
saveas(fig3c, fullfile(summDir, 'validation_pack_temp_rmse_hist.png'));
if CLOSE_FIGS, close(fig3c); end

% --- Bias vs SoC start ---
fig4 = figure('Position', [50 50 900 500], 'Visible', 'off');
hold on;
if ~isempty(campA)
    scatter(campA.soc_start, campA.bias_V_mV, 50, [0.2 0.4 0.8], 'o', 'filled', ...
        'MarkerFaceAlpha', 0.7, 'DisplayName', 'Campaign A');
end
if ~isempty(campB)
    scatter(campB.soc_start, campB.bias_V_mV, 50, [0.9 0.5 0.1], 's', 'filled', ...
        'MarkerFaceAlpha', 0.7, 'DisplayName', 'Campaign B');
end
yline(0, 'k--');
xlabel('SoC Start [%]');
ylabel('V_{pack} Bias [mV]');
title('Voltage Bias vs Initial SoC');
legend('Location', 'best');
grid on;
saveas(fig4, fullfile(summDir, 'validation_pack_bias_vs_soc.png'));
if CLOSE_FIGS, close(fig4); end

fprintf('\nSummary plots saved to: %s\n', summDir);
fprintf('Per-trip plots saved to: %s\n', plotDir);
fprintf('Done.\n');
