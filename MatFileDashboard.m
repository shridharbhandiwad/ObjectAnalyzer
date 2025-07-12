function MatFileDashboard()
    % MATFILEDASHBOARD - Dashboard for reading and analyzing .mat files
    % Features:
    % 1. Browse or drag & drop .mat files
    % 2. Show activation flags plot
    % 3. Remove second instance variables (containing '2_')
    % 4. Interactive buttons and plots
    
    % Create main figure
    fig = figure('Name', 'MAT File Dashboard', 'NumberTitle', 'off', ...
                 'Position', [100, 100, 1200, 800], 'MenuBar', 'none', ...
                 'ToolBar', 'none', 'Resize', 'on');
    
    % Global variables to store data
    global currentData activationData cycleData
    currentData = [];
    activationData = [];
    cycleData = [];
    
    % Create UI components
    createUI(fig);
    
    % Enable drag and drop
    enableDragDrop(fig);
end

function createUI(fig)
    % Create main panels
    controlPanel = uipanel('Parent', fig, 'Title', 'Control Panel', ...
                          'Position', [0.02, 0.7, 0.25, 0.28]);
    
    plotPanel = uipanel('Parent', fig, 'Title', 'Activation Plot', ...
                       'Position', [0.3, 0.35, 0.68, 0.63]);
    
    dataPanel = uipanel('Parent', fig, 'Title', 'Data Information', ...
                       'Position', [0.02, 0.35, 0.25, 0.33]);
    
    statusPanel = uipanel('Parent', fig, 'Title', 'Status', ...
                         'Position', [0.02, 0.02, 0.96, 0.3]);
    
    % Control Panel Components
    uicontrol('Parent', controlPanel, 'Style', 'text', ...
              'String', 'File Operations:', 'FontWeight', 'bold', ...
              'Position', [10, 180, 120, 20], 'HorizontalAlignment', 'left');
    
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
              'String', 'Browse MAT File', 'Position', [10, 150, 120, 25], ...
              'Callback', @browseFile);
    
    uicontrol('Parent', controlPanel, 'Style', 'text', ...
              'String', 'Data Processing:', 'FontWeight', 'bold', ...
              'Position', [10, 115, 120, 20], 'HorizontalAlignment', 'left');
    
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
              'String', 'Show Activation', 'Position', [10, 85, 120, 25], ...
              'Callback', @showActivation);
    
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
              'String', 'Remove 2_ Variables', 'Position', [10, 55, 120, 25], ...
              'Callback', @removeSecondInstance);
    
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
              'String', 'Clear All Data', 'Position', [10, 25, 120, 25], ...
              'Callback', @clearData);
    
    % Data Panel Components
    uicontrol('Parent', dataPanel, 'Style', 'text', ...
              'String', 'Loaded Variables:', 'FontWeight', 'bold', ...
              'Position', [10, 220, 120, 20], 'HorizontalAlignment', 'left');
    
    global variableList
    variableList = uicontrol('Parent', dataPanel, 'Style', 'listbox', ...
                            'Position', [10, 50, 170, 170], 'FontSize', 8);
    
    uicontrol('Parent', dataPanel, 'Style', 'text', ...
              'String', 'File Status:', 'FontWeight', 'bold', ...
              'Position', [10, 25, 120, 20], 'HorizontalAlignment', 'left');
    
    global statusText
    statusText = uicontrol('Parent', dataPanel, 'Style', 'text', ...
                          'String', 'No file loaded', 'FontSize', 8, ...
                          'Position', [10, 5, 170, 15], 'HorizontalAlignment', 'left');
    
    % Create axes for plotting
    global activationAxes
    activationAxes = axes('Parent', plotPanel, 'Position', [0.1, 0.1, 0.85, 0.8]);
    title(activationAxes, 'Activation Flags Over Cycles');
    xlabel(activationAxes, 'Cycle');
    ylabel(activationAxes, 'Activation State');
    grid(activationAxes, 'on');
    
    % Status Panel - Create text area for logging
    global logText
    logText = uicontrol('Parent', statusPanel, 'Style', 'edit', ...
                       'Max', 10, 'Min', 0, 'Position', [10, 10, 1130, 200], ...
                       'FontSize', 9, 'FontName', 'Courier', ...
                       'HorizontalAlignment', 'left', 'Enable', 'inactive');
    
    % Add initial log message
    addLog('Dashboard initialized. Please browse or drag & drop a .mat file.');
end

