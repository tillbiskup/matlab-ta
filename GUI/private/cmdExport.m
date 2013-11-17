function [status,warnings] = cmdExport(handle,opt,varargin)
% CMDEXPORT Command line command of the TA GUI.
%
% Usage:
%   cmdExport(handle,opt)
%   [status,warnings] = cmdExport(handle,opt)
%
%   handle  - handle
%             Handle of the window the command should be performed for
%
%   opt     - cell array
%             Options of the command
%
%   status  - scalar
%             Return value for the exit status:
%              0: command successfully performed
%             -1: no GUI window found
%             -2: missing options
%             -3: some other problems
%
%  warnings - cell array
%             Contains warnings/error messages if any, otherwise empty

% (c) 2013, Till Biskup
% 2013-11-17

status = 0;
warnings = cell(0);

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('handle', @(x)ishandle(x));
p.addRequired('opt', @(x)iscell(x));
%p.addOptional('opt',cell(0),@(x)iscell(x));
p.parse(handle,opt,varargin{:});
handle = p.Results.handle;
opt = p.Results.opt;

% Get command name from mfilename
cmd = mfilename;
cmd = lower(cmd(4:end));

% Is there the GUI requested?
if (isempty(handle))
    warnings{end+1} = 'No GUI window could be found.';
    status = -1;
    return;
end

% Get appdata from handle
ad = getappdata(handle);

% For convenience and shorter lines
active = ad.control.spectra.active;

% If there is no active dataset, return
if ~active
    warnings{end+1} = sprintf('Command "%s": No active dataset.',cmd);
    status = -3;
    return;
end

if isempty(opt)
    warnings{end+1} = sprintf(...
        'Command "%s": Not enough options. Use "help %s" to get some help.',cmd,cmd);
    status = -2;
    return;
end

% Check for correct first option
firstOption = {'fig','figure','axis','axes','1D'};
if ~any(strcmpi(opt{1},firstOption))
    warnings{end+1} = sprintf(...
        'Command "%s": Option "%s" not understood.',cmd,opt{1});
    status = -3;
    return;
end

% Handle different things to export
switch lower(opt{1})
    case {'fig','figure','axis','axes'}
        % TODO: Handle additional optional parameters
        %       Call function saving the current axis
        % Handle actual work in an internal function
        [if_status,if_warnings] = if_exportFigure(handle,opt(2:end));
        % Deal with status and warnings from internal function
        if if_status
            status = if_status;
        end
        if ~isempty(if_warnings)
            for k=1:length(if_warnings)
                warnings{end+1} = if_warnings{k}; %#ok<AGROW>
            end
        end
        return;
    case '1d'
        % TODO: Handle additional optional parameters
        %       Call function saving the current axis
        % Handle actual work in an internal function
        [if_status,if_warnings] = if_export1Ddata(handle,opt(2:end));
        % Deal with status and warnings from internal function
        if if_status
            status = if_status;
        end
        if ~isempty(if_warnings)
            for k=1:length(if_warnings)
                warnings{end+1} = if_warnings{k}; %#ok<AGROW>
            end
        end
        return;
    otherwise
        warnings{end+1} = sprintf(...
            'Command "%s": Option "%s" not understood.',cmd,opt{1});
        status = -3;
        return;
end

end

function [if_status,if_warnings] = if_exportFigure(handle,opt)
% IF_EXPORTFIGURE Internal function used to handle exporting figures.
%
% Please note: This internal function itself only prepares the function
% call for the actual function used to export the figure.

if_status = 0;
if_warnings = cell(0);

% Get appdata and handles of handle
ad = getappdata(handle);
gh = guihandles(handle);

% Get export format
figExportFormats = cellstr(...
    get(gh.display_panel_axesexport_format_popupmenu,'String'));
exportFormat = figExportFormats{...
    get(gh.display_panel_axesexport_format_popupmenu,'Value')};

% Get file type to save to
fileTypes = cellstr(...
    get(gh.display_panel_axesexport_filetype_popupmenu,'String'));
fileType = fileTypes{...
    get(gh.display_panel_axesexport_filetype_popupmenu,'Value')};

% Handle additional options
% Please note: These options of the internal function are a subset of the
%              original options the command was called with.
% Order of checking does matter to a certain extend, as the last remaining
% option is used as a filename, if any.
if ~isempty(opt)
    % Check for image format
    formatidx = strncmpi('format=',opt,6);
    formatstr = opt(formatidx);
    % Remove respective entries from opt cell array
    opt(formatidx) = [];
    if ~isempty(formatstr)
        exportFormat = formatstr{1}(8:end);
    end
    
    % Check for file type
    typeidx = strncmpi('type=',opt,6);
    typestr = opt(typeidx);
    % Remove respective entries from opt cell array
    opt(typeidx) = [];
    if ~isempty(typestr)
        fileType = typestr{1}(8:end);
    end
    
    % Finally, take remaining options as file name
    if ~isempty(opt)
        if allTraces
            if_warnings{end+1} = sprintf(...
                'Command "%s": Single filename with multiple files!',cmd,opt{1});
            if_status = -3;
            return;
        end
        fileName = strtrim('%s ',opt{:});
    end
