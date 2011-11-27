function handle = guiSliderPanel(parentHandle,position)
% GUIWELCOMEPANEL Add a panel for slider value display to a gui
%       Should only be called from within a GUI defining function.
%
%       Arguments: parent Handle and position vector.
%
%       Returns the handle of the added panel.

% (c) 2011, Till Biskup
% 2011-11-27

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

defaultBackground = get(parentHandle,'Color');

% Variables that definitely have to be stored otherwise (appdata.configure)
sl1_bgcolor = [1.0 0.7 0.7];
sl2_bgcolor = [1.0 1.0 0.8];
sl3_bgcolor = [0.8 1.0 1.0];

handle = uipanel('Tag','slider_panel',...
    'parent',parentHandle,...
    'Title','Slider values',...
    'FontUnit','Pixel','Fontsize',12,...
    'FontWeight','bold',...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'Units','pixels','Position',position);

% Create the "Slider values" panel
handle_size = get(handle,'Position');
uicontrol('Tag','slider_panel_description',...
    'Style','text',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 handle_size(4)-60 handle_size(3)-20 30],...
    'String',{'Display values of the sliders attached to the main axes (on the left)'}...
    );

handle_p1 = uipanel('Tag','slider_panel_position_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-175 handle_size(3)-20 105],...
    'Title','Position'...
    );
uicontrol('Tag','slider_panel_position_index_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 60 (handle_size(3)-90)/2 25],...
    'String','index'...
    );
uicontrol('Tag','slider_panel_position_unit_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 60 (handle_size(3)-90)/2 25],...
    'String','unit'...
    );
uicontrol('Tag','slider_panel_position_x_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 40 35 20],...
    'String','x'...
    );
uicontrol('Tag','slider_panel_position_x_index_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',sl1_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 40 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@position_edit_Callback,'xindex'}...
    );
uicontrol('Tag','slider_panel_position_x_unit_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',sl1_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 40 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@position_edit_Callback,'xunit'}...
    );
uicontrol('Tag','slider_panel_position_y_text',...
    'Style','text',...
    'Parent',handle_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 35 20],...
    'String','y'...
    );
uicontrol('Tag','slider_panel_position_y_index_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',sl1_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 10 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@position_edit_Callback,'yindex'}...
    );
uicontrol('Tag','slider_panel_position_y_unit_edit',...
    'Style','edit',...
    'Parent',handle_p1,...
    'BackgroundColor',sl1_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 10 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@position_edit_Callback,'yunit'}...
    );

handle_p2 = uipanel('Tag','slider_panel_scaling_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-320 handle_size(3)-20 135],...
    'Title','Scaling'...
    );
uicontrol('Tag','slider_panel_scaling_index_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 90 (handle_size(3)-90)/2 25],...
    'String','factor'...
    );
uicontrol('Tag','slider_panel_scaling_unit_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 90 (handle_size(3)-90)/2 25],...
    'String','Delta in units',...
    'TooltipString','Difference to unscaled in units' ...
    );
uicontrol('Tag','slider_panel_scaling_x_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 70 35 20],...
    'String','x'...
    );
uicontrol('Tag','slider_panel_scaling_x_index_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',sl2_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 70 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@scaling_edit_Callback,'xindex'}...
    );
uicontrol('Tag','slider_panel_scaling_x_unit_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',sl2_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 70 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@scaling_edit_Callback,'xunit'}...
    );
uicontrol('Tag','slider_panel_scaling_y_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 40 35 20],...
    'String','y'...
    );
uicontrol('Tag','slider_panel_scaling_y_index_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',sl2_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 40 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@scaling_edit_Callback,'yindex'}...
    );
uicontrol('Tag','slider_panel_scaling_y_unit_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',sl2_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 40 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@scaling_edit_Callback,'yunit'}...
    );
uicontrol('Tag','slider_panel_scaling_z_text',...
    'Style','text',...
    'Parent',handle_p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 35 20],...
    'String','z'...
    );
uicontrol('Tag','slider_panel_scaling_z_index_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',sl2_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 10 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@scaling_edit_Callback,'zindex'}...
    );
