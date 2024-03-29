function [status,message] = TAremoveDatasetFromMainGUI(dataset,varargin)
% TAREMOVEDATASETFROMMAINGUI Remove dataset(s) from main GUI.
%
% Usage:
%   status = TAremoveDatasetFromMainGUI(dataset);
%   [status,message] = TAremoveDatasetFromMainGUI(dataset);
%
% Status:  0 - everything fine
%         -1 - no main GUI window found
%
% Message - string
%           In case of status <> 0 contains message telling user what went
%           wrong.

% Copyright (c) 2011-13, Till Biskup
% 2013-07-15

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
    mainWindow = TAguiGetWindowHandle();
    
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
    
    % Get position of currently active dataset in visible listbox
    gh = guihandles(mainWindow); % Get handles of main window
    activePosition = get(gh.data_panel_visible_listbox,'Value');
    
    % Sort datasets
    dataset = sort(dataset);
    
    % Remove dataset(s) from main GUI
    for k=length(dataset):-1:1
        if ~p.Results.force
            if ~any(ad.control.spectra.modified==dataset(k))
                removedDatasetsLabels{end+1} = ad.data{dataset(k)}.label; %#ok<*AGROW>
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
        end
    end
    
    % Set currently active spectrum to new (valid) value
    if isempty(ad.control.spectra.visible)
        ad.control.spectra.active = 0;
    elseif activePosition > length(ad.control.spectra.visible)
        ad.control.spectra.active = ...
            ad.control.spectra.visible(end);
    else
        ad.control.spectra.active = ...
            ad.control.spectra.visible(activePosition);
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
    status = TAmsg(msg,'info');
    invStr = sprintf('%i ',ad.control.spectra.invisible);
    visStr = sprintf('%i ',ad.control.spectra.visible);
    msgStr = sprintf(...
        'Currently invisible: [ %s]; currently visible: [ %s]; total: %i',...
        invStr,visStr,length(ad.data));
    TAmsg(msgStr,'debug');
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
