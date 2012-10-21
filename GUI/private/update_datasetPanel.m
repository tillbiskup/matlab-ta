function status = update_datasetPanel()
% UPDATE_DATASETPANEL Helper function that updates the display panel
%   of the TA GUI, namely TA_gui_mainwindow.
%
%   STATUS: return value for the exit status
%           -1: no tEPR_gui_mainwindow found
%            0: successfully updated main axis

% (c) 2011-12, Till Biskup
% 2012-10-21

% Is there currently a TAgui object?
mainWindow = TAguiGetWindowHandle();
if (isempty(mainWindow))
    status = -1;
    return;
end

% Get handles from main window
gh = guidata(mainWindow);

% Get appdata from main GUI
ad = getappdata(mainWindow);

% Update display type popupmenu
% displayTypes = cellstr(get(gh.data_panel_displaytype_popupmenu,'String'));
% for k=1:length(displayTypes)
%     if strcmp(displayTypes(k),ad.control.axis.displayType)
%         set(gh.data_panel_displaytype_popupmenu,'Value',k)
%     end
% end

update_visibleSpectra();
update_invisibleSpectra();

status = 0;

end