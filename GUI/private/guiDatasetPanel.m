function handle = guiDatasetPanel(parentHandle,position)
% GUIDATASETPANEL Add a panel for dataset control to a gui
%       Should only be called from within a GUI defining function.
%
%       Arguments: parent Handle and position vector.
%       TODO: Add guidata and appdata to list of arguments
%
%       Returns the handle of the added panel.

% (Leave a blank line following the help.)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

defaultBackground = get(parentHandle,'Color');

handle = uipanel('Tag','data_panel',...
    'parent',parentHandle,...
    'Title','Dataset display',...
    'FontUnit','Pixel','Fontsize',12,...
    'FontWeight','bold',...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'Units','pixels','Position',position);

% Create the "Dataset display" panel
panel_size = get(handle,'Position');
uicontrol('Tag','data_panel_description',...
    'Style','text',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 panel_size(4)-60 panel_size(3)-20 30],...
    'String',{'Choose the datasets to be displayed in the main axes (on the left)'}...
    );

handle_p1 = uipanel('Tag','data_panel_invisible_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 panel_size(4)-170 panel_size(3)-20 100],...
    'Title','Invisible datasets'...
    );
uicontrol('Tag','data_panel_invisible_listbox',...
    'Style','listbox',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 panel_size(3)-40 70],...
    'String','',...
    'Callback',{@invisible_listbox_Callback}...
    );

handle_p2 = uipanel('Tag','data_panel_visible_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 panel_size(4)-315 panel_size(3)-20 100],...
    'Title','Visible datasets'...
    );
uicontrol('Tag','data_panel_visible_listbox',...
    'Style','listbox',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 panel_size(3)-40 70],...
    'String','',...
    'Callback',{@visible_listbox_Callback}...
    );

uicontrol('Tag','data_panel_show_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 panel_size(4)-205 60 25],...
    'String','Show',...
    'TooltipString','Show currently highlighted spectrum',...
    'Callback', {@show_pushbutton_Callback}...
    );
uicontrol('Tag','data_panel_hide_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[panel_size(3)-70 panel_size(4)-205 60 25],...
    'String','Hide',...
    'TooltipString','Hide currently highlighted spectrum',...
    'Callback', {@hide_pushbutton_Callback}...
    );
uicontrol('Tag','show_hide_button_explanation',...
    'Style','text',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Center',...
    'FontAngle','oblique',...
    'Position',[75 panel_size(4)-215 panel_size(3)-150 30],...
    'String',{'Selected dataset'}...
    );

handle_p3 = uipanel('Tag','data_panel_multiple_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'FontUnit','Pixel','Fontsize',12,...
    'Position',[10 panel_size(4)-380 panel_size(3)-20 55],...
    'Title','Multiple datasets'...
    );
uicontrol('Tag','data_panel_combine_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 floor((panel_size(3)-40)/3) 25],...
    'TooltipString',sprintf('%s\n%s',...
    'Combine multiple datasets into one',...
    '(e.g., if forgotten to check "combine" at load)'),...
    'String','Combine',...
    'Callback',{@pushbutton_Callback,'Combine'}...
    );
uicontrol('Tag','data_panel_showall_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[floor((panel_size(3)-40)/3)+10 10 floor((panel_size(3)-40)/3) 25],...
    'TooltipString','Show all datasets',...
    'String','Show all',...
    'Callback',{@pushbutton_Callback,'ShowAll'}...
    );
uicontrol('Tag','data_panel_hideall_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[floor((panel_size(3)-40)/3*2)+10 10 floor((panel_size(3)-40)/3) 25],...
    'TooltipString','Hide all datasets',...
    'String','Hide all',...
    'Callback',{@pushbutton_Callback,'HideAll'}...
    );

handle_p4 = uipanel('Tag','data_panel_currentlyactive_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'FontUnit','Pixel','Fontsize',12,...
    'Position',[10 panel_size(4)-470 panel_size(3)-20 80],...
    'Title','Currently active dataset'...
    );
