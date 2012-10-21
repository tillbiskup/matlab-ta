function varargout = TAgui_combine_settingswindow(data,varargin)
% TAGUI_COMBINE_SETTINGSWINDOW Set parameters for scaling different parts
% of a spectrum that is to be combined to a single spectrum
%
% Normally, this window is called from the TAgui_combinewindow in context
% of the TAgui window.
%
% IMPORTANT: The actual work is NOT performed by this GUI function, but by
%            TAscale. This is according to the toolbox philosophy to not
%            mix GUI and routines processing data.
%
% See also TAGUI, TAGUI_COMBINEWINDOW, TASCALE

% (c) 2012, Till Biskup
% 2012-10-21

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make GUI effectively a singleton
singleton = findobj('Tag','TAgui_combine_settingswindow');
if (singleton)
    figure(singleton);
    return;
end

% Construct the components
hMainFigure = figure('Tag','TAgui_combine_settingswindow',...
    'Visible','off',...
    'Name','TA GUI : Combine Settings Window',...
    'Units','Pixels',...
    'Position',[30,330,650,340],...
    'Resize','off',...
    'NumberTitle','off', ...
    'KeyPressFcn',@keypress_Callback,...
    'Menu','none','Toolbar','none');

defaultBackground = get(hMainFigure,'Color');
%noneditableBackground = [0.92 0.92 0.92];
editableBackground = [1 1 1];
mainPanelWidth = 260;
guiSize = get(hMainFigure,'Position');
guiSize = guiSize([3,4]);

axes(...
    'Tag','mainAxis',...
	'Parent', hMainFigure, ...
    'Box','on',...
    'XTick',[],...
    'YTick',[],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units', 'Pixels', ...
    'Position',[20 85 330 230]);


pp1 = uipanel('Tag','method_panel',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[guiSize(1)-mainPanelWidth-20 guiSize(2)-75 mainPanelWidth 55],...
    'Title','Method & Factor'...
    );

pp2 = uipanel('Tag','timeavg_panel',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[guiSize(1)-mainPanelWidth-20 guiSize(2)-255 mainPanelWidth 170],...
    'Title','Settings',...
    'Visible','On'...
    );

pp3 = uipanel('Tag','mindiff_panel',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[guiSize(1)-mainPanelWidth-20 guiSize(2)-255 mainPanelWidth 170],...
    'Title','Settings',...
    'Visible','Off'...
    );

pp5 = uipanel('Tag','displaysettings_panel',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[20 20 guiSize(1)-mainPanelWidth-60 55],...
    'Title','Display settings'...
    );


% ------------------------------------------------------------------------
% UI controls for pp1
uicontrol('Tag','method_panel_method_popupmenu',...
    'Style','popupmenu',...
    'Parent',pp1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 13 100 20],...
    'String','time avg|min(diff)',...
    'Value',1, ...
    'Callback',{@popupmenu_Callback,'scalingmethod'} ...
    );
uicontrol('Tag','method_panel_factor_edit',...
    'Style','edit',...
    'Parent',pp1,...
    'BackgroundColor',editableBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','center',...
    'Units','Pixels',...
    'Position',[120 10 mainPanelWidth-130 25],...
    'String','1.000000',...
    'TooltipString','Factor for scaling the two curves onto each other',...
    'Enable','on',...
    'Callback',{@edit_Callback,'factor'}...
    );

% ------------------------------------------------------------------------
% UI controls for pp2
pp2_p1 = uipanel('Tag','averagearea_panel',...
    'Parent',pp2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 mainPanelWidth-20 140],...
    'Title','Average area'...
    );
uicontrol('Tag','averagearea_index_text',...
    'Style','text',...
    'Parent',pp2_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 90 (mainPanelWidth-90)/2 25],...
    'String','index'...
    );
uicontrol('Tag','averagearea_unit_text',...
    'Style','text',...
    'Parent',pp2_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(mainPanelWidth-90)/2 90 (mainPanelWidth-90)/2 25],...
    'String','unit'...
    );
