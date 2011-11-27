function status = update_processingPanel()
% UPDATE_PROCESSINGPANEL Helper function that updates the processing panel
%   of the trEPR GUI, namely trEPR_gui_mainwindow.
%
%   STATUS: return value for the exit status
%           -1: no tEPR_gui_mainwindow found
%            0: successfully updated main axis

% (c) 2011, Till Biskup
% 2011-11-27

% Is there currently a trEPRgui object?
mainWindow = guiGetWindowHandle;
if (isempty(mainWindow))
    status = -1;
    return;
end

% Get handles from main window
gh = guidata(mainWindow);

% Get appdata from main GUI
ad = getappdata(mainWindow);


% Get appdata of main window
mainWindow = guiGetWindowHandle;
ad = getappdata(mainWindow);

if isempty(ad.control.spectra.active) || (ad.control.spectra.active == 0)
    set(findobj(allchild(gh.processing_panel),'-not','type','uipanel'),'Enable','Inactive');
    return;
else
    set(findobj(allchild(gh.processing_panel),'-not','type','uipanel'),'Enable','On');
end

% Update x points display
set(gh.processing_panel_average_x_points_edit,...
    'String',...
    num2str(ad.data{ad.control.spectra.active}.display.smoothing.x.value)...
    );

% Update x unit display
[x,y] = size(ad.data{ad.control.spectra.active}.data);
x = linspace(1,x,x);
y = linspace(1,y,y);
if (isfield(ad.data{ad.control.spectra.active},'axes') ...
        && isfield(ad.data{ad.control.spectra.active}.axes,'x') ...
        && isfield(ad.data{ad.control.spectra.active}.axes.x,'values') ...
        && not (isempty(ad.data{ad.control.spectra.active}.axes.x.values)))
    x = ad.data{ad.control.spectra.active}.axes.x.values;
end
% In case that we loaded 1D data...
if isscalar(x)
    x = [x x+1];
end
if isscalar(y)
    y = [y y+1];
end
set(gh.processing_panel_average_x_unit_edit,...
    'String',...
    num2str((x(2)-x(1))*str2num(get(gh.processing_panel_average_x_points_edit,'String')))...
    );

% Update y points display
set(gh.processing_panel_average_y_points_edit,...
    'String',...
    num2str(ad.data{ad.control.spectra.active}.display.smoothing.y.value)...
    );

% Update y unit display accordingly
[x,y] = size(ad.data{ad.control.spectra.active}.data);
x = linspace(1,x,x);
y = linspace(1,y,y);
% In case that we loaded 1D data...
if (isfield(ad.data{ad.control.spectra.active},'axes') ...
        && isfield(ad.data{ad.control.spectra.active}.axes,'y') ...
        && isfield(ad.data{ad.control.spectra.active}.axes.y,'values') ...
        && not (isempty(ad.data{ad.control.spectra.active}.axes.y.values)))
    y = ad.data{ad.control.spectra.active}.axes.y.values;
end
if isscalar(x)
    x = [x x+1];
end
if isscalar(y)
    y = [y y+1];
end
set(gh.processing_panel_average_y_unit_edit,...
    'String',...
    num2str((y(2)-y(1))*str2num(get(gh.processing_panel_average_y_points_edit,'String'))));


status = 0;

end