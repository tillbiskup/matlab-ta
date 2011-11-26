function status = switchDisplayType(displayType)
% SWITCHDISPLAYTYPE Private function to switch between panels of the main GUI
%
% displayType - string with the name of the display type
%
% status      - return value of the function. Either 0 (OK) or -1 (failed)

% (c) 2011, Till Biskup
% 2011-10-30

try
    % Get appdata and handles of main window
    mainWindow = guiGetWindowHandle;
    ad = getappdata(mainWindow);
    gh = guihandles(mainWindow);
    
    if strcmpi(get(gh.displaytype_popupmenu,'Enable'),'Off')
        % The display type menu is disabled, meaning that there is no data
        % displayed currently and therefore no need to switch something.
        return;
    end
   
    switch displayType
        case '2D plot'
            set(gh.displaytype_popupmenu,'String','2D plot');
            ad.control.axis.displayType = displayType;
        case '1D along x'
            set(gh.displaytype_popupmenu,'String','1D along x');
            ad.control.axis.displayType = displayType;
        case '1D along y'
            set(gh.displaytype_popupmenu,'String','1D along y');
            ad.control.axis.displayType = displayType;
        otherwise
            % That shall never happen...
            msg = 'switchDisplayType(): Unknown display type';
            add2status(msg);
            return;
    end
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);
    
    update_mainAxis();
    
    status = 0;
catch exception
    try
        trEPRgui_bugreportwindow(exception);
    catch exception2
        % If even displaying the bug report window fails, what lasts to do?
        exception = addCause(exception2, exception);
        throw(exception);
    end
    status = -1;
end

end