function status = TAappendDatasetToMainGUI(dataset,varargin)
% TAAPPENDDATASETTOMAINGUI Append dataset to main GUI.
%
% Usage:
%   status = TAappendDatasetToMainGUI(dataset);
%
% Status:  0 - everything fine
%         -1 - no main GUI window found

% (c) 2011-14, Till Biskup
% 2014-05-09

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
    mainWindow = TAguiGetWindowHandle();
    
    % If there is no main GUI window, silently return
    if isempty(mainWindow)
        status = -1;
        return;
    end
    
    % Get datastructure
    dataStructure = TAguiDataStructure('datastructure');
    
    % Copy dataStructure into dataset
    dataset = structcopy(dataStructure,dataset);
    
    % Sanitise dataset a bit - check for some of the necessary fields in
    % structure we need not to crash the GUI immediately
    if ~isfield(dataset,'label')
        dataset.label = 'New dataset';
    end
    if ~isfield(dataset,'display')
        dataset.display = dataStructure.display;
    end
    if ~isfield(dataset,'line')
        dataset.display = dataStructure.line;
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
    status = TAmsg(msg,'info');
    
    % Update main GUI's axes and panels
    update_visibleSpectra();
    update_datasetPanel();
    update_processingPanel();
    update_mainAxis();
    
    status = 0;
    
catch exception
    try
        msgStr = ['An exception occurred in ' ...
            exception.stack(1).name  '.'];
        TAmsg(msgStr,'error');
    catch exception2
        exception = addCause(exception2, exception);
        disp(msgStr);
    end
    try
        TAgui_bugreportwindow(exception);
    catch exception3
        % If even displaying the bug report window fails...
        exception = addCause(exception3, exception);
        throw(exception);
    end
end

end