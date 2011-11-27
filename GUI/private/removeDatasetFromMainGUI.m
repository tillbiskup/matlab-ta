function [status,message] = removeDatasetFromMainGUI(dataset,varargin)
% REMOVEDATASETFROMMAINGUI Remove dataset(s) from main GUI.
%
% Usage:
%   status = removeDatasetFromMainGUI(dataset);
%   [status,message] = removeDatasetFromMainGUI(dataset);
%
% Status:  0 - everything fine
%         -1 - no main GUI window found
%
% Message - string
%           In case of status <> 0 contains message telling user what went
%           wrong.

% (c) 2011, Till Biskup
% 2011-11-27

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('dataset', @(x)isnumeric(x));
p.addParamValue('force',false,@islogical);
p.parse(dataset,varargin{:});

try
    % First, find main GUI window
    mainWindow = guiGetWindowHandle();
    
    % Preset message
    message = '';
    
    % If there is no main GUI window, silently return
    if isempty(mainWindow)
        status = -1;
        message = 'No main GUI window found';
        return;
    end
    
    % Get appdata of main window
    ad = getappdata(mainWindow);

    % Cell array for labels of removed datasets
    removedDatasetsLabels = cell(0);
    
    % Remove dataset(s) from main GUI
    for k=length(dataset):-1:1
        if ~p.Results.force
            if ~any(ad.control.spectra.modified==dataset)
                removedDatasetsLabels{end+1} = ad.data{dataset(k)}.label;
                ad.data(dataset(k)) = [];
                ad.origdata(dataset(k)) = [];
                ad.control.spectra.visible(...
                    ad.control.spectra.visible==dataset(k)) = [];
                ad.control.spectra.invisible(...
                    ad.control.spectra.invisible==dataset(k)) = [];
                ad.control.spectra.modified(...
                    ad.control.spectra.modified==dataset(k)) = [];
                ad.control.spectra.visible(...
                    ad.control.spectra.visible>dataset(k)) = ...
                    ad.control.spectra.visible(...
                    ad.control.spectra.visible>dataset(k)) -1;
                ad.control.spectra.invisible(...
                    ad.control.spectra.invisible>dataset(k)) = ...
                    ad.control.spectra.invisible(...
                    ad.control.spectra.invisible>dataset(k)) -1;
                ad.control.spectra.modified(...
                    ad.control.spectra.modified>dataset(k)) = ...
                    ad.control.spectra.modified(...
                    ad.control.spectra.modified>dataset(k)) -1;
                if ad.control.spectra.active >= dataset(k)
                    ad.control.spectra.active = ad.control.spectra.active-1;
                end
            else
                remove = false;
                answer = questdlg(...
                    {'Dataset was modified. Remove anyway?'...
                    ' '...
                    'Note that "Remove" means that you loose the changes you made,'...
                    'but the (original) file will not be deleted from the file system.'...
                    ' '...
                    'Other options include "Save & Remove" or "Cancel".'},...
                    'Warning: Dataset Modified...',...
                    'Save & Remove','Remove','Cancel',...
                    'Save & Remove');
                switch answer
                    case 'Save & Remove'
                        status = saveDatasetInMainGUI(dataset);
                        if status
                            % That means that something went wrong with the saveAs
                            return;
                        end
                        remove = true;
                    case 'Remove'
                        remove = true;
                    case 'Cancel'
                end
                if remove
                    removedDatasetsLabels{end+1} = ad.data{dataset(k)}.label;
                    ad.data(dataset(k)) = [];
                    ad.origdata(dataset(k)) = [];
                    ad.control.spectra.visible(...
                        ad.control.spectra.visible==dataset(k)) = [];
                    ad.control.spectra.invisible(...
                        ad.control.spectra.invisible==dataset(k)) = [];
                    ad.control.spectra.modified(...
                        ad.control.spectra.modified==dataset(k)) = [];
                    ad.control.spectra.visible(...
                        ad.control.spectra.visible>dataset(k)) = ...
                        ad.control.spectra.visible(...
                        ad.control.spectra.visible>dataset(k)) -1;
                    ad.control.spectra.invisible(...
                        ad.control.spectra.invisible>dataset(k)) = ...
                        ad.control.spectra.invisible(...
                        ad.control.spectra.invisible>dataset(k)) -1;
                    ad.control.spectra.modified(...
                        ad.control.spectra.modified>dataset(k)) = ...
                        ad.control.spectra.modified(...
                        ad.control.spectra.modified>dataset(k)) -1;
                    if ad.control.spectra.active >= dataset(k)
                        ad.control.spectra.active = ad.control.spectra.active-1;
                    end
                end
            end
        else
            removedDatasetsLabels{end+1} = ad.data{dataset(k)}.label;
            ad.data(dataset(k)) = [];
            ad.origdata(dataset(k)) = [];
            ad.control.spectra.visible(...
                ad.control.spectra.visible==dataset(k)) = [];
            ad.control.spectra.invisible(...
                ad.control.spectra.invisible==dataset(k)) = [];
            ad.control.spectra.modified(...
                ad.control.spectra.modified==dataset(k)) = [];
            ad.control.spectra.visible(...
                ad.control.spectra.visible>dataset(k)) = ...
                ad.control.spectra.visible(...
                ad.control.spectra.visible>dataset(k)) -1;
            ad.control.spectra.invisible(...
                ad.control.spectra.invisible>dataset(k)) = ...
                ad.control.spectra.invisible(...
                ad.control.spectra.invisible>dataset(k)) -1;
            ad.control.spectra.modified(...
                ad.control.spectra.modified>dataset(k)) = ...
                ad.control.spectra.modified(...
                ad.control.spectra.modified>dataset(k)) -1;
            if ad.control.spectra.active >= dataset(k)
                ad.control.spectra.active = ad.control.spectra.active-1;
            end
        end
    end
    
    % Write appdata
    setappdata(mainWindow,'data',ad.data);
    setappdata(mainWindow,'origdata',ad.data);
    setappdata(mainWindow,'control',ad.control);
    
    % Adding status line
    msg = cell(0);
    msg{end+1} = sprintf('Datasets successfully removed from main GUI');
    for k=1:length(removedDatasetsLabels)
        msg{end+1} = sprintf('  Label: %s',removedDatasetsLabels{k});
    end
    status = add2status(msg);
    invStr = sprintf('%i ',ad.control.spectra.invisible);
    visStr = sprintf('%i ',ad.control.spectra.visible);
    msgStr = sprintf(...
        'Currently invisible: [ %s]; currently visible: [ %s]; total: %i',...
        invStr,visStr,length(ad.data));
    add2status(msgStr);
    clear msgStr;
    
    % Update main GUI's axes and panels
    update_invisibleSpectra();
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