uicontrol('Tag','data_panel_save_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 35 floor((panel_size(3)-40)/3) 25],...
    'String','Save',...
    'TooltipString','Save currently active spectrum',...
    'Callback', {@save_pushbutton_Callback}...
    );
uicontrol('Tag','data_panel_saveas_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[floor((panel_size(3)-40)/3)+10 35 floor((panel_size(3)-40)/3) 25],...
    'String','Save as',...
    'TooltipString','Save currently active spectrum under different filename',...
    'Callback', {@saveas_pushbutton_Callback}...
    );
uicontrol('Tag','data_panel_remove_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[(floor((panel_size(3)-40)/3)*2)+10 35 floor((panel_size(3)-40)/3) 25],...
    'String','Remove',...
    'TooltipString',sprintf('%s\n%s',...
    'Remove currently active spectrum from GUI',...
    '(does not delete the file)'),...
    'Callback', {@remove_pushbutton_Callback}...
    );
uicontrol('Tag','data_panel_undo_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 floor((panel_size(3)-40)/3) 25],...
    'String','Undo',...
    'TooltipString','Undo last operation on currently active dataset'...
    );
uicontrol('Tag','data_panel_getinfo_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[floor((panel_size(3)-40)/3)+10 10 floor((panel_size(3)-40)/3) 25],...
    'String','Get info',...
    'Callback', {@trEPRgui_infowindow}...
    );
