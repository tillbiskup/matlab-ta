function guiZoom(action)
% GUIZOOM Private function to handle displacing of datasets
%
% Arguments:
%     action    - string
%                 Action to be performed: on|off|reset

% (c) 2013, Till Biskup
% 2013-07-12

try
    % Get appdata of main window
    mainWindow = TAguiGetWindowHandle();
    ad = getappdata(mainWindow);
    % Get guihandles of main window
    gh = guihandles(mainWindow);
    
    % Somehow, MATLAB(TM) seems inapt to save the main Axis handle to gh
    mainAxis = ad.UsedByGUIData_m.mainAxis;
    
    % Set position for dataset
    switch lower(action)
        case 'on'
            set(gh.zoom_togglebutton,'Value',1);
            zh = zoom(mainWindow);
            % set(zh,'UIContextMenu',handles.axisToolsContextMenu);
            set(zh,'Enable','on');
            set(zh,'Motion','both');
            set(zh,'Direction','in');
            ad.control.axis.zoom.enable = true;
        case 'off'
            set(gh.zoom_togglebutton,'Value',0);
            zh = zoom(mainWindow);
            set(zh,'Enable','off');
            refresh;
            % Get current x and y limits of main axis
            currentXLim = get(mainAxis,'XLim');
            currentYLim = get(mainAxis,'YLim');
            switch lower(ad.control.axis.displayType)
                case '2d plot'
                    setXLim = [ ad.control.axis.limits.x.min ...
                        ad.control.axis.limits.x.max];
                    setYLim = [ ad.control.axis.limits.y.min ...
                        ad.control.axis.limits.y.max];
                    ad.control.axis.zoom.x = get(mainAxis,'XLim');
                    ad.control.axis.zoom.y = get(mainAxis,'YLim');
                case '1d along x'
                    setXLim = [ ad.control.axis.limits.x.min ...
                        ad.control.axis.limits.x.max];
                    setYLim = [ ad.control.axis.limits.z.min ...
                        ad.control.axis.limits.z.max];
                    ad.control.axis.zoom.x = get(mainAxis,'XLim');
                    ad.control.axis.zoom.z = get(mainAxis,'YLim');
                case '1d along y'
                    setXLim = [ ad.control.axis.limits.y.min ...
                        ad.control.axis.limits.y.max];
                    setYLim = [ ad.control.axis.limits.z.min ...
                        ad.control.axis.limits.z.max];
                    ad.control.axis.zoom.y = get(mainAxis,'XLim');
                    ad.control.axis.zoom.z = get(mainAxis,'YLim');
            end
            if all(currentXLim == setXLim) && all(currentYLim == setYLim)
                ad.control.axis.zoom.enable = false;
                ad.control.axis.zoom.x = [0 0];
                ad.control.axis.zoom.y = [0 0];
                ad.control.axis.zoom.z = [0 0];
            else
                ad.control.axis.zoom.enable = true;
            end
        case 'reset'
            set(gh.zoom_togglebutton,'Value',0);
            zh = zoom(mainWindow);
            set(zh,'Enable','off');
            
            ad.control.axis.zoom.enable = false;
            ad.control.axis.zoom.x = [0 0];
            ad.control.axis.zoom.y = [0 0];
            ad.control.axis.zoom.z = [0 0];
            setappdata(mainWindow,'control',ad.control);
            
            %Update main axis
            update_mainAxis();
    end
    setappdata(mainWindow,'control',ad.control);
catch exception
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