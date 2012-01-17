function status = update_displayPanel()
% UPDATE_DISPLAYPANEL Helper function that updates the display panel
%   of the TA GUI, namely TA_gui_mainwindow.
%
%   STATUS: return value for the exit status
%           -1: no tEPR_gui_mainwindow found
%            0: successfully updated main axis

% (c) 2011-12, Till Biskup
% 2012-01-17

% Is there currently a TAgui object?
mainWindow = guiGetWindowHandle;
if (isempty(mainWindow))
    status = -1;
    return;
end

% Get handles from main window
gh = guidata(mainWindow);

% Get appdata from main GUI
ad = getappdata(mainWindow);

% Toggle "Highlight active"
if isempty(ad.control.axis.highlight.method)
    set(gh.display_panel_highlight_checkbox,'Value',0);
else
    set(gh.display_panel_highlight_checkbox,'Value',1);
end

% Set axis labels fields
set(gh.display_panel_axislabels_x_measure_edit,'String',...
    ad.control.axis.labels.x.measure);
set(gh.display_panel_axislabels_x_unit_edit,'String',...
    ad.control.axis.labels.x.unit);
set(gh.display_panel_axislabels_y_measure_edit,'String',...
    ad.control.axis.labels.y.measure);
set(gh.display_panel_axislabels_y_unit_edit,'String',...
    ad.control.axis.labels.y.unit);
set(gh.display_panel_axislabels_z_measure_edit,'String',...
    ad.control.axis.labels.z.measure);
set(gh.display_panel_axislabels_z_unit_edit,'String',...
    ad.control.axis.labels.z.unit);

% Toggle state of "get axislabels from current dataset"
if (ad.control.spectra.active)
    set(...
        gh.display_panel_axislabels_getfromactivedataset_pushbutton,...
        'Enable','on'...
        );
else
    set(...
        gh.display_panel_axislabels_getfromactivedataset_pushbutton,...
        'Enable','off'...
        );
end

% Set axis limits fields
set(gh.display_panel_axislimits_x_min_edit,'String',...
    num2str(ad.control.axis.limits.x.min));
set(gh.display_panel_axislimits_x_max_edit,'String',...
    num2str(ad.control.axis.limits.x.max));
set(gh.display_panel_axislimits_y_min_edit,'String',...
    num2str(ad.control.axis.limits.y.min));
set(gh.display_panel_axislimits_y_max_edit,'String',...
    num2str(ad.control.axis.limits.y.max));
set(gh.display_panel_axislimits_z_min_edit,'String',...
    num2str(ad.control.axis.limits.z.min));
set(gh.display_panel_axislimits_z_max_edit,'String',...
    num2str(ad.control.axis.limits.z.max));

% Toggle state of axislimits edit fields according to "automatic"
editHandles = findobj(...
    'Parent',gh.display_panel_axislimits_panel,'Style','edit');
if (get(gh.display_panel_axislimits_auto_checkbox,'Value'))
    set(editHandles,'Enable','Off');
else
    set(editHandles,'Enable','On');
end

% Set line settings
if ad.control.spectra.active
    % Set line colour
    if ischar(ad.data{ad.control.spectra.active}.line.color)
        set(gh.display_panel_colour_type2_popupmenu,...
            'Value',strfind('bgrcmyk',...
            ad.data{ad.control.spectra.active}.line.color));
    end
    
    % Set line width
    set(gh.display_panel_linewidth_popupmenu,'Value',...
        ad.data{ad.control.spectra.active}.line.width);

    % Set line style
    lineStyles = {'-','--',':','-.','none'};
    lineStyle = ad.data{ad.control.spectra.active}.line.style;
    for k=1:length(lineStyles)
        if strcmp(lineStyles{k},lineStyle)
            lineStyleIndex = k;
        end
    end
    set(gh.display_panel_linestyle_popupmenu,'Value',lineStyleIndex);
    
    % Set line marker
    lineMarkers = {'none','+','o','*','.','x','s','d','^','v','>','<','p','h'};
    lineMarker = ad.data{ad.control.spectra.active}.line.marker;
    for k=1:length(lineMarkers)
        if strcmp(lineMarkers{k},lineMarker)
            lineMarkerIndex = k;
        end
    end
    set(gh.display_panel_linemarker_popupmenu,'Value',lineMarkerIndex);
end

% Set 3D export panel
if ad.control.spectra.active
    [dimx,dimy] = size(ad.data{ad.control.spectra.active}.data);
    set(gh.display_panel_3D_original_x_edit,'String',num2str(dimy));
    set(gh.display_panel_3D_original_y_edit,'String',num2str(dimx));
    set(gh.display_panel_3D_size_x_edit,'String',num2str(dimy));
    set(gh.display_panel_3D_size_y_edit,'String',num2str(dimx));
end

% Set threshold values
if ad.control.spectra.active
    if ad.data{ad.control.spectra.active}.display.threshold.min.enable
        set(gh.display_panel_threshold_min_edit,'Enable','On');
        set(gh.display_panel_threshold_min_checkbox,'Value',1);
    else
        set(gh.display_panel_threshold_min_edit,'Enable','Off');
        set(gh.display_panel_threshold_min_checkbox,'Value',0);
    end
    set(gh.display_panel_threshold_min_edit,'String',...
        num2str(ad.data{ad.control.spectra.active}.display.threshold.min.value));
    if ad.data{ad.control.spectra.active}.display.threshold.max.enable
        set(gh.display_panel_threshold_max_edit,'Enable','On');
        set(gh.display_panel_threshold_max_checkbox,'Value',1);
    else
        set(gh.display_panel_threshold_max_edit,'Enable','Off');
        set(gh.display_panel_threshold_max_checkbox,'Value',0);
    end
    set(gh.display_panel_threshold_max_edit,'String',...
        num2str(ad.data{ad.control.spectra.active}.display.threshold.max.value));
end


status = 0;

end