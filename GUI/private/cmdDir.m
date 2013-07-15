function [status,warnings] = cmdDir(handle,opt,varargin)
% CMDDIR Command line command of the TA GUI.
%
% Usage:
%   cmdDir(handle,opt)
%   [status,warnings] = cmdDir(handle,opt)
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
    TAgui_setdirectorieswindow();
    return;
end

% Get appdata from handle
ad = getappdata(handle);
% Get handles from handle
% gh = guidata(handle);

switch lower(opt{1})
    case {'load','loaddir'}
        if size(opt) < 2
            TAmsg(['Load dir: ' ad.control.dirs.lastLoad],'info');
            return;
        else
            opt{2} = TAparseDir(opt{2});
            if exist(opt{2},'dir')
                ad.control.dirs.lastLoad = opt{2};
            end
        end
    case {'save','savedir'}
        if size(opt) < 2
            TAmsg(['Save dir: ' ad.control.dirs.lastSave],'info');
            return;
        else
            opt{2} = TAparseDir(opt{2});
            if exist(opt{2},'dir')
                ad.control.dirs.lastSave = opt{2};
            end
        end
    case {'savefig','savefigdir','figsave','figsavedir','fig','figdir'}
        if size(opt) < 2
            TAmsg(['Save figure dir: ' ad.control.dirs.lastFigSave],'info');
            return;
        else
            opt{2} = TAparseDir(opt{2});
            if exist(opt{2},'dir')
                ad.control.dirs.lastFigSave = opt{2};
            end
        end
    case {'export','exportdir'}
        if size(opt) < 2
            TAmsg(['Export dir: ' ad.control.dirs.lastExport],'info');
            return;
        else
            opt{2} = TAparseDir(opt{2});
            if exist(opt{2},'dir')
                ad.control.dirs.lastExport = opt{2};
            end
        end
    case {'snapshot','snapshotdir'}
        if size(opt) < 2
            TAmsg(['Snapshot dir: ' ad.control.dirs.lastSnapshot],'info');
            return;
        else
            opt{2} = TAparseDir(opt{2});
            if exist(opt{2},'dir')
                ad.control.dirs.lastSnapshot = opt{2};
            end
        end
    otherwise
        return;
end

setappdata(handle,'control',ad.control);

end