function enableDragDrop(fig)
    % Enable drag and drop functionality
    jFrame = get(fig, 'JavaFrame');
    try
        jFrame.fHG2Client.getWindow.setDropTarget([]);
        dndObj = handle(jFrame.fHG2Client.getWindow, 'CallbackProperties');
        set(dndObj, 'DragEnterCallback', @dragEnterCallback);
        set(dndObj, 'DragOverCallback', @dragOverCallback);
        set(dndObj, 'DropCallback', @dropCallback);
    catch
        addLog('Warning: Drag & drop functionality may not be available in this MATLAB version.');
    end
end

function dragEnterCallback(~, evt)
    % Handle drag enter event
    if evt.DropAction == 1 % COPY
        evt.DropAction = 1;
        evt.showDropTargetEffect;
    end
end

function dragOverCallback(~, evt)
    % Handle drag over event
    if evt.DropAction == 1 % COPY
        evt.DropAction = 1;
        evt.showDropTargetEffect;
    end
end

function dropCallback(~, evt)
    % Handle drop event
    try
        files = evt.DropInfo.getTransferData();
        if ~isempty(files)
            fileName = char(files(1));
            if endsWith(fileName, '.mat')
                loadMatFile(fileName);
            else
                addLog('Error: Please drop a .mat file.');
            end
        end
    catch ME
        addLog(['Error in drag & drop: ' ME.message]);
    end
end

function browseFile(~, ~)
    % Browse for MAT file
    [fileName, pathName] = uigetfile('*.mat', 'Select MAT File');
    if fileName ~= 0
        fullPath = fullfile(pathName, fileName);
        loadMatFile(fullPath);
    end
end

function loadMatFile(fileName)
    % Load MAT file and update interface
    global currentData statusText variableList
    
    try
        addLog(['Loading file: ' fileName]);
        currentData = load(fileName);
        
        % Update status
        set(statusText, 'String', ['Loaded: ' fileName]);
        
        % Update variable list
        varNames = fieldnames(currentData);
        set(variableList, 'String', varNames);
        
        addLog(['Successfully loaded ' num2str(length(varNames)) ' variables.']);
        
        % List some key variables for debugging
        for i = 1:min(5, length(varNames))
            varInfo = whos('-file', fileName, varNames{i});
            addLog(['  ' varNames{i} ': ' varInfo.class ' [' num2str(varInfo.size) ']']);
        end
        
    catch ME
        addLog(['Error loading file: ' ME.message]);
    end
end

