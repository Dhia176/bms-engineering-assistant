% init_plant_model.m
% Initializes the MATLAB base workspace for pack_96s / module_12s / cell_ecm_2rc.
% Called automatically by the pack_96s PreLoadFcn callback, or run manually.
%
% Loads:
%   1. ecm_params.mat       — LUT data, breakpoints, pack constants
%   2. drivecycles_meas.mat — measurement drive-cycle structs
%
% Defines all workspace variables required by the three Simulink models.

%% --- Resolve paths ----------------------------------------------------
scriptDir = fileparts(mfilename('fullpath'));
dataDir   = fullfile(scriptDir, '..', 'data');

%% --- Load LUT parameters ---------------------------------------------
paramFile = fullfile(dataDir, 'ecm_params.mat');
if ~isfile(paramFile)
    error('init_plant_model:fileNotFound', ...
        'ecm_params.mat not found. Run export_luts.m first.\n  Expected: %s', paramFile);
end
load(paramFile);  % SoC_bp_ocv, SoC_bp_ecm, T_bp, OCV_data, R0/R1/C1/R2/C2_data, N_series, Q_nom_Ah, dt

%% --- Load drive-cycle data --------------------------------------------
measFile = fullfile(dataDir, 'drivecycles_meas.mat');
if isfile(measFile)
    trips_meas = load(measFile);
    fprintf('init_plant_model: loaded %d measurement trips\n', numel(fieldnames(trips_meas)));
else
    warning('init_plant_model:noMeasData', 'drivecycles_meas.mat not found — skipping.');
    trips_meas = struct();
end

simFile = fullfile(dataDir, 'drivecycles_sim.mat');
if isfile(simFile)
    trips_sim = load(simFile);
    fprintf('init_plant_model: loaded %d simulation trips\n', numel(fieldnames(trips_sim)));
else
    trips_sim = struct();
end

%% --- Cell thermal parameters ------------------------------------------
thermalCsv = fullfile(dataDir, 'thermal_params.csv');
if isfile(thermalCsv)
    tp = readtable(thermalCsv);
    m_cell  = tp.m_cell_kg;      % [kg]
    cp_cell = tp.cp_cell_JkgK;   % [J/(kg*K)]
    h_cool  = tp.h_cool_WK;     % [W/K]
    h_amb   = tp.h_amb_WK;      % [W/K]
else
    % Fallback defaults (used before first calibration run)
    m_cell  = 1.3;     % [kg]
    cp_cell = 1000;    % [J/(kg*K)]
    h_cool  = 0.02;    % [W/K]
    h_amb   = 0.15;    % [W/K]
end

%% --- Coolant loop parameters ------------------------------------------
m_coolant  = 8;    % [kg]
cp_coolant = 3500; % [J/(kg*K)]  50/50 ethylene-glycol / water
h_rad      = 40;   % [W/K]       radiator HTC

%% --- Heater / Chiller parameters --------------------------------------
tau_heater    = 10;   % [s]  first-order time constant
tau_chiller   = 10;   % [s]
P_heater_max  = 7000; % [W]  max heater power
P_chiller_max = 5000; % [W]  max chiller power

% %% --- Thermal manager relay thresholds ---------------------------------
% T_heat_target = 15;   % [deg C]  heating setpoint for coolant
% T_cool_target = 25;   % [deg C]  cooling setpoint for coolant
% T_heat_on     = 5;    % [deg C]  heater ON  when T_cell_min <= this
% T_heat_off    = 10;   % [deg C]  heater OFF when T_cell_min >= this
% T_cool_on     = 35;   % [deg C]  chiller ON  when T_cell_max >= this
% T_cool_off    = 30;   % [deg C]  chiller OFF when T_cell_max <= this
%% --- Thermal manager relay thresholds (Améliorés) -----------------------
T_target_heat = 18;   % Cible de fin de chauffage
T_target_cool = 25;   % Cible de fin de refroidissement

