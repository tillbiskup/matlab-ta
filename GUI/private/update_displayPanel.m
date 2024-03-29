function status = update_displayPanel()
% UPDATE_DISPLAYPANEL Helper function that updates the display panel
%   of the TA GUI, namely TA_gui_mainwindow.
%
%   STATUS: return value for the exit status
%           -1: no tEPR_gui_mainwindow found
%            0: successfully updated main axis

% Copyright (c) 2011-13, Till Biskup
% 2013-07-15

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

% Make life easier
active = ad.control.spectra.active;

% Toggle legend box display
set(gh.display_panel_legendbox_checkbox,'Value',ad.control.axis.legend.box);

% Toggle "Highlight active"
if isempty(ad.control.axis.highlight.method)
    set(gh.display_panel_highlight_checkbox,'Value',0);
    set(gh.display_panel_highlight2_checkbox,'Value',0);
    set(gh.mfe_highlight_checkbox,'Value',0);
else
    set(gh.display_panel_highlight_checkbox,'Value',1);
    set(gh.display_panel_highlight2_checkbox,'Value',1);
    set(gh.mfe_highlight_checkbox,'Value',1);
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

% Set zero line settings
% Set colour sample
set(gh.display_panel_zerolinecoloursample_text,'BackgroundColor',...
    ad.control.axis.grid.zero.color);

% Set line width
set(gh.display_panel_zerolinewidth_edit,'String',...
    num2str(ad.control.axis.grid.zero.width));

% Set line style
zeroLineStyles = {'-','--',':','-.','none'};
zeroLineStyle = ad.control.axis.grid.zero.style;
for k=1:length(zeroLineStyles)
    if strcmp(zeroLineStyles{k},zeroLineStyle)
        zeroLineStyleIndex = k;
    end
end
set(gh.display_panel_zerolinestyle_popupmenu,'Value',zeroLineStyleIndex);


% Set line settings
if active
    % Set colour sample
    set(gh.display_panel_linecoloursample_text,'BackgroundColor',...
        ad.data{active}.line.color);
    
    % Set line width
    set(gh.display_panel_linewidth_popupmenu,'Value',...
        ad.data{active}.line.width);

    % Set line style
    lineStyles = {'-','--',':','-.','none'};
    lineStyle = ad.data{active}.line.style;
    for k=1:length(lineStyles)
        if strcmp(lineStyles{k},lineStyle)
            lineStyleIndex = k;
        end
    end
    set(gh.display_panel_linestyle_popupmenu,'Value',lineStyleIndex);
    
    % Set line marker type
    lineMarkers = {'none','+','o','*','.','x','s','d','^','v','>','<','p','h'};
    lineMarker = ad.data{active}.line.marker.type;
    for k=1:length(lineMarkers)
        if strcmp(lineMarkers{k},lineMarker)
            lineMarkerIndex = k;
        end
    end
    set(gh.display_panel_linemarker_popupmenu,'Value',lineMarkerIndex);
    % Set line marker edge colour
    lineMarkerEdgeColor = ad.data{active}.line.marker.edgeColor;
    lineMarkerEdgeColorPopupmenuValues = ...
        cellstr(get(gh.display_panel_markeredgecolour_popupmenu,'String'));
    if ischar(lineMarkerEdgeColor) && length(lineMarkerEdgeColor)>1
        set(gh.display_panel_markeredgecolour_popupmenu,'Value',...
            find(strcmpi(lineMarkerEdgeColor,...
            lineMarkerEdgeColorPopupmenuValues)));
        switch lineMarkerEdgeColor
            case 'none'
                set(gh.display_panel_markeredgecoloursample_text,...
                    'BackgroundColor',get(mainWindow,'Color'))
            case 'auto'
                set(gh.display_panel_markeredgecoloursample_text,...
                    'BackgroundColor',ad.data{active}.line.color);
        end
    else
        set(gh.display_panel_markeredgecolour_popupmenu,'Value',...
            find(strcmpi('colour',lineMarkerEdgeColorPopupmenuValues)));
        set(gh.display_panel_markeredgecoloursample_text,...
            'BackgroundColor',ad.data{active}.line.marker.edgeColor);
    end
    % Set line marker face colour
    lineMarkerFaceColor = ad.data{active}.line.marker.faceColor;
    lineMarkerFaceColorPopupmenuValues = ...
        cellstr(get(gh.display_panel_markerfacecolour_popupmenu,'String'));
    if ischar(lineMarkerFaceColor) && length(lineMarkerFaceColor)>1
        set(gh.display_panel_markerfacecolour_popupmenu,'Value',...
            find(strcmpi(lineMarkerFaceColor,...
            lineMarkerFaceColorPopupmenuValues)));
        switch lineMarkerFaceColor
            case 'none'
                set(gh.display_panel_markerfacecoloursample_text,...
                    'BackgroundColor',get(mainWindow,'Color'))
            case 'auto'
                set(gh.display_panel_markerfacecoloursample_text,...
                    'BackgroundColor',get(gca,'Color'));
        end
    else
        set(gh.display_panel_markerfacecolour_popupmenu,'Value',...
            find(strcmpi('colour',lineMarkerFaceColorPopupmenuValues)));
        set(gh.display_panel_markerfacecoloursample_text,...
            'BackgroundColor',ad.data{active}.line.marker.faceColor);
    end
    % Set line marker size
    set(gh.display_panel_markersize_edit,'String',...
        num2str(ad.data{active}.line.marker.size));
