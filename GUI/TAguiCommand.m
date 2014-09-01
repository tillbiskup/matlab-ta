function [status,warnings] = TAguiCommand(command,varargin)
% TAGUICOMMAND Helper function dealing with the command line of the
% TA GUI.
%
% Usage:
%   TAguiCommand(command)
%   [status,warnings] = TAguiCommand(command)
%
%   command - string
%             Command to be executed
%
%   status  - scalar
%             Return value for the exit status:
%              0: command successfully performed
%             -1: no TAgui window found
%             -2: TAgui window appdata don't contain necessary fields
%             -3: some other problems
%
%  warnings - cell array
%             Contains warnings/error messages if any, otherwise empty

% Copyright (c) 2013, Till Biskup
% 2013-07-12

status = 0;
warnings = cell(0);

% If called with no input arguments, just display help and exit
if (nargin==0)
    help TAguiCommand;
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

% Is there currently a TAgui object?
mainWindow = TAguiGetWindowHandle();
if (isempty(mainWindow))
    warnings{end+1} = 'No TAgui window could be found.';
    status = -1;
    return;
end

if isempty(command)
    warnings{end+1} = 'Command empty.';
    status = -3;
    return;
end

if strncmp(command,'%',1)
    warnings{end+1} = 'Command is a comment.';
    status = -3;
    return;
end

% Get appdata from mainwindow
ad = getappdata(mainWindow);
% % Get handles from main GUI
% gh = guidata(mainWindow);

% Add command to command history
ad.control.cmd.history{end+1} = command;
ad.control.cmd.historypos = length(ad.control.cmd.history);
setappdata(mainWindow,'control',ad.control);

% Check whether to save history
if ad.control.cmd.historysave
    [histsavestat,histsavewarn] = TAgui_cmd_writeToFile(command);
    if histsavestat
        TAmsg(histsavewarn,'warn');
    end
end

% For future use: parse command, split it at spaces, use first part as
% command, all other parts as options
input = regexp(command,' ','split');
cmd = input{1};
if (length(input) > 1)
    opt = input(2:end);
    % Remove empty opts
    opt = opt(~cellfun('isempty',opt));
else
    opt = cell(0);
end

% Assign some important variables for potential use in command assignment
active = ad.control.spectra.active; %#ok<NASGU>

% For now, just a list of internal commands and their translation into
% existing commands.
guiCommands;

% Handle special situations, such as "?"
switch lower(cmd)
    case '?'
        cmd = 'help';
end

if find(strcmpi(cmdMatch(:,1),cmd)) %#ok<NODEF>
    fun = str2func(cmdMatch{(strcmpi(cmdMatch(:,1),cmd)),2});
    if cmdMatch{(strcmpi(cmdMatch(:,1),cmd)),4}
        arguments = cmdMatch((strcmpi(cmdMatch(:,1),cmd)),3);
        if ~isempty(arguments)
            if iscell(arguments)
                fun(arguments{:});
            else
                fun(arguments);
            end
        else
            fun();
        end
    end
elseif exist(['cmd' upper(cmd(1)) lower(cmd(2:end))],'file')
    fun = str2func(['cmd' upper(cmd(1)) lower(cmd(2:end))]);
    [cmdStatus,cmdWarnings] = fun(mainWindow,opt);
    if cmdStatus
        warnings = [warnings cmdWarnings];
        status = -3;
    end
else
    % For debug purposes.
    disp(cmd);
    if ~isempty(opt)
        celldisp(opt);
    end
end

end
