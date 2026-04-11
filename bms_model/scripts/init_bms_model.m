%% init_bms_model.m  --  BMS workspace initialisation
%  Loads plant parameters first, then defines BMS-specific objects.
%  Called by bms_plant_closed_loop.slx PreLoadFcn callback.
%
%  Usage:
%    >> init_bms_model          % from command window
%    % -or- set as PreLoadFcn in bms_plant_closed_loop.slx

%% 1) Load plant model parameters (ECM LUTs, thermal, drive cycles)
projRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
run(fullfile(projRoot,'plant_model','scripts','init_plant_model.m'));

%% === 2) BMS Bus Objects ================================================

%% SlaveToMasterBus (5 elements)
clear elems_;
elems_(1) = Simulink.BusElement; elems_(1).Name = 'V_module';
    elems_(1).Dimensions = 1;
elems_(2) = Simulink.BusElement; elems_(2).Name = 'V_cells';
    elems_(2).Dimensions = 12;
elems_(3) = Simulink.BusElement; elems_(3).Name = 'T_sensors';
    elems_(3).Dimensions = 4;
elems_(4) = Simulink.BusElement; elems_(4).Name = 'I_module';
    elems_(4).Dimensions = 1;
elems_(5) = Simulink.BusElement; elems_(5).Name = 'fault_flags';
    elems_(5).Dimensions = 1;
    % Encoding : 12 - bit packed scalar ( double ).
    % Bits [1:0]= OV , [3:2]= UV , [5:4]= OT , [7:6]= UT severity
    % Values per field : 0= None , 1= Warning , 2= Derating , 3= Critical

SlaveToMasterBus = Simulink.Bus;
SlaveToMasterBus.Elements = elems_;

%% SlaveReportsBus  (aggregated 8-module input for bms_master)
%  The parent model concatenates 8 SlaveToMasterBus outputs into this bus.
clear elems_;
elems_(1) = Simulink.BusElement; elems_(1).Name = 'V_module';
    elems_(1).Dimensions = 8;
elems_(2) = Simulink.BusElement; elems_(2).Name = 'T_sensors';
    elems_(2).Dimensions = 32;       % 4 sensors x 8 modules
elems_(3) = Simulink.BusElement; elems_(3).Name = 'I_module';
    elems_(3).Dimensions = 8;
elems_(4) = Simulink.BusElement; elems_(4).Name = 'fault_flags';
    elems_(4).Dimensions = 8;
SlaveReportsBus = Simulink.Bus;
SlaveReportsBus.Elements = elems_;

%% MasterToSlaveBus (1 element -- enable_bal only)
clear elems_;
elems_(1) = Simulink.BusElement; elems_(1).Name = 'enable_bal';
    elems_(1).Dimensions = 1;
MasterToSlaveBus = Simulink.Bus;
MasterToSlaveBus.Elements = elems_;

%% MasterOutputBus (9 elements -- includes SoH_pack)
clear elems_;
elems_(1) = Simulink.BusElement; elems_(1).Name = 'V_pack';
    elems_(1).Dimensions = 1;
elems_(2) = Simulink.BusElement; elems_(2).Name = 'I_pack';
    elems_(2).Dimensions = 1;
elems_(3) = Simulink.BusElement; elems_(3).Name = 'SoC_pack';
    elems_(3).Dimensions = 1;
elems_(4) = Simulink.BusElement; elems_(4).Name = 'T_pack_avg';
    elems_(4).Dimensions = 1;
elems_(5) = Simulink.BusElement; elems_(5).Name = 'T_cell_min';
    elems_(5).Dimensions = 1;
elems_(6) = Simulink.BusElement; elems_(6).Name = 'T_cell_max';
    elems_(6).Dimensions = 1;
elems_(7) = Simulink.BusElement; elems_(7).Name = 'shutdown_cmd';
    elems_(7).Dimensions = 1;
