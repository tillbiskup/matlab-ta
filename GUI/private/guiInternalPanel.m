function handle = guiInternalPanel(parentHandle,position)
% GUIINTERNALPANEL Add a panel helping with internal settings of a GUI
%       Should only be called from within a GUI defining function.
%
%       Arguments: parent Handle and position vector.
%
%       Returns the handle of the added panel.

% Copyright (c) 2013, Till Biskup
% 2013-07-15

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

defaultBackground = get(parentHandle,'Color');

handle = uipanel('Tag','internal_panel',...
    'parent',parentHandle,...
    'Title','GUI Internals',...
    'FontUnit','Pixel','Fontsize',12,...
    'FontWeight','bold',...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'Units','pixels','Position',position);

% Create the "Help" panel
handle_size = get(handle,'Position');
uicontrol('Tag','internal_panel_description',...
    'Style','text',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 handle_size(4)-60 handle_size(3)-20 30],...
    'String',{'GUI internals: setting directories and log levels, make snapshots, ...'}...
    );

handle_p1 = uipanel('Tag','internal_panel_directories_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-130 handle_size(3)-20 60],...
    'Title','GUI directories'...
    );
uicontrol('Tag','internal_panel_directories_description',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 10 handle_size(3)-110 30],...
    'String',{'Show/set directories used by the GUI.'}...
    );
uicontrol('Tag','internal_panel_directories_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[handle_size(3)-90 10 60 30],...
    'String','Show',...
    'TooltipString','Show/set directories used by the GUI.',...
    'Callback',{@pushbutton_Callback,'directories'}...
    );

handle_p2 = uipanel('Tag','internal_panel_messaging_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-225 handle_size(3)-20 85],...
    'Title','Messages/Log levels'...
    );
uicontrol('Tag','internal_panel_messaging_debug_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 40 80 18],...
    'String',{'Debug:'}...
    );
uicontrol('Tag','internal_panel_messaging_debug_popupmenu',...
    'Style','popupmenu',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[90 40 handle_size(3)-120 20],...
    'String','error|warning|info|debug|all',...
    'Value',5,...
    'Callback',{@popupmenu_Callback,'debug'}...
    );
uicontrol('Tag','internal_panel_messaging_display_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 10 80 18],...
    'String',{'Display:'}...
    );
uicontrol('Tag','internal_panel_messaging_display_popupmenu',...
    'Style','popupmenu',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[90 10 handle_size(3)-120 20],...
    'String','error|warning|info|debug|all',...
    'Value',5,...
    'Callback',{@popupmenu_Callback,'display'}...
    );

handle_p3 = uipanel('Tag','internal_panel_snapshot_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-335 handle_size(3)-20 100],...
    'Title','Snapshots'...
    );
uicontrol('Tag','internal_panel_snapshot_description',...
    'Style','text',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 45 handle_size(3)-70 30],...
    'String',{'Save/load snapshots','To set directory, see above'}...
    );
uicontrol('Tag','internal_panel_snapshot_help_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'ForegroundColor',[0 0 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'FontWeight','bold',...
    'String','?',...
    'TooltipString','Display help about snapshots in the TA GUI',...
    'Position',[handle_size(3)-55 55 25 25],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'snapshotHelp'}...
    );
uicontrol('Tag','internal_panel_snapshot_save_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 (handle_size(3)-40)/3 30],...
    'String','Save',...
    'TooltipString','Save current state of the TA GUI as snapshot',...
    'Callback',{@pushbutton_Callback,'snapshotSave'}...
    );
uicontrol('Tag','internal_panel_snapshot_load_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10+(handle_size(3)-40)/3 10 (handle_size(3)-40)/3 30],...
    'String','Load',...
    'TooltipString','Load saved state of the TA GUI as snapshot',...
    'Callback',{@pushbutton_Callback,'snapshotLoad'}...
    );
uicontrol('Tag','internal_panel_snapshot_show_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10+(handle_size(3)-40)/3*2 10 (handle_size(3)-40)/3 30],...
    'String','Show',...
    'TooltipString','Show saved snapshots of the TA GUI',...
    'Callback',{@pushbutton_Callback,'snapshotShow'}...
    );

handle_p4 = uipanel('Tag','internal_panel_cmd_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-440 handle_size(3)-20 95],...
    'Title','Command line (CMD)'...
    );
uicontrol('Tag','internal_panel_cmd_savehistory_checkbox',...
    'Style','checkbox',...
    'Parent',handle_p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 50 handle_size(3)-70 20],...
    'String',' Save cmd history',...
    'TooltipString',sprintf('%s\n%s\n%s',...
    'Decide whether the cmd line history gets saved.',...
    'If saved, it is available across sessions.',...
    'You can set the file and directory in the configuration file.'),...
    'Callback',{@checkbox_Callback,'cmdSaveHistory'}...
    );
