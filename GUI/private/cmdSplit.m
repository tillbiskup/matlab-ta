function [status,warnings] = cmdSplit(handle,opt,varargin)
% CMDSPLIT Command line command of the TA GUI.
%
% Usage:
%   cmdSplit(handle,opt)
%   [status,warnings] = cmdSplit(handle,opt)
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

% Copyright (c) 2015, Till Biskup
% 2015-06-01

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
%opt = p.Results.opt;

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

datasets = TAsplit(ad.data{active});

% If there is only one dataset returned, there was nothing to split...
if length(datasets) == 1
    return;
end

for idx = 1:length(datasets)
    % Add dataset(s) to main GUI
    status = TAappendDatasetToMainGUI(datasets{idx},'modified',true);
    if status
        warnings{end+1} = sprintf(...
            'Command "%s": Some problems appending dataset.',cmd); %#ok<AGROW>
        status = -3;
    end
end

end

