function status = refreshDatasetInMainGUI(dataset,id,varargin)
% REFRESHDATASETINMAINGUI Refresh dataset in main GUI.
%
% Usage:
%   status = refreshDatasetInMainGUI(dataset,id);
%
% Status:  0 - everything fine
%         -1 - no main GUI window found

% (c) 2011, Till Biskup
% 2011-11-03

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('dataset', @(x)isstruct(x) || iscell(x));
p.addParamValue('modified',false,@islogical);
p.addParamValue('label','',@ischar);
p.parse(dataset,varargin{:});

try
    % First, find main GUI window
    mainWindow = guiGetWindowHandle('trEPRgui');
    
    % If there is no main GUI window, silently return
    if isempty(mainWindow)
        status = -1;
        return;
    end
    
    % Get appdata of main window
    ad = getappdata(mainWindow);
    
    % TODO: Check whether Id exists in main GUI, otherwise append
    % Get labels from all datasets of the main GUI
    labels = cell(length(ad.data),1);
    for k=1:length(ad.data)
        labels{k} = ad.data{k}.label;
    end
    if ~isempty(p.Results.label)
        label = p.Results.label;
    else
        label = dataset.label;
    end
    % Check for identity of labels, otherwise try to find dataset with
    % identical label
    if id > length(ad.data) || ~strcmp(label,ad.data{id}.label)
        matches = find(strcmp(label,labels));
        if length(matches) == 1
            % In this case, the id has changed, but can unequivocally be
            % assigned
            id = matches;
        elseif length(matches) > 1
            % In this case, there is more than one dataset in the main GUI
            % with identical label. Additionally, the Ids have changed so
            % that we cannot any more unequivocally assign the dataset.
            % Therefore, the first match is used and the user informed.
            id = matches(1);
            % Adding status line
            msgStr = {...
                'No unequivocal assignment of dataset possible.'...
                sprintf(...
                'Therefore, the first matching dataset has been used: %i',...
                id)...
                };
            status = add2status(msgStr);
            % Get appdata of main window
            ad = getappdata(mainWindow);
        else
            % In this case, the original Id has changed and there is no
            % longer any dataset with an identical label to that from the
            % given dataset. Whereas we cannot exclude that the user in
            % between changed things greatly in the main GUI, such as
            % moving the Ids and at the same time changing labels, meaning
            % that the corresponding dataset in the main GUI now has both a
            % different label and a different id, we savely append it to
            % the main GUI.
            appendDatasetToMainGUI(dataset,'modified',p.Results.modified);
            status = 0;
            return;
        end
    end
    
    % Refresh dataset in main GUI
    ad.data{id} = dataset;
    
    % Handle whether it should go to modified as well
    if (p.Results.modified) && isempty(find(ad.control.spectra.modified==id,1))
        ad.control.spectra.modified(end+1) = id;
    end
    
    % Write appdata
    setappdata(mainWindow,'data',ad.data);
    setappdata(mainWindow,'origdata',ad.data);
    setappdata(mainWindow,'control',ad.control);
    
    % Adding status line
    msg = {...
        sprintf('Dataset %i successfully refreshed in main GUI',id)...
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