uicontrol('Tag','average_start_text',...
    'Style','text',...
    'Parent',pp2_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','right',...
    'Units','Pixels',...
    'Position',[10 70 45 20],...
    'String','Start '...
    );
uicontrol('Tag','average_start_index_edit',...
    'Style','edit',...
    'Parent',pp2_p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 70 (mainPanelWidth-90)/2 25],...
    'String','0',...
    'Callback',{@edit_Callback,'avgstartindex'}...
    );
uicontrol('Tag','average_start_unit_edit',...
    'Style','edit',...
    'Parent',pp2_p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(mainPanelWidth-90)/2 70 (mainPanelWidth-90)/2 25],...
    'String','0',...
    'Callback',{@edit_Callback,'avgstartunit'}...
    );
uicontrol('Tag','average_stop_text',...
    'Style','text',...
    'Parent',pp2_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','right',...
    'Units','Pixels',...
    'Position',[10 40 45 20],...
    'String','Stop '...
    );
uicontrol('Tag','average_stop_index_edit',...
    'Style','edit',...
    'Parent',pp2_p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 40 (mainPanelWidth-90)/2 25],...
    'String','0',...
    'Callback',{@edit_Callback,'avgstopindex'}...
    );
uicontrol('Tag','average_stop_unit_edit',...
    'Style','edit',...
    'Parent',pp2_p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(mainPanelWidth-90)/2 40 (mainPanelWidth-90)/2 25],...
    'String','0',...
    'Callback',{@edit_Callback,'avgstopunit'}...
    );
uicontrol('Tag','average_draw_pushbutton',...
    'Style','pushbutton',...
    'Parent',pp2_p1,...
    'BackgroundColor',defaultBackground,...
    'Enable','on',...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 10 (mainPanelWidth-90)/2 25],...
    'String','Draw',...
    'TooltipString','Draw area to average over',...
    'Callback',{@pushbutton_Callback,'averageDraw'}...
    );
uicontrol('Tag','average_clear_pushbutton',...
    'Style','pushbutton',...
    'Parent',pp2_p1,...
    'BackgroundColor',defaultBackground,...
    'Enable','on',...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(mainPanelWidth-90)/2 10 (mainPanelWidth-90)/2 25],...
    'String','Reset',...
    'TooltipString','Reset average area to standard value',...
    'Callback',{@pushbutton_Callback,'averageReset'}...
    );

% ------------------------------------------------------------------------
% UI controls for pp3
pp3_p1 = uipanel('Tag','settings_panel_smoothing_panel',...
    'Parent',pp3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 70 mainPanelWidth-20 80],...
    'Title','Smoothing (running average)'...
    );
uicontrol('Tag','settings_panel_average_points_text',...
    'Style','text',...
    'Parent',pp3_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 30 (mainPanelWidth-90)/2 25],...
    'String','points'...
    );
uicontrol('Tag','settings_panel_average_unit_text',...
    'Style','text',...
    'Parent',pp3_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(mainPanelWidth-90)/2 30 (mainPanelWidth-90)/2 25],...
    'String','unit'...
    );
uicontrol('Tag','settings_panel_average_x_text',...
    'Style','text',...
    'Parent',pp3_p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 35 20],...
    'String','x'...
    );
uicontrol('Tag','settings_panel_average_x_points_edit',...
    'Style','edit',...
    'Parent',pp3_p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 10 (mainPanelWidth-90)/2 25],...
    'String','1',...
    'Callback',{@average_edit_Callback,'xindex'}...
    );
uicontrol('Tag','settings_panel_average_x_unit_edit',...
    'Style','edit',...
    'Parent',pp3_p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60+(mainPanelWidth-90)/2 10 (mainPanelWidth-90)/2 25],...
    'String','0',...
    'Callback',{@average_edit_Callback,'xunit'}...
    );