T_heat_on  = 8;       % Seuil de déclenchement (augmenté pour plus de sécurité)
T_heat_off = T_target_heat; 

T_cool_on  = 35;      % Seuil de déclenchement refroidissement
T_cool_off = T_target_cool;

%% --- Per-cell variation arrays (nominal: no cell-to-cell variation) ----
cell_Q_Ah     = Q_nom_Ah * ones(12, 8);     % [Ah]  capacity per cell  (12 cells x 8 modules)
cell_dSoC_pct = zeros(12, 8);               % [%]   SoC offset per cell (12 x 8)
cell_RO_scale = ones(12, 8);                % [–]   R0 scale factor     (12 x 8)




firstTripFields = fieldnames(trips_meas);
if ~isempty(firstTripFields)
    firstTrip = trips_meas.(firstTripFields{1});
    T_init_scalar = double(firstTrip.T_cell_C(1));   % first sample of first trip
    fprintf('init_plant_model: T_cells_init set to %.1f °C (from trip "%s")\n', ...
        T_init_scalar, firstTripFields{1});
else
    T_init_scalar = 25;
    warning('init_plant_model:noTripData', ...
        'No measurement trips found — T_cells_init defaulting to 25 °C.');
end
T_cells_init = T_init_scalar * ones(12, 8);  % [deg C] initial cell temperature (12 x 8)

%% --- Initial conditions -----------------------------------------------
% RC voltage initial conditions (cold-start default = 0)
V_RC1_init_cell = 0;   % [V]  per-cell RC1 voltage IC
V_RC2_init_cell = 0;   % [V]  per-cell RC2 voltage IC

% Scalar initial RC voltages — broadcast to all cells in all modules
V_RC1_init = V_RC1_init_cell;  % [scalar]
V_RC2_init = V_RC2_init_cell;  % [scalar]

%% --- Balancing current placeholder ------------------------------------
I_bal_default = zeros(12, 8);   % [A]  no balancing active

%% --- BMS thermal override flag ----------------------------------------
bms_thermal_override = false;   % false = use internal Thermal_Manager_Stub

%% --- Simulation time --------------------------------------------------
T_stop = 3600;   % [s]  default stop time (1 hour); overridden by validation scripts

%% --- Summary ----------------------------------------------------------
fprintf('init_plant_model: workspace ready (%ds1p, Q_nom=%.0f Ah, dt=%.2f s, T_stop=%.0f s)\n', ...
    N_series, Q_nom_Ah, dt, T_stop);

%% --- BMS bus object definitions (needed by module_12s Outport blocks) --
%  PlantToSlaveBus: module → slave BMS  (6 signals)
%  SlaveToPlantBus: slave BMS → module  (1 signal)
clear elems_;
elems_(1) = Simulink.BusElement; elems_(1).Name = 'V_module';        elems_(1).Dimensions = 1;
elems_(2) = Simulink.BusElement; elems_(2).Name = 'V_cells_12';      elems_(2).Dimensions = 12;
elems_(3) = Simulink.BusElement; elems_(3).Name = 'SoC_cells_12';    elems_(3).Dimensions = 12;
elems_(4) = Simulink.BusElement; elems_(4).Name = 'T_cells_12';      elems_(4).Dimensions = 12;
elems_(5) = Simulink.BusElement; elems_(5).Name = 'Q_gen_cells_12';  elems_(5).Dimensions = 12;
elems_(6) = Simulink.BusElement; elems_(6).Name = 'I_module_meas';   elems_(6).Dimensions = 1;
PlantToSlaveBus = Simulink.Bus;
PlantToSlaveBus.Elements = elems_;

clear elems_;
elems_(1) = Simulink.BusElement; elems_(1).Name = 'I_bal'; elems_(1).Dimensions = 12;
SlaveToPlantBus = Simulink.Bus;
SlaveToPlantBus.Elements = elems_;
clear elems_;