end

% Important: First generate filename suggestion and ask user for
% filename, then start redrawing the figure in a new figure window.
% If the user quits the file selection dialogue box, nothing is
% left to close in this case.

if ~exist('fileName','var')
    fileNameSuggested = suggestFilename(handle,'Type','figure');
    
    % Ask user for file name
    [fileName,pathName] = uiputfile(...
        sprintf('*.%s',fileType),...
        'Get filename to export figure to',...
        fileNameSuggested);
    % If user aborts process, return
    if fileName == 0
        return;
    end
    % Create filename with full path
    fileName = fullfile(pathName,fileName);
end

% set lastFigSave Dir in appdata
if exist(pathName,'dir')
    ad.control.dir.lastFigSave = pathName;
end
setappdata(handle,'control',ad.control);

% Open new figure window
newFig = figure();

% Make new figure window invisible
set(newFig,'Visible','off');

% Plot into new figure window
% Check whether to plot title
if get(gh.display_panel_axesexport_includetitle_checkbox,'Value')
    update_mainAxis(newFig);
else
    update_mainAxis(newFig,'notitle');
end

% Check whether to open caption GUI
if get(gh.display_panel_axesexport_includecaption_checkbox,'Value')
    TAgui_figureCaptionwindow(fileName);
end

% Save figure, depending on settings for file type and format
status = fig2file(newFig,fileName,...
    'fileType',fileType,'exportFormat',exportFormat);
if status
    TAmsg(status,'warning');
end

% Close figure window
close(newFig);

end

function [if_status,if_warnings] = if_export1Ddata(handle,opt)
% IF_EXPORTFIGURE Internal function used to handle exporting data.
%
% Please note: This internal function itself only prepares the function
% call for the actual function used to export the data.

if_status = 0;
if_warnings = cell(0);

% Get appdata and handles of handle
ad = getappdata(handle);
gh = guihandles(handle);

% Set default options
multipleFiles = get(...
    gh.display_panel_dataexport_multiplefiles_checkbox,'value');

allTraces = any(cell2mat(...
    get([gh.display_panel_dataexport_multiplefiles_checkbox,...
    gh.display_panel_dataexport_multiple1file_checkbox],'value')));

% Handle additional options
% Please note: These options of the internal function are a subset of the
%              original options the command was called with.
% Order of checking does matter to a certain extend, as the last remaining
% option is used as a filename, if any.
if ~isempty(opt)
    
    % Check which datasets should be exported, default is what is set in
    % the GUI
    currentidx = strcmpi('current',opt);
    if any(currentidx)
        % Remove respective entries from opt cell array
        opt(currentidx) = [];
    end
    allidx = strcmpi('all',opt);
    if any(allidx)
        % Remove respective entries from opt cell array
        opt(allidx) = [];
        allTraces = true;
    end
    
    % Check which datasets should be exported, default is what is set in
    % the GUI
    singleidx = strcmpi('single',opt);
    if any(singleidx)
        % Remove respective entries from opt cell array
        opt(singleidx) = [];
        multipleFiles = false;
    end
    multipleidx = strcmpi('multiple',opt);
    if any(multipleidx)
        % Remove respective entries from opt cell array
        opt(multipleidx) = [];
        multipleFiles = true;
    end
    
    % Check for file type
    typeidx = strncmpi('type=',opt,6);
    typestr = opt(typeidx);
    % Remove respective entries from opt cell array
    opt(typeidx) = [];
    if ~isempty(typestr)
        fileType = typestr{1}(8:end);
    end
    
    % Finally, take remaining options as file name
    if ~isempty(opt)
        if allTraces
            if_warnings{end+1} = sprintf(...
                'Command "%s": Single filename with multiple files!',cmd,opt{1});
            if_status = -3;
            return;
        end
        fileName = strtrim('%s ',opt{:});
    end
end

if ~exist('fileType','var')
    % Get file type to save to
    fileTypes = cellstr(...
        get(gh.display_panel_dataexport_filetype_popupmenu,'String'));
    fileType = fileTypes{...
        get(gh.display_panel_dataexport_filetype_popupmenu,'Value')};
end

if ~exist('MFEline','var')
    % Get line to save
    MFElines = cellstr(...
        get(gh.display_panel_dataexport_line_popupmenu,'String'));
    MFEline = MFElines{...
        get(gh.display_panel_dataexport_line_popupmenu,'Value')};
end

% Set directory where to save files to
if isfield(ad,'control') && isfield(ad.control,'dir') && ...
        isfield(ad.control.dir,'lastExport')  && ...
        ~isempty(ad.control.dir.lastExport)
    startDir = ad.control.dir.lastExport;
else
    startDir = pwd;
end

switch fileType
    case 'ASCII'
        fileExtension = 'dat';
    otherwise
        fileExtension = '';
end

