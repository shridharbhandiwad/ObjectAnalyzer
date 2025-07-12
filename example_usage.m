% example_usage.m
% Example script demonstrating the MAT File Dashboard functionality

%% Clean workspace
clear all; close all; clc;

%% Create Sample Data for Testing
% This creates a sample .mat file with the expected structure
% for testing the dashboard functionality

% Create sample activation data
numCycles = 1000;
time = 1:numCycles;

% Create sample brake type active data (binary)
brakeTypeActive = double(rand(numCycles, 1) > 0.7); % 30% activation rate

% Create sample current state data (binary)
currentState = double(rand(numCycles, 1) > 0.8); % 20% activation rate

% Create the expected data structure
SfRunMainProc_m_portMainProc_out.m_brakeTypeActive = brakeTypeActive;
SfRunMainProc_debugvariables.m_stateMachines.m_hbaStateMachine.m_currentState = currentState;

% Add some additional variables for testing
SfRunMainProc_m_portMainProc_out.m_velocity = 50 + 20*sin(time/100) + 5*randn(size(time));
SfRunMainProc_debugvariables.m_stateMachines.m_hbaStateMachine.m_previousState = [0; currentState(1:end-1)];

% Create some variables with '2_' in their names (for removal testing)
SfRunMainProc_2_backup.m_brakeTypeActive = brakeTypeActive;
SfRunMainProc_debugvariables_2_copy.m_stateMachines.m_hbaStateMachine.m_currentState = currentState;

% Add some metadata
metadata.createdBy = 'example_usage.m';
metadata.createdOn = datestr(now);
metadata.numCycles = numCycles;
metadata.description = 'Sample data for MAT File Dashboard testing';

%% Save sample data
fprintf('Creating sample .mat file...\n');
save('sample_data.mat', 'SfRunMainProc_m_portMainProc_out', ...
     'SfRunMainProc_debugvariables', 'SfRunMainProc_2_backup', ...
     'SfRunMainProc_debugvariables_2_copy', 'metadata', 'time');

fprintf('Sample data saved to sample_data.mat\n');
fprintf('Variables saved:\n');
whos('-file', 'sample_data.mat')

%% Launch the Dashboard
fprintf('\nLaunching MAT File Dashboard...\n');
fprintf('Instructions:\n');
fprintf('1. Use "Browse MAT File" to load sample_data.mat\n');
fprintf('2. Click "Show Activation" to plot the activation flags\n');
fprintf('3. Click "Remove 2_ Variables" to clean up duplicate variables\n');
fprintf('4. Monitor the status panel for real-time feedback\n');
fprintf('\nStarting dashboard...\n');

% Launch the dashboard
MatFileDashboard();

%% Additional Helper Functions

function demonstrateActivationCalculation()
    % This function demonstrates how the activation flags are calculated
    % Load the sample data
    if exist('sample_data.mat', 'file')
        data = load('sample_data.mat');
        
        % Extract the variables
        brakeActive = data.SfRunMainProc_m_portMainProc_out.m_brakeTypeActive;
        currentState = data.SfRunMainProc_debugvariables.m_stateMachines.m_hbaStateMachine.m_currentState;
        
        % Calculate activation flags
        activationFlags = brakeActive | currentState;
        
        % Display results
        fprintf('\nActivation Calculation Example:\n');
        fprintf('Brake Type Active: %d samples with mean = %.3f\n', ...
                length(brakeActive), mean(brakeActive));
        fprintf('Current State: %d samples with mean = %.3f\n', ...
                length(currentState), mean(currentState));
        fprintf('Combined Activation: %d samples with mean = %.3f\n', ...
                length(activationFlags), mean(activationFlags));
        
        % Show first 10 samples
        fprintf('\nFirst 10 samples:\n');
        fprintf('Cycle\tBrake\tState\tCombined\n');
        for i = 1:min(10, length(activationFlags))
            fprintf('%d\t%d\t%d\t%d\n', i, brakeActive(i), currentState(i), activationFlags(i));
        end
        
        % Create a simple plot
        figure('Name', 'Activation Demonstration', 'Position', [200, 200, 800, 400]);
        
        subplot(2,1,1);
        plot(1:length(brakeActive), brakeActive, 'r-', 'LineWidth', 1.5);
        hold on;
        plot(1:length(currentState), currentState, 'g-', 'LineWidth', 1.5);
        plot(1:length(activationFlags), activationFlags, 'b-', 'LineWidth', 2);
        legend('Brake Type Active', 'Current State', 'Combined Activation');
        title('Activation Flags Over Time');
        xlabel('Cycle');
        ylabel('Activation State');
        grid on;
        
        subplot(2,1,2);
        % Show activation periods
        activePeriods = find(activationFlags);
        if ~isempty(activePeriods)
            stem(activePeriods, ones(size(activePeriods)), 'b', 'filled');
            title('Active Periods');
            xlabel('Cycle');
            ylabel('Active');
            grid on;
        end
        
    else
        fprintf('sample_data.mat not found. Please run the main script first.\n');
    end
end

function cleanupExample()
    % Example of removing variables with '2_' in their names
    fprintf('\nVariable Cleanup Example:\n');
    
    if exist('sample_data.mat', 'file')
        data = load('sample_data.mat');
        varNames = fieldnames(data);
        
        fprintf('Original variables:\n');
        for i = 1:length(varNames)
            fprintf('  %s\n', varNames{i});
        end
        
        % Find variables with '2_'
        varsToRemove = {};
        for i = 1:length(varNames)
            if contains(varNames{i}, '2_')
                varsToRemove{end+1} = varNames{i};
            end
        end
        
        fprintf('\nVariables to remove (containing "2_"):\n');
        for i = 1:length(varsToRemove)
            fprintf('  %s\n', varsToRemove{i});
        end
        
        % Remove the variables
        for i = 1:length(varsToRemove)
            data = rmfield(data, varsToRemove{i});
        end
        
        % Show remaining variables
        remainingVars = fieldnames(data);
        fprintf('\nRemaining variables:\n');
        for i = 1:length(remainingVars)
            fprintf('  %s\n', remainingVars{i});
        end
        
        fprintf('\nRemoved %d variables containing "2_"\n', length(varsToRemove));
        
    else
        fprintf('sample_data.mat not found. Please run the main script first.\n');
    end
end

%% Run additional demonstrations if requested
if nargout == 0
    % Only run if script is executed directly, not if called as function
    fprintf('\n=== Additional Demonstrations ===\n');
    fprintf('Run these commands for more examples:\n');
    fprintf('>> demonstrateActivationCalculation()\n');
    fprintf('>> cleanupExample()\n');
end