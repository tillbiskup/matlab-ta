function [status,warnings] = cmdLoad(handle,opt,varargin)
% CMDLOAD Command line command of the TA GUI.
%
% Usage:
%   cmdLoad(handle,opt)
%   [status,warnings] = cmdLoad(handle,opt)
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
%             -1: GUI window found
%             -2: missing options
%             -3: Failed loading file(s)
%             -4: some other problems
%
%  warnings - cell array
%             Contains warnings/error messages if any, otherwise empty

% (c) 2013, Till Biskup
% 2013-11-15

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
cmd = cmd(4:end);

% Is there the GUI requested?
if (isempty(handle))
    warnings{end+1} = 'No GUI window could be found.';
    status = -1;
    return;
end

% Get appdata from handle
ad = getappdata(handle);
% Get handles from handle
gh = guidata(handle);

% Convert opt into FileName
FileName = opt;
mainWindow = handle;

if isempty(FileName)
    warnings{end+1} = ['Command "' lower(cmd) '" needs at least one filename.'];
    return;
end

if get(gh.load_panel_files_combine_checkbox,'Value')
    state.comb = true;
else
    state.comb = false;
end

if get(gh.load_panel_infofile_checkbox,'Value')
    loadInfoFile = true;
else
    loadInfoFile = false;
end

[path,name,ext] = fileparts(FileName{1});
if isempty(path)
    FileName = fullfile(ad.control.dirs.lastLoad,[name ext]);
end

% FileName is always a cell, as it comes from opt
% To prevent problems with TAload, check whether it is a one-element
% cell array and if so, convert it.
if iscell(FileName) && length(FileName) == 1
    FileName = FileName{1};
end

% Adding status line
TAmsg([{'Calling TAload and trying to load:'} FileName],'info');

TAbusyWindow('start','Trying to load spectra...<br />please wait.');

[data,warnings] = TAload(FileName,'combine',state.comb,...
    'loadInfoFile',loadInfoFile);

% Get appdata, to make sure not to skip any messages that might be
% written by TAload
%ad = getappdata(mainWindow);

if isequal(data,0) || isempty(data)
    TAmsg('Data could not be loaded.','error');
    TAbusyWindow('stop','Trying to load spectra...<br /><b>failed</b>.');
    return;
end

if ~isempty(warnings) && ~isempty(warnings{1})
    msgStr = cell(0);
    msgStr{end+1} = 'Some warnings occurred while reading files:';
    msg = [msgStr warnings{:}];
    TAmsg(msg,'warning');
    clear msgStr msg;
end
% if ~isempty(warnings)
%     % Add warnings to status messages
%     msgStr = cell(0);
%     msgStr{end+1} = 'Some warnings occurred when trying to load ';
%     if isa(FileName,'cell')
%         FileName = char(FileName);
%     end
%     msgStr{end+1} = FileName;
%     for k=1:length(warnings)
%         if length(warnings{k})>1
%             for m=1:length(warnings{k})
%                 msgStr{end+1} = ['Identifier: ' warnings{k}{m}.identifier]; %#ok<AGROW>
%                 msgStr{end+1} = ['Message:    ' warnings{k}{m}.message]; %#ok<AGROW>
%             end
%         else
%             msgStr{end+1} = warnings{k}.identifier; %#ok<AGROW>
%             msgStr{end+1} = warnings{k}.message; %#ok<AGROW>
%         end
%     end
%     TAmsg(msgStr,'warning');
%     clear msgStr;
% end

% Check whether data{n}.data is numeric (very basic test for format)
fnNoData = cell(0);
nNoData = [];
if iscell(data)
    for k=1:length(data)
        if (isfield(data{k},'data') && ~isnumeric(data{k}.data))
            fnNoData{k} = data{k}.file.name;
            nNoData = [ nNoData k ]; %#ok<AGROW>
        elseif ~isfield(data{k},'data')
            nNoData = [ nNoData k ]; %#ok<AGROW>
        end
    end
    % Remove datasets from data cell array
    data(nNoData) = [];
else
    if not(isnumeric(data.data))
        fnNoData = data.file.name;
        data = [];
    end
end

% Add status line
if not (isempty(fnNoData))
    msgStr = cell(0);
    msgStr{length(msgStr)+1} = ...
        'The following files contained no numerical data (and were DISCARDED):';
    msg = [msgStr fnNoData];
    TAmsg(msg,'warning');
    clear msgStr msg;
end

if isempty(data)
    TAbusyWindow('stop','Trying to load spectra...<br /><b>failed</b>.');
    status = -4;
    warnings{end+1} = 'Failed loading file(s)';
    return;
end

