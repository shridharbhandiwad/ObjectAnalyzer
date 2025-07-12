classdef ActivationPlotAnalyzer < handle
    properties
        figHandle
        axesHandle
        data
        activation_flags
        cycles
        first_activation_cycle
        dep_objects
        dep_ids
        current_dep_activation
        zoom_handle
        pan_handle
        instances = {}
    end
    
    methods
        function obj = ActivationPlotAnalyzer()
            % Constructor - automatically remove existing instances when loaded
            obj.removeExistingInstances();
            obj.createMainWindow();
            obj.setupPlotControls();
            obj.initializeDEPIntelligence();
        end
        
        function removeExistingInstances(obj)
            % Automatically remove existing instances when file is loaded
            existing_figs = findobj('Type', 'figure', 'Tag', 'ActivationPlotAnalyzer');
            if ~isempty(existing_figs)
                delete(existing_figs);
                fprintf('Removed %d existing ActivationPlotAnalyzer instances\n', length(existing_figs));
            end
            
            % Clear any existing instances from base workspace
            if evalin('base', 'exist(''activationAnalyzer'', ''var'')')
                evalin('base', 'clear activationAnalyzer');
            end
        end
        
        function createMainWindow(obj)
            % Create main window with minimize, maximize, close buttons
            obj.figHandle = figure('Name', 'Activation Plot Analyzer', ...
                                 'Tag', 'ActivationPlotAnalyzer', ...
                                 'MenuBar', 'none', ...
                                 'ToolBar', 'none', ...
                                 'Resize', 'on', ...
                                 'Position', [100, 100, 1200, 800], ...
                                 'CloseRequestFcn', @(src, evt) obj.closeWindow());
            
            % Create custom toolbar with window controls
            obj.createCustomToolbar();
            
            % Create main axes for plotting
            obj.axesHandle = axes('Parent', obj.figHandle, ...
                                'Position', [0.1, 0.15, 0.8, 0.7]);
            
            % Create control panel
            obj.createControlPanel();
        end
        
        function createCustomToolbar(obj)
            % Create custom toolbar with minimize, maximize, close, zoom, pan
            toolbar = uitoolbar(obj.figHandle);
            
            % Window control buttons
            uipushtool(toolbar, 'CData', obj.createMinimizeIcon(), ...
                      'TooltipString', 'Minimize Window', ...
                      'ClickedCallback', @(src, evt) obj.minimizeWindow());
            
            uipushtool(toolbar, 'CData', obj.createMaximizeIcon(), ...
                      'TooltipString', 'Maximize Window', ...
                      'ClickedCallback', @(src, evt) obj.maximizeWindow());
            
            uipushtool(toolbar, 'CData', obj.createCloseIcon(), ...
                      'TooltipString', 'Close Window', ...
                      'ClickedCallback', @(src, evt) obj.closeWindow());
            
            % Separator
            uipushtool(toolbar, 'CData', ones(16,16,3), 'Separator', 'on');
            
            % Zoom and Pan controls
            obj.zoom_handle = zoom(obj.figHandle);
            obj.pan_handle = pan(obj.figHandle);
            
            uitoggletool(toolbar, 'CData', obj.createZoomIcon(), ...
                        'TooltipString', 'Zoom Tool', ...
                        'OnCallback', @(src, evt) obj.enableZoom(), ...
                        'OffCallback', @(src, evt) obj.disableZoom());
            
            uitoggletool(toolbar, 'CData', obj.createPanIcon(), ...
                        'TooltipString', 'Pan Tool', ...
                        'OnCallback', @(src, evt) obj.enablePan(), ...
                        'OffCallback', @(src, evt) obj.disablePan());
            
            uipushtool(toolbar, 'CData', obj.createResetIcon(), ...
                      'TooltipString', 'Reset View', ...
                      'ClickedCallback', @(src, evt) obj.resetView());
        end
        
        function setupPlotControls(obj)
            % Setup plot control functionality
            set(obj.zoom_handle, 'ActionPostCallback', @(src, evt) obj.updatePlotInfo());
            set(obj.pan_handle, 'ActionPostCallback', @(src, evt) obj.updatePlotInfo());
        end
        
        function initializeDEPIntelligence(obj)
            % Initialize DEP object intelligence system
            obj.dep_objects = containers.Map();
            obj.dep_ids = {};
            obj.current_dep_activation = struct();
            
            % Define known DEP object patterns
            obj.setupDEPPatterns();
        end
        
        function setupDEPPatterns(obj)
            % Setup DEP object identification patterns
            dep_patterns = {
                'SfRunMainProc_m_portMainProc_out', 'MAIN_PROC_DEP_001';
                'SfRunMainProc_debugvariables', 'DEBUG_VAR_DEP_002';
                'g_PerSpdRunnable_m_syncInfoPort_out', 'SYNC_INFO_DEP_003';
                'm_brakeTypeActive', 'BRAKE_TYPE_DEP_004';
                'm_hbaStateMachine', 'HBA_STATE_DEP_005';
                'm_currentState', 'CURRENT_STATE_DEP_006'
            };
            
            for i = 1:size(dep_patterns, 1)
                obj.dep_objects(dep_patterns{i, 1}) = dep_patterns{i, 2};
                obj.dep_ids{end+1} = dep_patterns{i, 2};
            end
        end
        
        function redefineActivationPlot(obj, SfRunMainProc_m_portMainProc_out, ...
                                       SfRunMainProc_debugvariables, ...
                                       g_PerSpdRunnable_m_syncInfoPort_out)
            % Redefine activation plot by logic as specified
            
            % Calculate activation flags using the specified logic
            obj.activation_flags = SfRunMainProc_m_portMainProc_out.m_brakeTypeActive | ...
                                  SfRunMainProc_debugvariables.m_stateMachines.m_hbaStateMachine.m_currentState;
            
            % Calculate cycles using interp1
            obj.cycles = interp1(g_PerSpdRunnable_m_syncInfoPort_out.time, ...
                                1:length(g_PerSpdRunnable_m_syncInfoPort_out.time), ...
                                SfRunMainProc_m_portMainProc_out.time, ...
                                'nearest', 'extrap');
            
            % Find first activation cycle
            activation_indices = find(obj.activation_flags, 1);
            if ~isempty(activation_indices)
                obj.first_activation_cycle = obj.cycles(activation_indices);
            else
                obj.first_activation_cycle = [];
            end
            
            % Identify which DEP object triggered the activation
            obj.identifyDEPActivation(SfRunMainProc_m_portMainProc_out, ...
                                     SfRunMainProc_debugvariables);
            
            % Plot the results
            obj.plotActivationData();
            
            % Update info panel
            obj.updateInfoPanel();
        end
        
        function identifyDEPActivation(obj, mainProc, debugVars)
            % Intelligence to identify which DEP object triggered activation
            obj.current_dep_activation = struct();
            
            % Check brake type activation
            if any(mainProc.m_brakeTypeActive)
                obj.current_dep_activation.brake_type = {
                    'dep_id', obj.dep_objects('m_brakeTypeActive');
                    'activation_time', mainProc.time(find(mainProc.m_brakeTypeActive, 1));
                    'activation_cycles', obj.cycles(find(mainProc.m_brakeTypeActive, 1));
                };
            end
            
            % Check HBA state machine activation
            if any(debugVars.m_stateMachines.m_hbaStateMachine.m_currentState)
                obj.current_dep_activation.hba_state = {
                    'dep_id', obj.dep_objects('m_currentState');
                    'activation_time', mainProc.time(find(debugVars.m_stateMachines.m_hbaStateMachine.m_currentState, 1));
                    'activation_cycles', obj.cycles(find(debugVars.m_stateMachines.m_hbaStateMachine.m_currentState, 1));
                };
            end
            
            % Determine primary activation trigger
            if isfield(obj.current_dep_activation, 'brake_type') && ...
               isfield(obj.current_dep_activation, 'hba_state')
                if obj.current_dep_activation.brake_type{2, 2} < obj.current_dep_activation.hba_state{2, 2}
                    obj.current_dep_activation.primary_trigger = 'brake_type';
                else
                    obj.current_dep_activation.primary_trigger = 'hba_state';
                end
            elseif isfield(obj.current_dep_activation, 'brake_type')
                obj.current_dep_activation.primary_trigger = 'brake_type';
            elseif isfield(obj.current_dep_activation, 'hba_state')
                obj.current_dep_activation.primary_trigger = 'hba_state';
            else
                obj.current_dep_activation.primary_trigger = 'none';
            end
        end
        
        function plotActivationData(obj)
            % Plot the activation data
            cla(obj.axesHandle);
            hold(obj.axesHandle, 'on');
            
            % Plot activation flags
            if ~isempty(obj.activation_flags)
                plot(obj.axesHandle, obj.cycles, double(obj.activation_flags), ...
                     'LineWidth', 2, 'Color', 'blue', 'DisplayName', 'Activation Flags');
            end
            
            % Highlight first activation cycle
            if ~isempty(obj.first_activation_cycle)
                plot(obj.axesHandle, obj.first_activation_cycle, 1, ...
                     'ro', 'MarkerSize', 10, 'LineWidth', 3, ...
                     'DisplayName', 'First Activation');
            end
            
            % Add DEP activation markers
            obj.plotDEPActivations();
            
            xlabel(obj.axesHandle, 'Cycles');
            ylabel(obj.axesHandle, 'Activation State');
            title(obj.axesHandle, 'Activation Plot Analysis');
            legend(obj.axesHandle, 'show');
            grid(obj.axesHandle, 'on');
            hold(obj.axesHandle, 'off');
        end
        
        function plotDEPActivations(obj)
            % Plot DEP activation markers
            if isfield(obj.current_dep_activation, 'brake_type')
                cycle = obj.current_dep_activation.brake_type{3, 2};
                plot(obj.axesHandle, cycle, 0.8, 'gs', 'MarkerSize', 8, ...
                     'DisplayName', 'Brake Type DEP');
            end
            
            if isfield(obj.current_dep_activation, 'hba_state')
                cycle = obj.current_dep_activation.hba_state{3, 2};
                plot(obj.axesHandle, cycle, 0.6, 'ms', 'MarkerSize', 8, ...
                     'DisplayName', 'HBA State DEP');
            end
        end
        
        function createControlPanel(obj)
            % Create control panel with DEP information
            panel = uipanel('Parent', obj.figHandle, ...
                           'Title', 'DEP Object Analysis', ...
                           'Position', [0.05, 0.02, 0.9, 0.1]);
            
            % DEP ID display
            uicontrol('Parent', panel, 'Style', 'text', ...
                     'String', 'DEP IDs:', 'FontWeight', 'bold', ...
                     'Position', [10, 50, 80, 20], ...
                     'HorizontalAlignment', 'left');
            
            obj.dep_display = uicontrol('Parent', panel, 'Style', 'text', ...
                                       'String', obj.formatDEPIds(), ...
                                       'Position', [100, 50, 400, 20], ...
                                       'HorizontalAlignment', 'left');
            
            % Activation info
            uicontrol('Parent', panel, 'Style', 'text', ...
                     'String', 'Primary Trigger:', 'FontWeight', 'bold', ...
                     'Position', [10, 25, 100, 20], ...
                     'HorizontalAlignment', 'left');
            
            obj.trigger_display = uicontrol('Parent', panel, 'Style', 'text', ...
                                           'String', 'None', ...
                                           'Position', [120, 25, 200, 20], ...
                                           'HorizontalAlignment', 'left');
            
            % First activation cycle
            uicontrol('Parent', panel, 'Style', 'text', ...
                     'String', 'First Activation Cycle:', 'FontWeight', 'bold', ...
                     'Position', [10, 5, 150, 20], ...
                     'HorizontalAlignment', 'left');
            
            obj.cycle_display = uicontrol('Parent', panel, 'Style', 'text', ...
                                         'String', 'None', ...
                                         'Position', [170, 5, 100, 20], ...
                                         'HorizontalAlignment', 'left');
        end
        
        function updateInfoPanel(obj)
            % Update the information panel with current data
            if isfield(obj, 'dep_display')
                set(obj.dep_display, 'String', obj.formatDEPIds());
            end
            
            if isfield(obj, 'trigger_display')
                if isfield(obj.current_dep_activation, 'primary_trigger')
                    trigger_text = obj.current_dep_activation.primary_trigger;
                    if strcmp(trigger_text, 'brake_type')
                        trigger_text = sprintf('%s (ID: %s)', trigger_text, ...
                                             obj.dep_objects('m_brakeTypeActive'));
                    elseif strcmp(trigger_text, 'hba_state')
                        trigger_text = sprintf('%s (ID: %s)', trigger_text, ...
                                             obj.dep_objects('m_currentState'));
                    end
                    set(obj.trigger_display, 'String', trigger_text);
                else
                    set(obj.trigger_display, 'String', 'None');
                end
            end
            
            if isfield(obj, 'cycle_display')
                if ~isempty(obj.first_activation_cycle)
                    set(obj.cycle_display, 'String', num2str(obj.first_activation_cycle));
                else
                    set(obj.cycle_display, 'String', 'None');
                end
            end
        end
        
        function str = formatDEPIds(obj)
            % Format DEP IDs for display
            str = strjoin(obj.dep_ids, ', ');
        end
        
        % Window control methods
        function minimizeWindow(obj)
            set(obj.figHandle, 'WindowState', 'minimized');
        end
        
        function maximizeWindow(obj)
            if strcmp(get(obj.figHandle, 'WindowState'), 'maximized')
                set(obj.figHandle, 'WindowState', 'normal');
            else
                set(obj.figHandle, 'WindowState', 'maximized');
            end
        end
        
        function closeWindow(obj)
            delete(obj.figHandle);
        end
        
        % Plot control methods
        function enableZoom(obj)
            pan(obj.figHandle, 'off');
            zoom(obj.figHandle, 'on');
        end
        
        function disableZoom(obj)
            zoom(obj.figHandle, 'off');
        end
        
        function enablePan(obj)
            zoom(obj.figHandle, 'off');
            pan(obj.figHandle, 'on');
        end
        
        function disablePan(obj)
            pan(obj.figHandle, 'off');
        end
        
        function resetView(obj)
            zoom(obj.figHandle, 'out');
            zoom(obj.figHandle, 'reset');
            pan(obj.figHandle, 'off');
        end
        
        function updatePlotInfo(obj)
            % Update plot information after zoom/pan
            % This can be extended to show current view information
        end
        
        % Icon creation methods
        function icon = createMinimizeIcon(obj)
            icon = zeros(16, 16, 3);
            icon(12:14, 4:12, :) = 1;
        end
        
        function icon = createMaximizeIcon(obj)
            icon = zeros(16, 16, 3);
            icon(3:5, 4:12, :) = 1;
            icon(6:13, 4:6, :) = 1;
            icon(6:13, 10:12, :) = 1;
            icon(11:13, 4:12, :) = 1;
        end
        
        function icon = createCloseIcon(obj)
            icon = zeros(16, 16, 3);
            for i = 1:3
                icon(4:12, 4:12, i) = eye(9) + flipud(eye(9));
            end
            icon(icon > 0) = 1;
        end
        
        function icon = createZoomIcon(obj)
            icon = zeros(16, 16, 3);
            % Create magnifying glass
            [x, y] = meshgrid(1:16, 1:16);
            center = [8, 8];
            mask = ((x - center(1)).^2 + (y - center(2)).^2) <= 25 & ...
                   ((x - center(1)).^2 + (y - center(2)).^2) >= 16;
            icon(mask) = 1;
            % Add handle
            icon(12:15, 12:15, :) = 1;
        end
        
        function icon = createPanIcon(obj)
            icon = zeros(16, 16, 3);
            % Create hand icon
            icon(6:10, 6:10, :) = 1;
            icon(4:8, 8:10, :) = 1;
            icon(8:12, 4:6, :) = 1;
        end
        
        function icon = createResetIcon(obj)
            icon = zeros(16, 16, 3);
            % Create reset/home icon
            icon(3:13, 7:9, :) = 1;
            icon(7:11, 3:13, :) = 1;
        end
    end
end