% If multipleFiles is set, meaning that multiple visible datasets should be
% saved each to a separate file
if multipleFiles

    % Iterate over each visible dataset
    for idx = 1:length(ad.control.spectra.visible)
        % Ask user for filename
        [~,f,~] = ...
            fileparts(ad.data{ad.control.spectra.visible(idx)}.file.name);
        fileNameSuggested = fullfile(startDir,[f '-1D']);
        clear f;
        % Ask user for file name
        [fileName,pathName] = uiputfile(...
            sprintf('*.%s',fileExtension),...
            sprintf('Filename for dataset "%s"',...
            ad.data{ad.control.spectra.visible(idx)}.label),...
            fileNameSuggested);
        % If user aborts process, return
        if fileName == 0
            return;
        end
        % Create filename with full path
        fileName = fullfile(pathName,fileName);
        
        % set lastExport Dir in appdata
        if exist(pathName,'dir')
            ad.control.dir.lastExport = pathName;
        end
        setappdata(handle,'control',ad.control);
        
        % Create parameters structure
        export1Dparameters = struct();
        switch ad.control.axis.displayType
            case '1D along x'
                export1Dparameters.crosssection.direction = 'x';
                export1Dparameters.crosssection.position = ...
                    ad.data{ad.control.spectra.visible(idx)}.display.position.y;
            case '1D along y'
                export1Dparameters.crosssection.direction = 'y';
                export1Dparameters.crosssection.position = ...
                    ad.data{ad.control.spectra.visible(idx)}.display.position.x;
            otherwise
                msg = 'Cannot determine cross section direction (2D mode)';
                TAmsg(msg,'error');
                msgbox(msg,'Error with exporting 1D','error');
        end
        export1Dparameters.display.MFEdisplay = MFEline;
        export1Dparameters.header.character = ...
            get(gh.display_panel_dataexport_header_edit,'String');
        export1Dparameters.axis.include = ...
            get(gh.display_panel_dataexport_includeaxis_checkbox,'Value');
        export1Dparameters.stdev.include = ...
            get(gh.display_panel_dataexport_includestdev_checkbox,'Value');
        export1Dparameters.file.type = fileType;
        export1Dparameters.file.overwrite = 1;
        
        % Save 1D cross section, depending on settings for file type and
        % additional parameters
        status = TAexport1D(...
            ad.data{ad.control.spectra.visible(idx)},...
            fileName,export1Dparameters);
        if status
            TAmsg(status,'warning');
            msgbox(status,'Problems with exporting 1D','warn');
        else
            msgbox(sprintf('%s\n%s',...
                'Current 1D display successfully exported to file',...
                fileName),...
                'Exporting 1D','help');
        end
    end
    
else
    
    % If no filename is provided, ask user for filename
    if ~exist('fileName','var')
        % Suggest file name if possible
        [~,f,~] = ...
            fileparts(ad.data{ad.control.spectra.active}.file.name);
        fileNameSuggested = fullfile(startDir,[f '-1D']);
        clear f;
        % Ask user for file name
        [fileName,pathName] = uiputfile(...
            sprintf('*.%s',fileExtension),...
            'Get filename to save 1D cross section of currently active dataset to',...
            fileNameSuggested);
        % If user aborts process, return
        if fileName == 0
            return;
        end
        % Create filename with full path
        fileName = fullfile(pathName,fileName);
    end
    
    % set lastExport Dir in appdata
    if exist(pathName,'dir')
        ad.control.dir.lastExport = pathName;
    end
    setappdata(handle,'control',ad.control);
    
    % Create parameters structure
    export1Dparameters = struct();
    switch ad.control.axis.displayType
        case '1D along x'
            export1Dparameters.crosssection.direction = 'x';
            export1Dparameters.crosssection.position = ...
                ad.data{ad.control.spectra.active}.display.position.y;
        case '1D along y'
            export1Dparameters.crosssection.direction = 'y';
            export1Dparameters.crosssection.position = ...
                ad.data{ad.control.spectra.active}.display.position.x;
        otherwise
            msg = 'Cannot determine cross section direction (2D mode)';
            TAmsg(msg,'error');
            msgbox(msg,'Error with exporting 1D','error');
    end
    export1Dparameters.display.MFEdisplay = MFEline;
    export1Dparameters.header.character = ...
        get(gh.display_panel_dataexport_header_edit,'String');
    export1Dparameters.axis.include = ...
        get(gh.display_panel_dataexport_includeaxis_checkbox,'Value');
    export1Dparameters.stdev.include = ...
        get(gh.display_panel_dataexport_includestdev_checkbox,'Value');
    export1Dparameters.file.type = fileType;
    export1Dparameters.file.overwrite = 1;
    
    % Save 1D cross section, depending on settings for file type and
    % additional parameters
    status = TAexport1D(...
        ad.data{ad.control.spectra.active},fileName,export1Dparameters);
    if status
        TAmsg(status,'warning');
        msgbox(status,'Problems with exporting 1D','warn');
    else
        msgbox(sprintf('%s\n%s',...
            'Current 1D display successfully exported to file',...
            fileName),...
            'Exporting 1D','help');
    end
    
end

end

