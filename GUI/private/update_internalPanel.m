function status = update_internalPanel()
% UPDATE_INTERNALPANEL Helper function that updates the internal panel
%   of the TA GUI, namely TA_gui_mainwindow.
%
%   STATUS: return value for the exit status
%           -1: no tEPR_gui_mainwindow found
%            0: successfully updated main axis

% Copyright (c) 2013, Till Biskup
% 2013-07-15

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

% Messages/log level
% Set display/debug popupmenus
displayValues = cellstr(...
    get(gh.internal_panel_messaging_display_popupmenu,'String'));
debugValues = cellstr(...
    get(gh.internal_panel_messaging_debug_popupmenu,'String'));
set(gh.internal_panel_messaging_display_popupmenu,'Value',...
    find(strcmpi(displayValues,ad.control.messages.display.level)));
set(gh.internal_panel_messaging_debug_popupmenu,'Value',...
    find(strcmpi(debugValues,ad.control.messages.debug.level)));

% Cmd
% Set save history checkbox
set(gh.internal_panel_cmd_savehistory_checkbox,...
    'Value',ad.control.cmd.historysave);

status = 0;

end
