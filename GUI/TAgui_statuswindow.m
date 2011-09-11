function varargout = TAgui_statuswindow(varargin)
% TAGUI_STATUSWINDOW Brief description of GUI.
%                    Comments displayed at the command line in response 
%                    to the help command. 

% (c) 2011, Till Biskup
% 2011-09-11

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make GUI effectively a singleton
singleton = findobj('Tag','TA_gui_statuswindow');
if (singleton)
    figure(singleton);
    return;
end

%  Construct the components
hMainFigure = figure('Tag','TA_gui_statuswindow',...
    'Visible','off',...
    'Name','TA GUI : Status Window',...
    'Units','Pixels',...
    'Position',[30,50,950,250],...
    'Resize','off',...
    'NumberTitle','off', ...
    'Menu','none','Toolbar','none',...
    'KeyPressFcn',@keyBindings,...
    'CloseRequestFcn',@closeGUI);

defaultBackground = get(hMainFigure,'Color');
guiSize = get(hMainFigure,'Position');
guiSize = guiSize([3,4]);

% Create the message window
textdisplay = uicontrol('Tag','status_text',...
    'Style','edit',...
    'Parent',hMainFigure,...
    'BackgroundColor',[1 1 1],...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'Position',[10 10 guiSize(1)-20 guiSize(2)-20],...
    'Enable','inactive',...
    'Max',2,'Min',0,...
    'FontName','FixedWidth',...
    'String','');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Store handles in guidata
guidata(hMainFigure,guihandles);

% Make the GUI visible.
set(hMainFigure,'Visible','on');

% Set string
mainGuiWindow = guiGetWindowHandle;
if (mainGuiWindow)
    ad = getappdata(mainGuiWindow);
    % Check for availability of necessary fields in appdata
    if (isfield(ad,'control') ~= 0) && (isfield(ad.control,'status') ~= 0)
        statusstring = ad.control.status;
    end
else
    statusstring = {...
        '  1: There seems to be no TA GUI main window...',...
        };
end
update_statuswindow(statusstring);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function closeGUI(~,~)
    try
        delete(hMainFigure);
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
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

function keyBindings(src,evt)
    try
    if ~isempty(evt.Modifier)
        if (strcmpi(evt.Modifier{1},'command')) || ...
                (strcmpi(evt.Modifier{1},'control'))
            switch evt.Key
                case 'w'
                    closeGUI();
                    return;
                otherwise
                    return;
            end
        end
    end
    switch evt.Key
        case 'f1'
            return;
        otherwise
%             disp(evt);
%             fprintf('       Caller: %i\n\n',src);
            return;
    end
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
