% debug_sim.m — diagnose why pack_96s sim fails
scriptDir = fileparts(mfilename('fullpath'));
modelsDir = fullfile(scriptDir, '..', 'models');
addpath(modelsDir);
addpath(scriptDir);
run(fullfile(scriptDir, 'init_plant_model.m'));

fprintf('\n=== Loading pack_96s ===\n');
load_system('pack_96s');
fprintf('Model loaded.\n');

% Load all referenced models
refModels = find_mdlrefs('pack_96s', 'AllLevels', true);
for i = 1:numel(refModels)
    load_system(refModels{i});
end
fprintf('Loaded %d referenced models.\n', numel(refModels));

% Try loading referenced models explicitly
fprintf('\n=== Loading referenced models ===\n');
try
    load_system('module_12s');
    fprintf('module_12s loaded.\n');
catch e
    fprintf('module_12s FAILED: %s\n', e.message);
end

try
    load_system('cell_ecm_2rc');
    fprintf('cell_ecm_2rc loaded.\n');
catch e
    fprintf('cell_ecm_2rc FAILED: %s\n', e.message);
end

% Check simulation mode
fprintf('\n=== Model reference info ===\n');
mdlRefs = find_mdlrefs('pack_96s');
fprintf('Model references:\n');
for i = 1:numel(mdlRefs)
    fprintf('  %s\n', mdlRefs{i});
end

% Try updating the diagram
fprintf('\n=== Updating diagram ===\n');
try
    set_param('pack_96s', 'SimulationCommand', 'update');
    fprintf('Update OK.\n');
catch e
    fprintf('Update FAILED: %s\n', e.message);
    if ~isempty(e.cause)
        for i = 1:numel(e.cause)
            fprintf('  CAUSE %d: %s\n', i, e.cause{i}.message);
        end
    end
end

% Try simulation
fprintf('\n=== Attempting 10s sim ===\n');
try
    simOut = sim('pack_96s', 'StopTime', '10');
    fprintf('SIM OK!\n');
catch e
    fprintf('SIM FAILED: %s\n', e.message);
    if ~isempty(e.cause)
        for i = 1:numel(e.cause)
            fprintf('  CAUSE %d: %s\n', i, e.cause{i}.message);
        end
    end
end

bdclose all;
fprintf('\n=== Done ===\n');