uicontrol('Tag','internal_panel_cmd_help_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p4,...
    'BackgroundColor',defaultBackground,...
    'ForegroundColor',[0 0 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'FontWeight','bold',...
    'String','?',...
    'TooltipString',sprintf('Display help about the command line (CMD)\n in the TA GUI'),...
    'Position',[handle_size(3)-55 50 25 25],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'cmdhelp'}...
    );
uicontrol('Tag','internal_panel_cmd_run_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 (handle_size(3)-40)/2 30],...
    'String','Show history',...
    'TooltipString',sprintf('%s\n%s',...
    'Show history of the command line feature of the TA GUI.',...
    'Will allow in the future to select and reexecute parts.'),...
    'Callback',{@pushbutton_Callback,'cmdHistory'}...
    );
uicontrol('Tag','internal_panel_cmd_run_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10+(handle_size(3)-40)/2 10 (handle_size(3)-40)/2 30],...
    'String','Run script',...
    'TooltipString',sprintf('%s\n%s',...
    'Open file and run it as script',...
    'in the command line of the TA GUI.'),...
    'Callback',{@pushbutton_Callback,'cmdRun'}...
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
        mainWindow = TAguiGetWindowHandle();
        ad = getappdata(mainWindow);
        % Get handles of main window
%         gh = guihandles(mainWindow);

        switch lower(action)
            case 'directories'
                TAgui_setdirectorieswindow();
            case 'snapshothelp'
                TAgui_helpwindow();
            case 'cmdhelp'
                TAgui_cmd_helpwindow();
            case 'cmdhistory'
                TAgui_cmd_historywindow();
            case 'cmdrun'
                startDir = ad.control.dirs.lastLoad;
                [fileName,pathName,~] = uigetfile(...
                    '*.*',...
                    'Get filename of script to execute on the TA GUI command line (CMD)',...
                    'MultiSelect','off',...
                    startDir...
                    );
                if fileName == 0
                    return;
                end
                % Set path in GUI
                if pathName ~= 0
                    ad.control.dirs.lastLoad = pathName;
                end
                [status,warnings] = TAguiRunScript(fileName);
                if status
                    TAmsg(warnings,'warning');
                end
            case 'snapshotsave'
                fileNameSuggested = fullfile(...
                    ad.control.dirs.lastSnapshot,[datestr(now,30) '.mat']);
                % Ask user for file name
                [fileName,pathName] = uiputfile(...
                    '*.mat',...
                    'Get filename to save snapshot of the GUI to',...
                    fileNameSuggested);
                % If user aborts process, return
                if fileName == 0
                    return;
                end
                % Set path in GUI
                if pathName ~= 0
                    ad.control.dirs.lastSnapshot = pathName;
                end
                [status,warnings] = cmdSnapshot(mainWindow,{'save',fileName});
                if status
                    TAmsg(warnings,'warning');
                end
            case 'snapshotload'
                startDir = ad.control.dirs.lastSnapshot;
                [fileName,pathName,~] = uigetfile(...
                    '*.mat',...
                    'Get filename to load snapshot of the GUI from',...
                    'MultiSelect','off',...
                    startDir...
                    );
                if fileName == 0
                    return;
                end
                % Set path in GUI
                if pathName ~= 0
                    ad.control.dirs.lastSnapshot = pathName;
                end
                [status,warnings] = cmdSnapshot(mainWindow,{'load',fileName});
                if status
                    TAmsg(warnings,'warning');
                end
            case 'snapshotshow'
                TAgui_snapshot_showwindow();
            otherwise
                st = dbstack;
                TAmsg(...
                    [st.name ' : unknown action "' action '"'],...
                    'warning');
                return;
        end
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

function popupmenu_Callback(source,~,action)
    try
        if isempty(action)
            return;
        end
        
        values = cellstr(get(source,'String'));
        value = values{get(source,'Value')};
        
        % Get appdata of main window
        mainWindow = TAguiGetWindowHandle();
        ad = getappdata(mainWindow);

        switch lower(action)
            case 'debug'
                ad.control.messages.debug.level = lower(value);
            case 'display'
                ad.control.messages.display.level = lower(value);
            otherwise
                st = dbstack;
                TAmsg(...
                    [st.name ' : unknown action "' action '"'],...
                    'warning');
                return;
        end
        
        % Set appdata
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

function checkbox_Callback(source,~,action)
    try
        if isempty(action)
            return;
        end
        
        % Get appdata of main window
        mainWindow = TAguiGetWindowHandle();
        ad = getappdata(mainWindow);

        switch lower(action)
            case 'cmdsavehistory'
                ad.control.cmd.historysave = get(source,'Value');
            otherwise
                st = dbstack;
                TAmsg(...
                    [st.name ' : unknown action "' action '"'],...
                    'warning');
                return;
        end
        
        % Set appdata
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