% Get names of successfully loaded files
% In parallel, add additional fields to each dataset
% Define default display structure to add to datasets
guiDataStruct = TAguiDataStructure('datastructure');
% Important: Delete "history" field not to overwrite history
guiDataStruct = rmfield(guiDataStruct,'history');
guiDataStructFields = fieldnames(guiDataStruct);
if iscell(data)
    fileNames = cell(0);
    for k = 1 : length(data)
        [p,fn,ext] = fileparts(data{k}.file.name);
        fileNames{k} = fullfile(p,[fn ext]);
        if ~isfield(data{k},'label') || isempty(data{k}.label)
            data{k}.label = [fn ext];
        end
        for l=1:length(guiDataStructFields)
            data{k}.(guiDataStructFields{l}) = ...
                guiDataStruct.(guiDataStructFields{l});
        end
        if ~isfield(data{k},'history')
            data{k}.history = cell(0);
        end
        % For compatibility with old versions of TAread and for
        % consistency with the naming of all other structures
        if (isfield(data{k},'axes') && isfield(data{k}.axes,'xaxis'))
            data{k}.axes.x = data{k}.axes.xaxis;
            data{k}.axes = rmfield(data{k}.axes,'xaxis');
        end
        if (isfield(data{k},'axes') && isfield(data{k}.axes,'yaxis'))
            data{k}.axes.y = data{k}.axes.yaxis;
            data{k}.axes = rmfield(data{k}.axes,'yaxis');
        end
    end
else
    fileNames = data.file.name;
    [~,fn,ext] = fileparts(data.file.name);
    if ~isfield(data,'label') || isempty(data.label)
        data.label = [fn ext];
    end
    for l=1:length(guiDataStructFields)
        data.(guiDataStructFields{l}) = ...
            guiDataStruct.(guiDataStructFields{l});
    end
    if ~isfield(data,'history')
        data.history = cell(0);
    end
    % For compatibility with old versions of TAread and for
    % consistency with the naming of all other structures
    if (isfield(data,'axes') && isfield(data.axes,'xaxis'))
        data.axes.x = data.axes.xaxis;
        data.axes = rmfield(data.axes,'xaxis');
    end
    if (isfield(data,'axes') && isfield(data.axes,'yaxis'))
        data.axes.y = data.axes.yaxis;
        data.axes = rmfield(data.axes,'yaxis');
    end
end

% Get indices of new datasets
% Necessary in case of further corrections applied to datasets
% after loading
newDataIdx = length(ad.data)+1 : 1 : length(ad.data)+length(data);

% Add data to main GUI (appdata)
[rows,cols] = size(data);
if rows == 1
    ad.data = [ ad.data data ];
    ad.origdata = [ ad.origdata data ];
elseif cols == 1
    ad.data = [ ad.data data' ];
    ad.origdata = [ ad.origdata data' ];
end

setappdata(mainWindow,'data',ad.data);
setappdata(mainWindow,'origdata',ad.origdata);

% Adding status line
msgStr = sprintf('%i data set(s) successfully loaded:',length(data));
TAmsg([msgStr fileNames],'info');
clear msgStr;

TAbusyWindow('stop','Trying to load spectra...<br /><b>done</b>.');
TAbusyWindow('deletedelayed');

% Get appdata again after making changes to it before
ad = getappdata(mainWindow);

% Add new loaded spectra to "invisible"
ad.control.spectra.invisible = [...
    ad.control.spectra.invisible ...
    newDataIdx...
    ];
setappdata(mainWindow,'control',ad.control);

update_invisibleSpectra;

% % Handle dataset corrections when checked
% % pretrigger offset compensation
% if get(gh.load_panel_preprocessing_offset_checkbox,'Value')
%     for k=1:length(newDataIdx)
%         guiProcessingPOC(newDataIdx(k));
%     end
% end
% 
% % background subtraction
% if get(gh.load_panel_preprocessing_background_checkbox,'Value')
%     for k=1:length(newDataIdx)
%         guiProcessingBGC(newDataIdx(k));
%     end
% end

% Try to load axis labels from file
if get(gh.load_panel_axislabels_checkbox,'Value')
    if (isfield(ad.data{newDataIdx(end)},'axes'))
        if (isfield(ad.data{newDataIdx(end)}.axes,'x') && ...
                isfield(ad.data{newDataIdx(end)}.axes.x,'measure'))
            ad.control.axis.labels.x.measure = ...
                ad.data{newDataIdx(end)}.axes.x.measure;
        end
        if (isfield(ad.data{newDataIdx(end)}.axes,'x') && ...
                isfield(ad.data{newDataIdx(end)}.axes.x,'unit'))
            ad.control.axis.labels.x.unit = ...
                ad.data{newDataIdx(end)}.axes.x.unit;
        end
        if (isfield(ad.data{newDataIdx(end)}.axes,'y') && ...
                isfield(ad.data{newDataIdx(end)}.axes.y,'measure'))
            ad.control.axis.labels.y.measure = ...
                ad.data{newDataIdx(end)}.axes.y.measure;
        end
        if (isfield(ad.data{newDataIdx(end)}.axes,'y') && ...
                isfield(ad.data{newDataIdx(end)}.axes.y,'unit'))
            ad.control.axis.labels.y.unit = ...
                ad.data{newDataIdx(end)}.axes.y.unit;
        end
        if (isfield(ad.data{newDataIdx(end)}.axes,'z') && ...
                isfield(ad.data{newDataIdx(end)}.axes.z,'measure'))
            ad.control.axis.labels.z.measure = ...
                ad.data{newDataIdx(end)}.axes.z.measure;
        end
        if (isfield(ad.data{newDataIdx(end)}.axes,'z') && ...
                isfield(ad.data{newDataIdx(end)}.axes.z,'unit'))
            ad.control.axis.labels.z.unit = ...
                ad.data{newDataIdx(end)}.axes.z.unit;
        end
    end
    setappdata(mainWindow,'control',ad.control);
end


end