% ------------------------------------------------------------------------
% UI controls for pp5
uicontrol('Tag','display_panel_min_text',...
    'Style','text',...
    'Parent',pp5,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','right',...
    'Units','Pixels',...
    'Position',[10 10 35 20],...
    'String','Min '...
    );
uicontrol('Tag','display_panel_min_edit',...
    'Style','edit',...
    'Parent',pp5,...
    'BackgroundColor',editableBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','center',...
    'Units','Pixels',...
    'Position',[50 10 110 25],...
    'String','-0.00011',...
    'TooltipString','Minimum in z',...
    'Enable','on',...
    'Callback',{@edit_Callback,'min'}...
    );
uicontrol('Tag','display_panel_max_text',...
    'Style','text',...
    'Parent',pp5,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','right',...
    'Units','Pixels',...
    'Position',[170 10 35 20],...
    'String','Max '...
    );
uicontrol('Tag','display_panel_max_edit',...
    'Style','edit',...
    'Parent',pp5,...
    'BackgroundColor',editableBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','center',...
    'Units','Pixels',...
    'Position',[210 10 110 25],...
    'String','0.00011',...
    'TooltipString','Maximum in z',...
    'Enable','on',...
    'Callback',{@edit_Callback,'max'}...
    );


% ------------------------------------------------------------------------
% UI controls for main window
uicontrol('Tag','zoom_togglebutton',...
    'Style','togglebutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'ForegroundColor',[0 0 0],...
    'FontUnit','Pixel','Fontsize',12,...
    'FontWeight','bold',...
    'String','+',...
    'TooltipString','Zoom',...
    'pos',[guiSize(1)-mainPanelWidth-20 32 25 25],...
    'Enable','on',...
    'Callback',{@togglebutton_Callback,'Zoom'}...
    );
uicontrol('Tag','help_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'ForegroundColor',[0 0 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'FontWeight','bold',...
    'String','?',...
    'TooltipString','Display help for how to operate the Combine GUI',...
    'pos',[guiSize(1)-mainPanelWidth+10 32 25 25],...
    'Enable','on',...
    'Callback',@TAgui_combine_helpwindow...
    );

uicontrol('Tag','apply_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Apply',...
    'TooltipString','Combine selected datasets to new dataset',...
    'pos',[guiSize(1)-((mainPanelWidth)/3*2)-25 20 guiSize(1)-(mainPanelWidth*2)-40 50],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'Apply'}...
    );
uicontrol('Tag','close_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Close',...
    'TooltipString','Close Combine GUI',...
    'pos',[guiSize(1)-((mainPanelWidth)/3)-20 20 (mainPanelWidth)/3+5 50],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'Close'}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Store handles in guidata
guidata(hMainFigure,guihandles);

% Set default parameters for parameters and configuration (to be on the
% safe side) - if there is more than one input parameter, these parameters
% will be overwritten.
ad.parameters = struct(...
    'method','time avg',...
    'master',1 ...
    );
ad.configuration = struct(...
    'avg',struct(...
        'start',0.15,...
        'end',1,...
        'patch',struct(...
            'edge','none',...
            'color',[0.5 0.5 1],...
            'alpha',0.4 ...
            )...
        ),...
    'smoothing',struct(...
        'method','boxcar',...
        'index',1 ...
        )...
    );

% Check for additional parameters (be very error tolerant)
if nargin > 1
    ad.parameters = varargin{1};
    if nargin > 2
        ad.configuration = varargin{2};
    end
end

% Scale - struct
% Used to store all necessary parameters of the scaling procedure.
% Gets finally returned to the caller.
ad.scale = struct(...
    'method',ad.parameters.method,...
    'master',ad.parameters.master,...
    'factor',1,...
    'parameters',struct(...
        'avg',struct(...
            'index',[],...
            'values',[],...
            'unit',''...
            ),...
        'smoothing',struct(...
            'index',[],...
            'values',[],...
            'unit',''...
            )...
        ),...
    'overlappingWavelength',[], ...
    'scaledArea',[] ...
    );