end

% Set 3D export panel
if active
    [dimx,dimy] = size(ad.data{active}.data);
    set(gh.display_panel_3D_original_x_edit,'String',num2str(dimy));
    set(gh.display_panel_3D_original_y_edit,'String',num2str(dimx));
    set(gh.display_panel_3D_size_x_edit,'String',num2str(dimy));
    set(gh.display_panel_3D_size_y_edit,'String',num2str(dimx));
end

% Set threshold values
if active
    if ad.data{active}.display.threshold.min.enable
        set(gh.display_panel_threshold_min_edit,'Enable','On');
        set(gh.display_panel_threshold_min_checkbox,'Value',1);
    else
        set(gh.display_panel_threshold_min_edit,'Enable','Off');
        set(gh.display_panel_threshold_min_checkbox,'Value',0);
    end
    set(gh.display_panel_threshold_min_edit,'String',...
        num2str(ad.data{active}.display.threshold.min.value));
    if ad.data{active}.display.threshold.max.enable
        set(gh.display_panel_threshold_max_edit,'Enable','On');
        set(gh.display_panel_threshold_max_checkbox,'Value',1);
    else
        set(gh.display_panel_threshold_max_edit,'Enable','Off');
        set(gh.display_panel_threshold_max_checkbox,'Value',0);
    end
    set(gh.display_panel_threshold_max_edit,'String',...
        num2str(ad.data{active}.display.threshold.max.value));
end

% Set MFE panel

if ~active
    return;
end

% Define available line styles
lineStyles = {...
    'solid','-'; ...
    'dashed','--'; ...
    'dotted',':'; ...
    'dash-dotted','-.'; ...
    'none','none' ...
    };

% Define available line marker
lineMarker = {...
    'none','none'; ...
    'plus','+'; ...
    'circle','o'; ...
    'asterisk','*'; ...
    'point','.'; ...
    'cross','x'; ...
    'square','s'; ...
    'diamond','d'; ...
    'triangle up','^'; ...
    'triangle down','v'; ...
    'triangle right','<'; ...
    'triangle left','>'; ...
    'pentagram','p'; ...
    'hexagram','h' ...
    };

% Get line type currently selected (MFoff/MFon/DeltaMF)
MFElines = cellstr(get(gh.mfe_line_popupmenu,'String'));
MFEline = MFElines{get(gh.mfe_line_popupmenu,'Value')};

% Get values of line style popupmenu
lineStyleValues = cellstr(get(gh.mfe_linestyle_popupmenu,'String'));

% Get values of line marker popupmenu
lineMarkerValues = cellstr(get(gh.mfe_linemarker_popupmenu,'String'));

