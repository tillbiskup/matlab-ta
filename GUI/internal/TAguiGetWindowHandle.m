function handle = TAguiGetWindowHandle(varargin)
% TAGUIGETWINDOWHANDLE Internal function to get window handles of GUI
% windows.
%
% The idea behind having this function is to have only one place where you
% have to define the tag of the respective GUI windows (except, of course,
% in the respective m-files defining the GUI windows itself). That should
% be very much helpful for using the same GUI components for other
% toolboxes as well. Therefore, this function has to reside in the
% "private" directory of the GUI directory.
%
% Usage:
%    handle = TAguiGetWindowHandle();
%    handle = TAguiGetWindowHandle(identifier);
%
% Where, in the latter case, "identifier" is a string that defines which
% GUI window to look for. Normally, for convenience, this should be the
% name of the respective m-file the particular GUI window gets defined in.
%
% If no identifier is given, the handle of the main GUI window is returned.
%
% If no handle could be found, an empty cell array will be returned.

% (c) 2011-12, Till Biskup
% 2012-10-21

try
    % Check whether we are called with input argument
    if nargin && ischar(varargin{1})
        identifier = varargin{1};
    else
        identifier = '';
    end
    
    windowTags = struct();
    windowTags.TAgui = 'TAgui';
    
    % Fill struct with generic names - assuming everybody followed the
    % conventions of naming GUI windows
    
    % Get GUI window filenames
    guiFileNames = struct2cell(...
        dir(fullfile(TAinfo('dir'),'GUI','TA*window.m')));
    guiFileNames = guiFileNames(1,:);
    guiSubWindowNames = struct2cell(...
        dir(fullfile(TAinfo('dir'),'GUI','private','TA*window.m')));
    % Get module subdirectories - do it generically for all modules
    moduleDirs = struct2cell(dir(fullfile(TAinfo('dir'),'modules')));
    moduleDirs = moduleDirs(1,[moduleDirs{4,:}]);
    moduleDirs(strncmp(moduleDirs,'.',1)) = [];
    if ~isempty(moduleDirs)
        guiModuleWindowNames = cell(0);
        for k=1:length(moduleDirs)
            tmpNames = struct2cell(dir(fullfile(TAinfo('dir'),'modules',...
                moduleDirs{k},'GUI','TA*window.m')));
            guiModuleWindowNames = [guiModuleWindowNames tmpNames(1,:)]; %#ok<AGROW>
        end
        guiFileNames = [ guiFileNames guiSubWindowNames(1,:) ...
            guiModuleWindowNames(1,:)];
    else
        guiFileNames = [ guiFileNames guiSubWindowNames(1,:)];
    end
    for k=1:length(guiFileNames)
        windowTags.(guiFileNames{k}(1:end-2)) = guiFileNames{k}(1:end-2);
    end
    
    % Define default tag
    defaultTag = windowTags.TAgui;
    
    if identifier
        if isfield(windowTags,identifier)
            handle = findobj('Tag',windowTags.(identifier));
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