% TEMPORARY FIX
scaleTraces(1,:) = data{1}.data(...
    data{1}.axes.y.values==ad.parameters.overlappingWavelength,:);
scaleTraces(2,:) = data{2}.data(...
    data{2}.axes.y.values==ad.parameters.overlappingWavelength,:);

ad.scale.parameters.avg.index(1) = round(...
    length(scaleTraces(1,:))*ad.configuration.avg.index(1));
ad.scale.parameters.avg.index(2) = round(...
    length(scaleTraces(1,:))*ad.configuration.avg.index(2));
ad.scale.factor = 1;

setappdata(hMainFigure,'configuration',ad.configuration);
setappdata(hMainFigure,'parameters',ad.parameters);
setappdata(hMainFigure,'scale',ad.scale);

% Make the GUI visible.
set(hMainFigure,'Visible','on');
TAmsg('Combine GUI scaling parameters window opened','info');

updateAxis();
updatePanel();

% Add keypress function to every element that can have one...
handles = findall(...
    allchild(hMainFigure),'style','pushbutton',...
    '-or','style','togglebutton',...
    '-or','style','edit',...
    '-or','style','listbox',...
    '-or','style','popupmenu');
for m=1:length(handles)
    set(handles(m),'KeyPressFcn',@keypress_Callback);
end

% Assign default to output argument in case we get killed instead of
% properly closed...
if nargout
    varargout{1} = ad.scale;
end

% Important for the return parameter. Otherwise Matlab will throw errors.
uiwait;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function edit_Callback(source,~,field)
    try
        if isempty(field)
            return;
        end
        
        % Get appdata of main window
        mainWindow = guiGetWindowHandle(mfilename);
        ad = getappdata(mainWindow);
        
        value = get(source,'String');
        
        switch field
            case 'avgstartindex'
                value = str2double(value);
                if isnan(value)
                    value = ad.scale.parameters.avg.index(1);
                end
                if value<1
                    ad.scale.parameters.avg.index(1) = 1;
                elseif value>length(data{1}.data(1,:))
                    ad.scale.parameters.avg.index(1) = ...
                        length(data{1}.data(1,:));
                elseif value>ad.scale.parameters.avg.index(2)
                    ad.scale.parameters.avg.index(1) = ...
                        ad.scale.parameters.avg.index(2);
                else
                    ad.scale.parameters.avg.index(1) = value;
                end
                setappdata(mainWindow,'scale',ad.scale);
                updatePanel();  
                updateAxis();
            case 'avgstopindex'
                value = str2double(value);
                if isnan(value)
                    value = ad.scale.parameters.avg.index(2);
                end
                if value<1
                    ad.scale.parameters.avg.index(2) = 1;
                elseif value>length(data{1}.data(1,:))
                    ad.scale.parameters.avg.index(2) = ...
                        length(data{1}.data(1,:));
                elseif value<ad.scale.parameters.avg.index(1)
                    ad.scale.parameters.avg.index(2) = ...
                        ad.scale.parameters.avg.index(1);
                else
                    ad.scale.parameters.avg.index(2) = value;
                end
                setappdata(mainWindow,'scale',ad.scale);
                updatePanel();  
                updateAxis();
            otherwise
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

function pushbutton_Callback(~,~,action)
    try
        if isempty(action)
            return;
        end
        
        % Get appdata of main window
        mainWindow = guiGetWindowHandle(mfilename);
        ad = getappdata(mainWindow);

        switch action
            case 'averageReset'
                ad.scale.parameters.avg.index(1) = round(...
                    length(scaleTraces(1,:))*ad.configuration.avg.index(1));
                ad.scale.parameters.avg.index(2) = round(...
                    length(scaleTraces(1,:))*ad.configuration.avg.index(2));
                setappdata(mainWindow,'scale',ad.scale);
                updatePanel();
                updateAxis();
            case 'Apply'
                calculateScalingFactor()
            case 'Close'
                TAmsg('Combine GUI settings window closed.','info');
                delete(guiGetWindowHandle(mfilename));
                varargout{1} = ad.scale;
            otherwise
                disp(['TAgui_combine_settingswindow: '...
                    'pushbutton_Callback(): Unknown action "'...
                    action '"']);
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

