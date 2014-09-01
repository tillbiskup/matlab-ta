function status = update_visibleSpectra()
% UPDATE_VISIBLESPECTRA Helper function that updates the panels 
%   of the TA GUI, namely TA_gui_mainwindow, that list the
%   loaded and currently visible spectra.
%
%   At the same time, it updates the list of visible spectra in other
%   panels.
%
%   STATUS: return value for the exit status
%           -1: no tEPR_gui_mainwindow found
%            0: successfully updated panels listing the spectra

% Copyright (c) 2011-12, Till Biskup
% 2012-10-21

% Is there currently a TAgui object?
mainWindow = TAguiGetWindowHandle;
if (isempty(mainWindow))
    status = -1;
    return;
end

% Get handle for visible spectra listbox
gh = guidata(mainWindow);
visLbox = gh.data_panel_visible_listbox;

% Get appdata from main GUI
ad = getappdata(mainWindow);

% Get indices of visible spectra
vis = ad.control.spectra.visible;

if ~isempty(vis) && (isempty(ad.control.spectra.active) ...
        || ~ad.control.spectra.active)
    ad.control.spectra.active = vis(1);
    setappdata(mainWindow,'control',ad.control)
end

% Get names for display in listbox
labels = cell(0);
for k=1:length(vis)
    if (find(vis(k)==ad.control.spectra.modified))
        labels{k} = ['*' ad.data{vis(k)}.label];
    else
        labels{k} = ad.data{vis(k)}.label;
    end
end

% Update status display
set(visLbox,'String',labels);
if (get(visLbox,'Value')>length(vis))
    set(visLbox,'Value',length(vis));
end
if get(visLbox,'Value')==0
    set(visLbox,'Value',1);
end

% Highlight currently active
if ad.control.spectra.active
    set(visLbox,'Value',find(vis==ad.control.spectra.active));
end

% Change enable status of pushbuttons and other elements
multiplePanelChildren = findobj(...
    'Parent',gh.data_panel_multiple_panel,'-not','Style','Listbox');
if isempty(ad.data)
    set(multiplePanelChildren,'Enable','off');
else
    if (length(ad.data) > 1)
        set(multiplePanelChildren,'Enable','on');
    else
        set(multiplePanelChildren,'Enable','off');
    end
end

currActiveButtons = findobj('Parent',gh.data_panel_currentlyactive_panel);
if isempty(ad.control.spectra.visible)
    set(gh.data_panel_hide_pushbutton,'Enable','off');
    set(gh.data_panel_hideall_pushbutton,'Enable','off');
    set(currActiveButtons,'Enable','off');
    set(gh.processing_panel_datasets_listbox,'Enable','off');
    set(gh.display_panel_datasets_listbox,'Enable','off');
    set(gh.data_panel_visible_listbox,'Enable','off');
    set(gh.displaytype_popupmenu,'Enable','off');
    set(gh.previous_pushbutton,'Enable','off');
    set(gh.next_pushbutton,'Enable','off');
else
    set(gh.data_panel_hide_pushbutton,'Enable','on');
    set(gh.data_panel_hideall_pushbutton,'Enable','on');
    set(currActiveButtons,'Enable','on');
    set(gh.data_panel_visible_listbox,'Enable','on');
    set(gh.processing_panel_datasets_listbox,'Enable','on');
    set(gh.display_panel_datasets_listbox,'Enable','on');
    set(gh.data_panel_visible_listbox,'Enable','on');
    set(gh.displaytype_popupmenu,'Enable','on');
    set(gh.previous_pushbutton,'Enable','on');
    set(gh.next_pushbutton,'Enable','on');

    % Make "Save" button active only if currently active spectrum is
    % modified
    if (find(ad.control.spectra.modified==ad.control.spectra.active))
        set(gh.data_panel_save_pushbutton,'Enable','On');
    else
        set(gh.data_panel_save_pushbutton,'Enable','Off');
    end
    
    % Set displayType in ad.control.axis
    if isempty(ad.control.axis.displayType)
        displayTypes = cellstr(get(gh.displaytype_popupmenu,'String'));
        displayType = displayTypes{get(gh.displaytype_popupmenu,'Value')};
        ad.control.axis.displayType = displayType;
        % Update appdata of main window
        setappdata(mainWindow,'control',ad.control);
    end
end

% Update list of spectra of the processing panel
procPLbox = gh.processing_panel_datasets_listbox;
set(procPLbox,'String',labels);
procPLbox2 = gh.processing_panel_datasets2_listbox;
set(procPLbox2,'String',labels);

% Highlight currently active
if ad.control.spectra.active
    set(procPLbox,'Value',find(vis==ad.control.spectra.active));
    set(procPLbox2,'Value',find(vis==ad.control.spectra.active));
end

% Update list of spectra of the display panel
dispPLbox = gh.display_panel_datasets_listbox;
set(dispPLbox,'String',labels);

% Highlight currently active
if ad.control.spectra.active
    set(dispPLbox,'Value',find(vis==ad.control.spectra.active));
end


status = 0;

end
