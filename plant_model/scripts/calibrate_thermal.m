% calibrate_thermal.m  –  Forward-ODE calibration of cell thermal parameters
% Direct evaluation of candidate parameter sets (avoids long optimization loops
% that crash with MATLAB trial license).

addpath(fileparts(mfilename('fullpath')));
run('init_plant_model.m');

D = load(fullfile(fileparts(mfilename('fullpath')), '..', 'data', 'drivecycles_meas.mat'));
fn = fieldnames(D);

% Load ECM LUTs (wide format: SoC_pct, T0C, T5C, ..., T30C)
dataRoot = fullfile(fileparts(mfilename('fullpath')), '..', 'data');
R0_tbl = readtable(fullfile(dataRoot, 'r0_lut.csv'));
R1_tbl = readtable(fullfile(dataRoot, 'r1_lut.csv'));
R2_tbl = readtable(fullfile(dataRoot, 'r2_lut.csv'));
C1_tbl = readtable(fullfile(dataRoot, 'c1_lut.csv'));
C2_tbl = readtable(fullfile(dataRoot, 'c2_lut.csv'));
SoC_bp_r0 = R0_tbl.SoC_pct;
T_bp_r0   = [0 5 10 15 20 25 30];
R0_map = table2array(R0_tbl(:, 2:end));
R1_map = table2array(R1_tbl(:, 2:end));
R2_map = table2array(R2_tbl(:, 2:end));
C1_map = table2array(C1_tbl(:, 2:end));
C2_map = table2array(C2_tbl(:, 2:end));

% Pack all ECM maps into a struct for convenience
ecm = struct('R0', R0_map, 'R1', R1_map, 'R2', R2_map, ...
             'C1', C1_map, 'C2', C2_map, ...
             'SoC_bp', SoC_bp_r0, 'T_bp', T_bp_r0);

% Select & downsample calibration trips (keep only 10 representative ones)
DS = 20;  % aggressive downsample
calib = {};
for k = 1:numel(fn)
    s = D.(fn{k});
    if all(s.T_cool_C == 0), continue; end
    dur = s.time_s(end) - s.time_s(1);
    dT = max(s.T_cell_C) - min(s.T_cell_C);
    if dur > 2000 && dT >= 2  % stricter filter for fewer trips
        idx = 1:DS:numel(s.time_s);
        sd.time_s   = s.time_s(idx);
        sd.I_A      = s.I_A(idx);
        sd.SoC_pct  = s.SoC_pct(idx);
        sd.T_cell_C = s.T_cell_C(idx);
        sd.T_cool_C = s.T_cool_C(idx);
        sd.T_amb_C  = s.T_amb_C(idx);
        sd.name     = fn{k};
        calib{end+1} = sd;
    end
end
fprintf('Calibration trips: %d (downsampled %dx)\n', numel(calib), DS);

% Candidate parameter sets [Cth, h_cool, h_amb]
% Phase 3: fine-tune around [1500, 0.03, 0.2]
candidates = [
    1300, 0.020, 0.15;
    1300, 0.025, 0.15;
    1300, 0.025, 0.20;
    1300, 0.030, 0.15;
    1300, 0.030, 0.20;
    1300, 0.035, 0.20;
    1400, 0.020, 0.15;
    1400, 0.025, 0.15;
    1400, 0.025, 0.20;
    1400, 0.030, 0.15;
    1400, 0.030, 0.20;
    1400, 0.035, 0.20;
    1500, 0.020, 0.15;
    1500, 0.025, 0.15;
    1500, 0.025, 0.20;
    1500, 0.030, 0.15;
    1500, 0.030, 0.20;
    1500, 0.035, 0.15;
    1500, 0.035, 0.20;
    1500, 0.040, 0.20;
    1600, 0.025, 0.15;
    1600, 0.025, 0.20;
    1600, 0.030, 0.15;
    1600, 0.030, 0.20;
    1600, 0.035, 0.20;
    1700, 0.030, 0.15;
    1700, 0.030, 0.20;
    1700, 0.035, 0.20;
];

fprintf('Evaluating %d candidate parameter sets...\n', size(candidates,1));
bestMSE = Inf;
bestIdx = 1;
for c = 1:size(candidates,1)
    p = candidates(c,:);
    mse = sim_error(p, calib, ecm);
    fprintf('  [%5.0f, %.3f, %.3f] => RMSE=%.3f\n', p(1), p(2), p(3), sqrt(mse));
    if mse < bestMSE
        bestMSE = mse;
        bestIdx = c;
    end
end

xopt = candidates(bestIdx,:);
fprintf('\n=== Best Parameters ===\n');
fprintf('Cth     = %.1f J/K\n', xopt(1));
fprintf('h_cool  = %.4f W/K\n', xopt(2));
fprintf('h_amb   = %.4f W/K\n', xopt(3));
fprintf('m_cell  = %.3f kg  (assuming cp=1000)\n', xopt(1)/1000);
fprintf('RMSE    = %.3f deg\n', sqrt(bestMSE));

