function handle = guiConfigurePanel(parentHandle,position)
% GUICONFIGUREPANEL Add a panel for configuring tasks of a GUI to a gui
%       Should only be called from within a GUI defining function.
%
%       Arguments: parent Handle and position vector.
%
%       Returns the handle of the added panel.

% (c) 11, Till Biskup
% 2011-11-27

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

defaultBackground = get(parentHandle,'Color');

handle = uipanel('Tag','configure_panel',...
    'parent',parentHandle,...
    'Title','Data configure',...
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
    'String',{'Diverse configuration settings for the main GUI'}...
    );

handle_p1 = uipanel('Tag','configure_panel_xxx_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-210 handle_size(3)-20 140],...
    'Title','First point',...
    'Visible','off'...
    );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function configure_setslider_checkbox_Callback(source,~)
    try
        % Get appdata of main window
        mainWindow = guiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        ad.control.help.setslider = get(source,'Value');
        
        % Update appdata of main window
        setappdata(mainWindow,'control',ad.control);
        
        % Update slider panel
        update_sliderPanel();
        
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end