elems_(8) = Simulink.BusElement; elems_(8).Name = 'fault_severity';
    elems_(8).Dimensions = 1;
elems_(9) = Simulink.BusElement; elems_(9).Name = 'SoH_pack';
    elems_(9).Dimensions = 1;
MasterOutputBus = Simulink.Bus;
MasterOutputBus.Elements = elems_;
clear elems_;

%% === 3) BMS Parameters =================================================

% Software-path fault thresholds
bms.V_OV_warn  = 4.15;  bms.V_OV_derate = 4.20;  bms.V_OV_shut = 4.25;
bms.V_UV_warn  = 2.80;  bms.V_UV_derate = 2.60;  bms.V_UV_shut = 2.50;
bms.T_OT_warn  = 45;    bms.T_OT_derate = 50;    bms.T_OT_shut = 60;
bms.T_UT_warn  = -10;   bms.T_UT_derate = -15;   bms.T_UT_shut = -20;
bms.I_OC_chg_warn = 100; bms.I_OC_chg_derate = 120; bms.I_OC_chg_shut = 150;
bms.I_OC_dchg_warn = 280; bms.I_OC_dchg_derate = 350; bms.I_OC_dchg_shut = 450;

% Debounce (samples at dt = 0.1 s)
bms.N_debounce_warn  = 10;   %  1.0 s
bms.N_debounce_derate = 30;  %  3.0 s
bms.N_debounce_shut  = 5;    %  0.5 s

% Hardware-path thresholds (no debounce)
bms.I_SC_thresh   = 800;    % [A] short-circuit
bms.V_OVP2_thresh = 4.50;   % [V/cell] critical OVP

% I^2t protection
bms.I_nom       = 180;      % [A] continuous rated
bms.I2t_Eth_max = 1e6;      % [A^2.s] thermal limit

% Slave watchdog
bms.N_watchdog_timeout = 10;
bms.N_slave_disconnect_warn = 1;
bms.N_slave_disconnect_derate = 2;
bms.N_slave_disconnect_shut = 4;


% Balancing (voltage-based -- Slave decides locally)
bms.bal_dV_thresh = 0.010;  % [V] cell voltage difference threshold (10 mV)
bms.bal_dV_module_thresh = 0.12;
bms.bal_I_nom = 0.1;        % [A] passive bleed current
bms.bal_dSoC_thresh = 1.0;  % [%] module-level SoC spread for Master enable

% EKF tuning (8 module-level EKFs)
ekf_params.Q_SoC  = 1e-6;   ekf_params.Q_VRC1 = 1e-5;   ekf_params.Q_VRC2 = 1e-5;
ekf_params.R_V    = 1e-3;    % measurement noise (module voltage)
ekf_params.P0_SoC = 0.01;
ekf_params.SoC0   = 0.80;
ekf_params.N_modules = 8;    % number of module-level EKF instances

%% === 4) SoH Estimator Parameters =======================================
bms.Q_nom_Ah     = Q_nom_Ah;     % from init_plant_model (60 Ah)
bms.dSoC_min_pct = 40;           % [%] min delta-SoC window for capacity update
bms.alpha_ema    = 0.05;         % EMA smoothing for R0 tracking

% R0_fresh: extract from R0 LUT at reference point (SoC=50%, T=25 degC)
SoC_ref_idx      = find(SoC_bp_ecm == 50, 1);
T_ref_idx        = find(T_bp == 25, 1);
bms.R0_fresh     = R0_data(SoC_ref_idx, T_ref_idx);  % [Ohm] BoL reference
bms.R0_window_s  = 300;          % [s] observation window (informational)

% Flatten SoH params as standalone workspace variables
% (required by the SoH_Estimator MATLAB Function block)
R0_fresh     = bms.R0_fresh;
alpha_ema    = bms.alpha_ema;
dSoC_min_pct = bms.dSoC_min_pct;

fprintf('init_bms_model: BMS workspace ready.\n');
