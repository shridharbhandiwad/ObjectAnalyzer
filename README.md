# MAT File Dashboard

A comprehensive MATLAB dashboard for loading, analyzing, and visualizing .mat files with specialized functionality for activation flag analysis.

## Features

### 🔍 File Loading
- **Browse**: Use the "Browse MAT File" button to select .mat files from your system
- **Drag & Drop**: Simply drag and drop .mat files directly onto the dashboard window
- **Variable Display**: View all loaded variables in the data information panel

### 📊 Activation Analysis
- **Show Activation**: Generate plots showing activation flags over cycles
- **Formula**: `activation_flags = SfRunMainProc_m_portMainProc_out.m_brakeTypeActive | SfRunMainProc_debugvariables.m_stateMachines.m_hbaStateMachine.m_currentState`
- **Multi-line Plot**: Displays combined activation, brake type active, and current state signals
- **Intelligent Variable Detection**: Automatically searches for similar variables if exact names aren't found

### 🧹 Data Cleaning
- **Remove 2_ Variables**: Automatically removes all variables containing "2_" in their names
- **Clear All Data**: Reset the dashboard and clear all loaded data
- **Real-time Updates**: Variable list updates automatically after operations

### 📈 Visualization
- **Interactive Plots**: Zoom, pan, and explore activation data
- **Legend Support**: Clear identification of different signal components
- **Grid Lines**: Enhanced readability with grid overlay
- **Multi-signal Display**: Shows individual components and combined result

### 📝 Logging
- **Status Panel**: Real-time logging of all operations
- **Timestamps**: Every log entry includes precise timing
- **Error Handling**: Comprehensive error reporting and troubleshooting
- **Auto-scroll**: Automatic scrolling to latest log entries

## How to Use

### Starting the Dashboard
```matlab
% Run the dashboard
MatFileDashboard();
```

### Loading Data
1. **Method 1 - Browse**: Click "Browse MAT File" and select your .mat file
2. **Method 2 - Drag & Drop**: Drag your .mat file directly onto the dashboard window

### Analyzing Activation
1. Load your .mat file first
2. Click "Show Activation" to generate the activation plot
3. The dashboard will automatically:
   - Search for the required variables
   - Combine them using bitwise OR operation
   - Display the result with individual components

### Cleaning Data
1. Click "Remove 2_ Variables" to eliminate duplicate/secondary variables
2. Use "Clear All Data" to reset the dashboard completely

## Expected Data Structure

The dashboard looks for these specific variables in your .mat file:

```matlab
% Primary variables
SfRunMainProc_m_portMainProc_out.m_brakeTypeActive
SfRunMainProc_debugvariables.m_stateMachines.m_hbaStateMachine.m_currentState

% Fallback: variables containing these keywords
- 'brake' (case-insensitive)
- 'state' (case-insensitive)
```

## Dashboard Layout

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                               MAT File Dashboard                                │
├─────────────────────┬───────────────────────────────────────────────────────────┤
│   Control Panel     │                                                           │
│ ┌─────────────────┐ │                   Activation Plot                         │
│ │ Browse MAT File │ │                                                           │
│ │ Show Activation │ │                                                           │
│ │ Remove 2_ Vars  │ │                                                           │
│ │ Clear All Data  │ │                                                           │
│ └─────────────────┘ │                                                           │
├─────────────────────┤                                                           │
│  Data Information   │                                                           │
│ ┌─────────────────┐ │                                                           │
│ │ Loaded Variables│ │                                                           │
│ │ - Variable 1    │ │                                                           │
│ │ - Variable 2    │ │                                                           │
│ │ - ...           │ │                                                           │
│ └─────────────────┘ │                                                           │
│ File Status: Ready  │                                                           │
├─────────────────────┴───────────────────────────────────────────────────────────┤
│                                Status Panel                                     │
│ [10:30:15] Dashboard initialized. Please browse or drag & drop a .mat file.    │
│ [10:30:45] Loading file: example.mat                                           │
│ [10:30:46] Successfully loaded 25 variables.                                  │
│ [10:31:02] Found m_brakeTypeActive variable                                    │
│ [10:31:02] Found m_currentState variable                                       │
│ [10:31:03] Plotted activation flags for 1000 cycles                           │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Technical Details

### Activation Flag Calculation
The activation flags are calculated using the bitwise OR operation:
```matlab
activation_flags = brakeTypeActive | currentState
```

### Variable Removal Algorithm
```matlab
% Equivalent to the requested functionality
variables = fieldnames(currentData);
for i = 1:length(variables)
    if contains(variables{i}, '2_')
        currentData = rmfield(currentData, variables{i});
    end
end
```

### Error Handling
- Robust error handling for missing variables
- Automatic fallback to similar variable names
- Comprehensive logging of all operations
- Graceful handling of incompatible data types

## Compatibility

- **MATLAB Version**: R2016b or later (recommended R2018a+)
- **Toolboxes**: No additional toolboxes required
- **Platform**: Windows, macOS, Linux

## Troubleshooting

### Common Issues

1. **Drag & Drop Not Working**
   - Some MATLAB versions have limited drag & drop support
   - Use the "Browse MAT File" button instead

2. **Variables Not Found**
   - Check the status panel for available variables
   - The dashboard will attempt to find similar variables automatically

3. **Plot Not Displaying**
   - Ensure your variables contain numeric data
   - Check that variables have compatible dimensions

4. **Performance Issues**
   - Large .mat files may take time to load
   - Consider using smaller data sets for testing

### Getting Help

Check the status panel for detailed error messages and troubleshooting information. The dashboard provides comprehensive logging to help diagnose issues.

## Example Usage

```matlab
% Start the dashboard
MatFileDashboard();

% The dashboard will open with a GUI
% 1. Load your .mat file using browse or drag & drop
% 2. Click "Show Activation" to visualize the data
% 3. Use "Remove 2_ Variables" to clean up duplicates
% 4. Monitor the status panel for real-time feedback
```

## License

This dashboard is provided as-is for educational and research purposes.