uicontrol('Tag','slider_panel_scaling_z_unit_edit',...
    'Style','edit',...
    'Parent',handle_p2,...
    'BackgroundColor',sl2_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 10 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@scaling_edit_Callback,'zunit'}...
    );

handle_p3 = uipanel('Tag','slider_panel_displacement_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-465 handle_size(3)-20 135],...
    'Title','Displacement'...
    );
uicontrol('Tag','slider_panel_displacement_index_text',...
    'Style','text',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 90 (handle_size(3)-90)/2 25],...
    'String','index'...
    );
uicontrol('Tag','slider_panel_displacement_unit_text',...
    'Style','text',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 90 (handle_size(3)-90)/2 25],...
    'String','unit'...
    );
uicontrol('Tag','slider_panel_displacement_x_text',...
    'Style','text',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 70 35 20],...
    'String','x'...
    );
uicontrol('Tag','slider_panel_displacement_x_index_edit',...
    'Style','edit',...
    'Parent',handle_p3,...
    'BackgroundColor',sl3_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 70 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@displacement_edit_Callback,'xindex'}...
    );
uicontrol('Tag','slider_panel_displacement_x_unit_edit',...
    'Style','edit',...
    'Parent',handle_p3,...
    'BackgroundColor',sl3_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 70 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@displacement_edit_Callback,'xunit'}...
    );
uicontrol('Tag','slider_panel_displacement_y_text',...
    'Style','text',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 40 35 20],...
    'String','y'...
    );
uicontrol('Tag','slider_panel_displacement_y_index_edit',...
    'Style','edit',...
    'Parent',handle_p3,...
    'BackgroundColor',sl3_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 40 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@displacement_edit_Callback,'yindex'}...
    );
uicontrol('Tag','slider_panel_displacement_y_unit_edit',...
    'Style','edit',...
    'Parent',handle_p3,...
    'BackgroundColor',sl3_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 40 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@displacement_edit_Callback,'yunit'}...
    );
uicontrol('Tag','slider_panel_displacement_z_text',...
    'Style','text',...
    'Parent',handle_p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 35 20],...
    'String','z'...
    );
uicontrol('Tag','slider_panel_displacement_z_index_edit',...
    'Style','edit',...
    'Parent',handle_p3,...
    'BackgroundColor',sl3_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 10 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@displacement_edit_Callback,'zindex'}...
    );
uicontrol('Tag','slider_panel_displacement_z_unit_edit',...
    'Style','edit',...
    'Parent',handle_p3,...
    'BackgroundColor',sl3_bgcolor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(handle_size(3)-90)/2 10 (handle_size(3)-90)/2 25],...
    'String','0',...
    'Callback',{@displacement_edit_Callback,'zunit'}...
    );

