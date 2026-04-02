function inspect()
% inspect.m
% =========================================================================
%  Enhanced Simulink Model Structure Inspector
%  Inspects: cell_ecm_2rc.slx, module_12s.slx, pack_96s.slx
%  Outputs:  Console report + <project_root>/inspect_report.txt
% =========================================================================
%  Purpose:
%    Generate a single self-contained .txt snapshot of every detail inside
%    the Simulink plant model so that an AI assistant (or any reviewer) can
%    fully understand the model without access to MATLAB / Simulink.
%
%  Usage:
%    >> cd <project_root>/plant_model
%    >> inspect
%  or:
%    >> run('<project_root>/plant_model/scripts/inspect.m')
% =========================================================================

clc;

% --- Resolve key directories relative to this script file ----------------
scriptDir  = fileparts(mfilename('fullpath'));
modelDir   = fullfile(scriptDir, '..', 'models');
dataDir    = fullfile(scriptDir, '..', 'data');
projectDir = fullfile(scriptDir, '..', '..');   % bms-engineering-assistant root

models = {'cell_ecm_2rc', 'module_12s', 'pack_96s'};

% --- Open log file (saved at project root) -------------------------------
logFile = fullfile(projectDir, 'inspect_report.txt');
fid = fopen(logFile, 'w');
cleanup = onCleanup(@() fclose(fid));

% --- Formatting constants ------------------------------------------------
SEP  = repmat('=', 1, 90);
SEP2 = repmat('-', 1, 82);
SEP3 = repmat('.', 1, 60);

