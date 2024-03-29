function handle = guiConfigurePanel(parentHandle,position)
% GUICONFIGUREPANEL Add a panel for configuring tasks of a GUI to a gui
%       Should only be called from within a GUI defining function.
%
%       Arguments: parent Handle and position vector.
%
%       Returns the handle of the added panel.

% Copyright (c) 2011-12, Till Biskup
% 2012-10-21

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Try to get list of all config files
configFiles = TAconf('files');
% If there are no config files yet, try to create them
if isempty(configFiles)
    disp('No config files yet. Trying to create them...');
    TAconf('create');
    configFiles = TAconf('files');
end
if ~isempty(configFiles)
    confFileNames = cell(length(configFiles),1);
    for k=1:length(configFiles)
        [~,fn,ext] = fileparts(configFiles{k});
        confFileNames{k} = [fn ext];
        clear fn ext;
    end
end

defaultBackground = get(parentHandle,'Color');

handle = uipanel('Tag','configure_panel',...
    'parent',parentHandle,...
    'Title','Configure',...
    'FontUnit','Pixel','Fontsize',12,...
    'FontWeight','bold',...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'Units','pixels','Position',position);

% Create the "Help" panel
handle_size = get(handle,'Position');
uicontrol('Tag','configure_panel_description',...
    'Style','text',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 handle_size(4)-60 handle_size(3)-20 30],...
    'String',{'Configuration settings (not only) for the main GUI'}...
    );

handle_p1 = uipanel('Tag','configure_panel_conffilecreate_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-170 handle_size(3)-20 100],...
    'Title','Create config files'...
    );
uicontrol('Tag','configure_panel_conffilecreate_description',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 35 handle_size(3)-40 40],...
    'String',{'Create local config files from distributed templates.'}...
    );
uicontrol('Tag','configure_panel_conffileedit_overwrite_checkbox',...
    'Style','checkbox',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','left',...
    'Units','Pixels',...
    'Position',[10 15 130 20],...
    'TooltipString',sprintf('%s\n%s',...
    'Whether to overwrite local config files','(if they exist)'),...
    'String','overwrite local'...
    );
uicontrol('Tag','configure_panel_conffilecreate_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[handle_size(3)-90 10 60 30],...
    'String','Create',...
    'TooltipString','Edit config file in MATLAB(r) editor',...
    'Callback',{@pushbutton_Callback,'conffilecreate'}...
    );

handle_p2 = uipanel('Tag','configure_panel_conffileedit_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-280 handle_size(3)-20 100],...
    'Title','Edit config files'...
    );
uicontrol('Tag','configure_panel_conffileedit_description',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 35 handle_size(3)-40 40],...
    'String',{'Edit configuration files with MATLAB(r) editor.'}...
    );
uicontrol('Tag','configure_panel_conffileedit_file_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','left',...
    'Units','Pixels',...
    'Position',[10 10 40 20],...
    'String','File'...
    );
uicontrol('Tag','configure_panel_conffileedit_file_popupmenu',...
    'Style','popupmenu',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[50 15 120 20],...
    'String',confFileNames,...
    'TooltipString','Select configuration file to edit'...
    );
uicontrol('Tag','configure_panel_conffileedit_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[handle_size(3)-90 10 60 30],...
    'String','Edit',...
    'TooltipString','Edit config file in MATLAB(r) editor',...
    'Callback',{@pushbutton_Callback,'conffileedit'}...
    );

handle_p3 = uipanel('Tag','configure_panel_conffilereset_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-390 handle_size(3)-20 100],...
    'Title','Reset config files'...
    );
uicontrol('Tag','configure_panel_conffilereset_description',...
    'Style','text',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 35 handle_size(3)-40 40],...
    'String',{'Reset config files to their default from distributed template.'}...
    );
uicontrol('Tag','configure_panel_conffilereset_file_text',...
    'Style','text',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','left',...
    'Units','Pixels',...
    'Position',[10 10 40 20],...
    'String','File'...
    );
uicontrol('Tag','configure_panel_conffilereset_file_popupmenu',...
    'Style','popupmenu',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[50 15 120 20],...
    'String',['none'; confFileNames],...
    'TooltipString','Select configuration file to reset'...
    );
uicontrol('Tag','configure_panel_conffilereset_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[handle_size(3)-90 10 60 30],...
    'String','Reset',...
    'TooltipString','Reset selected config file',...
    'Callback',{@pushbutton_Callback,'conffilereset'}...
    );

handle_p4 = uipanel('Tag','configure_panel_configuration_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-460 handle_size(3)-20 60],...
    'Title','Configuration'...
    );
uicontrol('Tag','configure_panel_configuration_check_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 (handle_size(3)-40)/2 30],...
    'String','Check',...
    'TooltipString','Check configuration for validity',...
    'Callback',{@pushbutton_Callback,'check'}...
    );
uicontrol('Tag','configure_panel_configuration_apply_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle_p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10+(handle_size(3)-40)/2 10 (handle_size(3)-40)/2 30],...
    'String','Apply',...
    'TooltipString','Apply current configuration to GUI(s)',...
    'Callback',{@pushbutton_Callback,'apply'}...
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
        gh = guihandles(mainWindow);

        switch lower(action)
            case 'conffilecreate'
                TAconf('create','overwrite',logical(get(...
                    gh.configure_panel_conffileedit_overwrite_checkbox,...
                    'value')));
                return;
            case 'conffileedit'
                % Get config file name with full path
                confFile = configFiles{...
                    get(gh.configure_panel_conffileedit_file_popupmenu,...
                    'Value')};
                edit(confFile);
                return;
            case 'conffilereset'
                confFiles = get(...
                    gh.configure_panel_conffilereset_file_popupmenu,'String');
                confFile = confFiles{get(...
                    gh.configure_panel_conffilereset_file_popupmenu,'Value')};
                if strcmpi(confFile,'none')
                    return;
                end
                confFile = configFiles{...
                    get(gh.configure_panel_conffilereset_file_popupmenu,...
                    'Value')-1};
                TAconf('create','overwrite',true,'file',confFile);
                return;
            case 'apply'
                % For the time being, just apply configuration for TAgui
                % main window
                status = guiConfigApply('TAgui');
                
                % Update axis
                update_mainAxis();
                
                if status
                    TAmsg(status,'warning');
                end
            otherwise
                fprintf('%s%s "%s"\n',...
                    'TAgui : guiAnalysisPanel() : ',...
                    'pushbutton_Callback(): Unknown action',...
                    action);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
