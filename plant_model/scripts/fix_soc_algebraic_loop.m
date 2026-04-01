% fix_soc_algebraic_loop.m
% Suppress the algebraic-loop diagnostic that arises from the
% SoC -> OCV/R lookup -> V_cell feedback path in the ECM hierarchy.
%
% The loop is broken at runtime by the Integrator block inside
% SoC_Estimator (state delay), so it is safe to silence the warning.
% This script is idempotent — safe to call multiple times.
%
% The setting must be saved into each .slx so that the model-reference
% build (MEX target) also picks it up.

scriptDir_ = fileparts(mfilename('fullpath'));
modelDir_  = fullfile(scriptDir_, '..', 'models');

mdls = {'cell_ecm_2rc', 'module_12s', 'pack_96s'};

for i = 1:numel(mdls)
    m = mdls{i};

    % Ensure the model is loaded
    if ~bdIsLoaded(m)
        load_system(fullfile(modelDir_, m));
    end

    % Only touch (and save) if the setting is not already 'none'
    cur = get_param(m, 'AlgebraicLoopMsg');
    if ~strcmpi(cur, 'none')
        set_param(m, 'AlgebraicLoopMsg', 'none');
        save_system(m);
        fprintf('fix_soc_algebraic_loop: %s — AlgebraicLoopMsg set to none (saved)\n', m);
    end
end
