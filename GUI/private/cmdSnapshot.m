function [status,warnings] = cmdSnapshot(handle,opt,varargin)
% CMDSNAPSHOT Command line command of the TA GUI.
%
% Usage:
%   cmdSnapshot(handle,opt)
%   [status,warnings] = cmdSnapshot(handle,opt)
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
%             -3: some other problems
%
%  warnings - cell array
%             Contains warnings/error messages if any, otherwise empty

% (c) 2013, Till Biskup
% 2013-07-15

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

if isempty(opt)
    TAmsg(['Command: ' cmd ' needs two options.'],'warning');
    return;
end

% Get appdata from handle
ad = getappdata(handle);
% Get handles from handle
% gh = guidata(handle);

switch lower(opt{1})
    case {'load','l'}
        if size(opt) < 2
            TAmsg(['Command: ' cmd ' needs two options.'],'warning');
            return;
        else
            [path,name,ext] = fileparts(opt{2});
            if isempty(path)
                fileName = fullfile(ad.control.dirs.lastSnapshot,[name ext]);
            else
                fileName = opt{2};
            end
            AD = load(fileName);
            % Simple test: Check whether version of appdata is identical,
            % otherwise warn user and let him decide.
            if ~strcmp(ad.format.name,AD.ad.format.name) ...
                    || ~strcmp(ad.format.version,AD.ad.format.version)
                qstring = sprintf(['The format of the snapshot you try to'...
                    ' load appears to be different from the one the'...
                    ' toolbox currently uses.\n'... 
                    'Do you really want to continue? If so, you do it'...
                    'on your own risk!']);
                button = questdlg(qstring,'Problem loading Snapshot',...
                    'Yes','No','No');
                switch lower(button)
                    case 'yes'
                    otherwise
                        TAmsg('Loading GUI snapshot aborted by user','info');
                        return;
                end
            end
            appdataFields = fieldnames(AD.ad);
            % Remove field "UsedByGUIData_m" to prevent problems
            appdataFields((strcmpi(appdataFields,'UsedByGUIData_m'))) = [];
            for k=1:length(appdataFields)
                setappdata(handle,appdataFields{k},AD.ad.(appdataFields{k}));
            end
            TAmsg(['Loaded GUI snapshot from file ' fileName],'info');
            update_mainAxis();
            return;
        end
    case {'save','s'}
        if size(opt) < 2
            TAmsg(['Command: ' cmd ' needs two options.'],'warning');
            return;
        else
            [path,name,ext] = fileparts(opt{2});
            if isempty(path)
                fileName = fullfile(ad.control.dirs.lastSnapshot,[name ext]);
            else
                fileName = opt{2};
            end
            % IMPORTANT: The filename should be parsed for bad characters
            % before, especially minus signs and such things seem to be bad
            % with MATLAB.
            datetime = datestr(now,30); %#ok<NASGU>
            save(fileName,'ad','datetime');
            TAmsg(['Saved GUI snapshot to file ' fileName],'info');
            return;
        end
    otherwise
        return;
end

end

