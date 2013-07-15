function [status,warnings] = trEPRgui_cmd_writeToFile(command,varargin)
% TREPRGUI_CMD_WRITETOFILE Writing command string to cmd history file
%
% Usage:
%   trEPRgui_cmd_writeToFile(command)
%   [status,warnings] = trEPRgui_cmd_writeToFile(command)
%
%   command - string
%             Command to be saved to the history file
%
%   status  - scalar
%             Return value for the exit status:
%              0: command successfully saved
%             -1: no trEPRgui window found
%             -2: trEPRgui window appdata don't contain necessary fields
%             -3: some other problems
%
%  warnings - cell array
%             Contains warnings/error messages if any, otherwise empty

% (c) 2013, Till Biskup
% 2013-04-07

status = 0;
warnings = cell(0);

% If called with no input arguments, just display help and exit
if (nargin==0)
    help trEPRgui_cmd_writeToFile;
    return;
end

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('command', @(x)ischar(x));
%p.addOptional('command','',@(x)ischar(x));
p.parse(command,varargin{:});

% Is there currently a trEPRgui object?
mainWindow = trEPRguiGetWindowHandle();
if (isempty(mainWindow))
    warnings{end+1} = 'No trEPRgui window could be found.';
    status = -1;
    return;
end

if isempty(command)
    warnings{end+1} = 'Command empty.';
    status = -3;
    return;
end

% Get appdata from mainwindow
ad = getappdata(mainWindow);

if ~isfield(ad.control.cmd,'historyfile')
    warnings{end+1} = 'trEPRgui window appdata miss necessary field.';
    status = -2;
end

% Fallback: If historyfile is not set, use default
if isempty(ad.control.cmd.historyfile)
    ad.control.cmd.historyfile = '~/.trepr/history';
    setappdata(mainWindow,'control',ad.control);
end

if ~exist(ad.control.cmd.historyfile,'file') && ~strncmp(command,'%',1)
    timeStamp = ['%-- ' datestr(now,'yyyy-mm-dd HH:MM') ' --%'];
    command = sprintf('%s\n%s',timeStamp,command);
end

% Actual write of file
fid = fopen(trEPRparseDir(ad.control.cmd.historyfile),'a');
if fid < 0
    status = '-3';
    warnings = 'Problems opening history file';
    return;
end
fprintf(fid,'%s\n',command);
fclose(fid);

end