function showActivation(~, ~)
    % Show activation plot
    global currentData activationData cycleData activationAxes
    
    if isempty(currentData)
        addLog('Error: No data loaded. Please load a .mat file first.');
        return;
    end
    
    try
        % Extract activation flags
        % activation_flags = SfRunMainProc_m_portMainProc_out.m_brakeTypeActive | 
        %                   SfRunMainProc_debugvariables.m_stateMachines.m_hbaStateMachine.m_currentState;
        
        brakeTypeActive = [];
        currentState = [];
        
        % Try to find the brake type active variable
        if isfield(currentData, 'SfRunMainProc_m_portMainProc_out')
            if isfield(currentData.SfRunMainProc_m_portMainProc_out, 'm_brakeTypeActive')
                brakeTypeActive = currentData.SfRunMainProc_m_portMainProc_out.m_brakeTypeActive;
                addLog('Found m_brakeTypeActive variable');
            end
        end
        
        % Try to find the current state variable
        if isfield(currentData, 'SfRunMainProc_debugvariables')
            if isfield(currentData.SfRunMainProc_debugvariables, 'm_stateMachines')
                if isfield(currentData.SfRunMainProc_debugvariables.m_stateMachines, 'm_hbaStateMachine')
                    if isfield(currentData.SfRunMainProc_debugvariables.m_stateMachines.m_hbaStateMachine, 'm_currentState')
                        currentState = currentData.SfRunMainProc_debugvariables.m_stateMachines.m_hbaStateMachine.m_currentState;
                        addLog('Found m_currentState variable');
                    end
                end
            end
        end
        
        % If we couldn't find the exact variables, try to find similar ones
        if isempty(brakeTypeActive) || isempty(currentState)
            addLog('Could not find exact variable names. Searching for similar variables...');
            varNames = fieldnames(currentData);
            
            % Search for brake-related variables
            brakeVars = varNames(contains(varNames, 'brake', 'IgnoreCase', true));
            if ~isempty(brakeVars)
                addLog(['Found brake-related variables: ' strjoin(brakeVars, ', ')]);
                % Try to use the first brake variable found
                try
                    brakeTypeActive = currentData.(brakeVars{1});
                    addLog(['Using ' brakeVars{1} ' as brake type active']);
                catch
                    addLog(['Could not access ' brakeVars{1}]);
                end
            end
            
            % Search for state-related variables
            stateVars = varNames(contains(varNames, 'state', 'IgnoreCase', true));
            if ~isempty(stateVars)
                addLog(['Found state-related variables: ' strjoin(stateVars, ', ')]);
                % Try to use the first state variable found
                try
                    currentState = currentData.(stateVars{1});
                    addLog(['Using ' stateVars{1} ' as current state']);
                catch
                    addLog(['Could not access ' stateVars{1}]);
                end
            end
        end
        
        % Create activation flags
        if ~isempty(brakeTypeActive) && ~isempty(currentState)
            % Ensure both variables have the same length
            minLen = min(length(brakeTypeActive), length(currentState));
            brakeTypeActive = brakeTypeActive(1:minLen);
            currentState = currentState(1:minLen);
            
            % Create activation flags using bitwise OR
            activationData = brakeTypeActive | currentState;
            cycleData = 1:length(activationData);
            
            % Plot the activation flags
            cla(activationAxes);
            plot(activationAxes, cycleData, activationData, 'b-', 'LineWidth', 2);
            hold(activationAxes, 'on');
            plot(activationAxes, cycleData, brakeTypeActive, 'r--', 'LineWidth', 1);
            plot(activationAxes, cycleData, currentState, 'g--', 'LineWidth', 1);
            
            title(activationAxes, 'Activation Flags Over Cycles');
            xlabel(activationAxes, 'Cycle');
            ylabel(activationAxes, 'Activation State');
            legend(activationAxes, 'Combined Activation', 'Brake Type Active', 'Current State');
            grid(activationAxes, 'on');
            
            addLog(['Plotted activation flags for ' num2str(length(activationData)) ' cycles']);
            
        else
            addLog('Error: Could not find required variables for activation plot.');
            addLog('Available variables:');
            varNames = fieldnames(currentData);
            for i = 1:min(10, length(varNames))
                addLog(['  ' varNames{i}]);
            end
        end
        
    catch ME
        addLog(['Error creating activation plot: ' ME.message]);
    end
end

function removeSecondInstance(~, ~)
    % Remove variables containing '2_'
    global currentData variableList
    
    if isempty(currentData)
        addLog('Error: No data loaded. Please load a .mat file first.');
        return;
    end
    
    try
        varNames = fieldnames(currentData);
        removedCount = 0;
        
        % Find variables containing '2_'
        varsToRemove = {};
        for i = 1:length(varNames)
            if contains(varNames{i}, '2_')
                varsToRemove{end+1} = varNames{i};
            end
        end
        
        % Remove the variables
        for i = 1:length(varsToRemove)
            currentData = rmfield(currentData, varsToRemove{i});
            addLog(['Removed variable: ' varsToRemove{i}]);
            removedCount = removedCount + 1;
        end
        
        % Update variable list
        newVarNames = fieldnames(currentData);
        set(variableList, 'String', newVarNames);
        
        addLog(['Successfully removed ' num2str(removedCount) ' variables containing "2_"']);
        
    catch ME
        addLog(['Error removing variables: ' ME.message]);
    end
end

function clearData(~, ~)
    % Clear all loaded data
    global currentData activationData cycleData variableList statusText activationAxes
    
    currentData = [];
    activationData = [];
    cycleData = [];
    
    set(variableList, 'String', {});
    set(statusText, 'String', 'No file loaded');
    
    cla(activationAxes);
    title(activationAxes, 'Activation Flags Over Cycles');
    xlabel(activationAxes, 'Cycle');
    ylabel(activationAxes, 'Activation State');
    grid(activationAxes, 'on');
    
    addLog('All data cleared.');
end

function addLog(message)
    % Add message to log
    global logText
    
    if isempty(logText)
        return;
    end
    
    currentLog = get(logText, 'String');
    timestamp = datestr(now, 'HH:MM:SS');
    newMessage = ['[' timestamp '] ' message];
    
    if isempty(currentLog)
        newLog = {newMessage};
    else
        if iscell(currentLog)
            newLog = [currentLog; {newMessage}];
        else
            newLog = {currentLog; newMessage};
        end
        
        % Keep only last 50 messages
        if length(newLog) > 50
            newLog = newLog(end-49:end);
        end
    end
    
    set(logText, 'String', newLog);
    
    % Auto-scroll to bottom
    drawnow;
end