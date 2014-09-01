function [status,warnings] = TAopen(filename, varargin)
% TAOPEN Open file and display in GUI. Open TAgui main window if
% necessary.
%
% Usage
%   TAopen(filename)
%   status = TAopen(filename)
%
%   filename - string
%              name of a valid filename
%
%   status   - scalar
%              Return value for the exit status:
%               0: command successfully performed
%              -1: Invalid filename
%              -2: some other problems
%
%  warnings  - cell array
%              Contains warnings/error messages if any, otherwise empty

% Copyright (c) 2013, Till Biskup
% 2013-07-12

status = 0;
warnings = cell(0);

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('filename', @(x)ischar(x));
p.parse(filename,varargin{:});

% If file does not exist, return
if ~exist(filename,'file')
    status = -1;
    warnings{end+1} = sprintf('File %s does not exist.',filename);
    if nargout < 2
        disp(warnings{end});
    end
    return;
end

% Try to find out whether filename is a fully qualified filename
[path,~,~] = fileparts(filename);
if isempty(path)
    filename = fullfile(pwd,filename);
end

% If FileName is not a cell string, convert it into a cell string
if ~isa(filename,'cell')
    filename = cellstr(filename);
end

% Open TAgui
h = TAgui;

PWD = pwd;
try
    cd(fullfile(TAinfo('dir'),'GUI','private'));
    [loadStatus,loadWarnings] = cmdLoad(h,filename);
    if loadStatus
        disp(loadWarnings)
    else
        cmdShow(h,cell(0));
        % Tidy up and close TAbusyWindow telling the user that the file has
        % been loaded successfully...
        hBusyWindow = findobj('Tag','TAbusyWindow');
        if ~isempty(hBusyWindow)
            for k=1:length(hBusyWindow)
                close(hBusyWindow(k));
            end
        end
    end
    cd(PWD);
catch exception
    cd(PWD);
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
