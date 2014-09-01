function [status,warnings] = cmdPwd(handle,opt,varargin)
% CMDPWD Command line command of the TA GUI.
%
% Usage:
%   cmdPwd(handle,opt)
%   [status,warnings] = cmdPwd(handle,opt)
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

% Copyright (c) 2013, Till Biskup
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

% Get appdata from handle
ad = getappdata(handle);

if isempty(opt)
    message = {...
        'Directories currently set for the TA GUI:'...
        ['Load:        ' ad.control.dirs.lastLoad] ...
        ['Save:        ' ad.control.dirs.lastSave] ...
        ['Figure save: ' ad.control.dirs.lastFigSave] ...
        ['Export:      ' ad.control.dirs.lastExport] ...
        ['Snapshot:    ' ad.control.dirs.lastSnapshot] ...
        };
    TAmsg(message,'info');
    return;
end

switch lower(opt{1})
    case 'gui'
        TAgui_setdirectorieswindow();
        return;
    case {'l','load','loaddir'}
        TAmsg(['Load dir: ' ad.control.dirs.lastLoad],'info');
        return;
    case {'s','save','savedir'}
        TAmsg(['Save dir: ' ad.control.dirs.lastSave],'info');
        return;
    case {'sf','savefig','savefigdir','figsave','figsavedir','fig','figdir'}
        TAmsg(['Figure save dir: ' ad.control.dirs.lastFigSave],'info');
        return;
    case {'e','export','exportdir'}
        TAmsg(['Export dir: ' ad.control.dirs.lastExport],'info');
        return;
    case {'ss','snapshot','snapshotdir'}
        TAmsg(['Snapshot dir: ' ad.control.dirs.lastExport],'info');
        return;
    otherwise
        TAmsg(['Command ' lower(cmd) ': option ' lower(opt{1}) ...
            ' not understood'],'warning');
        return;
end

end

