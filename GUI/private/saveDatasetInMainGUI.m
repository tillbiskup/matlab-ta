function [status,message] = saveDatasetInMainGUI(id,varargin)
% SAVEDATASETINMAINGUI Save dataset in main GUI.
%
% Usage:
%   status = saveDatasetInMainGUI(id);
%
% Status:  0 - everything fine
%         -1 - no main GUI window found
%
% Message - string
%           In case of status <> 0 contains message telling user what went
%           wrong.

% Copyright (c) 2011-13, Till Biskup
% 2013-11-15

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('id', @(x)isnumeric(x));
p.parse(id,varargin{:});

try
    % First, find main GUI window
    mainWindow = TAguiGetWindowHandle();
        
    % Preset message
    message = '';
    
    % Set file extension
    zipext = '.taz';

    % If there is no main GUI window, silently return
    if isempty(mainWindow)
        status = -1;
        message = 'No main GUI window found';
        return;
    end
    
    % Get appdata of main window
    ad = getappdata(mainWindow);
    
    % Check whether selected dataset has a (valid) filename
    if ~isfield(ad.data{id}.file,'name') || ...
            (strcmp(ad.data{id}.file.name,''))
        status = saveAsDatasetInMainGUI(id);
        return;
    else
        [fpath,fname,fext] = fileparts(ad.data{id}.file.name);
        if ~strcmp(fext,zipext)
            ad.data{id}.file.name = fullfile(fpath,[fname zipext]);
            % Need to test for existing file and in case, ask user...
            if (exist(ad.data{id}.file.name,'file'))
                answer = questdlg(...
                    {'WARNING: You''re about to save the current dataset to the file'...
                    ad.data{id}.file.name ...
                    ' '...
                    'This file exists already! Are you sure you want to overwrite it?'...
                    ' '...
                    'Please hold on and think twice before you hit "Overwrite".'...
                    'Alternatively you can press "Save as" and choose a different name.'},...
                    'Warning: File exists already...',...
                    'Overwrite','Save as','Cancel',...
                    'Cancel');
                switch answer
                    case 'Overwrite'
                    case 'Save as'
                        status = saveAsDatasetInMainGUI(id);
                        return;
                    case 'Cancel'
                        return;
                    otherwise
                        return;
                end
            end
        end
    end
    
    for k = 1:length(ad.data)
        if (strcmp(ad.data{k}.file.name,ad.data{id}.file.name)) && (k ~= id)
            answer = questdlg(...
                {'WARNING: You''re about to save the current dataset to the file'...
                ad.data{id}.file.name ...
                ' '...
                'A dataset loaded from a file with that name has been loaded to the GUI!'...
                ' '...
                'Please use "Save as" and choose a different name or press "Cancel".'},...
                'Warning: Dataset with same filename loaded to GUI...',...
                'Save as','Cancel',...
                'Cancel');
            switch answer
                case 'Save as'
                    status = saveAsDatasetInMainGUI(id);
                    return;
                case 'Cancel'
                    return;
                otherwise
                    return;
            end
        end
    end
    
    TAbusyWindow('start','Trying to save spectra...<br />please wait.');
    
    % Do the actual saving
    [ saveStatus, exception ] = ...
        TAsave(ad.data{id}.file.name,ad.data{id});
    
    % In case something went wrong
    if ~isempty(saveStatus)
        % Adding status line
        msgStr = cell(0);
        msgStr{end+1} = ...
            sprintf('Problems when trying to save "%s" to file',...
            ad.data{id}.label);
        msgStr{end+1} = ad.data{id}.file.name;
        msgStr = [ msgStr saveStatus ];
        status = TAmsg(msgStr,'error');
        TAbusyWindow('stop','Trying to save spectra...<br /><b>failed</b>.');
        %warndlg(msgStr,'Problems saving file','modal');
        clear msgStr;
        status = -1;
        return;
    else
        % Get second output parameter from TAsave, i.e. filename
        % (See help of TAsave for details)
        filename = exception;
    end
    
    % Remove from modified
    ad.control.spectra.modified(ad.control.spectra.modified == id) = [];
    
    % Set last save dir
    ad.control.dirs.lastSave = fpath;
    
    % Write appdata
    setappdata(mainWindow,'data',ad.data);
    setappdata(mainWindow,'origdata',ad.data);
    setappdata(mainWindow,'control',ad.control);
    
    % Adding status line
    msg = {...
        sprintf('Dataset %i successfully saved',id)...
        sprintf('Label: %s',ad.data{id}.label)...
        sprintf('File: %s',filename)...
        };
    status = TAmsg(msg,'info');
    
    % Update main GUI's axes and panels
    update_visibleSpectra();
    update_datasetPanel();
    update_processingPanel();
    update_mainAxis();
    
    %msgbox(msg,'Successful saving of file','help'); 
    TAbusyWindow('stop','Trying to save spectra...<br /><b>done</b>.');
    TAbusyWindow('deletedelayed');
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