function togglebutton_Callback(source,~,action)
    try
        if isempty(action)
            return;
        end
        
        % Get appdata of main window
        mainWindow = guiGetWindowHandle(mfilename);
        ad = getappdata(mainWindow);

        % Get state of toggle button
        value = get(source,'Value');
        
        % For those togglebuttons who do more complicated stuff
        % Toggle button
        if value % If toggle switched ON
            switch lower(action)
                case 'zoom'
                    % Reset pointer callback functions
                    set(hMainFigure,'WindowButtonMotionFcn','');
                    set(hMainFigure,'WindowButtonDownFcn','');
                    % Reset other zoom toggle button
                    zoom(hMainFigure,'on');
                    return;
                otherwise
                    disp(['TAgui_combine_settingswindow: ' ...
                        'togglebutton_Callback(): Unknown action '...
                        '"' action '"']);
                    return;
            end
        else % If toggle button switched OFF
            switch lower(action)
                case 'zoom'
                    zoom(hMainFigure,'off');
                    return;
                otherwise
                    disp(['TAgui_combine_settingswindow: ' ...
                        'togglebutton_Callback(): Unknown action '...
                        '"' action '"']);
                    return;
            end
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
            trEPRgui_bugreportwindow(exception);
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
        
        % Get appdata of main window
        mainWindow = guiGetWindowHandle(mfilename);
        ad = getappdata(mainWindow);
        
        values = cellstr(get(source,'String'));
        value = values{get(source,'Value')};
        
        switch lower(action)
            case 'scalingmethod'
                ad.scale.method = value;
                setappdata(mainWindow,'scale',ad.scale);
                updatePanel();
                updateAxis();
            otherwise
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

function keypress_Callback(src,evt)
    try
        if isempty(evt.Character) && isempty(evt.Key)
            % In case "Character" is the empty string, i.e. only modifier key
            % was pressed...
            return;
        end
        mainWindow = guiGetWindowHandle(mfilename);
        % Get appdata from combine GUI
        ad = getappdata(mainWindow);

        if ~isempty(evt.Modifier)
            if (strcmpi(evt.Modifier{1},'command')) || ...
                    (strcmpi(evt.Modifier{1},'control'))
                switch evt.Key
                    case 'w'
                        pushbutton_Callback(src,evt,'Close')
                        return;
                end
            end
        end
        switch evt.Key
            case 'f1'
                TAgui_combine_helpwindow();
                return;
            otherwise
%                 disp(evt);
%                 fprintf('       Caller: %i\n\n',src);
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

function updatePanel()
    try
        mainWindow = guiGetWindowHandle(mfilename);
        % Get appdata of combine GUI
        ad = getappdata(mainWindow);
        
        % Get handles of combine GUI
        gh = guihandles(mainWindow);
        
        % Set method popupmenu according to chosen method
        methods = cellstr(get(gh.method_panel_method_popupmenu,'String'));
        set(gh.method_panel_method_popupmenu,'Value',...
            find(strcmpi(ad.scale.method,methods)));
        
        switch ad.scale.method
            case 'time avg'
                % Switch visibility of panels
                set(pp2,'Visible','on');
                set(pp3,'Visible','off');

                % Update fields
                ad.scale.parameters.avg.values = data{1}.axes.x.values(...
                    ad.scale.parameters.avg.index);
                set(gh.average_start_index_edit,'String',num2str(...
                    ad.scale.parameters.avg.index(1)));
                set(gh.average_start_unit_edit,'String',num2str(...
                    ad.scale.parameters.avg.values(1)));
                set(gh.average_stop_index_edit,'String',num2str(...
                    ad.scale.parameters.avg.index(2)));
                set(gh.average_stop_unit_edit,'String',num2str(...
                    ad.scale.parameters.avg.values(2)));
                setappdata(mainWindow,'scale',ad.scale);
            case 'min(diff)'
                % Switch visibility of panels
                set(pp3,'Visible','on');
                set(pp2,'Visible','off');
                
                % Update fields
            otherwise
                disp(['TAgui_combine_settingswindow : updateAxis() : '...
                    'unknown method "' ad.scale.method '"']);
        end
    catch exception
        try
            msgStr = ['An exception occurred in ' ...
                exception.stack(1).name  '.'];
            TAmsg(msgStr,'error');
        catch exception2
            exception = addcause(exception2, exception);
            disp(msgstr);
        end
        try
            TAgui_bugreportwindow(exception);
        catch exception3
            % if even displaying the bug report window fails...
            exception = addcause(exception3, exception);
            throw(exception);
        end
    end