% Per-trip RMSE
fprintf('\n=== Per-Trip RMSE ===\n');
trip_names = cell(numel(calib), 1);
trip_rmse  = zeros(numel(calib), 1);
for i = 1:numel(calib)
    s = calib{i};
    Tc_sim = run_thermal_ode(xopt, s, ecm);
    trip_rmse(i) = sqrt(mean((Tc_sim - s.T_cell_C).^2));
    trip_names{i} = s.name;
    fprintf('%s: RMSE=%.3f C\n', s.name, trip_rmse(i));
end

%% ======================================================================
%  Save calibrated parameters to CSV
%  ======================================================================
cp_cell = 1000;  % [J/(kg*K)] assumed specific heat
calibResults = table( ...
    xopt(1), ...            % Cth [J/K]
    xopt(1)/cp_cell, ...    % m_cell [kg]
    cp_cell, ...            % cp_cell [J/(kg*K)]
    xopt(2), ...            % h_cool [W/K]
    xopt(3), ...            % h_amb  [W/K]
    sqrt(bestMSE), ...      % overall RMSE [deg C]
    numel(calib), ...       % number of calibration trips
    'VariableNames', {'Cth_JK', 'm_cell_kg', 'cp_cell_JkgK', ...
                      'h_cool_WK', 'h_amb_WK', 'rmse_C', 'n_trips'});

csvPath = fullfile(dataRoot, 'thermal_params.csv');
writetable(calibResults, csvPath);
fprintf('\nCalibrated parameters saved to: %s\n', csvPath);

% ---- local functions ----
function mse = sim_error(params, calib, ecm)
    totalErr = 0;
    totalN   = 0;
    for i = 1:numel(calib)
        s = calib{i};
        Tc_sim = run_thermal_ode(params, s, ecm);
        err = (Tc_sim - s.T_cell_C).^2;
        totalErr = totalErr + sum(err(isfinite(err)));
        totalN   = totalN + sum(isfinite(err));
    end
    if totalN == 0
        mse = 1e10;
    else
        mse = totalErr / totalN;
    end
end

function Tc_sim = run_thermal_ode(params, s, ecm)
    Cth  = params(1);
    hcl  = params(2);
    hamb = params(3);

    t   = s.time_s;
    I   = s.I_A;
    SoC = s.SoC_pct;
    Tcl = s.T_cool_C;
    Ta  = s.T_amb_C;
    N   = numel(t);

    SoC_bp = ecm.SoC_bp;
    T_bp   = ecm.T_bp;

    Tc_sim    = zeros(N,1);
    Tc_sim(1) = s.T_cell_C(1);

    % RC-pair voltage states (initialise at steady-state: V_RCi = Ri * I)
    soc_0 = max(min(SoC(1), max(SoC_bp)), min(SoC_bp));
    t_0   = max(min(s.T_cell_C(1), max(T_bp)), min(T_bp));
    R1_0  = interp2(T_bp', SoC_bp, ecm.R1, t_0, soc_0, 'linear');
    R2_0  = interp2(T_bp', SoC_bp, ecm.R2, t_0, soc_0, 'linear');
    Vrc1  = R1_0 * I(1);
    Vrc2  = R2_0 * I(1);

    for j = 1:N-1
        dt = t(j+1) - t(j);
        if dt <= 0, dt = 1; end

        soc_q = max(min(SoC(j), max(SoC_bp)), min(SoC_bp));
        t_q   = max(min(Tc_sim(j), max(T_bp)), min(T_bp));

        R0 = interp2(T_bp', SoC_bp, ecm.R0, t_q, soc_q, 'linear');
        R1 = interp2(T_bp', SoC_bp, ecm.R1, t_q, soc_q, 'linear');
        R2 = interp2(T_bp', SoC_bp, ecm.R2, t_q, soc_q, 'linear');
        C1 = interp2(T_bp', SoC_bp, ecm.C1, t_q, soc_q, 'linear');
        C2 = interp2(T_bp', SoC_bp, ecm.C2, t_q, soc_q, 'linear');

        % RC dynamics — exact exponential solution (stable for large dt)
        %   V_RC(t+dt) = I*R*(1-exp(-dt/tau)) + V_RC(t)*exp(-dt/tau)
        tau1 = R1 * C1;
        tau2 = R2 * C2;
        exp1 = exp(-dt / tau1);
        exp2 = exp(-dt / tau2);
        Vrc1 = I(j) * R1 * (1 - exp1) + Vrc1 * exp1;
        Vrc2 = I(j) * R2 * (1 - exp2) + Vrc2 * exp2;

        % Total heat = I^2*R0 + V_RC1^2/R1 + V_RC2^2/R2
        Qgen = I(j)^2 * R0 + Vrc1^2 / R1 + Vrc2^2 / R2;

        dTdt = (Qgen - hcl*(Tc_sim(j)-Tcl(j)) - hamb*(Tc_sim(j)-Ta(j))) / Cth;
        Tc_sim(j+1) = Tc_sim(j) + dTdt * dt;

        % Guard against divergence
        if abs(Tc_sim(j+1)) > 200
            Tc_sim(j+1:end) = 200 * sign(Tc_sim(j+1));
            break;
        end
    end
end
