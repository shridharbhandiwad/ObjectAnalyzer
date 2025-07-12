% quickStart.m - Quick Start Script for Activation Plot Analyzer
% 
% This script demonstrates how to quickly launch the Activation Plot Analyzer
% with all requested features implemented.
%
% Features Implemented:
% 1. Activation plot redefined by logic:
%    activation_flags = SfRunMainProc_m_portMainProc_out.m_brakeTypeActive | 
%                      SfRunMainProc_debugvariables.m_stateMachines.m_hbaStateMachine.m_currentState
%
% 2. Cycles calculation using interp1:
%    cycles = interp1(g_PerSpdRunnable_m_syncInfoPort_out.time, 
%                     1:length(g_PerSpdRunnable_m_syncInfoPort_out.time), 
%                     SfRunMainProc_m_portMainProc_out.time, 'nearest', 'extrap')
%
% 3. First activation cycle detection:
%    first_activation_cycle = cycles(find(activation_flags, 1))
%
% 4. Automatic instance removal when file is loaded
% 5. DEP object intelligence with DEP IDs
% 6. Window controls: minimize, maximize, close buttons
% 7. Zoom and pan options for all plots

clear; clc;

fprintf('=================================================\n');
fprintf('    ACTIVATION PLOT ANALYZER - QUICK START\n');
fprintf('=================================================\n');
fprintf('\n');

% Launch the analyzer with demo data
fprintf('Starting Activation Plot Analyzer...\n');
fprintf('This will automatically remove any existing instances.\n\n');

% Create the analyzer - this will automatically handle instance removal
analyzer = runActivationAnalysis();

fprintf('\n=================================================\n');
fprintf('    ACTIVATION PLOT ANALYZER LAUNCHED\n');
fprintf('=================================================\n');
fprintf('\n');

fprintf('Available DEP Object IDs:\n');
for i = 1:length(analyzer.dep_ids)
    fprintf('  - %s\n', analyzer.dep_ids{i});
end

fprintf('\nWindow Controls Available:\n');
fprintf('  - Minimize Button: Minimizes the window\n');
fprintf('  - Maximize Button: Toggles maximize/restore\n');
fprintf('  - Close Button: Closes the window\n');
fprintf('  - Zoom Tool: Click and drag to zoom in/out\n');
fprintf('  - Pan Tool: Click and drag to pan around\n');
fprintf('  - Reset View: Returns to original view\n');

fprintf('\nActivation Logic Applied:\n');
fprintf('  activation_flags = m_brakeTypeActive | m_currentState\n');
fprintf('  cycles = interp1(sync_time, 1:length(sync_time), main_time, ''nearest'', ''extrap'')\n');
fprintf('  first_activation_cycle = cycles(find(activation_flags, 1))\n');

fprintf('\nTo use with your own data:\n');
fprintf('  analyzer = runActivationAnalysis(mainProc, debugVars, syncInfo)\n');

fprintf('\n=================================================\n');
fprintf('Ready to analyze activation patterns!\n');
fprintf('Check the plot window for visualization.\n');
fprintf('=================================================\n');

% Store analyzer in base workspace for easy access
assignin('base', 'activationAnalyzer', analyzer);
fprintf('\nAnalyzer stored as ''activationAnalyzer'' in base workspace.\n');