end

function updateAxis()
    try
        mainWindow = guiGetWindowHandle(mfilename);
        % Get appdata of combine GUI
        ad = getappdata(mainWindow);
        
        % Get handles of combine GUI
        gh = guihandles(mainWindow);
        
        % Clear axis
        cla(gh.mainAxis);
                
        switch ad.scale.method
            case 'time avg'
                % Plot traces
                hold on;
                plot(gh.mainAxis,scaleTraces(1,:),'k-');
                plot(gh.mainAxis,scaleTraces(2,:),'r-');
                hold off;
                ylim = get(gh.mainAxis,'YLim');
                % Plot AVG area
                patch(...
                    'XData',[...
                    ad.scale.parameters.avg.index(1) ad.scale.parameters.avg.index(1)...
                    ad.scale.parameters.avg.index(2) ad.scale.parameters.avg.index(2)],...
                    'YData',[ylim(1) ylim(end) ylim(end) ylim(1)],...
                    'ZData',[0 0 0 0],...
                    'EdgeColor',ad.configuration.avg.patch.edge,...
                    'FaceColor',ad.configuration.avg.patch.color,...
                    'FaceAlpha',ad.configuration.avg.patch.alpha,...
                    'Parent',gh.mainAxis);
            case 'min(diff)'
                % TODO: Apply smoothing if necessary
                % Plot traces
                hold on;
                plot(gh.mainAxis,scaleTraces(1,:),'k-');
                plot(gh.mainAxis,scaleTraces(2,:),'r-');
                hold off;
            otherwise
                disp(['TAgui_combine_settingswindow : updateAxis() : '...
                    'unknown method "' ad.scale.method '"']);
        end
    catch exception
        try
            msgStr = ['An exception occurred in ' ...
                exception.stack(1).name  '.'];
            TAmsg(msgStr,'error');
        catch exception2
            exception = addcause(exception2, exception);
            disp(msgstr);
        end
        try
            TAgui_bugreportwindow(exception);
        catch exception3
            % if even displaying the bug report window fails...
            exception = addcause(exception3, exception);
            throw(exception);
        end
    end
end

function calculateScalingFactor()
    try
        mainWindow = guiGetWindowHandle(mfilename);
        % Get appdata of combine GUI
        ad = getappdata(mainWindow);
        
        % Get handles of combine GUI
        gh = guihandles(mainWindow);
        
        ad.scale = TAscale('factor',data,ad.scale);

        setappdata(mainWindow,'scale',ad.scale);
        set(gh.method_panel_factor_edit,'String',...
            num2str(ad.scale.factor));
    catch exception
        try
            msgStr = ['An exception occurred in ' ...
                exception.stack(1).name  '.'];
            TAmsg(msgStr,'error');
        catch exception2
            exception = addcause(exception2, exception);
            disp(msgstr);
        end
        try
            TAgui_bugreportwindow(exception);
        catch exception3
            % if even displaying the bug report window fails...
            exception = addcause(exception3, exception);
            throw(exception);
        end
    end
end

end