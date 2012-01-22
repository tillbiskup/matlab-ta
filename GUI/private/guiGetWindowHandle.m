function handle = guiGetWindowHandle(varargin)
% GUIGETWINDOWHANDLE Private function to get window handles of GUI windows.
%
% The idea behind having this function is to have only one place where you
% have to define the tag of the respective GUI windows (except, of course,
% in the respective m-files defining the GUI windows itself). That should
% be very much helpful for using the same GUI components for other
% toolboxes as well. Therefore, this function has to reside in the
% "private" directory of the GUI directory.
%
% Usage:
%    handle = guiGetWindowHandle();
%    handle = guiGetWindowHandle(identifier);
%
% Where, in the latter case, "identifier" is a string that defines which
% GUI window to look for. Normally, for convenience, this should be the
% name of the respective m-file the particular GUI window gets defined in.
%
% If no identifier is given, the handle of the main GUI window is returned.
%
% If no handle could be found, an empty cell array will be returned.

% (c) 2011-12, Till Biskup
% 2012-01-19

try
    % Check whether we are called with input argument
    if nargin && ischar(varargin{1})
        identifier = varargin{1};
    else
        identifier = '';
    end
    
    windowTags = struct();
    windowTags.TAgui = 'TAgui_mainwindow';
    windowTags.TAgui_aboutwindow = 'TAgui_aboutwindow';
    windowTags.TAgui_statuswindow = 'TAgui_statuswindow';
    % Add here list of other window tags
    windowTags.TAgui_combinewindow = 'TAgui_combinewindow';
    windowTags.TAgui_combine_settingswindow = 'TAgui_combine_settingswindow';
    windowTags.TAgui_bugreportwindow = 'TAgui_bugreportwindow';
    windowTags.TAgui_AVGwindow = 'TAgui_AVGwindow';
    windowTags.TAgui_AVG_helpwindow = 'TAgui_AVG_helpwindow';
    
    % Define default tag
    defaultTag = windowTags.TAgui;
    
    if identifier
        if isfield(windowTags,identifier)
            handle = findobj('Tag',getfield(windowTags,identifier));
        else
            handle = cell(0,1);
        end
    else
        % Get the appdata of the main window
        handle = findobj('Tag',defaultTag);
    end
catch exception
    try
        TAgui_bugreportwindow(exception);
    catch exception2
        % If even displaying the bug report window fails...
        exception = addCause(exception2, exception);
        throw(exception);
    end
end

end