% uicontrol('Tag','slider_panel_reset_pushbutton',...
%     'Style','pushbutton',...
%     'Parent',handle,...
%     'BackgroundColor',defaultBackground,...
%     'FontUnit','Pixel','Fontsize',12,...
%     'Units','Pixels',...
%     'Position',[10 20 90 30],...
%     'String','Reset',...
%     'TooltipString','Reset scaling and displacement slider values',...
%     'Callback',{@reset_pushbutton_Callback}...
%     );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function position_edit_Callback(source,~,value)
    try
        % If value is empty or NaN after conversion to numeric, restore
        % previous entry and return
        if (isempty(get(source,'String')) || isnan(str2double(get(source,'String'))))
            % Update slider panel
            update_sliderPanel();
            return;
        end
        
        % Get appdata of main window
        mainWindow = guiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        % Be as robust as possible: if there is no axes, default is indices
        [y,x] = size(ad.data{ad.control.spectra.active}.data);
        x = linspace(1,x,x);
        y = linspace(1,y,y);
        if (isfield(ad.data{ad.control.spectra.active},'axes') ...
                && isfield(ad.data{ad.control.spectra.active}.axes,'x') ...
                && isfield(ad.data{ad.control.spectra.active}.axes.x,'values') ...
                && not (isempty(ad.data{ad.control.spectra.active}.axes.x.values)))
            x = ad.data{ad.control.spectra.active}.axes.x.values;
        end
        if (isfield(ad.data{ad.control.spectra.active},'axes') ...
                && isfield(ad.data{ad.control.spectra.active}.axes,'y') ...
                && isfield(ad.data{ad.control.spectra.active}.axes.y,'values') ...
                && not (isempty(ad.data{ad.control.spectra.active}.axes.y.values)))
            y = ad.data{ad.control.spectra.active}.axes.y.values;
        end
        
        switch value
            case 'xindex'
                value = round(str2double(get(source,'String')));
                if (value > length(x)) value = length(x); end
                if (value < 1) value = 1; end
                ad.data{ad.control.spectra.active}.display.position.x = ...
                    value;
            case 'xunit'
                value = str2double(get(source,'String'));
                if (value < x(1)) value = x(1); end
                if (value > x(end)) value = x(end); end
                ad.data{ad.control.spectra.active}.display.position.x = ...
                    interp1(...
                    x,[1:length(x)],...
                    value,...
                    'nearest'...
                    );
            case 'yindex'
                value = round(str2double(get(source,'String')));
                if (value > length(y)) value = length(y); end
                if (value < 1) value = 1; end
                ad.data{ad.control.spectra.active}.display.position.y = ...
                    value;
            case 'yunit'
                value = str2double(get(source,'String'));
                if (value < y(1)) value = y(1); end
                if (value > y(end)) value = y(end); end
                ad.data{ad.control.spectra.active}.display.position.y = ...
                    interp1(...
                    y,[1:length(y)],...
                    value,...
                    'nearest'...
                    );
            otherwise
                return;
        end
        
        % Update appdata of main window
        setappdata(mainWindow,'data',ad.data);
        
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

