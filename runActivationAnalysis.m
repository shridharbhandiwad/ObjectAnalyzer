function analyzer = runActivationAnalysis(varargin)
    % runActivationAnalysis - Launch the Activation Plot Analyzer
    %
    % Usage:
    %   analyzer = runActivationAnalysis()  % Launch with demo data
    %   analyzer = runActivationAnalysis(mainProc, debugVars, syncInfo)  % Launch with real data
    %
    % Inputs:
    %   mainProc  - SfRunMainProc_m_portMainProc_out structure
    %   debugVars - SfRunMainProc_debugvariables structure
    %   syncInfo  - g_PerSpdRunnable_m_syncInfoPort_out structure
    %
    % Outputs:
    %   analyzer  - ActivationPlotAnalyzer instance
    %
    % Features:
    %   - Automatically removes existing instances when loaded
    %   - Provides minimize, maximize, close buttons
    %   - Zoom and pan functionality for all plots
    %   - Intelligent DEP object identification
    %   - Real-time activation analysis
    
    fprintf('Launching Activation Plot Analyzer...\n');
    
    % Create analyzer instance (automatically removes existing instances)
    analyzer = ActivationPlotAnalyzer();
    
    % Handle input arguments
    if nargin == 0
        fprintf('No data provided. Generating demo data...\n');
        [mainProc, debugVars, syncInfo] = generateDemoData();
        analyzer.redefineActivationPlot(mainProc, debugVars, syncInfo);
        fprintf('Demo data loaded successfully.\n');
    elseif nargin == 3
        fprintf('Processing provided data...\n');
        analyzer.redefineActivationPlot(varargin{1}, varargin{2}, varargin{3});
        fprintf('Data processed successfully.\n');
    else
        error('Invalid number of arguments. Use either 0 or 3 arguments.');
    end
    
    % Display information about DEP objects
    fprintf('\nDEP Object Information:\n');
    fprintf('======================\n');
    for i = 1:length(analyzer.dep_ids)
        fprintf('DEP ID: %s\n', analyzer.dep_ids{i});
    end
    
    if ~isempty(analyzer.first_activation_cycle)
        fprintf('\nFirst Activation Cycle: %d\n', analyzer.first_activation_cycle);
    else
        fprintf('\nNo activation detected.\n');
    end
    
    if isfield(analyzer.current_dep_activation, 'primary_trigger')
        fprintf('Primary Trigger: %s\n', analyzer.current_dep_activation.primary_trigger);
    end
    
    fprintf('\nActivation Plot Analyzer launched successfully!\n');
    fprintf('Use the toolbar buttons to:\n');
    fprintf('- Minimize, maximize, or close the window\n');
    fprintf('- Zoom in/out on the plot\n');
    fprintf('- Pan around the plot\n');
    fprintf('- Reset the view\n\n');
end

function [mainProc, debugVars, syncInfo] = generateDemoData()
    % Generate demo data for testing the activation plot analyzer
    
    % Time vectors
    n_samples = 1000;
    time_main = linspace(0, 10, n_samples);
    time_sync = linspace(0, 10, n_samples + 100);  % Slightly different sampling
    
    % Create main process data
    mainProc = struct();
    mainProc.time = time_main;
    
    % Generate brake type activation signal
    % Activate brake type at random intervals
    brake_activation_points = [200, 400, 600, 800];
    mainProc.m_brakeTypeActive = zeros(size(time_main));
    for point = brake_activation_points
        if point <= length(time_main)
            activation_length = randi([10, 50]);  % Random activation duration
            end_point = min(point + activation_length, length(time_main));
            mainProc.m_brakeTypeActive(point:end_point) = 1;
        end
    end
    
    % Create debug variables
    debugVars = struct();
    debugVars.m_stateMachines = struct();
    debugVars.m_stateMachines.m_hbaStateMachine = struct();
    
    % Generate HBA state machine current state
    % Activate HBA state at different intervals
    hba_activation_points = [150, 350, 550, 750];
    hba_current_state = zeros(size(time_main));
    for point = hba_activation_points
        if point <= length(time_main)
            activation_length = randi([15, 60]);  % Random activation duration
            end_point = min(point + activation_length, length(time_main));
            hba_current_state(point:end_point) = randi([1, 5]);  % Random state value
        end
    end
    debugVars.m_stateMachines.m_hbaStateMachine.m_currentState = hba_current_state;
    
    % Create sync info
    syncInfo = struct();
    syncInfo.time = time_sync;
    
    fprintf('Demo data generated:\n');
    fprintf('- Main process time: %.2f to %.2f seconds (%d samples)\n', ...
            time_main(1), time_main(end), length(time_main));
    fprintf('- Sync info time: %.2f to %.2f seconds (%d samples)\n', ...
            time_sync(1), time_sync(end), length(time_sync));
    fprintf('- Brake activation points: %d\n', sum(mainProc.m_brakeTypeActive > 0));
    fprintf('- HBA state activation points: %d\n', sum(hba_current_state > 0));
end