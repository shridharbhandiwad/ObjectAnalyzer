# Activation Plot Analyzer Documentation

## Overview

The Activation Plot Analyzer is a comprehensive MATLAB tool for analyzing activation patterns in automotive control systems. It implements the specific logic requested for activation plot analysis with advanced windowing features, DEP object intelligence, and interactive plot controls.

## Key Features

### 1. Activation Plot Logic
The analyzer implements the exact logic specified:
```matlab
activation_flags = SfRunMainProc_m_portMainProc_out.m_brakeTypeActive | 
                  SfRunMainProc_debugvariables.m_stateMachines.m_hbaStateMachine.m_currentState;

cycles = interp1(g_PerSpdRunnable_m_syncInfoPort_out.time, 
                 1:length(g_PerSpdRunnable_m_syncInfoPort_out.time), 
                 SfRunMainProc_m_portMainProc_out.time, 'nearest', 'extrap');

first_activation_cycle = cycles(find(activation_flags, 1));
```

### 2. Automatic Instance Management
- Automatically removes existing instances when the file is loaded
- Prevents multiple windows from cluttering the workspace
- Cleans up base workspace variables

### 3. DEP Object Intelligence
- Identifies which DEP object triggers the activation
- Provides specific DEP IDs for each component:
  - `MAIN_PROC_DEP_001` - SfRunMainProc_m_portMainProc_out
  - `DEBUG_VAR_DEP_002` - SfRunMainProc_debugvariables
  - `SYNC_INFO_DEP_003` - g_PerSpdRunnable_m_syncInfoPort_out
  - `BRAKE_TYPE_DEP_004` - m_brakeTypeActive
  - `HBA_STATE_DEP_005` - m_hbaStateMachine
  - `CURRENT_STATE_DEP_006` - m_currentState

### 4. Window Controls
- **Minimize Button**: Minimizes the window to taskbar
- **Maximize Button**: Toggles between maximized and normal window states
- **Close Button**: Properly closes the window and cleans up resources

### 5. Interactive Plot Controls
- **Zoom Tool**: Click and drag to zoom in/out on specific regions
- **Pan Tool**: Click and drag to pan around the plot
- **Reset View**: Returns to the original view after zooming/panning

## Quick Start

### Method 1: Using the Quick Start Script
```matlab
run('quickStart.m')
```

### Method 2: Using the Function Directly
```matlab
% With demo data
analyzer = runActivationAnalysis();

% With your own data
analyzer = runActivationAnalysis(mainProc, debugVars, syncInfo);
```

### Method 3: Creating the Analyzer Directly
```matlab
analyzer = ActivationPlotAnalyzer();
analyzer.redefineActivationPlot(mainProc, debugVars, syncInfo);
```

## Data Structure Requirements

### SfRunMainProc_m_portMainProc_out
Required fields:
- `time`: Time vector (numeric array)
- `m_brakeTypeActive`: Brake type activation flags (logical/numeric array)

### SfRunMainProc_debugvariables
Required structure:
```matlab
debugVars.m_stateMachines.m_hbaStateMachine.m_currentState
```

### g_PerSpdRunnable_m_syncInfoPort_out
Required fields:
- `time`: Time vector for synchronization (numeric array)

## Usage Examples

### Example 1: Basic Usage with Demo Data
```matlab
% Launch with automatically generated demo data
analyzer = runActivationAnalysis();
```

### Example 2: Using Real Data
```matlab
% Load your data
load('your_data.mat');

% Create analyzer with your data
analyzer = runActivationAnalysis(SfRunMainProc_m_portMainProc_out, ...
                                SfRunMainProc_debugvariables, ...
                                g_PerSpdRunnable_m_syncInfoPort_out);
```

### Example 3: Advanced Usage
```matlab
% Create analyzer
analyzer = ActivationPlotAnalyzer();

% Process data
analyzer.redefineActivationPlot(mainProc, debugVars, syncInfo);

% Access analysis results
fprintf('First activation cycle: %d\n', analyzer.first_activation_cycle);
fprintf('Primary trigger: %s\n', analyzer.current_dep_activation.primary_trigger);

% Show all DEP IDs
disp(analyzer.dep_ids);
```

## Analysis Output

The analyzer provides comprehensive information about:

1. **Activation Flags**: Combined logical OR of brake type and HBA state activations
2. **Cycles**: Interpolated cycle numbers corresponding to activation times
3. **First Activation Cycle**: The cycle number where the first activation occurs
4. **DEP Object Analysis**: Which specific DEP object triggered the activation
5. **Primary Trigger**: The dominant activation source (brake_type or hba_state)

## Interactive Features

### Toolbar Controls
- **Window Controls**: Minimize, maximize, close buttons in the toolbar
- **Plot Tools**: Zoom, pan, and reset view tools
- **Visual Feedback**: Tool tips and visual indicators for all controls

### Plot Features
- **Activation Visualization**: Blue line showing activation flags over cycles
- **First Activation Marker**: Red circle highlighting the first activation point
- **DEP Activation Markers**: 
  - Green squares for brake type DEP activations
  - Magenta squares for HBA state DEP activations
- **Legend**: Automatic legend showing all plot elements
- **Grid**: Grid lines for better readability

### Information Panel
- **DEP IDs**: Lists all identified DEP object IDs
- **Primary Trigger**: Shows which DEP object was the primary activation trigger
- **First Activation Cycle**: Displays the cycle number of first activation

## Technical Details

### Class Structure
- **ActivationPlotAnalyzer**: Main class inheriting from `handle`
- **Properties**: Stores all analysis data and UI handles
- **Methods**: Organized into logical groups (plotting, window control, DEP analysis)

### Memory Management
- Automatic cleanup of existing instances
- Proper handle management for UI components
- Efficient data storage and processing

### Error Handling
- Robust input validation
- Graceful handling of missing data
- Informative error messages

## Troubleshooting

### Common Issues

1. **No activation detected**: Check if your data contains actual activation signals
2. **Time synchronization issues**: Ensure time vectors are properly aligned
3. **Missing data fields**: Verify that all required data structure fields are present

### Debug Information
The analyzer provides detailed console output including:
- Data loading status
- DEP object identification results
- Activation analysis results
- Warning messages for potential issues

## Extension and Customization

### Adding New DEP Objects
To add new DEP object patterns:
```matlab
% In setupDEPPatterns method
dep_patterns = {
    'your_new_object', 'YOUR_NEW_DEP_ID';
    % ... existing patterns
};
```

### Custom Activation Logic
To modify the activation logic:
```matlab
% In redefineActivationPlot method
obj.activation_flags = your_custom_logic;
```

### Additional Plot Types
The framework supports extension for additional plot types and analysis methods.

## Files Overview

- `ActivationPlotAnalyzer.m`: Main analyzer class
- `runActivationAnalysis.m`: Helper function for easy launching
- `quickStart.m`: Quick start demonstration script
- `ActivationPlotAnalyzer_Documentation.md`: This documentation file

## Version Information

- Version: 1.0
- Compatible with: MATLAB R2018b and later
- Dependencies: None (uses built-in MATLAB functions only)

## Support

For questions or issues:
1. Check the console output for diagnostic information
2. Verify your data structure matches the requirements
3. Try the demo data first to ensure the system works correctly
4. Review the troubleshooting section above