function scaling_edit_Callback(source,~,value)
    try
        % If value is empty or NaN after conversion to numeric, restore
        % previous entry and return
        if (isempty(get(source,'String')) || isnan(str2double(get(source,'String'))))
            % Update slider panel
            update_sliderPanel();
            return;
        end
        
        % Get appdata of main window
        mainWindow = guiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        % Get handles from main window
        gh = guidata(mainWindow);
        
        % Be as robust as possible: if there is no axes, default is indices
        [y,x] = size(ad.data{ad.control.spectra.active}.data);
        x = linspace(1,x,x);
        y = linspace(1,y,y);
        if (isfield(ad.data{ad.control.spectra.active},'axes') ...
                && isfield(ad.data{ad.control.spectra.active}.axes,'x') ...
                && isfield(ad.data{ad.control.spectra.active}.axes.x,'values') ...
                && not (isempty(ad.data{ad.control.spectra.active}.axes.x.values)))
            x = ad.data{ad.control.spectra.active}.axes.x.values;
        end
        if (isfield(ad.data{ad.control.spectra.active},'axes') ...
                && isfield(ad.data{ad.control.spectra.active}.axes,'y') ...
                && isfield(ad.data{ad.control.spectra.active}.axes.y,'values') ...
                && not (isempty(ad.data{ad.control.spectra.active}.axes.y.values)))
            y = ad.data{ad.control.spectra.active}.axes.y.values;
        end
        
        switch value
            case 'xindex'
                value = str2double(get(source,'String'));
                if (value < (1/((get(gh.vert2_slider,'Max')*2))))
                    value = 1/((get(gh.vert2_slider,'Max')*2));
                end
                if (value > (get(gh.vert2_slider,'Max')*2))
                    value = get(gh.vert2_slider,'Max')*2;
                end
                ad.data{ad.control.spectra.active}.display.scaling.x = ...
                    value;
            case 'xunit'
                value = str2double(get(source,'String'));
                if (value < -(x(end)-x(1))/(get(gh.vert2_slider,'Max')*2))
                    value = -(x(end)-x(1))/(get(gh.vert2_slider,'Max')*2);
                end
                if (value > (x(end)-x(1)*(get(gh.vert2_slider,'Max'))))
                    value = (x(end)-x(1)*(get(gh.vert2_slider,'Max')));
                end
                ad.data{ad.control.spectra.active}.display.scaling.x = ...
                    1+value/(x(end)-x(1));
            case 'yindex'
                value = str2double(get(source,'String'));
                if (value < (1/((get(gh.vert2_slider,'Max')*2))))
                    value = 1/((get(gh.vert2_slider,'Max')*2));
                end
                if (value > (get(gh.vert2_slider,'Max')*2))
                    value = get(gh.vert2_slider,'Max')*2;
                end
                ad.data{ad.control.spectra.active}.display.scaling.y = ...
                    value;
            case 'yunit'
                value = str2double(get(source,'String'));
                if (value < -(y(end)-y(1))/(get(gh.vert2_slider,'Max')*2))
                    value = -(y(end)-y(1))/(get(gh.vert2_slider,'Max')*2);
                end
                if (value > (y(end)-y(1)*(get(gh.vert2_slider,'Max'))))
                    value = (y(end)-y(1)*(get(gh.vert2_slider,'Max')));
                end
                ad.data{ad.control.spectra.active}.display.scaling.y = ...
                    1+value/(y(end)-y(1));
            case 'zindex'
                value = str2double(get(source,'String'));
                if (value < (1/((get(gh.vert2_slider,'Max')*2))))
                    value = 1/((get(gh.vert2_slider,'Max')*2));
                end
                if (value > (get(gh.vert2_slider,'Max')*2))
                    value = get(gh.vert2_slider,'Max')*2;
                end
                ad.data{ad.control.spectra.active}.display.scaling.z = ...
                    value;
            case 'zunit'
                value = str2double(get(source,'String'));
                switch ad.control.axis.normalisation
                    case 'pkpk'
                        z = [0 1];
                    case 'amplitude'
                        z(1) = min(min(ad.data{ad.control.spectra.active}.data/...
                            max(max(ad.data{ad.control.spectra.active}.data))));
                        z(2) = max(max(ad.data{ad.control.spectra.active}.data/...
                            max(max(ad.data{ad.control.spectra.active}.data))));
                    otherwise
                        z(1) = min(min(ad.data{ad.control.spectra.active}.data));
                        z(2) = max(max(ad.data{ad.control.spectra.active}.data));
                end
                if (value < -(z(2)-z(1))/(get(gh.vert2_slider,'Max')*2))
                    value = -(z(2)-z(1))/(get(gh.vert2_slider,'Max')*2);
                end
                if (value > (z(2)-z(1)*(get(gh.vert2_slider,'Max'))))
                    value = (z(2)-z(1)*(get(gh.vert2_slider,'Max')));
                end
                ad.data{ad.control.spectra.active}.display.scaling.z = ...
                    1+value/(z(2)-z(1));
            otherwise
                return;
        end
        
        % Update appdata of main window
        setappdata(mainWindow,'data',ad.data);
        
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

