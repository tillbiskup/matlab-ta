function status = appendDatasetToMainGUI(dataset,varargin)
% APPENDDATASETTOMAINGUI Append dataset to main GUI.
%
% Usage:
%   status = appendDatasetToMainGUI(dataset);
%
% Status:  0 - everything fine
%         -1 - no main GUI window found

% (c) 2011, Till Biskup
% 2011-07-04

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('dataset', @(x)isstruct(x) || iscell(x));
p.addParamValue('modified',false,@islogical);
p.parse(dataset,varargin{:});

try
    % First, find main GUI window
    mainWindow = guiGetWindowHandle('trEPRgui');
    
    % If there is no main GUI window, silently return
    if isempty(mainWindow)
        status = -1;
        return;
    end
    
    % Sanitise dataset a bit - check for some of the necessary fields in
    % structure we need not to crash the GUI immediately
    if ~isfield(dataset,'label')
        dataset.label = 'New dataset';
    end
    if ~isfield(dataset,'display')
        dataset.display.position.x = 1;
        dataset.display.position.y = 1;
        dataset.display.displacement.x = 0;
        dataset.display.displacement.y = 0;
        dataset.display.displacement.z = 0;
        dataset.display.scaling.x = 1;
        dataset.display.scaling.y = 1;
        dataset.display.scaling.z = 1;
        dataset.display.smoothing.x.value = 1;
        dataset.display.smoothing.y.value = 1;
    end
    if ~isfield(dataset,'line')
        dataset.line.color = 'k';
        dataset.line.style = '-';
        dataset.line.marker = 'none';
        dataset.line.width = 1;
    end
    
    % Get appdata of main window
    ad = getappdata(mainWindow);
    
    % Append dataset to data cell array of main GUI
    ad.data{end+1} = dataset;
    ad.origdata{end+1} = dataset;
    
    % Get ID of newly appended dataset
    newId = length(ad.data);
    
    % Make new dataset immediately visible
    ad.control.spectra.visible(end+1) = newId;
    
    % Handle whether it should go to modified as well
    if (p.Results.modified)
        ad.control.spectra.modified(end+1) = newId;
    end
    
    % In case there is currently no active spectrum, make the newly
    % appended one the active one
    if ~(ad.control.spectra.active)
        ad.control.spectra.active = newId;
    end
    
    % Write appdata
    setappdata(mainWindow,'data',ad.data);
    setappdata(mainWindow,'origdata',ad.data);
    setappdata(mainWindow,'control',ad.control);
    
    % Adding status line
    msg = {...
        sprintf('Dataset %i successfully appended to main GUI',newId)...
        sprintf('Label: %s',dataset.label)...
        };
    status = add2status(msg);
    
    % Update main GUI's axes and panels
    update_visibleSpectra();
    update_datasetPanel();
    update_processingPanel();
    update_mainAxis();
    
    status = 0;
    
catch exception
    try
        msgStr = ['An exception occurred. '...
            'The bug reporter should have been opened'];
        add2status(msgStr);
    catch exception2
        exception = addCause(exception2, exception);
        disp(msgStr);
    end
    try
        trEPRgui_bugreportwindow(exception);
    catch exception3
        % If even displaying the bug report window fails...
        exception = addCause(exception3, exception);
        throw(exception);
    end
end

end