% =========================================================================
%  HEADER
% =========================================================================
dprintf('%s\n', SEP);
dprintf('   SIMULINK MODEL STRUCTURE INSPECTION REPORT\n');
dprintf('   Generated : %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
dprintf('   MATLAB    : %s\n', version);
dprintf('   Models    : %s\n', strjoin(models, ', '));
dprintf('%s\n\n', SEP);

% =========================================================================
% A. EXECUTIVE SUMMARY  (filled after all models are inspected)
%    We collect summary data during the per-model loop and print it at the
%    very end of the report.
% =========================================================================
summaryData = struct();   % will accumulate per-model facts

% =========================================================================
% B. BASE-WORKSPACE VARIABLE DUMP
%    Why: many Simulink blocks reference workspace variables (LUT data,
%    thermal parameters, etc.). Dumping them here gives the AI all numeric
%    context in one place so it can cross-reference with block parameters.
% =========================================================================
dprintf('\n%s\n', SEP);
dprintf('  BASE-WORKSPACE VARIABLE SNAPSHOT\n');
dprintf('%s\n', SEP);
dprintf('  (All variables currently in the MATLAB base workspace)\n\n');

wsVars = evalin('base', 'whos');
if isempty(wsVars)
    dprintf('      (base workspace is empty)\n');
else
    % Sort alphabetically for easy lookup
    [~, sortIdx] = sort(lower({wsVars.name}));
    wsVars = wsVars(sortIdx);

    dprintf('      %-30s  %-12s  %-18s  %s\n', 'Variable', 'Class', 'Size', 'Value / Preview');
    dprintf('      %-30s  %-12s  %-18s  %s\n', '--------', '-----', '----', '---------------');

    for wi = 1:numel(wsVars)
        wv = wsVars(wi);
        sizeStr = strjoin(arrayfun(@num2str, wv.size, 'Uni', false), 'x');

        % Attempt to read the actual value for a compact preview
        try
            val = evalin('base', wv.name);
            preview = toStr(val);
        catch
            preview = '[unable to read]';
        end

        % Truncate very long previews to keep the report scannable
        if numel(preview) > 300
            preview = [preview(1:297), '...'];
        end

        dprintf('      %-30s  %-12s  %-18s  %s\n', wv.name, wv.class, sizeStr, preview);
    end
end
dprintf('\n');

% =========================================================================
% C. SIMULINK.BUS OBJECTS IN BASE WORKSPACE
%    Why: Bus objects define structured signal interfaces.  If any exist
%    we dump their full element lists so the AI knows the signal schema.
% =========================================================================
dprintf('\n%s\n', SEP);
dprintf('  SIMULINK.BUS OBJECT DEFINITIONS\n');
dprintf('%s\n\n', SEP);

busCount = 0;
for wi = 1:numel(wsVars)
    if strcmp(wsVars(wi).class, 'Simulink.Bus')
        busCount = busCount + 1;
        busName = wsVars(wi).name;
        busObj  = evalin('base', busName);
        dprintf('      Bus: %s\n', busName);
        if ~isempty(busObj.Description)
            dprintf('        Description: %s\n', busObj.Description);
        end
        elems = busObj.Elements;
        if isempty(elems)
            dprintf('        (no elements)\n');
        else
            dprintf('        %-25s  %-15s  %-10s  %-10s  %s\n', ...
                'Element', 'DataType', 'Dims', 'Complexity', 'Unit');
            for ei = 1:numel(elems)
                e = elems(ei);
                dims = toStr(e.Dimensions);
                unit = e.Unit; if isempty(unit), unit = '[not set]'; end
                dprintf('        %-25s  %-15s  %-10s  %-10s  %s\n', ...
                    e.Name, e.DataType, dims, e.Complexity, unit);
            end
        end
        dprintf('\n');
    end
end
if busCount == 0
    dprintf('      (no Simulink.Bus objects in base workspace)\n\n');
end

% =========================================================================
%  LOOP OVER EACH MODEL
% =========================================================================
for mi = 1:numel(models)
    mdlName = models{mi};
    mdlPath = fullfile(modelDir, mdlName);

    dprintf('\n%s\n', SEP);
    dprintf('  MODEL %d/%d :  %s.slx\n', mi, numel(models), mdlName);
    dprintf('%s\n\n', SEP);

    % --- Load model (headless — no GUI window) ---------------------------
    try
        load_system(mdlPath);
    catch ME
        dprintf('  *** FAILED TO LOAD: %s\n\n', ME.message);
        continue
    end

    % =====================================================================
    %  1. MODEL CONFIGURATION / SOLVER SETTINGS
    %     Why: solver type and step size determine simulation fidelity;
    %     stop time and save format affect post-processing.
    % =====================================================================
    dprintf('  [1] MODEL CONFIGURATION\n  %s\n', SEP2);

    configParams = {
        'SolverType', 'Solver', 'FixedStep', 'MaxStep', 'MinStep', ...
        'RelTol', 'AbsTol', ...
        'StopTime', 'StartTime', ...
        'SaveTime', 'SaveOutput', 'SaveFormat', ...
        'SignalLogging', 'SignalLoggingName', ...
        'SimulationMode', 'SystemTargetFile', ...
        'ReturnWorkspaceOutputs', 'ReturnWorkspaceOutputsName', ...
        'InlineParams', 'BlockReductionOpt', ...
        'BufferReuse', 'OptimizeBlockIOStorage'};

    for ci = 1:numel(configParams)
        try
            val = get_param(mdlName, configParams{ci});
            dprintf('      %-36s = %s\n', configParams{ci}, val);
        catch
            % parameter may not apply for this solver type — skip silently
        end
    end
    dprintf('\n');

    % =====================================================================
    %  2. MODEL CALLBACKS
    %     Why: callbacks can load MAT files, run scripts, or set workspace
    %     variables that the model depends on.
    % =====================================================================
    dprintf('  [2] MODEL CALLBACKS\n  %s\n', SEP2);

    cbNames = {'PreLoadFcn','PostLoadFcn','InitFcn','StartFcn', ...
               'StopFcn','CloseFcn','PreSaveFcn','PostSaveFcn'};
    anyCallback = false;
    for ci = 1:numel(cbNames)
        try
            cbVal = get_param(mdlName, cbNames{ci});
            if ~isempty(strtrim(cbVal))
                dprintf('      %s:\n', cbNames{ci});
                cbLines = strsplit(cbVal, newline);
                for li = 1:numel(cbLines)
                    dprintf('        | %s\n', cbLines{li});
                end
                anyCallback = true;
            end
        catch
        end
    end
    if ~anyCallback
        dprintf('      (none)\n');
    end
    dprintf('\n');

    % =====================================================================
    %  3. COMPLETE BLOCK INVENTORY
    %     Why: gives a quick numeric fingerprint — total blocks, type
    %     distribution.  Useful for detecting model complexity.
    % =====================================================================
    dprintf('  [3] COMPLETE BLOCK INVENTORY\n  %s\n', SEP2);

    allBlocks  = find_system(mdlName, 'Type', 'block');
    blockTypes = get_param(allBlocks, 'BlockType');

    [uniqueTypes, ~, idx] = unique(blockTypes);
    typeCounts = accumarray(idx, 1);
    [typeCounts, sortI] = sort(typeCounts, 'descend');
    uniqueTypes = uniqueTypes(sortI);

    dprintf('      Total blocks: %d\n\n', numel(allBlocks));
    dprintf('      %-32s  Count\n', 'Block Type');
    dprintf('      %-32s  -----\n', '----------');
    for ti = 1:numel(uniqueTypes)
        dprintf('      %-32s  %d\n', uniqueTypes{ti}, typeCounts(ti));
    end
    dprintf('\n');

    % Save for summary
    summaryData(mi).name       = mdlName;
    summaryData(mi).totalBlks  = numel(allBlocks);
    summaryData(mi).subsystems = find_system(mdlName, 'BlockType', 'SubSystem');

    % =====================================================================
    %  4. HIERARCHICAL SUBSYSTEM TREE
    %     Why: reveals the architectural nesting of the model at a glance.
    %     Tags masked / for-each subsystems.
    % =====================================================================
    dprintf('  [4] SUBSYSTEM HIERARCHY\n  %s\n', SEP2);

    subsystems = find_system(mdlName, 'BlockType', 'SubSystem');
    for si = 1:numel(subsystems)
        ss    = subsystems{si};
        depth = numel(strfind(ss, '/')) - numel(strfind(mdlName, '/'));
        indent = repmat('  ', 1, depth);

        ssName  = get_param(ss, 'Name');
        hasMask = strcmp(safeGet(ss, 'Mask', 'off'), 'on');
        maskType = safeGet(ss, 'MaskType', '');
        innerFE  = find_system(ss, 'SearchDepth', 1, 'BlockType', 'ForEach');
        isForEach = ~isempty(innerFE);

        % Count direct children for context
        directBlks = find_system(ss, 'SearchDepth', 1, 'Type', 'block');
        nChildren  = numel(directBlks) - 1;  % minus the subsystem itself

        label = ssName;
        if hasMask,   label = [label, '  [MASKED]']; end %#ok<AGROW>
        if isForEach, label = [label, '  [FOR-EACH]']; end %#ok<AGROW>
        if ~isempty(maskType) && ~strcmp(maskType, '')
            label = [label, sprintf('  (MaskType: %s)', maskType)]; %#ok<AGROW>
        end
        label = [label, sprintf('  (%d children)', nChildren)]; %#ok<AGROW>

        dprintf('      %s|-- %s\n', indent, label);
    end
    dprintf('\n');

    % =====================================================================
    %  5. INPORTS & OUTPORTS (every subsystem level)
    %     Why: defines the data interface at each hierarchical boundary.
    %     We include description and unit annotations when set.
    % =====================================================================
    dprintf('  [5] INPORTS & OUTPORTS (all levels)\n  %s\n', SEP2);

    % Top-level
    dprintf('      --- Top Level: %s ---\n', mdlName);
    % FIX: call local_printPorts directly — it is a proper nested function
    %      defined at the end of inspect(). The anonymous wrapper that was
    %      here before caused a crash because MATLAB forbids nested function
    %      definitions inside control-flow blocks (for/if/while).
    local_printPorts(find_system(mdlName, 'SearchDepth', 1, 'BlockType', 'Inport'), 'Inports');
    local_printPorts(find_system(mdlName, 'SearchDepth', 1, 'BlockType', 'Outport'), 'Outports');
    dprintf('\n');

    % Subsystem-level ports
    for si = 1:numel(subsystems)
        ss = subsystems{si};
        ssIn  = find_system(ss, 'SearchDepth', 1, 'BlockType', 'Inport');
        ssOut = find_system(ss, 'SearchDepth', 1, 'BlockType', 'Outport');
        if isempty(ssIn) && isempty(ssOut), continue; end
        dprintf('      --- Subsystem: %s ---\n', relPath(ss, mdlName));
        local_printPorts(ssIn, 'Inports');
        local_printPorts(ssOut, 'Outports');
        dprintf('\n');
    end

    % Store top-level port names for summary
    topIn  = find_system(mdlName, 'SearchDepth', 1, 'BlockType', 'Inport');
    topOut = find_system(mdlName, 'SearchDepth', 1, 'BlockType', 'Outport');
    summaryData(mi).inports  = cellfun(@(b) get_param(b,'Name'), topIn, 'Uni', false);
    summaryData(mi).outports = cellfun(@(b) get_param(b,'Name'), topOut, 'Uni', false);

    % =====================================================================
    %  6. MASKED SUBSYSTEMS & MASK PARAMETERS
    %     Why: masks encapsulate tuneable parameters.  Dumping their
    %     current values and init code shows how the model is configured.
    % =====================================================================
    dprintf('  [6] MASKED SUBSYSTEMS & MASK PARAMETERS\n  %s\n', SEP2);

    maskedBlocks = find_system(mdlName, 'Type', 'block', 'Mask', 'on');
    if isempty(maskedBlocks)
        dprintf('      (no masked blocks)\n');
    end
    for bi = 1:numel(maskedBlocks)
        blk = maskedBlocks{bi};
        rp  = relPath(blk, mdlName);
        dprintf('      %s\n', SEP3);
        dprintf('      Block: %s\n', rp);

        maskObj = Simulink.Mask.get(blk);
        if ~isempty(maskObj)
            % Description
            if ~isempty(maskObj.Description)
                dprintf('        Description: %s\n', maskObj.Description);
            end

            params = maskObj.Parameters;
            if ~isempty(params)
                dprintf('        Mask Parameters:\n');
                dprintf('        %-20s %-12s %-25s %s\n', ...
                    'Variable', 'Type', 'Value', 'Prompt');
                for pi = 1:numel(params)
                    p = params(pi);
                    try
                        val = get_param(blk, p.Name);
                    catch
                        val = p.Value;
                    end
                    dprintf('        %-20s %-12s %-25s %s\n', ...
                        p.Name, p.Type, toStr(val), p.Prompt);
                end
            end

            % Mask initialization code
            initCode = maskObj.Initialization;
            if ~isempty(strtrim(initCode))
                dprintf('        Mask Init Code:\n');
                codeLines = strsplit(initCode, newline);
                for li = 1:numel(codeLines)
                    dprintf('          | %s\n', codeLines{li});
                end
            end
        end
        dprintf('\n');
    end
    dprintf('\n');

    % =====================================================================
    %  7. LOOKUP TABLE BLOCKS — DETAILED
    %     Why: LUTs are the core of the ECM parametrisation.  For each one
    %     we capture the variable it references, its breakpoint/table
    %     expressions, interp/extrap methods, AND — if the variables exist
    %     in the base workspace — the actual numeric sizes & min/max ranges.
    % =====================================================================
    dprintf('  [7] LOOKUP TABLE BLOCKS (detailed)\n  %s\n', SEP2);

    lutTypes  = {'Lookup_n-D', 'Lookup', 'Interpolation_n-D', 'PreLookup'};
    anyLUT    = false;
    lutSummaryRows = {};  % for the dedicated LUT summary section

    for lt = 1:numel(lutTypes)
        luts = find_system(mdlName, 'BlockType', lutTypes{lt});
        for li = 1:numel(luts)
            anyLUT = true;
            blk = luts{li};
            rp  = relPath(blk, mdlName);
            dprintf('      Block: %s\n', rp);
            dprintf('        BlockType: %s\n', lutTypes{lt});

            numDims = safeGet(blk, 'NumberOfTableDimensions', '[not set]');
            dprintf('        Dimensions: %s\n', numDims);

            interpM = safeGet(blk, 'InterpMethod', '[not set]');
            extrapM = safeGet(blk, 'ExtrapMethod', '[not set]');
            dprintf('        InterpMethod: %s\n', interpM);
            dprintf('        ExtrapMethod: %s\n', extrapM);

            % For each dimension, get breakpoint expression & resolve value
            nDim = str2double(numDims);
            if isnan(nDim), nDim = 0; end
            bpExprs = {};
            for di = 1:min(nDim, 4)
                paramName = sprintf('BreakpointsForDimension%d', di);
                bpExpr = safeGet(blk, paramName, '');
                if ~isempty(bpExpr)
                    dprintf('        BP%d Expression: %s\n', di, bpExpr);
                    % Attempt to resolve the actual values from workspace
                    try
                        bpVal = evalin('base', bpExpr);
                        dprintf('        BP%d Resolved  : size=%s  min=%.6g  max=%.6g\n', ...
                            di, toStr(size(bpVal)), min(bpVal(:)), max(bpVal(:)));
                        dprintf('        BP%d Values    : %s\n', di, toStr(bpVal));
                    catch
                        dprintf('        BP%d Resolved  : [not in workspace]\n', di);
                    end
                    bpExprs{end+1} = bpExpr; %#ok<AGROW>
                end
            end

            % Table data expression & resolve
            tblExpr = safeGet(blk, 'Table', '');
            if ~isempty(tblExpr)
                dprintf('        Table Expression: %s\n', tblExpr);
                try
                    tblVal = evalin('base', tblExpr);
                    dprintf('        Table Resolved  : size=%s  min=%.6g  max=%.6g  mean=%.6g\n', ...
                        toStr(size(tblVal)), min(tblVal(:)), max(tblVal(:)), mean(tblVal(:)));
                    % Print full table if compact enough (≤ 200 elements)
                    if numel(tblVal) <= 200
                        dprintf('        Table Values    : %s\n', toStr(tblVal));
                    end
                catch
                    dprintf('        Table Resolved  : [not in workspace]\n');
                end
            end

            % Collect for LUT summary section
            lutSummaryRows{end+1, 1} = rp; %#ok<AGROW>
            lutSummaryRows{end,   2} = tblExpr;
            lutSummaryRows{end,   3} = strjoin(bpExprs, ', ');
            lutSummaryRows{end,   4} = numDims;
            lutSummaryRows{end,   5} = interpM;

            dprintf('\n');
        end
    end
    if ~anyLUT
        dprintf('      (no lookup tables found)\n\n');
    end

    % =====================================================================
    %  8. INTEGRATOR BLOCKS
    %     Why: integrators hold dynamic states (SoC, temperature, RC
    %     voltages).  IC source and limits are critical for initialisation.
    % =====================================================================
    dprintf('  [8] INTEGRATOR BLOCKS\n  %s\n', SEP2);

    intBlocks = find_system(mdlName, 'BlockType', 'Integrator');
    if isempty(intBlocks)
        dprintf('      (none)\n');
    end
    for bi = 1:numel(intBlocks)
        blk = intBlocks{bi};
        rp  = relPath(blk, mdlName);
        dprintf('      Block: %s\n', rp);
        try
            ic     = get_param(blk, 'InitialCondition');
            icSrc  = get_param(blk, 'InitialConditionSource');
            extRst = get_param(blk, 'ExternalReset');
            limEn  = get_param(blk, 'LimitOutput');
            dprintf('        IC Source:      %s\n', icSrc);
            if strcmp(icSrc, 'internal')
                dprintf('        IC Value:       %s\n', ic);
            end
            dprintf('        External Reset: %s\n', extRst);
            dprintf('        Limit Output:   %s\n', limEn);
            if strcmp(limEn, 'on')
                upLim  = get_param(blk, 'UpperSaturationLimit');
                loLim  = get_param(blk, 'LowerSaturationLimit');
                dprintf('        Upper Limit:    %s\n', upLim);
                dprintf('        Lower Limit:    %s\n', loLim);
            end
        catch
        end
        dprintf('\n');
    end

    % =====================================================================
    %  9. GAIN / CONSTANT / SUM BLOCKS
    %     Why: gains and constants often carry physical parameters (thermal
    %     coefficients, scaling factors).  Sum signs reveal signal polarity.
    % =====================================================================
    dprintf('  [9] GAIN / CONSTANT / SUM BLOCKS\n  %s\n', SEP2);

    gainBlocks = find_system(mdlName, 'BlockType', 'Gain');
    if ~isempty(gainBlocks)
        dprintf('      GAIN BLOCKS:\n');
        for bi = 1:numel(gainBlocks)
            blk = gainBlocks{bi};
            rp  = relPath(blk, mdlName);
            val = get_param(blk, 'Gain');
            % Try to resolve the gain numerically
            resolved = '';
            try
                numVal = evalin('base', val);
                if isnumeric(numVal)
                    resolved = sprintf('  -> %s', toStr(numVal));
                end
            catch
            end
            dprintf('        %-50s  Gain = %s%s\n', rp, val, resolved);
        end
        dprintf('\n');
    end

    constBlocks = find_system(mdlName, 'BlockType', 'Constant');
    if ~isempty(constBlocks)
        dprintf('      CONSTANT BLOCKS:\n');
        for bi = 1:numel(constBlocks)
            blk = constBlocks{bi};
            rp  = relPath(blk, mdlName);
            val = get_param(blk, 'Value');
            resolved = '';
            try
                numVal = evalin('base', val);
                if isnumeric(numVal)
                    resolved = sprintf('  -> %s', toStr(numVal));
                end
            catch
            end
            dprintf('        %-50s  Value = %s%s\n', rp, val, resolved);
        end
        dprintf('\n');
    end

    sumBlocks = find_system(mdlName, 'BlockType', 'Sum');
    if ~isempty(sumBlocks)
        dprintf('      SUM BLOCKS:\n');
        for bi = 1:numel(sumBlocks)
            blk = sumBlocks{bi};
            rp  = relPath(blk, mdlName);
            signs = get_param(blk, 'Inputs');
            dprintf('        %-50s  Signs = %s\n', rp, signs);
        end
        dprintf('\n');
    end

    % =====================================================================
    % 10. TRANSFER FUNCTION & SATURATION BLOCKS
    % =====================================================================
    dprintf('  [10] TRANSFER FUNCTION & SATURATION BLOCKS\n  %s\n', SEP2);

    tfBlocks = find_system(mdlName, 'BlockType', 'TransferFcn');
    if ~isempty(tfBlocks)
        dprintf('      TRANSFER FUNCTIONS:\n');
        for bi = 1:numel(tfBlocks)
            blk = tfBlocks{bi};
            rp  = relPath(blk, mdlName);
            num = get_param(blk, 'Numerator');
            den = get_param(blk, 'Denominator');
            dprintf('        %s\n', rp);
            dprintf('          Numerator:   %s\n', num);
            dprintf('          Denominator: %s\n', den);
            % Resolve denominator to show actual time constant
            try
                denVal = evalin('base', den);
                dprintf('          Denominator resolved: %s\n', toStr(denVal));
            catch
            end
        end
        dprintf('\n');
    end

    satBlocks = find_system(mdlName, 'BlockType', 'Saturate');
    if ~isempty(satBlocks)
        dprintf('      SATURATION BLOCKS:\n');
        for bi = 1:numel(satBlocks)
            blk = satBlocks{bi};
            rp  = relPath(blk, mdlName);
            upLim = get_param(blk, 'UpperLimit');
            loLim = get_param(blk, 'LowerLimit');
            % Resolve limits
            upRes = ''; loRes = '';
            try upVal = evalin('base', upLim); upRes = sprintf(' -> %.6g', upVal); catch, end
            try loVal = evalin('base', loLim); loRes = sprintf(' -> %.6g', loVal); catch, end
            dprintf('        %-45s  [%s%s, %s%s]\n', rp, loLim, loRes, upLim, upRes);
        end
        dprintf('\n');
    end

    if isempty(tfBlocks) && isempty(satBlocks)
        dprintf('      (none)\n\n');
    end

    % =====================================================================
    % 11. RELAY / SWITCH / LOGIC BLOCKS
    %     Why: relays and switches implement thermal-manager hysteresis
    %     logic.  Thresholds define the activation/deactivation bands.
    % =====================================================================
    dprintf('  [11] RELAY / SWITCH / LOGIC BLOCKS\n  %s\n', SEP2);

    anyDisc = false;
    relayBlocks = find_system(mdlName, 'BlockType', 'Relay');
    if ~isempty(relayBlocks)
        anyDisc = true;
        dprintf('      RELAY BLOCKS:\n');
        for bi = 1:numel(relayBlocks)
            blk = relayBlocks{bi};
            rp  = relPath(blk, mdlName);
            onPt  = get_param(blk, 'OnSwitchValue');
            offPt = get_param(blk, 'OffSwitchValue');
            onOut = get_param(blk, 'OnOutputValue');
            offOut= get_param(blk, 'OffOutputValue');
            dprintf('        %s\n', rp);
            dprintf('          OnPt=%s  OffPt=%s  OnOut=%s  OffOut=%s\n', ...
                onPt, offPt, onOut, offOut);
            % Resolve numeric values
            try
                dprintf('          Resolved: OnPt=%.6g  OffPt=%.6g\n', ...
                    evalin('base', onPt), evalin('base', offPt));
            catch
            end
        end
        dprintf('\n');
    end

    switchBlocks = find_system(mdlName, 'BlockType', 'Switch');
    if ~isempty(switchBlocks)
        anyDisc = true;
        dprintf('      SWITCH BLOCKS:\n');
        for bi = 1:numel(switchBlocks)
            blk = switchBlocks{bi};
            rp  = relPath(blk, mdlName);
            thresh = get_param(blk, 'Threshold');
            crit   = get_param(blk, 'Criteria');
            dprintf('        %-45s  Criteria=%s  Threshold=%s\n', rp, crit, thresh);
        end
        dprintf('\n');
    end

    if ~anyDisc
        dprintf('      (none)\n\n');
    end

    % =====================================================================
    % 12. MODEL REFERENCES
    %     Why: model references create the hierarchical pack→module→cell
    %     architecture.  Knowing which model is referenced where is
    %     essential for understanding the composition.
    % =====================================================================
    dprintf('  [12] MODEL REFERENCES\n  %s\n', SEP2);

    mdlRefs = find_system(mdlName, 'BlockType', 'ModelReference');
    if isempty(mdlRefs)
        dprintf('      (none)\n');
    end
    for bi = 1:numel(mdlRefs)
        blk     = mdlRefs{bi};
        rp      = relPath(blk, mdlName);
        refMdl  = get_param(blk, 'ModelName');
        simMode = get_param(blk, 'SimulationMode');
        dprintf('      Block: %s\n', rp);
        dprintf('        Referenced Model: %s\n', refMdl);
        dprintf('        Sim Mode:         %s\n', simMode);
        dprintf('\n');
    end
    dprintf('\n');

    % =====================================================================
    % 13. FOR-EACH SUBSYSTEM DETAILS
    %     Why: for-each blocks replicate a subsystem across an array
    %     dimension (12 cells per module, 8 modules per pack).
    %     Partition dimensions reveal how data is sliced.
    % =====================================================================
    dprintf('  [13] FOR-EACH SUBSYSTEM DETAILS\n  %s\n', SEP2);

    feBlocks = find_system(mdlName, 'BlockType', 'ForEach');
    if isempty(feBlocks)
        dprintf('      (none)\n');
    end
    for bi = 1:numel(feBlocks)
        blk = feBlocks{bi};
        rp  = relPath(blk, mdlName);
        dprintf('      Block: %s\n', rp);
        try dprintf('        InputPartitionDimension:  %s\n', get_param(blk, 'InputPartitionDimension')); catch, end
        try dprintf('        InputPartitionWidth:      %s\n', get_param(blk, 'InputPartitionWidth')); catch, end
        try dprintf('        OutputConcatenationDim:   %s\n', get_param(blk, 'OutputConcatenationDimension')); catch, end
        dprintf('\n');
    end
    dprintf('\n');

    % =====================================================================
    % 14. BUS CREATOR / BUS SELECTOR BLOCKS
    % =====================================================================
    dprintf('  [14] BUS CREATOR / BUS SELECTOR BLOCKS\n  %s\n', SEP2);

    anyBus = false;
    bcBlocks = find_system(mdlName, 'BlockType', 'BusCreator');
    if ~isempty(bcBlocks)
        anyBus = true;
        dprintf('      BUS CREATORS:\n');
        for bi = 1:numel(bcBlocks)
            blk = bcBlocks{bi};
            rp  = relPath(blk, mdlName);
            nInputs = get_param(blk, 'Inputs');
            dprintf('        %-45s  Inputs=%s\n', rp, nInputs);
            try
                busObj = get_param(blk, 'OutDataTypeStr');
                dprintf('          BusObject: %s\n', busObj);
            catch, end
        end
        dprintf('\n');
    end

    bsBlocks = find_system(mdlName, 'BlockType', 'BusSelector');
    if ~isempty(bsBlocks)
        anyBus = true;
        dprintf('      BUS SELECTORS:\n');
        for bi = 1:numel(bsBlocks)
            blk = bsBlocks{bi};
            rp  = relPath(blk, mdlName);
            outSigs = get_param(blk, 'OutputSignals');
            dprintf('        %s\n', rp);
            dprintf('          OutputSignals: %s\n', outSigs);
        end
        dprintf('\n');
    end

    if ~anyBus
        dprintf('      (none)\n\n');
    end

    % =====================================================================
    % 15. SIGNAL CONNECTIVITY MAP  (source → destination)
    %     Why: this is the "wiring diagram" of the model.  For every line
    %     we capture: source block/port → destination block/port, plus the
    %     signal name (if set).  This replaces the old "named signals"
    %     section with a much more complete picture.
    % =====================================================================
    dprintf('  [15] SIGNAL CONNECTIVITY MAP\n  %s\n', SEP2);
    dprintf('      (Source Block : Port  -->  Destination Block : Port   Signal Name)\n\n');

    allLines = find_system(mdlName, 'FindAll', 'on', 'Type', 'line');
    lineCount = 0;

    for li = 1:numel(allLines)
        lh = allLines(li);
        sigName = get_param(lh, 'Name');
        if isempty(sigName), sigName = '[not set]'; end

        % Source
        srcH = get_param(lh, 'SrcBlockHandle');
        srcP = get_param(lh, 'SrcPortHandle');
        if srcH > 0
            srcStr = relPath(getfullname(srcH), mdlName);
            try srcPortIdx = get_param(srcP, 'PortNumber'); catch, srcPortIdx = 0; end
        else
            srcStr = '(unconnected)'; srcPortIdx = 0;
        end

        % Destination (a line can fan out to multiple destinations)
        dstH = get_param(lh, 'DstBlockHandle');
        dstP = get_param(lh, 'DstPortHandle');

        if isempty(dstH) || all(dstH < 0)
            dstStr = '(unconnected)';
            dprintf('      %-45s :%d  -->  %-45s      sig=%s\n', ...
                srcStr, srcPortIdx, dstStr, sigName);
            lineCount = lineCount + 1;
        else
            for di = 1:numel(dstH)
                if dstH(di) > 0
                    dstStr = relPath(getfullname(dstH(di)), mdlName);
                    try dstPortIdx = get_param(dstP(di), 'PortNumber'); catch, dstPortIdx = 0; end
                else
                    dstStr = '(unconnected)'; dstPortIdx = 0;
                end
                dprintf('      %-45s :%d  -->  %-45s :%d  sig=%s\n', ...
                    srcStr, srcPortIdx, dstStr, dstPortIdx, sigName);
                lineCount = lineCount + 1;
            end
        end
    end

    dprintf('\n      Total signal lines: %d\n\n', lineCount);

    % =====================================================================
    % 16. WORKSPACE VARIABLE REFERENCES & DEPENDENCY MAP
    %     Why: this tells the AI which workspace variable feeds which block
    %     and parameter.  This is essential for understanding how changing
    %     a LUT CSV or a thermal constant propagates through the model.
    % =====================================================================
    dprintf('  [16] WORKSPACE VARIABLE REFERENCES & DEPENDENCY MAP\n  %s\n', SEP2);

    % Scan all blocks for parameter values that are workspace expressions
    varRefs = {};
    for bi = 1:numel(allBlocks)
        blk = allBlocks{bi};
        bt  = blockTypes{bi};

        paramCandidates = {};
        switch bt
            case 'Gain',           paramCandidates = {'Gain'};
            case 'Constant',       paramCandidates = {'Value'};
            case 'Integrator',     paramCandidates = {'InitialCondition'};
            case 'TransferFcn',    paramCandidates = {'Numerator', 'Denominator'};
            case 'Saturate',       paramCandidates = {'UpperLimit', 'LowerLimit'};
            case 'Relay',          paramCandidates = {'OnSwitchValue', 'OffSwitchValue', ...
                                                      'OnOutputValue', 'OffOutputValue'};
            case 'Lookup_n-D',     paramCandidates = {'BreakpointsForDimension1', ...
                                                      'BreakpointsForDimension2', ...
                                                      'BreakpointsForDimension3', 'Table'};
            case 'Switch',         paramCandidates = {'Threshold'};
            case 'Fcn',            paramCandidates = {'Expr'};
        end

        for pci = 1:numel(paramCandidates)
            try
                val = get_param(blk, paramCandidates{pci});
                % A workspace reference is a non-empty char that is not a
                % pure numeric literal (str2double returns NaN for
                % expressions containing variable names)
                if ischar(val) && ~isempty(val) && isnan(str2double(val))
                    varRefs{end+1, 1} = val; %#ok<AGROW>
                    varRefs{end,   2} = paramCandidates{pci};
                    varRefs{end,   3} = relPath(blk, mdlName);
                end
            catch
            end
        end
    end

    % Also scan FromWorkspace / ToWorkspace blocks
    fwBlks = find_system(mdlName, 'BlockType', 'FromWorkspace');
    for bi = 1:numel(fwBlks)
        vn = get_param(fwBlks{bi}, 'VariableName');
        varRefs{end+1, 1} = vn; %#ok<AGROW>
        varRefs{end,   2} = 'VariableName (FromWorkspace)';
        varRefs{end,   3} = relPath(fwBlks{bi}, mdlName);
    end
    twBlks = find_system(mdlName, 'BlockType', 'ToWorkspace');
    for bi = 1:numel(twBlks)
        vn = get_param(twBlks{bi}, 'VariableName');
        varRefs{end+1, 1} = vn; %#ok<AGROW>
        varRefs{end,   2} = 'VariableName (ToWorkspace)';
        varRefs{end,   3} = relPath(twBlks{bi}, mdlName);
    end

    if isempty(varRefs)
        dprintf('      (no workspace variable references detected)\n');
    else
        % --- Full listing (variable → parameter → block) -----------------
        dprintf('      A) Full Reference List\n\n');
        dprintf('      %-35s  %-28s  %s\n', 'Variable / Expression', 'Parameter', 'Block');
        dprintf('      %-35s  %-28s  %s\n', '---------------------', '---------', '-----');
        for ri = 1:size(varRefs, 1)
            dprintf('      %-35s  %-28s  %s\n', ...
                varRefs{ri, 1}, varRefs{ri, 2}, varRefs{ri, 3});
        end
        dprintf('\n');

        % --- Dependency map: variable → all consuming blocks --------------
        dprintf('      B) Dependency Map (Variable -> Consuming Blocks)\n\n');
        [uVars, ~, ~] = unique(varRefs(:,1));
        for vi = 1:numel(uVars)
            mask = strcmp(varRefs(:,1), uVars{vi});
            consumers = varRefs(mask, 3);
            dprintf('      %-35s  <-  %s\n', uVars{vi}, strjoin(consumers', ' ; '));
        end
    end
    dprintf('\n');

    % =====================================================================
    % 17. LUT SUMMARY TABLE
    %     Why: a compact, scannable table summarising every LUT in the
    %     model alongside its breakpoint / table variable names, sizes,
    %     and numeric ranges.  Designed for fast AI cross-referencing.
    % =====================================================================
    dprintf('  [17] LOOKUP TABLE SUMMARY\n  %s\n', SEP2);

    if isempty(lutSummaryRows)
        dprintf('      (no lookup tables in this model)\n');
    else
        % FIX: format string now has 5 specifiers matching the 5 arguments.
        %      Previously the header had 3 specifiers + 2 extra empty args,
        %      causing fprintf to cycle the format and emit garbage output.
        dprintf('      %-45s  %-15s  %-30s  %-4s  %s\n', ...
            'Block', 'Table Var', 'BP Vars', 'Dims', 'Interp');
        dprintf('      %-45s  %-15s  %-30s  %-4s  %s\n', ...
            '-----', '---------', '-------', '----', '------');
        for ri = 1:size(lutSummaryRows, 1)
            dprintf('      %-45s  %-15s  %-30s  %-4s  %s\n', ...
                lutSummaryRows{ri,1}, lutSummaryRows{ri,2}, ...
                lutSummaryRows{ri,3}, lutSummaryRows{ri,4}, ...
                lutSummaryRows{ri,5});
        end
    end
    dprintf('\n');

    % =====================================================================
    % 18. FROM WORKSPACE / TO WORKSPACE BLOCKS
    % =====================================================================
    dprintf('  [18] FROM WORKSPACE / TO WORKSPACE BLOCKS\n  %s\n', SEP2);

    anyWS = false;
    fwBlocks = find_system(mdlName, 'BlockType', 'FromWorkspace');
    if ~isempty(fwBlocks)
        anyWS = true;
        dprintf('      FROM WORKSPACE:\n');
        for bi = 1:numel(fwBlocks)
            blk = fwBlocks{bi};
            rp  = relPath(blk, mdlName);
            varName = get_param(blk, 'VariableName');
            dprintf('        %-45s  Var = %s\n', rp, varName);
        end
        dprintf('\n');
    end

    twBlocks = find_system(mdlName, 'BlockType', 'ToWorkspace');
    if ~isempty(twBlocks)
        anyWS = true;
        dprintf('      TO WORKSPACE:\n');
        for bi = 1:numel(twBlocks)
            blk = twBlocks{bi};
            rp  = relPath(blk, mdlName);
            varName = get_param(blk, 'VariableName');
            dprintf('        %-45s  Var = %s\n', rp, varName);
        end
        dprintf('\n');
    end

    if ~anyWS
        dprintf('      (none)\n\n');
    end

    % =====================================================================
    % 19. SCOPE / DISPLAY / TERMINATOR BLOCKS
    % =====================================================================
    dprintf('  [19] SCOPE / DISPLAY / TERMINATOR BLOCKS\n  %s\n', SEP2);

    anySink = false;
    for sinkType = {'Scope', 'Display', 'Terminator'}
        sinkBlocks = find_system(mdlName, 'BlockType', sinkType{1});
        if ~isempty(sinkBlocks)
            anySink = true;
            dprintf('      %s:\n', upper(sinkType{1}));
            for bi = 1:numel(sinkBlocks)
                dprintf('        %s\n', relPath(sinkBlocks{bi}, mdlName));
            end
            dprintf('\n');
        end
    end
    if ~anySink
        dprintf('      (none)\n\n');
    end

    % =====================================================================
    % 20. MATH FUNCTION / PRODUCT / MINMAX BLOCKS
    % =====================================================================
    dprintf('  [20] MATH FUNCTION / PRODUCT / MINMAX BLOCKS\n  %s\n', SEP2);

    mathFcnBlocks = find_system(mdlName, 'BlockType', 'Math');
    if ~isempty(mathFcnBlocks)
        dprintf('      MATH FUNCTION:\n');
        for bi = 1:numel(mathFcnBlocks)
            blk = mathFcnBlocks{bi};
            rp  = relPath(blk, mdlName);
            fcn = get_param(blk, 'Operator');
            dprintf('        %-45s  Operator = %s\n', rp, fcn);
        end
        dprintf('\n');
    end

    prodBlocks = find_system(mdlName, 'BlockType', 'Product');
    if ~isempty(prodBlocks)
        dprintf('      PRODUCT:\n');
        for bi = 1:numel(prodBlocks)
            blk = prodBlocks{bi};
            rp  = relPath(blk, mdlName);
            inputs = get_param(blk, 'Inputs');
            dprintf('        %-45s  Inputs = %s\n', rp, inputs);
        end
        dprintf('\n');
    end

    mmBlocks = find_system(mdlName, 'BlockType', 'MinMax');
    if ~isempty(mmBlocks)
        dprintf('      MINMAX:\n');
        for bi = 1:numel(mmBlocks)
            blk = mmBlocks{bi};
            rp  = relPath(blk, mdlName);
            fcn = get_param(blk, 'Function');
            dprintf('        %-45s  Function = %s\n', rp, fcn);
        end
        dprintf('\n');
    end

    fcnBlocks = find_system(mdlName, 'BlockType', 'Fcn');
    if ~isempty(fcnBlocks)
        dprintf('      FCN (expression) BLOCKS:\n');
        for bi = 1:numel(fcnBlocks)
            blk = fcnBlocks{bi};
            rp  = relPath(blk, mdlName);
            expr = safeGet(blk, 'Expr', '[not set]');
            dprintf('        %-45s  Expr = %s\n', rp, expr);
        end
        dprintf('\n');
    end

    if isempty(mathFcnBlocks) && isempty(prodBlocks) && isempty(mmBlocks) && isempty(fcnBlocks)
        dprintf('      (none)\n\n');
    end

    % =====================================================================
    % 21. SIGNAL ROUTING (Reshape / Mux / Demux / Selector / Concat)
    % =====================================================================
    dprintf('  [21] SIGNAL ROUTING (Reshape / Mux / Demux / Selector / Concat)\n  %s\n', SEP2);

    anyRouting = false;
    routeTypes = {'Reshape', 'Mux', 'Demux', 'Selector', 'Concatenate'};
    for rti = 1:numel(routeTypes)
        rTypeName = routeTypes{rti};
        rBlocks = find_system(mdlName, 'BlockType', rTypeName);
        if ~isempty(rBlocks)
            anyRouting = true;
            dprintf('      %s:\n', upper(rTypeName));
            for bi = 1:numel(rBlocks)
                blk = rBlocks{bi};
                rp  = relPath(blk, mdlName);
                dprintf('        %s\n', rp);
                if strcmp(rTypeName, 'Reshape')
                    try
                        outDims = get_param(blk, 'OutputDimensions');
                        dprintf('          OutputDimensions: %s\n', outDims);
                    catch, end
                end
                if strcmp(rTypeName, 'Mux') || strcmp(rTypeName, 'Demux')
                    try
                        nPorts = get_param(blk, 'Inputs');
                        dprintf('          Inputs/Outputs: %s\n', nPorts);
                    catch, end
                end
                if strcmp(rTypeName, 'Selector')
                    try
                        idxParam = get_param(blk, 'IndexParamArray');
                        dprintf('          IndexParamArray: %s\n', toStr(idxParam));
                    catch, end
                end
            end
            dprintf('\n');
        end
    end
    if ~anyRouting
        dprintf('      (none)\n\n');
    end

    % =====================================================================
    % 22. STATE BLOCKS (Memory / IC / Unit Delay)
    % =====================================================================
    dprintf('  [22] STATE BLOCKS (Memory / IC / Unit Delay)\n  %s\n', SEP2);

    anyState = false;
    stateTypes = {'Memory', 'InitialCondition', 'UnitDelay'};
    for sti = 1:numel(stateTypes)
        sTypeName = stateTypes{sti};
        sBlocks = find_system(mdlName, 'BlockType', sTypeName);
        if ~isempty(sBlocks)
            anyState = true;
            dprintf('      %s:\n', upper(sTypeName));
            for bi = 1:numel(sBlocks)
                blk = sBlocks{bi};
                rp  = relPath(blk, mdlName);
                dprintf('        %s\n', rp);
                try
                    ic = get_param(blk, 'InitialCondition');
                    dprintf('          IC = %s\n', ic);
                catch, end
                if strcmp(sTypeName, 'UnitDelay')
                    try
                        st = get_param(blk, 'SampleTime');
                        dprintf('          SampleTime = %s\n', st);
                    catch, end
                end
            end
            dprintf('\n');
        end
    end
    if ~anyState
        dprintf('      (none)\n\n');
    end

    % =====================================================================
    % 23. GOTO / FROM TAGS
    % =====================================================================
    dprintf('  [23] GOTO / FROM TAGS\n  %s\n', SEP2);

    anyTag = false;
    gotoBlocks = find_system(mdlName, 'BlockType', 'Goto');
    if ~isempty(gotoBlocks)
        anyTag = true;
        dprintf('      GOTO:\n');
        for bi = 1:numel(gotoBlocks)
            blk = gotoBlocks{bi};
            rp  = relPath(blk, mdlName);
            tag = get_param(blk, 'GotoTag');
            vis = get_param(blk, 'TagVisibility');
            dprintf('        %-45s  Tag=%s  Visibility=%s\n', rp, tag, vis);
        end
        dprintf('\n');
    end

    fromBlocks = find_system(mdlName, 'BlockType', 'From');
    if ~isempty(fromBlocks)
        anyTag = true;
        dprintf('      FROM:\n');
        for bi = 1:numel(fromBlocks)
            blk = fromBlocks{bi};
            rp  = relPath(blk, mdlName);
            tag = get_param(blk, 'GotoTag');
            dprintf('        %-45s  Tag=%s\n', rp, tag);
        end
        dprintf('\n');
    end

    if ~anyTag
        dprintf('      (none)\n\n');
    end

    % =====================================================================
    % 24. DATA STORE MEMORY / READ / WRITE
    % =====================================================================
    dprintf('  [24] DATA STORE MEMORY / READ / WRITE\n  %s\n', SEP2);

    anyDS = false;
    dsTypes = {'DataStoreMemory', 'DataStoreRead', 'DataStoreWrite'};
    for dsi = 1:numel(dsTypes)
        dsTypeName = dsTypes{dsi};
        dsBlocks = find_system(mdlName, 'BlockType', dsTypeName);
        if ~isempty(dsBlocks)
            anyDS = true;
            dprintf('      %s:\n', upper(dsTypeName));
            for bi = 1:numel(dsBlocks)
                blk = dsBlocks{bi};
                rp  = relPath(blk, mdlName);
                dsName = get_param(blk, 'DataStoreName');
                dprintf('        %-45s  DataStore=%s\n', rp, dsName);
            end
            dprintf('\n');
        end
    end
    if ~anyDS
        dprintf('      (none)\n\n');
    end

    % =====================================================================
    % 25. ANNOTATIONS & DESCRIPTIONS
    %     Why: model annotations are free-text notes left by the author.
    %     They may document design intent or known limitations.
    % =====================================================================
    dprintf('  [25] MODEL ANNOTATIONS\n  %s\n', SEP2);

    try
        annots = find_system(mdlName, 'FindAll', 'on', 'Type', 'annotation');
        if isempty(annots)
            dprintf('      (none)\n');
        else
            for ai = 1:numel(annots)
                txt = get_param(annots(ai), 'Text');
                dprintf('      [%d] %s\n', ai, strrep(txt, newline, ' | '));
            end
        end
    catch
        dprintf('      (unable to query annotations)\n');
    end
    dprintf('\n');

    % =====================================================================
    % 26. FULL BLOCK LISTING WITH KEY PARAMETERS
    %     Why: the definitive flat list of every block, its type, and its
    %     most important parameter(s) so the AI can grep for anything.
    % =====================================================================
    dprintf('  [26] FULL BLOCK LISTING\n  %s\n', SEP2);
    dprintf('      %-60s  %-18s  %s\n', 'Block Path', 'BlockType', 'Key Params');
    dprintf('      %-60s  %-18s  %s\n', '----------', '---------', '----------');
    for bi = 1:numel(allBlocks)
        blk = allBlocks{bi};
        bt  = blockTypes{bi};
        rp  = relPath(blk, mdlName);

        % Extract the most informative parameter for each block type
        keyParam = '';
        try
            switch bt
                case 'Gain',        keyParam = sprintf('Gain=%s', get_param(blk, 'Gain'));
                case 'Constant',    keyParam = sprintf('Value=%s', get_param(blk, 'Value'));
                case 'Sum',         keyParam = sprintf('Signs=%s', get_param(blk, 'Inputs'));
                case 'Product',     keyParam = sprintf('Inputs=%s', get_param(blk, 'Inputs'));
                case 'Integrator'
                    icSrc = get_param(blk, 'InitialConditionSource');
                    if strcmp(icSrc, 'internal')
                        keyParam = sprintf('IC=%s', get_param(blk, 'InitialCondition'));
                    else
                        keyParam = 'IC=external';
                    end
                case 'Lookup_n-D',  keyParam = sprintf('Table=%s', safeGet(blk, 'Table', '?'));
                case 'Saturate',    keyParam = sprintf('[%s,%s]', safeGet(blk,'LowerLimit','?'), safeGet(blk,'UpperLimit','?'));
                case 'TransferFcn', keyParam = sprintf('Den=%s', get_param(blk, 'Denominator'));
                case 'Relay',       keyParam = sprintf('On=%s Off=%s', safeGet(blk,'OnSwitchValue','?'), safeGet(blk,'OffSwitchValue','?'));
                case 'Switch',      keyParam = sprintf('Thresh=%s', get_param(blk, 'Threshold'));
                case 'ModelReference', keyParam = sprintf('Ref=%s', get_param(blk, 'ModelName'));
                case 'Fcn',         keyParam = sprintf('Expr=%s', safeGet(blk, 'Expr', '?'));
                case 'Reshape',     keyParam = sprintf('OutDim=%s', safeGet(blk, 'OutputDimensions', '?'));
                case 'MinMax',      keyParam = sprintf('Func=%s', get_param(blk, 'Function'));
                case 'Math',        keyParam = sprintf('Op=%s', get_param(blk, 'Operator'));
                case 'Inport'
                    dt = safeGet(blk, 'OutDataTypeStr', '');
                    keyParam = sprintf('Port=%s DT=%s', get_param(blk, 'Port'), dt);
                case 'Outport',     keyParam = sprintf('Port=%s', get_param(blk, 'Port'));
            end
        catch
        end

        dprintf('      %-60s  %-18s  %s\n', rp, bt, keyParam);
    end
    dprintf('\n');

    % --- Close model without saving ---
    close_system(mdlName, 0);

end  % model loop

% =========================================================================
%  EXECUTIVE SUMMARY  (printed at the end for a quick overview)
%  Why: placing it at the end means all data has been collected. An AI or
%  human reader can jump here first for the 30-second overview.
% =========================================================================
dprintf('\n%s\n', SEP);
dprintf('  EXECUTIVE SUMMARY\n');
dprintf('%s\n\n', SEP);

for mi = 1:numel(summaryData)
    if ~isfield(summaryData(mi), 'name') || isempty(summaryData(mi).name)
        continue;
    end
    sd = summaryData(mi);
    dprintf('  Model: %s.slx\n', sd.name);
    dprintf('    Total blocks:  %d\n', sd.totalBlks);
    dprintf('    Subsystems:    %d\n', numel(sd.subsystems));
    dprintf('    Inports:       %s\n', strjoin(sd.inports, ', '));
    dprintf('    Outports:      %s\n', strjoin(sd.outports, ', '));
    dprintf('\n');
end

dprintf('  Architecture:  pack_96s (96s1p) -> 8 x module_12s (12s) -> 12 x cell_ecm_2rc (2-RC ECM)\n');
dprintf('  Thermal:       Coolant loop + heater/chiller with relay-based thermal manager stub\n');
dprintf('  LUT params:    OCV, R0, R1, C1, R2, C2  (all f(SoC, T))\n');
dprintf('\n');

% =========================================================================
%  FOOTER
% =========================================================================
dprintf('\n%s\n', SEP);
dprintf('  INSPECTION COMPLETE\n');
dprintf('  Report saved to: %s\n', logFile);
dprintf('  Timestamp:       %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
dprintf('%s\n', SEP);

fprintf('\nDone. Report also saved to:\n  %s\n', logFile);

% =========================================================================
%  NESTED HELPER FUNCTIONS
%  All nested functions are grouped here at the end of inspect(), outside
%  any control-flow block. MATLAB requires nested functions to be defined
%  at the function body level — never inside for/if/while/switch blocks.
% =========================================================================

% -------------------------------------------------------------------------
%  dprintf — dual output: console + log file
% -------------------------------------------------------------------------
    function dprintf(fmt, varargin)
        msg = sprintf(fmt, varargin{:});
        fprintf('%s', msg);
        fprintf(fid, '%s', msg);
    end

% -------------------------------------------------------------------------
%  toStr — safe string conversion for any value type
%  Used whenever we need to print a variable that might be numeric,
%  struct, cell, or char.  Avoids crashing on unexpected types.
% -------------------------------------------------------------------------
    function s = toStr(v)
        if ischar(v)
            s = v;
        elseif isstring(v)
            s = char(v);
        elseif isnumeric(v) || islogical(v)
            if isscalar(v)
                s = num2str(v, '%.6g');
            elseif numel(v) <= 200
                s = mat2str(v, 6);
            else
                s = sprintf('[%s array, min=%.6g, max=%.6g]', ...
                    strjoin(arrayfun(@num2str, size(v), 'Uni', false), 'x'), ...
                    min(v(:)), max(v(:)));
            end
        elseif isstruct(v)
            s = sprintf('[struct with fields: %s]', strjoin(fieldnames(v), ', '));
        elseif iscell(v)
            s = sprintf('[%dx%d cell]', size(v,1), size(v,2));
        elseif isa(v, 'timeseries') || isa(v, 'Simulink.SimulationData.Dataset')
            s = sprintf('[%s object]', class(v));
        else
            s = sprintf('[%s]', class(v));
        end
    end

% -------------------------------------------------------------------------
%  safeGet — safely get a block parameter, returning a default on failure
% -------------------------------------------------------------------------
    function v = safeGet(blk, param, default)
        try
            v = get_param(blk, param);
        catch
            v = default;
        end
    end

% -------------------------------------------------------------------------
%  relPath — relative block path (strips model name prefix)
%  FIX: output variable renamed from 'rp' to 'result' to avoid variable
%       shadowing. In MATLAB nested functions, output variables are shared
%       with the parent workspace by name; using 'rp' here would collide
%       with the 'rp' variable used extensively throughout inspect().
% -------------------------------------------------------------------------
    function result = relPath(blk, mdl)
        result = strrep(blk, [mdl '/'], '');
    end

% -------------------------------------------------------------------------
%  local_printPorts — print inport/outport info with description & unit
%  FIX: moved here from inside the 'for mi' loop where it was originally
%       defined. MATLAB forbids nested function definitions inside
%       control-flow structures (for, if, while, switch). Placing it here,
%       at the body level of inspect(), makes it a valid nested function
%       accessible from anywhere inside inspect().
% -------------------------------------------------------------------------
    function local_printPorts(ports, tag)
        if isempty(ports), return; end
        dprintf('        %s:\n', tag);
        for ppi = 1:numel(ports)
            pp    = ports{ppi};
            pName = get_param(pp, 'Name');
            pNum  = get_param(pp, 'Port');
            dt    = safeGet(pp, 'OutDataTypeStr', '[not set]');
            desc  = safeGet(pp, 'Description', '');
            unit  = safeGet(pp, 'Unit', '');
            extra = '';
            if ~isempty(desc), extra = [extra, '  Desc="', desc, '"']; end
            if ~isempty(unit), extra = [extra, '  Unit=', unit]; end
            dprintf('          [%s] %-25s  DataType: %-20s%s\n', ...
                pNum, pName, dt, extra);
        end
    end

end  % inspect()