function displacement_edit_Callback(source,~,value)
    try
        % If value is empty or NaN after conversion to numeric, restore
        % previous entry and return
        if (isempty(get(source,'String')) || isnan(str2double(get(source,'String'))))
            % Update slider panel
            update_sliderPanel();
            return;
        end
        
        % Get appdata of main window
        mainWindow = guiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        % Get handles from main window
        gh = guidata(mainWindow);
        
        % Be as robust as possible: if there is no axes, default is indices
        [y,x] = size(ad.data{ad.control.spectra.active}.data);
        x = linspace(1,x,x);
        y = linspace(1,y,y);
        if (isfield(ad.data{ad.control.spectra.active},'axes') ...
                && isfield(ad.data{ad.control.spectra.active}.axes,'x') ...
                && isfield(ad.data{ad.control.spectra.active}.axes.x,'values') ...
                && not (isempty(ad.data{ad.control.spectra.active}.axes.x.values)))
            x = ad.data{ad.control.spectra.active}.axes.x.values;
        end
        if (isfield(ad.data{ad.control.spectra.active},'axes') ...
                && isfield(ad.data{ad.control.spectra.active}.axes,'y') ...
                && isfield(ad.data{ad.control.spectra.active}.axes.y,'values') ...
                && not (isempty(ad.data{ad.control.spectra.active}.axes.y.values)))
            y = ad.data{ad.control.spectra.active}.axes.y.values;
        end
        
        switch value
            case 'xindex'
                value = round(str2double(get(source,'String')));
                if (value > length(x)) value = length(x); end
                if (value < -length(x)) value = -length(x); end
                ad.data{ad.control.spectra.active}.display.displacement.x = ...
                    value;
            case 'xunit'
                value = str2double(get(source,'String'));
                if (value < -(x(2)-x(1))*length(x)) value = -(x(2)-x(1))*length(x); end
                if (value > (x(2)-x(1))*length(x)) value = (x(2)-x(1))*length(x); end
                ad.data{ad.control.spectra.active}.display.displacement.x = ...
                    value/(x(2)-x(1));
            case 'yindex'
                value = round(str2double(get(source,'String')));
                if (value > length(y)) value = length(y); end
                if (value < -length(y)) value = -length(y); end
                ad.data{ad.control.spectra.active}.display.displacement.y = ...
                    value;
            case 'yunit'
                value = str2double(get(source,'String'));
                if (value < -(y(2)-y(1))*length(y)) value = -(y(2)-y(1))*length(y); end
                if (value > (y(2)-y(1))*length(y)) value = (y(2)-y(1))*length(y); end
                ad.data{ad.control.spectra.active}.display.displacement.y = ...
                    value/(y(2)-y(1));
            case 'zindex'
                value = str2double(get(source,'String'));
                if (value > get(gh.vert3_slider,'Max'))
                    value = get(gh.vert3_slider,'Max');
                end
                if (value < get(gh.vert3_slider,'Min'))
                    value = get(gh.vert3_slider,'Min');
                end
                ad.data{ad.control.spectra.active}.display.displacement.z = ...
                    value;
            case 'zunit'
                value = str2double(get(source,'String'));
                switch ad.control.axis.normalisation
                    case 'pkpk'
                        z = [0 1];
                    case 'amplitude'
                        z(1) = min(min(ad.data{ad.control.spectra.active}.data/...
                            max(max(ad.data{ad.control.spectra.active}.data))));
                        z(2) = max(max(ad.data{ad.control.spectra.active}.data/...
                            max(max(ad.data{ad.control.spectra.active}.data))));
                    otherwise
                        z(1) = min(min(ad.data{ad.control.spectra.active}.data));
                        z(2) = max(max(ad.data{ad.control.spectra.active}.data));
                end
                if (value < (z(1)-z(2)))
                    value = (z(1)-z(2));
                end
                if (value > abs(z(1)-z(2)))
                    value = abs(z(1)-z(2));
                end
                % "round" is due to rounding mistakes that otherwise make
                % problems with the slider values...
                % If you don't understand what's going on here, DON'T TOUCH!
                ad.data{ad.control.spectra.active}.display.displacement.z = ...
                    round(...
                    value*(...
                    (max(max(ad.data{ad.control.spectra.active}.data)) - ...
                    min(min(ad.data{ad.control.spectra.active}.data)))/(z(2)-z(1))...
                    )*1e7)/1e7;
            otherwise
                return;
        end
        
        % Update appdata of main window
        setappdata(mainWindow,'data',ad.data);
        
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

function reset_pushbutton_Callback(source,~)
    try
        if (get(source,'Value') == 0)
            return;
        end
        
        % Get appdata of main window
        mainWindow = guiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        % Get handles of main window
        gh = guihandles(mainWindow);
        
        % Reset displacement and scaling for current spectrum
        ad.data{ad.control.spectra.active}.display.displacement.x = 0;
        ad.data{ad.control.spectra.active}.display.displacement.y = 0;
        ad.data{ad.control.spectra.active}.display.displacement.z = 0;
        
        ad.data{ad.control.spectra.active}.display.scaling.x = 1;
        ad.data{ad.control.spectra.active}.display.scaling.y = 1;
        ad.data{ad.control.spectra.active}.display.scaling.z = 1;
        
        % Update appdata of main window
        setappdata(mainWindow,'data',ad.data);
        
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