switch MFEline
    case 'MFoff'
        % Set colour sample
        set(gh.mfe_coloursample_text,'BackgroundColor',...
            ad.data{active}.line.color);
        % Set line width
        set(gh.mfe_linewidth_popupmenu,'Value',...
            ad.data{active}.line.width);
        % Set line style
        set(gh.mfe_linestyle_popupmenu,'Value',...
            find(strcmpi(lineStyles{strcmpi(ad.data{active}.line.style,...
            lineStyles(:,2)),1},lineStyleValues)));
        % Set line marker type
        set(gh.mfe_linemarker_popupmenu,'Value',...
            find(strcmpi(lineMarker{strcmpi(ad.data{active}.line.marker.type,...
            lineMarker(:,2)),1},lineMarkerValues)));
        % Set line marker edge colour
        lineMarkerEdgeColor = ad.data{active}.line.marker.edgeColor;
        lineMarkerEdgeColorPopupmenuValues = ...
            cellstr(get(gh.mfe_markeredgecolour_popupmenu,'String'));
        if ischar(lineMarkerEdgeColor) && length(lineMarkerEdgeColor)>1
            set(gh.mfe_markeredgecolour_popupmenu,'Value',...
                find(strcmpi(lineMarkerEdgeColor,...
                lineMarkerEdgeColorPopupmenuValues)));
            switch lineMarkerEdgeColor
                case 'none'
                    set(gh.mfe_markeredgecoloursample_text,...
                        'BackgroundColor',get(mainWindow,'Color'))
                case 'auto'
                    set(gh.mfe_markeredgecoloursample_text,...
                        'BackgroundColor',ad.data{active}.line.color);
            end
        else
            set(gh.mfe_markeredgecolour_popupmenu,'Value',...
                find(strcmpi('colour',lineMarkerEdgeColorPopupmenuValues)));
            set(gh.mfe_markeredgecoloursample_text,...
                'BackgroundColor',ad.data{active}.line.marker.edgeColor);
        end
        % Set line marker face colour
        lineMarkerFaceColor = ad.data{active}.line.marker.faceColor;
        lineMarkerFaceColorPopupmenuValues = ...
            cellstr(get(gh.mfe_markerfacecolour_popupmenu,'String'));
        if ischar(lineMarkerFaceColor) && length(lineMarkerFaceColor)>1
            set(gh.mfe_markerfacecolour_popupmenu,'Value',...
                find(strcmpi(lineMarkerFaceColor,...
                lineMarkerFaceColorPopupmenuValues)));
            switch lineMarkerFaceColor
                case 'none'
                    set(gh.mfe_markerfacecoloursample_text,...
                        'BackgroundColor',get(mainWindow,'Color'))
                case 'auto'
                    set(gh.mfe_markerfacecoloursample_text,...
                        'BackgroundColor',get(gca,'Color'));
            end
        else
            set(gh.mfe_markerfacecolour_popupmenu,'Value',...
                find(strcmpi('colour',lineMarkerFaceColorPopupmenuValues)));
            set(gh.mfe_markerfacecoloursample_text,...
                'BackgroundColor',ad.data{active}.line.marker.faceColor);
        end
        % Set line marker size
        set(gh.mfe_markersize_edit,'String',...
            num2str(ad.data{active}.line.marker.size));
    case 'MFon'
        % Set colour sample
        set(gh.mfe_coloursample_text,'BackgroundColor',...
            ad.data{active}.display.MFon.line.color)
        % Set line width
        set(gh.mfe_linewidth_popupmenu,'Value',...
            ad.data{active}.display.MFon.line.width);
        % Set line style
        set(gh.mfe_linestyle_popupmenu,'Value',...
            find(strcmpi(lineStyles{...
            strcmpi(ad.data{active}.display.MFon.line.style,...
            lineStyles(:,2)),1},lineStyleValues)));
        % Set line marker type
        set(gh.mfe_linemarker_popupmenu,'Value',...
            find(strcmpi(lineMarker{...
            strcmpi(ad.data{active}.display.MFon.line.marker.type,...
            lineMarker(:,2)),1},lineMarkerValues)));
        % Set line marker edge colour
        lineMarkerEdgeColor = ...
            ad.data{active}.display.MFon.line.marker.edgeColor;
        lineMarkerEdgeColorPopupmenuValues = ...
            cellstr(get(gh.mfe_markeredgecolour_popupmenu,'String'));
        if ischar(lineMarkerEdgeColor) && length(lineMarkerEdgeColor)>1
            set(gh.mfe_markeredgecolour_popupmenu,'Value',...
                find(strcmpi(lineMarkerEdgeColor,...
                lineMarkerEdgeColorPopupmenuValues)));
            switch lineMarkerEdgeColor
                case 'none'
                    set(gh.mfe_markeredgecoloursample_text,...
                        'BackgroundColor',get(mainWindow,'Color'))
                case 'auto'
                    set(gh.mfe_markeredgecoloursample_text,...
                        'BackgroundColor',...
                        ad.data{active}.display.MFon.line.color);
            end
        else
            set(gh.mfe_markeredgecolour_popupmenu,'Value',...
                find(strcmpi('colour',lineMarkerEdgeColorPopupmenuValues)));
            set(gh.mfe_markeredgecoloursample_text,...
                'BackgroundColor',...
                ad.data{active}.display.MFon.line.marker.edgeColor);
        end
        % Set line marker face colour
        lineMarkerFaceColor = ad.data{active}.display.MFon.line.marker.faceColor;
        lineMarkerFaceColorPopupmenuValues = ...
            cellstr(get(gh.mfe_markerfacecolour_popupmenu,'String'));
        if ischar(lineMarkerFaceColor) && length(lineMarkerFaceColor)>1
            set(gh.mfe_markerfacecolour_popupmenu,'Value',...
                find(strcmpi(lineMarkerFaceColor,...
                lineMarkerFaceColorPopupmenuValues)));
            switch lineMarkerFaceColor
                case 'none'
                    set(gh.mfe_markerfacecoloursample_text,...
                        'BackgroundColor',get(mainWindow,'Color'))
                case 'auto'
                    set(gh.mfe_markerfacecoloursample_text,...
                        'BackgroundColor',get(gca,'Color'));
            end
        else
            set(gh.mfe_markerfacecolour_popupmenu,'Value',...
                find(strcmpi('colour',lineMarkerFaceColorPopupmenuValues)));
            set(gh.mfe_markerfacecoloursample_text,...
                'BackgroundColor',...
                ad.data{active}.display.MFon.line.marker.faceColor);
        end
        % Set line marker size
        set(gh.mfe_markersize_edit,'String',...
            num2str(ad.data{active}.display.MFon.line.marker.size));
    case 'DeltaMF'
        % Set colour sample
        set(gh.mfe_coloursample_text,'BackgroundColor',...
            ad.data{active}.display.DeltaMF.line.color)
        % Set line width
        set(gh.mfe_linewidth_popupmenu,'Value',...
            ad.data{active}.display.DeltaMF.line.width);
        % Set line style
        set(gh.mfe_linestyle_popupmenu,'Value',...
            find(strcmpi(lineStyles{strcmpi(...
            ad.data{active}.display.DeltaMF.line.style,...
            lineStyles(:,2)),1},lineStyleValues)));
        % Set line marker type
        set(gh.mfe_linemarker_popupmenu,'Value',...
            find(strcmpi(lineMarker{...
            strcmpi(ad.data{active}.display.DeltaMF.line.marker.type,...
            lineMarker(:,2)),1},lineMarkerValues)));
        % Set line marker edge colour
        lineMarkerEdgeColor = ...
            ad.data{active}.display.DeltaMF.line.marker.edgeColor;
        lineMarkerEdgeColorPopupmenuValues = ...
            cellstr(get(gh.mfe_markeredgecolour_popupmenu,'String'));
        if ischar(lineMarkerEdgeColor) && length(lineMarkerEdgeColor)>1
            set(gh.mfe_markeredgecolour_popupmenu,'Value',...
                find(strcmpi(lineMarkerEdgeColor,...
                lineMarkerEdgeColorPopupmenuValues)));
            switch lineMarkerEdgeColor
                case 'none'
                    set(gh.mfe_markeredgecoloursample_text,...
                        'BackgroundColor',get(mainWindow,'Color'))
                case 'auto'
                    set(gh.mfe_markeredgecoloursample_text,...
                        'BackgroundColor',...
                        ad.data{active}.display.DeltaMF.line.color);
            end
        else
            set(gh.mfe_markeredgecolour_popupmenu,'Value',...
                find(strcmpi('colour',lineMarkerEdgeColorPopupmenuValues)));
            set(gh.mfe_markeredgecoloursample_text,...
                'BackgroundColor',...
                ad.data{active}.display.DeltaMF.line.marker.edgeColor);
        end
        % Set line marker face colour
        lineMarkerFaceColor = ...
            ad.data{active}.display.DeltaMF.line.marker.faceColor;
        lineMarkerFaceColorPopupmenuValues = ...
            cellstr(get(gh.mfe_markerfacecolour_popupmenu,'String'));
        if ischar(lineMarkerFaceColor) && length(lineMarkerFaceColor)>1
            set(gh.mfe_markerfacecolour_popupmenu,'Value',...
                find(strcmpi(lineMarkerFaceColor,...
                lineMarkerFaceColorPopupmenuValues)));
            switch lineMarkerFaceColor
                case 'none'
                    set(gh.mfe_markerfacecoloursample_text,...
                        'BackgroundColor',get(mainWindow,'Color'))
                case 'auto'
                    set(gh.mfe_markerfacecoloursample_text,...
                        'BackgroundColor',get(gca,'Color'));
            end
        else
            set(gh.mfe_markerfacecolour_popupmenu,'Value',...
                find(strcmpi('colour',lineMarkerFaceColorPopupmenuValues)));
            set(gh.mfe_markerfacecoloursample_text,...
                'BackgroundColor',...
                ad.data{active}.display.DeltaMF.line.marker.faceColor);
        end
        % Set line marker size
        set(gh.mfe_markersize_edit,'String',...
            num2str(ad.data{active}.display.DeltaMF.line.marker.size));
    otherwise
        disp(['TAgui : update_MFEPanel() : Unknown MFElineType '...
            '"' MFEline '"']);
end        


status = 0;

end
