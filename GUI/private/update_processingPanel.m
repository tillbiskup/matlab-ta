function status = update_processingPanel()
% UPDATE_PROCESSINGPANEL Helper function that updates the processing panel
%   of the TA GUI, namely TA_gui_mainwindow.
%
%   STATUS: return value for the exit status
%           -1: no tEPR_gui_mainwindow found
%            0: successfully updated main axis

% (c) 2011-12, Till Biskup
% 2012-10-21

% Is there currently a TAgui object?
mainWindow = TAguiGetWindowHandle;
if (isempty(mainWindow))
    status = -1;
    return;
end

% Get handles from main window
gh = guidata(mainWindow);

% Get appdata from main GUI
ad = getappdata(mainWindow);


% Get appdata of main window
mainWindow = TAguiGetWindowHandle;
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

% Update scaling edit field
if isnan(str2double(get(gh.processing_panel_scaling_edit,'String')))
    set(gh.processing_panel_scaling_edit,'String','1');
end

% Update primary and secondary spectra listboxes
% Get indices of visible spectra
vis = ad.control.spectra.visible;
% Get names for display in listbox
labels = cell(0);
for k=1:length(vis)
    if (find(vis(k)==ad.control.spectra.modified))
        labels{k} = ['*' ad.data{vis(k)}.label];
    else
        labels{k} = ad.data{vis(k)}.label;
    end
end
primaryLbox = gh.processing_panel_primary_listbox;
secondaryLbox = gh.processing_panel_secondary_listbox;
set(primaryLbox,'String',labels);
set(secondaryLbox,'String',labels);
% Update selected
if (get(primaryLbox,'Value')>length(vis))
    set(primaryLbox,'Value',length(vis));
end
if get(primaryLbox,'Value')==0
    set(primaryLbox,'Value',1);
end
if (get(secondaryLbox,'Value')>length(vis))
    set(secondaryLbox,'Value',length(vis));
end
if get(secondaryLbox,'Value')==0
    set(secondaryLbox,'Value',1);
end

status = 0;

end