function [status,message] = saveAsDatasetInMainGUI(id,varargin)
% SAVEASDATASETINMAINGUI Save dataset in main GUI under different name.
%
% Usage:
%   status = saveAsDatasetInMainGUI(id);
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

p.addRequired('id', @(x)isnumeric(x));
p.parse(id,varargin{:});

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
    
    % Create default filename
    [fpath,fname,fext] = fileparts(ad.data{id}.file.name);
    if ~strcmp(fext,'.zip')
        ad.data{id}.file.name = fullfile(fpath,[fname '.zip']);
    end
    % Need to test for existing file and in case, change default name
    if (exist(ad.data{id}.file.name,'file'))
        % 1. Check whether name ends with -NNN (where NNN are numbers)
        % 2. existingFiles = dir(sprintf('%s*',filename));
        % 2a. If name ends with -NNN, remove "-NNN" from filename before
        % 3. regexp existingFiles for "-NNN" pattern
        % 4. Get highest "-NNN" pattern and increment "NNN"
        % 5. Use filename with incremented "NNN" as new default filename
        if (regexp(fname,'_\d+$'))
            filesInDir = ...
                dir(sprintf('%s*',fullfile(fpath,regexprep(fname,'_\d+$',''))));
        else
            filesInDir = dir(sprintf('%s*',fullfile(fpath,fname)));
        end
        l=0;
        numbers = [];
        for k=1:length(filesInDir)
            token = regexp(filesInDir(k).name,'_(\d+)\..*$','tokens');
            if ~isempty(token)
                l=l+1;
                numbers(l) = str2double(token{1});
            end
        end
        if (~isempty(numbers));
            number = max(numbers)+1;
        else
            number = 1;
        end
        ad.data{id}.file.name = fullfile(...
            fpath,...
            sprintf('%s_%i.zip',fname,number));
    end
    
    % Show dialog for file selection
    [FileName,PathName,~] = uiputfile(...
        '*.zip',...
        'Save dataset in a new file',...
        ad.data{id}.file.name);
    
    if (FileName == 0)
        status = -1;
        return;
    end
    
    % Set filename to save in
    ad.data{id}.file.name = fullfile(PathName, FileName);
    
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
    
    % Do the actual saving
    [ saveStatus, exception ] = ...
        trEPRsave(ad.data{id}.file.name,ad.data{id});
    
    % In case something went wrong
    if saveStatus
        % Adding status line
        msgStr = cell(0);
        msgStr{length(msgStr)+1} = ...
            sprintf('Problems when trying to save "%s" to file',...
            ad.data{id}.label);
        msgStr{length(msgStr)+1} = ad.data{id}.file.name;
        status = add2status(msgStr);
        clear msgStr;
        return;
    else
        % Get second output parameter from trEPRsave, i.e. filename
        % (See help of trEPRsave for details)
        filename = exception;
    end
    
    % Remove from modified
    ad.control.spectra.modified(...
        (ad.control.spectra.modified == id)) = [];
    
    % Write appdata
    setappdata(mainWindow,'data',ad.data);
    setappdata(mainWindow,'origdata',ad.data);
    setappdata(mainWindow,'control',ad.control);
    
    % Adding status line
    msg = {...
        sprintf('Dataset %i successfully saved',id)...
        sprintf('Label: %s',ad.data{id}.label)...
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