uicontrol('Tag','data_panel_duplicate_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[(floor((panel_size(3)-40)/3)*2)+10 10 floor((panel_size(3)-40)/3) 25],...
    'TooltipString','Duplicate currently active dataset',...
    'String','Duplicate',...
    'Callback', {@duplicate_pushbutton_Callback}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
function pushbutton_Callback(~,~,action)
    try
        if isempty(action)
            return;
        end
        
        % Get appdata of main window
        mainWindow = guiGetWindowHandle();
        ad = getappdata(mainWindow);
        
        % Get handles of main window
        gh = guihandles(mainWindow);

        switch action
            case 'Combine'
                % If no datasets are loaded, return
                if isempty(ad.data)
                    return;
                end
                trEPRgui_combinewindow();
                return;
            case 'ShowAll'
                % If there are no invisible datasets, return immediately
                if isempty(ad.control.spectra.invisible)
                    return;
                end
                
                % Move to visible
                ad.control.spectra.visible = [...
                    ad.control.spectra.visible ...
                    ad.control.spectra.invisible ...
                    ];
                
                % Delete in invisible
                ad.control.spectra.invisible = [];
                
                % Set active if not done
                if isempty(ad.control.spectra.active) || (ad.control.spectra.active < 1)
                    ad.control.spectra.active = 1;
                end
                
                % Update appdata of main window
                setappdata(mainWindow,'control',ad.control);
                
                % Add status message (mainly for debug reasons)
                % IMPORTANT: Has to go AFTER setappdata
                msgStr = cell(0,1);
                msgStr{end+1} = 'Moved all datasets to visible';
                invStr = sprintf('%i ',ad.control.spectra.invisible);
                visStr = sprintf('%i ',ad.control.spectra.visible);
                msgStr{end+1} = sprintf(...
                    'Currently invisible: [ %s]; currently visible: [ %s]; total: %i',...
                    invStr,visStr,length(ad.data));
                add2status(msgStr);
                
                % Update both list boxes
                update_invisibleSpectra();
                update_visibleSpectra();
                
                %Update main axis
                update_mainAxis();
                return;
            case'HideAll'
                % If there are no visible datasets, return immediately
                if isempty(ad.control.spectra.visible)
                    return;
                end
                % Move to invisible
                ad.control.spectra.invisible = [...
                    ad.control.spectra.invisible ...
                    ad.control.spectra.visible ...
                    ];
                
                % Delete in visible
                ad.control.spectra.visible = [];
                
                % Reset active entry
                ad.control.spectra.active = 0;
                
                % Update appdata of main window
                setappdata(mainWindow,'control',ad.control);
                
                % Add status message (mainly for debug reasons)
                % IMPORTANT: Has to go AFTER setappdata
                msgStr = cell(0,1);
                msgStr{end+1} = 'Moved all datasets to invisible';
                invStr = sprintf('%i ',ad.control.spectra.invisible);
                visStr = sprintf('%i ',ad.control.spectra.visible);
                msgStr{end+1} = sprintf(...
                    'Currently invisible: [ %s]; currently visible: [ %s]; total: %i',...
                    invStr,visStr,length(ad.data));
                add2status(msgStr);
                
                % Update both list boxes
                update_invisibleSpectra();
                update_visibleSpectra();
                
                %Update main axis
                update_mainAxis();
                return;
            otherwise
                disp('trEPRgui : guiDatasetPanel() : pushbutton_Callback(): Unknown action');
                disp(action);
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
            trEPRgui_bugreportwindow(exception);
        catch exception3
            % If even displaying the bug report window fails...
            exception = addCause(exception3, exception);
            throw(exception);
        end
    end
end

function show_pushbutton_Callback(~,~)
    try
        % Get appdata of main window
        mainWindow = guiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        % Get handles of main window
        gh = guihandles(mainWindow);
        
        % Get selected item of listbox
        selected = get(gh.data_panel_invisible_listbox,'Value');
        
        % Be on the save side if user is faster than Matlab
        if selected == 0
            return;
        end
        
        % Move to visible
        ad.control.spectra.visible = [...
            ad.control.spectra.visible ...
            ad.control.spectra.invisible(selected) ...
            ];
        
        % Make moved entry active one
        ad.control.spectra.active = ad.control.spectra.invisible(selected);
        
        % Delete in invisible
        ad.control.spectra.invisible(selected) = [];
       
        % Update appdata of main window
        setappdata(mainWindow,'control',ad.control);
        
        % Add status message (mainly for debug reasons)
        % IMPORTANT: Has to go AFTER setappdata
        msgStr = cell(0,1);
        msgStr{end+1} = sprintf(...
            'Moved dataset %i (%s) to visible',...
            ad.control.spectra.active,...
            ad.data{ad.control.spectra.active}.label);
        invStr = sprintf('%i ',ad.control.spectra.invisible);
        visStr = sprintf('%i ',ad.control.spectra.visible);
        msgStr{end+1} = sprintf(...
            'Currently invisible: [ %s]; currently visible: [ %s]; total: %i',...
            invStr,visStr,length(ad.data));
        add2status(msgStr);
        
        % Update both list boxes
        update_invisibleSpectra();
        update_visibleSpectra();
        
        %Update main axis
        update_mainAxis();
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
            trEPRgui_bugreportwindow(exception);
        catch exception3
            % If even displaying the bug report window fails...
            exception = addCause(exception3, exception);
            throw(exception);
        end
    end
end


function hide_pushbutton_Callback(~,~)
    try
        % Get appdata of main window
        mainWindow = guiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        % Get handles of main window
        gh = guihandles(mainWindow);
        
        % Get selected item of listbox
        selected = get(gh.data_panel_visible_listbox,'Value');
        selectedId = ad.control.spectra.visible(selected);
        
        % Be on the save side if user is faster than Matlab
        if selected == 0
            return;
        end
        
        % Move to invisible
        ad.control.spectra.invisible = [...
            ad.control.spectra.invisible ...
            ad.control.spectra.visible(selected) ...
            ];
        
        % Delete in visible
        ad.control.spectra.visible(selected) = [];
        
        % Toggle active entry
        if (selected > length(ad.control.spectra.visible))
            if (selected == 1)
                ad.control.spectra.active = 0;
            else
                ad.control.spectra.active = ad.control.spectra.visible(end);
            end
        else
            ad.control.spectra.active = ad.control.spectra.visible(selected);
        end
        
        % Update appdata of main window
        setappdata(mainWindow,'control',ad.control);
        
        % Add status message (mainly for debug reasons)
        % IMPORTANT: Has to go AFTER setappdata
        msgStr = cell(0,1);
        msgStr{end+1} = sprintf(...
            'Moved dataset %i (%s) to invisible',...
            selectedId,...
            ad.data{selectedId}.label);
        invStr = sprintf('%i ',ad.control.spectra.invisible);
        visStr = sprintf('%i ',ad.control.spectra.visible);
        msgStr{end+1} = sprintf(...
            'Currently invisible: [ %s]; currently visible: [ %s]; total: %i',...
            invStr,visStr,length(ad.data));
        add2status(msgStr);
        
        % Update both list boxes
        update_invisibleSpectra();
        update_visibleSpectra();
        
        %Update main axis
        update_mainAxis();
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
            trEPRgui_bugreportwindow(exception);
        catch exception3
            % If even displaying the bug report window fails...
            exception = addCause(exception3, exception);
            throw(exception);
        end
    end
end

function save_pushbutton_Callback(~,~)
    try
        % Get appdata of main window
        mainWindow = guiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        % Get handles of main window
        gh = guihandles(mainWindow);
        
        % Get selected item of listbox
        selected = get(gh.data_panel_visible_listbox,'Value');
        
        % Get id of selected spectrum
        selectedId = ad.control.spectra.visible(selected);
        
        datasetSave(selectedId);
        
        % Update both list boxes
        update_invisibleSpectra();
        update_visibleSpectra();
        
        %Update main axis
        update_mainAxis();
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
            trEPRgui_bugreportwindow(exception);
        catch exception3
            % If even displaying the bug report window fails...
            exception = addCause(exception3, exception);
            throw(exception);
        end
    end
end

function saveas_pushbutton_Callback(~,~)
    try
        % Get appdata of main window
        mainWindow = guiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        % Get handles of main window
        gh = guihandles(mainWindow);
        
        % Get selected item of listbox
        selected = get(gh.data_panel_visible_listbox,'Value');
        
        % Get id of selected spectrum
        selectedId = ad.control.spectra.visible(selected);
        
        datasetSaveAs(selectedId);
        
        % Update both list boxes
        update_invisibleSpectra();
        update_visibleSpectra();
        
        %Update main axis
        update_mainAxis();
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
            trEPRgui_bugreportwindow(exception);
        catch exception3
            % If even displaying the bug report window fails...
            exception = addCause(exception3, exception);
            throw(exception);
        end
    end
end

function remove_pushbutton_Callback(~,~)
    try
        % Get appdata of main window
        mainWindow = guiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        % Get handles of main window
        gh = guihandles(mainWindow);
        
        % Get selected item of listbox
        selected = get(gh.data_panel_visible_listbox,'Value');
        
        % Fix for too slow MATLAB(r)
        if ~isempty(ad.control.spectra.visible)
            % If for whatever reason, selectedId is larger than the visible
            % spectra array, simply return
            if selected > length(ad.control.spectra.visible)
                return;
            end
            % Get id of selected spectrum
            selectedId = ad.control.spectra.visible(selected);
        else
            return;
        end
        
        % Check whether currently selected spectrum is modified, and if so,
        % ask the user whether to remove it anyway
        if find(ad.control.spectra.modified==selectedId)
            answer = questdlg(...
                {'Dataset was modified. Remove anyway?'...
                ' '...
                'Note that "Remove" means that you loose the changes you made,'...
                'but the (original) file will not be deleted from the file system.'...
                ' '...
                'Other options include "Save & Remove" or "Cancel".'},...
                'Warning: Dataset Modified...',...
                'Save & Remove','Remove','Cancel',...
                'Save & Remove');
            switch answer
                case 'Save & Remove'
                    status = datasetSave(selectedId);
                    if status
                        % That means that something went wrong with the saveAs
                        return;
                    end
                case 'Remove'
                case 'Cancel'
                    return;
                otherwise
                    return;
            end
        end
        
        removedDatasetLabel = ...
            ad.data{selectedId}.label;
        
        % Remove from data and origdata
        ad.data(selectedId) = [];
        ad.origdata(selectedId) = [];
        
        % Remove from modified if it's there
        ad.control.spectra.modified(...
            ad.control.spectra.modified == selectedId) = [];
        % Remove from missing if it's there
        ad.control.spectra.missing(...
            ad.control.spectra.missing == selectedId) = [];
        
        
        % Delete in visible
        ad.control.spectra.visible(selected) = [];
        
        % Shift numbering in spectra.visible and spectra.invisible
        if (~isempty(ad.control.spectra.visible))
            indices = find(ad.control.spectra.visible>selectedId);
            ad.control.spectra.visible(indices) = ...
                ad.control.spectra.visible(indices)-1;
        end
        if (~isempty(ad.control.spectra.invisible))
            indices = find(ad.control.spectra.invisible>selectedId);
            ad.control.spectra.invisible(indices) = ...
                ad.control.spectra.invisible(indices)-1;
        end
        
        % Shift numbering in spectra.modified
        if (~isempty(ad.control.spectra.modified))
            indices = find(ad.control.spectra.modified>selectedId);
            ad.control.spectra.modified(indices) = ...
                ad.control.spectra.modified(indices)-1;
        end
        
        % Toggle active entry
        if (selected > length(ad.control.spectra.visible))
            if (selected == 1)
                ad.control.spectra.active = [];
            else
                ad.control.spectra.active = ad.control.spectra.visible(end);
            end
        else
            ad.control.spectra.active = ad.control.spectra.visible(selected);
        end
        
        % Update appdata of main window
        setappdata(mainWindow,'control',ad.control);
        setappdata(mainWindow,'data',ad.data);
        setappdata(mainWindow,'origdata',ad.origdata);
        
        % Add status message (mainly for debug reasons)
        % IMPORTANT: Has to go AFTER setappdata
        msgStr = cell(0,1);
        msgStr{end+1} = ...
            sprintf('Data set "%s" removed from GUI',removedDatasetLabel);
        invStr = sprintf('%i ',ad.control.spectra.invisible);
        visStr = sprintf('%i ',ad.control.spectra.visible);
        msgStr{end+1} = sprintf(...
            'Currently invisible: [ %s]; currently visible: [ %s]; total: %i',...
            invStr,visStr,length(ad.data));
        add2status(msgStr);
        clear msgStr;
        
        % Update both list boxes
        update_invisibleSpectra();
        update_visibleSpectra();
        
        %Update main axis
        update_mainAxis();
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
            trEPRgui_bugreportwindow(exception);
        catch exception3
            % If even displaying the bug report window fails...
            exception = addCause(exception3, exception);
            throw(exception);
        end
    end
end

function duplicate_pushbutton_Callback(~,~)
    try
        % Get appdata of main window
        mainWindow = guiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        % Get handles of main window
        gh = guihandles(mainWindow);
        
        % Get selected item of listbox
        selected = get(gh.data_panel_visible_listbox,'Value');
        
        % Create label for duplicate
        % That is, add number in brackets at the end: (n)
        % But check whether there is already such a number in brackets in
        % any of the visible spectra with the same label.
        expression = sprintf('\\((\\d+)\\)$',ad.data{selected}.label);
        l = 0;
        token = [];
        for k=1:length(ad.control.spectra.visible)
            tokens = regexp(ad.data{ad.control.spectra.visible(k)}.label,expression,'tokens');
            if ~isempty(tokens)
                l=l+1;
                token(l) = str2double(char(tokens{1}));
            end
        end
        if ~isempty(token)
            ad.data{selected}.label
            if (regexp(ad.data{selected}.label,' \((\d+)\)$'))
                duplicateLabel = regexprep(...
                    ad.data{selected}.label,...
                    ' \((\d+)\)$',sprintf(' (%i)',max(token)+1));
            else
                duplicateLabel = sprintf('%s (%i)',ad.data{selected}.label,max(token)+1);
            end
        else
            duplicateLabel = sprintf('%s (1)',ad.data{selected}.label);
        end
        
        % Actually duplicate the dataset
        duplicate = ad.data{selected};
        % Set label of duplicate
        duplicate.label = duplicateLabel;
        % IMPORTANT: Set the filename of the duplicate to empty string
        duplicate.file.name = '';
        
        nSpectra = length(ad.data);
        
        ad.data{end+1} = duplicate;
        ad.origdata{end+1} = duplicate;
        
        ad.control.spectra.visible(end+1) = nSpectra+1;
        ad.control.spectra.modified(end+1) = nSpectra+1;
        
        % Update appdata of main window
        setappdata(mainWindow,'control',ad.control);
        setappdata(mainWindow,'data',ad.data);
        setappdata(mainWindow,'origdata',ad.origdata);
        
        % Add status message (mainly for debug reasons)
        % IMPORTANT: Has to go AFTER setappdata
        msgStr = cell(0,1);
        msgStr{end+1} = ...
            sprintf(...
            'Data set "%s" duplicated as %s',...
            ad.data{selected}.label,...
            duplicateLabel);
        invStr = sprintf('%i ',ad.control.spectra.invisible);
        visStr = sprintf('%i ',ad.control.spectra.visible);
        msgStr{end+1} = sprintf(...
            'Currently invisible: [ %s]; currently visible: [ %s]; total: %i',...
            invStr,visStr,length(ad.data));
        add2status(msgStr);
        clear msgStr;
        
        % Update both list boxes
        update_invisibleSpectra();
        update_visibleSpectra();
        
        %Update main axis
        update_mainAxis();
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
            trEPRgui_bugreportwindow(exception);
        catch exception3
            % If even displaying the bug report window fails...
            exception = addCause(exception3, exception);
            throw(exception);
        end
    end
end

function visible_listbox_Callback(~,~)
    try
        % Get appdata of main window
        mainWindow = guiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        % Get handles of main window
        gh = guihandles(mainWindow);
        
        ad.control.spectra.active = ad.control.spectra.visible(...
            get(gh.data_panel_visible_listbox,'Value')...
            );
        
        % Update appdata of main window
        setappdata(mainWindow,'control',ad.control);
        
        % If user double clicked on list entry
        if strcmp(get(gcf,'SelectionType'),'open')
            datasetChangeLabel(ad.control.spectra.active);
        end
        
        % Update processing panel
        update_processingPanel();
        
        % Update slider panel
        update_sliderPanel();
        
        % Update visible spectra listboxes (in diverse panels!)
        update_visibleSpectra();
        
        %Update main axis
        update_mainAxis();
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
            trEPRgui_bugreportwindow(exception);
        catch exception3
            % If even displaying the bug report window fails...
            exception = addCause(exception3, exception);
            throw(exception);
        end
    end
end

function invisible_listbox_Callback(source,~)
    try
        % Get appdata of main window
        mainWindow = guiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        % If user double clicked on list entry
        if strcmp(get(gcf,'SelectionType'),'open')
            datasetChangeLabel(...
                ad.control.spectra.invisible(...
                get(source,'Value')...
                ));
        end
        update_invisibleSpectra();
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
            trEPRgui_bugreportwindow(exception);
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

function datasetChangeLabel(index)
    try
        % Get appdata of main window
        mainWindow = guiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        ad.data{index}.label = trEPRgui_setLabelWindow(ad.data{index}.label);
        % Update appdata of main window
        setappdata(mainWindow,'data',ad.data);
        
        % Add status message (mainly for debug reasons)
        % IMPORTANT: Has to go AFTER setappdata
        msgStr = cell(0,1);
        msgStr{end+1} = sprintf(...
            'Changed label of dataset %i to "%s"',...
            ad.control.spectra.active,...
            ad.data{index}.label);
        invStr = sprintf('%i ',ad.control.spectra.invisible);
        visStr = sprintf('%i ',ad.control.spectra.visible);
        msgStr{end+1} = sprintf(...
            'Currently invisible: [ %s]; currently visible: [ %s]; total: %i',...
            invStr,visStr,length(ad.data));
        add2status(msgStr);
        clear msgStr;
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
            trEPRgui_bugreportwindow(exception);
        catch exception3
            % If even displaying the bug report window fails...
            exception = addCause(exception3, exception);
            throw(exception);
        end
    end
end

function status = datasetSave(id)
    % Internal function that saves a given dataset
    %
    % STATUS: 0 - in case save was successful
    %        -1 - in case something went wrong

    try
        % Get appdata of main window
        mainWindow = guiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        % Check whether selected dataset has a (valid) filename
        if ~isfield(ad.data{id}.file,'name') || ...
                (strcmp(ad.data{id}.file.name,''))
            status = datasetSaveAs(id);
            return;
        else
            [fpath,fname,fext] = fileparts(ad.data{id}.file.name);
            if ~strcmp(fext,'.zip')
                ad.data{id}.file.name = fullfile(fpath,[fname '.zip']);
                % Need to test for existing file and in case, ask user...
                if (exist(ad.data{id}.file.name,'file'))
                    answer = questdlg(...
                        {'WARNING: You''re about to save the current dataset to the file'...
                        ad.data{id}.file.name ...
                        ' '...
                        'This file exists already! Are you sure you want to overwrite it?'...
                        ' '...
                        'Please hold on and think twice before you hit "Overwrite".'...
                        'Alternatively you can press "Save as" and choose a different name.'},...
                        'Warning: File exists already...',...
                        'Overwrite','Save as','Cancel',...
                        'Cancel');
                    switch answer
                        case 'Overwrite'
                        case 'Save as'
                            status = datasetSaveAs(id);
                            return;
                        case 'Cancel'
                            return;
                        otherwise
                            return;
                    end
                end
            end
        end
        
        for k = 1:length(ad.data)
            if (strcmp(ad.data{k}.file.name,ad.data{id}.file.name)) && (k ~= id)
                answer = questdlg(...
                    {'WARNING: You''re about to save the current dataset to the file'...
                    ad.data{id}.file.name ...
                    ' '...
                    'A dataset loaded from a file with that name has been loaded to the GUI!'...
                    ' '...
                    'Please use "Save as" and choose a different name or press "Cancel".'},...
                    'Warning: Dataset with same filename loaded to GUI...',...
                    'Save as','Cancel',...
                    'Cancel');
                switch answer
                    case 'Save as'
                        status = datasetSaveAs(id);
                        return;
                    case 'Cancel'
                        return;
                    otherwise
                        return;
                end
            end
        end
        
        % Do the actual saving
        [ saveStatus, exception ] = ...
            trEPRsave(ad.data{id}.file.name,ad.data{id});
        
        % In case something went wrong
        if saveStatus
            % Adding status line
            msgStr = cell(0);
            msgStr{length(msgStr)+1} = ...
                sprintf('Problems when trying to save "%s" to file',...
                ad.data{id}.label);
            msgStr{length(msgStr)+1} = ad.data{id}.file.name;
            status = add2status(msgStr);
            clear msgStr;
            status = -1;
            return;
        else
            % Get second output parameter from trEPRsave, i.e. filename
            % (See help of trEPRsave for details)
            filename = exception;
        end
        
        % Remove from modified
        ad.control.spectra.modified(ad.control.spectra.modified == id) = [];
        
        % Update appdata of main window
        setappdata(mainWindow,'control',ad.control);
        setappdata(mainWindow,'data',ad.data);
        setappdata(mainWindow,'origdata',ad.origdata);
        
        % Adding status line
        msgStr = cell(0);
        msgStr{length(msgStr)+1} = ...
            sprintf('Data set "%s" saved to file',ad.data{id}.label);
        msgStr{length(msgStr)+1} = filename;
        status = add2status(msgStr);
        clear msgStr;
        
        status = 0;
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
            trEPRgui_bugreportwindow(exception);
        catch exception3
            % If even displaying the bug report window fails...
            exception = addCause(exception3, exception);
            throw(exception);
        end
    end
end

function status = datasetSaveAs(id)
    % Internal function that asks the user for a filename to save a given
    % dataset to
    %
    % STATUS: 0 - in case saveAs was successful
    %        -1 - in case something went wrong
    
    try
        % Get appdata of main window
        mainWindow = guiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        % Create default filename
        [fpath,fname,fext] = fileparts(ad.data{id}.file.name);
        if ~strcmp(fext,'.zip')
            ad.data{id}.file.name = fullfile(fpath,[fname '.zip']);
        end
        % Need to test for existing file and in case, change default name
        if (exist(ad.data{id}.file.name,'file'))
            % 1. Check whether name ends with -NNN (where NNN are numbers)
            % 2. existingFiles = dir(sprintf('%s*',filename));
            % 2a. If name ends with -NNN, remove "-NNN" from filename before
            % 3. regexp existingFiles for "-NNN" pattern
            % 4. Get highest "-NNN" pattern and increment "NNN"
            % 5. Use filename with incremented "NNN" as new default filename
            if (regexp(fname,'_\d+$'))
                filesInDir = ...
                    dir(sprintf('%s*',fullfile(fpath,regexprep(fname,'_\d+$',''))));
            else
                filesInDir = dir(sprintf('%s*',fullfile(fpath,fname)));
            end
            l=0;
            numbers = [];
            for k=1:length(filesInDir)
                token = regexp(filesInDir(k).name,'_(\d+)\..*$','tokens');
                if ~isempty(token)
                    l=l+1;
                    numbers(l) = str2double(token{1});
                end
            end
            if (~isempty(numbers));
                number = max(numbers)+1;
            else
                number = 1;
            end
            ad.data{id}.file.name = fullfile(...
                fpath,...
                sprintf('%s_%i.zip',fname,number));
        end
        
        % Show dialog for file selection
        [FileName,PathName,~] = uiputfile(...
            '*.zip',...
            'Save dataset in a new file',...
            ad.data{id}.file.name);
        
        if (FileName == 0)
            status = -1;
            return;
        end
        
        % Set filename to save in
        ad.data{id}.file.name = fullfile(PathName, FileName);
        
        for k = 1:length(ad.data)
            if (strcmp(ad.data{k}.file.name,ad.data{id}.file.name)) && (k ~= id)
                answer = questdlg(...
                    {'WARNING: You''re about to save the current dataset to the file'...
                    ad.data{id}.file.name ...
                    ' '...
                    'A dataset loaded from a file with that name has been loaded to the GUI!'...
                    ' '...
                    'Please use "Save as" and choose a different name or press "Cancel".'},...
                    'Warning: Dataset with same filename loaded to GUI...',...
                    'Save as','Cancel',...
                    'Cancel');
                switch answer
                    case 'Save as'
                        status = datasetSaveAs(id);
                        return;
                    case 'Cancel'
                        return;
                    otherwise
                        return;
                end
            end
        end
        
        % Do the actual saving
        [ saveStatus, exception ] = ...
            trEPRsave(ad.data{id}.file.name,ad.data{id});
        
        % In case something went wrong
        if saveStatus
            % Adding status line
            msgStr = cell(0);
            msgStr{length(msgStr)+1} = ...
                sprintf('Problems when trying to save "%s" to file',...
                ad.data{id}.label);
            msgStr{length(msgStr)+1} = ad.data{id}.file.name;
            status = add2status(msgStr);
            clear msgStr;
            return;
        else
            % Get second output parameter from trEPRsave, i.e. filename
            % (See help of trEPRsave for details)
            filename = exception;
        end
        
        % Remove from modified
        ad.control.spectra.modified(...
            (ad.control.spectra.modified == id)) = [];
        
        % Update appdata of main window
        setappdata(mainWindow,'control',ad.control);
        setappdata(mainWindow,'data',ad.data);
        setappdata(mainWindow,'origdata',ad.origdata);
        
        % Adding status line
        msgStr = cell(0);
        msgStr{length(msgStr)+1} = ...
            sprintf('Data set "%s" saved to file',ad.data{id}.label);
        msgStr{length(msgStr)+1} = filename;
        status = add2status(msgStr);
        clear msgStr;
        
        status = 0;
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
            trEPRgui_bugreportwindow(exception);
        catch exception3
            % If even displaying the bug report window fails...
            exception = addCause(exception3, exception);
            throw(exception);
        end
    end
end
    

end