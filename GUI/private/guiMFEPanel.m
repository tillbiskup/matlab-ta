function handle = guiMFEPanel(parentHandle,position)
% GUIMFEPANEL Add a panel adding MFE mfe controls to a gui
%       Should only be called from within a GUI defining function.
%
%       Arguments: parent Handle and position vector.
%
%       Returns the handle of the added panel.

% (c) 2011-12, Till Biskup
% 2012-02-23

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

defaultBackground = get(parentHandle,'Color');

handle = uipanel('Tag','mfe_panel',...
    'parent',parentHandle,...
    'Title','Magnetic Field Effect (MFE)',...
    'FontUnit','Pixel','Fontsize',12,...
    'FontWeight','bold',...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'Units','pixels','Position',position);

% Create the "Help" panel
handle_size = get(handle,'Position');
uicontrol('Tag','mfe_panel_description',...
    'Style','text',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 handle_size(4)-60 handle_size(3)-20 30],...
    'String',{'MFE tools. To calculate MFEs, use the "MFE" button at the bottom left. '}...
    );

p1 = uipanel('Tag','mfe_panel_displaymode_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-120 handle_size(3)-20 50],...
    'Title','MFE display type'...
    );
uicontrol('Tag','mfe_panel_displaymode_popupmenu',...
    'Style','popupmenu',...
    'Parent',p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-40 20],...
    'String','MFoff|MFoff+MFon|MFoff+MFon+DeltaMF|MFon|DeltaMF|sum(MFoff,MFon)|relative MFE',...
    'Value',1, ...
    'Callback',@mfe_displaymode_Callback ...
    );

p2 = uipanel('Tag','mfe_panel_line_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-450 handle_size(3)-20 320],...
    'Title','Line settings'...
    );
uicontrol('Tag','mfe_panel_highlight_checkbox',...
    'Style','checkbox',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[80 270 handle_size(3)-105 20],...
    'String',' Highlight active',...
    'TooltipString','Toggle between highlighting currently active dataset',...
    'Value',1,...
    'Callback',{@checkbox_Callback,'highlight'}...
    );
uicontrol('Tag','mfe_panel_line_text',...
    'Style','text',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 238 60 20],...
    'String','Line'...
    );
uicontrol('Tag','mfe_panel_line_popupmenu',...
    'Style','popupmenu',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[80 240 handle_size(3)-110 20],...
    'String','MFoff|MFon|DeltaMF',...
    'Callback',{@popupmenu_Callback,'line'}...
    );
uicontrol('Tag','mfe_panel_colour_text',...
    'Style','text',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 203 60 20],...
    'String','Colour'...
    );
uicontrol('Tag','mfe_panel_coloursample_text',...
    'Style','text',...
    'Parent',p2,...
    'BackgroundColor',[0 0 0],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[80 202 40 25],...
    'String',''...
    );
uicontrol('Tag','mfe_panel_colour_pushbutton',...
    'Style','pushbutton',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'Enable','on',...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[130 200 100 30],...
    'String','Palette...',...
    'Callback',{@pushbutton_Callback,'colourPalette'}...
    );
uicontrol('Tag','mfe_panel_linewidth_text',...
    'Style','text',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 168 60 20],...
    'String','Width'...
    );
uicontrol('Tag','mfe_panel_linewidth_popupmenu',...
    'Style','popupmenu',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[80 170 handle_size(3)-110 20],...
    'String','1 px|2 px|3 px|4 px|5 px',...
    'Callback',{@popupmenu_Callback,'linewidth'}...
    );
uicontrol('Tag','mfe_panel_linestyle_text',...
    'Style','text',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 138 60 20],...
    'String','Style'...
    );
uicontrol('Tag','mfe_panel_linestyle_popupmenu',...
    'Style','popupmenu',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[80 140 handle_size(3)-110 20],...
    'String','solid|dashed|dotted|dash-dotted|none',...
    'Callback',{@popupmenu_Callback,'linestyle'}...
    );
uicontrol('Tag','mfe_panel_linemarker_text',...
    'Style','text',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'FontAngle','Oblique',...
    'Units','Pixels',...
    'Position',[10 108 60 20],...
    'String','Marker'...
    );
uicontrol('Tag','mfe_panel_linemarker_popupmenu',...
    'Style','popupmenu',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[80 110 handle_size(3)-110 20],...
    'String',['none|plus|circle|asterisk|point|cross|square|diamond|'...
    'triangle up|triangle down|triangle right|triangle left|'...
    'pentagram|hexagram'],...
    'Callback',{@popupmenu_Callback,'linemarker'}...
    );
uicontrol('Tag','display_panel_markeredgecolour_text',...
    'Style','text',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Right',...
    'Units','Pixels',...
    'Position',[10 78 60 20],...
    'String','Edge'...
    );
uicontrol('Tag','mfe_panel_markeredgecolour_popupmenu',...
    'Style','popupmenu',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[80 80 handle_size(3)-180 20],...
    'String','auto|none|colour',...
    'Value',1,...
    'Callback',{@popupmenu_Callback,'markerEdgeColour'}...
    );
uicontrol('Tag','mfe_panel_markeredgecoloursample_text',...
    'Style','text',...
    'Parent',p2,...
    'BackgroundColor',[0 0 0],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[165 77 35 25],...
    'String',''...
    );
uicontrol('Tag','mfe_panel_markeredgecolour_pushbutton',...
    'Style','pushbutton',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'Enable','on',...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[205 77 25 25],...
    'String','...',...
    'TooltipString',sprintf('%s\n%s',...
    'Open colour palette for specifying','marker edge colour'),...
    'Callback',{@pushbutton_Callback,'markerEdgeColourPalette'}...
    );
uicontrol('Tag','mfe_panel_markerfacecolour_text',...
    'Style','text',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Right',...
    'Units','Pixels',...
    'Position',[10 43 60 20],...
    'String','Face'...
    );
uicontrol('Tag','mfe_panel_markerfacecolour_popupmenu',...
    'Style','popupmenu',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[80 45 handle_size(3)-180 20],...
    'String','auto|none|colour',...
    'Value',2,...
    'Callback',{@popupmenu_Callback,'markerFaceColour'}...
    );
uicontrol('Tag','mfe_panel_markerfacecoloursample_text',...
    'Style','text',...
    'Parent',p2,...
    'BackgroundColor',[0 0 0],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[165 42 35 25],...
    'String',''...
    );
uicontrol('Tag','mfe_panel_markerfacecolour_pushbutton',...
    'Style','pushbutton',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'Enable','on',...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[205 42 25 25],...
    'String','...',...
    'TooltipString',sprintf('%s\n%s',...
    'Open colour palette for specifying','marker face colour'),...
    'Callback',{@pushbutton_Callback,'markerFaceColourPalette'}...
    );
uicontrol('Tag','mfe_panel_markersize_text',...
    'Style','text',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Right',...
    'Units','Pixels',...
    'Position',[10 10 60 20],...
    'String','Size'...
    );
uicontrol('Tag','mfe_panel_markersize_edit',...
    'Style','edit',...
    'Parent',p2,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[80 10 50 25],...
    'String','6',...
    'Callback',{@edit_Callback,'markerSize'}...
    );
uicontrol('Tag','mfe_panel_markersize_text',...
    'Style','text',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','center',...
    'Units','Pixels',...
    'Position',[130 10 30 20],...
    'String','pt'...
    );
uicontrol('Tag','mfe_panel_markerdefaults_pushbutton',...
    'Style','pushbutton',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'Enable','on',...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[160 10 70 25],...
    'String','Default',...
    'TooltipString',sprintf('%s\n%s',...
    'Set marker settings (edge, face, size)','to default values.'),...
    'Callback',{@pushbutton_Callback,'markerDefaults'}...
    );

% uicontrol('Tag','mfe_panel_calculatemfe_pushbutton',...
%     'Style','pushbutton',...
% 	'Parent', handle, ...
%     'BackgroundColor',defaultBackground,...
%     'FontUnit','Pixel','Fontsize',12,...
%     'String','Calculate MFE',...
%     'TooltipString','Calculate time-averaged MFE (new window)',...
%     'pos',[10+(handle_size(3)-20)/2 handle_size(4)-470 (handle_size(3)-20)/2 40],...
%     'Enable','on',...
%     'Callback',{@TAgui_MFEwindow}...
%     );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mfe_displaymode_Callback(source,~)
    try
        % Get appdata of main window
        mainWindow = guiGetWindowHandle;
        ad = getappdata(mainWindow);
        
        % Get value from load_panel_filetype_popupmenu
        MFEdisplayModes = cellstr(get(source,'String'));
        MFEdisplayMode = MFEdisplayModes{get(source,'Value')};
        
        ad.control.axis.MFEdisplay = MFEdisplayMode;
        
        % Update appdata of main window
        setappdata(mainWindow,'control',ad.control);
        
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
        mainWindow = guiGetWindowHandle();
        ad = getappdata(mainWindow);
        
        % Get handles of main window
        gh = guihandles(mainWindow);

        switch lower(action)
            case 'highlight'
                if (get(source,'Value'))
                    set(gh.display_panel_highlight_method_popupmenu,...
                        'Enable','On');
                    set(gh.display_panel_highlight_value_popupmenu,...
                        'Enable','On');
                    highlightTypes = ...
                        cellstr(get(...
                        gh.display_panel_highlight_method_popupmenu,...
                        'String'));
                    highlightType = ...
                        highlightTypes{get(...
                        gh.display_panel_highlight_method_popupmenu,...
                        'Value')};
                    ad.control.axis.highlight.method = highlightType;
                else
                    set(gh.display_panel_highlight_method_popupmenu,...
                        'Enable','Off');
                    set(gh.display_panel_highlight_value_popupmenu,...
                        'Enable','Off');
                    ad.control.axis.highlight.method = '';
                end
                
                % Update appdata of main window
                setappdata(mainWindow,'control',ad.control);
                
                %Update main axis
                update_mainAxis();
            otherwise
                disp('TAgui : guiMFEPanel() : checkbox_Callback(): Unknown action');
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
        
        % Get appdata of main window
        mainWindow = guiGetWindowHandle();
        ad = getappdata(mainWindow);
        
        % Get handles of main window
        gh = guihandles(mainWindow);

        % Get line type currently selected (MFoff/MFon/DeltaMF)
        MFElines = cellstr(get(gh.mfe_panel_line_popupmenu,'String'));
        MFEline = MFElines{get(gh.mfe_panel_line_popupmenu,'Value')};
        
        % Get string of the currently selected popupmenu item
        sourceStrings = cellstr(get(source,'String'));
        sourceString = sourceStrings{get(source,'Value')};
        
        % Make life easier
        active = ad.control.spectra.active;
        
        % For safety, return immediately if there is no active dataset
        if active == 0
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
        
        switch lower(action)
            case 'line'
                % Update MFE panel
                update_MFEPanel();
            case 'linewidth'
                % convert source string into number
                sourceString = str2double(sourceString(1:end-3));
                switch MFEline
                    case 'MFoff'
                        ad.data{active}.line.width = sourceString;
                    case 'MFon'
                        ad.data{active}.display.MFon.line.width = ...
                            sourceString;
                    case 'DeltaMF'
                        ad.data{active}.display.DeltaMF.line.width = ...
                            sourceString;
                    otherwise
                        disp(['TAgui : guiMFEPanel() : '...
                            'popupmenu_Callback(): Unknown MFElineType '...
                            '"' MFEline '"']);
                end
            case 'linestyle'
                sourceString = lineStyles{...
                    strcmpi(sourceString,lineStyles(:,1)),2};
                switch MFEline
                    case 'MFoff'
                        ad.data{active}.line.style = sourceString;
                    case 'MFon'
                        ad.data{active}.display.MFon.line.style = ...
                            sourceString;
                    case 'DeltaMF'
                        ad.data{active}.display.DeltaMF.line.style = ...
                            sourceString;
                    otherwise
                        disp(['TAgui : guiMFEPanel() : '...
                            'popupmenu_Callback(): Unknown MFElineType '...
                            '"' MFEline '"']);
                end
            case 'linemarker'
                sourceString = lineMarker{...
                    strcmpi(sourceString,lineMarker(:,1)),2};
                switch MFEline
                    case 'MFoff'
                        ad.data{active}.line.marker.type = sourceString;
                    case 'MFon'
                        ad.data{active}.display.MFon.line.marker.type = ...
                            sourceString;
                    case 'DeltaMF'
                        ad.data{active}.display.DeltaMF.line.marker.type = ...
                            sourceString;
                    otherwise
                        disp(['TAgui : guiMFEPanel() : '...
                            'popupmenu_Callback(): Unknown MFElineType '...
                            '"' MFEline '"']);
                end
            case 'markeredgecolour'
                switch MFEline
                    case 'MFoff'
                        if strcmpi(sourceString,'colour')
                            ad.data{active}.line.marker.edgeColor = ...
                                ad.data{active}.line.color;
                        else
                            ad.data{active}.line.marker.edgeColor = ...
                                sourceString;
                        end
                    case 'MFon'
                        if strcmpi(sourceString,'colour')
                            ad.data{active}.display.MFon.line.marker.edgeColor = ...
                                ad.data{active}.display.MFon.line.color;
                        else
                            ad.data{active}.display.MFon.line.marker.edgeColor = ...
                                sourceString;
                        end
                    case 'DeltaMF'
                        if strcmpi(sourceString,'colour')
                            ad.data{active}.display.DeltaMF.line.marker.edgeColor = ...
                                ad.data{active}.display.DeltaMF.line.color;
                        else
                            ad.data{active}.display.DeltaMF.line.marker.edgeColor = ...
                                sourceString;
                        end
                    otherwise
                        disp(['TAgui : guiMFEPanel() : '...
                            'popupmenu_Callback(): Unknown MFElineType '...
                            '"' MFEline '"']);
                end
            case 'markerfacecolour'
                switch MFEline
                    case 'MFoff'
                        if strcmpi(sourceString,'colour')
                            ad.data{active}.line.marker.faceColor = ...
                                ad.data{active}.line.color;
                        else
                            ad.data{active}.line.marker.faceColor = ...
                                sourceString;
                        end
                    case 'MFon'
                        if strcmpi(sourceString,'colour')
                            ad.data{active}.display.MFon.line.marker.faceColor = ...
                                ad.data{active}.display.MFon.line.color;
                        else
                            ad.data{active}.display.MFon.line.marker.faceColor = ...
                                sourceString;
                        end
                    case 'DeltaMF'
                        if strcmpi(sourceString,'colour')
                            ad.data{active}.display.DeltaMF.line.marker.faceColor = ...
                                ad.data{active}.display.DeltaMF.line.color;
                        else
                            ad.data{active}.display.DeltaMF.line.marker.faceColor = ...
                                sourceString;
                        end
                    otherwise
                        disp(['TAgui : guiMFEPanel() : '...
                            'popupmenu_Callback(): Unknown MFElineType '...
                            '"' MFEline '"']);
                end
            otherwise
                disp(['TAgui : guiMFEPanel() : popupmenu_Callback(): '...
                    'Unknown action "' action '"']);
                return;
        end
        
        % Update appdata of main window
        setappdata(mainWindow,'data',ad.data);
        
        % Update MFE panel
        update_MFEPanel();
        
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
        mainWindow = guiGetWindowHandle();
        ad = getappdata(mainWindow);
        
        % Get handles of main window
        gh = guihandles(mainWindow);
        
        % Make life easier
        active = ad.control.spectra.active;
        
        % Return immediately if there is no active dataset
        if active == 0
            return;
        end
        
        % Get line type currently selected (MFoff/MFon/DeltaMF)
        MFElines = cellstr(get(gh.mfe_panel_line_popupmenu,'String'));
        MFEline = MFElines{get(gh.mfe_panel_line_popupmenu,'Value')};

        colors = {...
            'b',[0 0 1]; ...
            'g',[0 1 0]; ...
            'r',[1 0 0]; ...
            'c',[0 1 1]; ...
            'm',[1 0 1]; ...
            'y',[1 1 0]; ...
            'k',[0 0 0]; ...
            'w',[1 1 1]; ...
            };
        
        switch action
            case 'colourPalette'
                switch MFEline
                    case 'MFoff'
                        % Convert string in RGB triple if necessary
                        if ischar(ad.data{active}.line.color)
                            ad.data{active}.line.color = colors{...
                                strcmpi(ad.data{active}.line.color,...
                                colors(:,1)),2};
                        end
                        ad.data{active}.line.color = uisetcolor(...
                            ad.data{active}.line.color,...
                            'Set MFoff line colour');
                    case 'MFon'
                        % Convert string in RGB triple if necessary
                        if ischar(ad.data{active}.display.MFon.line.color)
                            ad.data{active}.display.MFon.line.color = colors{...
                                strcmpi(ad.data{active}.display.MFon.line.color,...
                                colors(:,1)),2};
                        end
                        ad.data{active}.display.MFon.line.color = ...
                            uisetcolor(...
                            ad.data{active}.display.MFon.line.color,...
                            'Set MFon line colour');
                    case 'DeltaMF'
                        % Convert string in RGB triple if necessary
                        if ischar(ad.data{active}.display.DeltaMF.line.color)
                            ad.data{active}.display.DeltaMF.line.color = colors{...
                                strcmpi(ad.data{active}.display.DeltaMF.line.color,...
                                colors(:,1)),2};
                        end
                        ad.data{active}.display.DeltaMF.line.color = ...
                            uisetcolor(...
                            ad.data{active}.display.DeltaMF.line.color,...
                            'Set DeltaMF line colour');
                    otherwise
                        disp(['TAgui : guiMFEPanel() : '...
                            'pushbutton_Callback(): Unknown MFElineType '...
                            '"' MFEline '"']);
                end
        
                % Update appdata of main window
                setappdata(mainWindow,'data',ad.data);
                
                % Update MFE panel
                update_MFEPanel();
                
                % Update main axis
                update_mainAxis();
                return;
            case 'markerEdgeColourPalette'
                switch MFEline
                    case 'MFoff'
                        % Convert string in RGB triple if necessary
                        if ischar(ad.data{active}.line.marker.edgeColor)
                            ad.data{active}.line.marker.edgeColor = colors{...
                                strcmpi(ad.data{active}.line.marker.edgeColor,...
                                colors(:,1)),2};
                        end
                        ad.data{active}.line.marker.edgeColor = uisetcolor(...
                            ad.data{active}.line.marker.edgeColor,...
                            'Set MFoff line marker edge colour');
                    case 'MFon'
                        % Convert string in RGB triple if necessary
                        if ischar(ad.data{active}.display.MFon.line.marker.edgeColor)
                            ad.data{active}.display.MFon.line.marker.edgeColor = colors{...
                                strcmpi(ad.data{active}.display.MFon.line.marker.edgeColor,...
                                colors(:,1)),2};
                        end
                        ad.data{active}.display.MFon.line.marker.edgeColor = ...
                            uisetcolor(...
                            ad.data{active}.display.MFon.line.marker.edgeColor,...
                            'Set MFon line marker edge colour');
                    case 'DeltaMF'
                        % Convert string in RGB triple if necessary
                        if ischar(ad.data{active}.display.DeltaMF.line.marker.edgeColor)
                            ad.data{active}.display.DeltaMF.line.marker.edgeColor = colors{...
                                strcmpi(ad.data{active}.display.DeltaMF.line.marker.edgeColor,...
                                colors(:,1)),2};
                        end
                        ad.data{active}.display.DeltaMF.line.marker.edgeColor = ...
                            uisetcolor(...
                            ad.data{active}.display.DeltaMF.line.marker.edgeColor,...
                            'Set DeltaMF line marker edge colour');
                    otherwise
                        disp(['TAgui : guiMFEPanel() : '...
                            'pushbutton_Callback(): Unknown MFElineType '...
                            '"' MFEline '"']);
                end
        
                % Update appdata of main window
                setappdata(mainWindow,'data',ad.data);
                
                % Update MFE panel
                update_MFEPanel();
                
                % Update main axis
                update_mainAxis();
                return;
            case 'markerFaceColourPalette'
                switch MFEline
                    case 'MFoff'
                        % Convert string in RGB triple if necessary
                        if ischar(ad.data{active}.line.marker.faceColor)
                            ad.data{active}.line.marker.faceColor = colors{...
                                strcmpi(ad.data{active}.line.marker.faceColor,...
                                colors(:,1)),2};
                        end
                        ad.data{active}.line.marker.faceColor = uisetcolor(...
                            ad.data{active}.line.marker.faceColor,...
                            'Set MFoff line marker face colour');
                    case 'MFon'
                        % Convert string in RGB triple if necessary
                        if ischar(ad.data{active}.display.MFon.line.marker.faceColor)
                            ad.data{active}.display.MFon.line.marker.faceColor = colors{...
                                strcmpi(ad.data{active}.display.MFon.line.marker.faceColor,...
                                colors(:,1)),2};
                        end
                        ad.data{active}.display.MFon.line.marker.faceColor = ...
                            uisetcolor(...
                            ad.data{active}.display.MFon.line.marker.faceColor,...
                            'Set MFon line marker face colour');
                    case 'DeltaMF'
                        % Convert string in RGB triple if necessary
                        if ischar(ad.data{active}.display.DeltaMF.line.marker.faceColor)
                            ad.data{active}.display.DeltaMF.line.marker.faceColor = colors{...
                                strcmpi(ad.data{active}.display.DeltaMF.line.marker.faceColor,...
                                colors(:,1)),2};
                        end
                        ad.data{active}.display.DeltaMF.line.marker.faceColor = ...
                            uisetcolor(...
                            ad.data{active}.display.DeltaMF.line.marker.faceColor,...
                            'Set DeltaMF line marker face colour');
                    otherwise
                        disp(['TAgui : guiMFEPanel() : '...
                            'pushbutton_Callback(): Unknown MFElineType '...
                            '"' MFEline '"']);
                end
        
                % Update appdata of main window
                setappdata(mainWindow,'data',ad.data);
                
                % Update MFE panel
                update_MFEPanel();
                
                % Update main axis
                update_mainAxis();
                return;
            case 'markerDefaults'
                switch MFEline
                    case 'MFoff'
                        ad.data{active}.line.marker.type = 'none';
                        ad.data{active}.line.marker.edgeColor = 'auto';
                        ad.data{active}.line.marker.faceColor = 'none';
                        ad.data{active}.line.marker.size = 6;
                    case 'MFon'
                        ad.data{active}.display.MFon.line.marker.type = 'none';
                        ad.data{active}.display.MFon.line.marker.edgeColor = 'auto';
                        ad.data{active}.display.MFon.line.marker.faceColor = 'none';
                        ad.data{active}.display.MFon.line.marker.size = 6;
                    case 'DeltaMF'
                        ad.data{active}.display.DeltaMF.line.marker.type = 'none';
                        ad.data{active}.display.DeltaMF.line.marker.edgeColor = 'auto';
                        ad.data{active}.display.DeltaMF.line.marker.faceColor = 'none';
                        ad.data{active}.display.DeltaMF.line.marker.size = 6;
                    otherwise
                        disp(['TAgui : guiMFEPanel() : '...
                            'pushbutton_Callback(): Unknown MFElineType '...
                            '"' MFEline '"']);
                end
                % Update appdata of main window
                setappdata(mainWindow,'data',ad.data);
                
                % Update display panel
                update_MFEPanel();
                
                % Update main axis
                update_mainAxis();
                return;                
            otherwise
                disp('TAgui : guiMFEPanel() : pushbutton_Callback(): Unknown action');
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
            TAgui_bugreportwindow(exception);
        catch exception3
            % If even displaying the bug report window fails...
            exception = addCause(exception3, exception);
            throw(exception);
        end
    end
end

function edit_Callback(source,~,action)
    try
        if isempty(action)
            return;
        end
        
        % Get appdata of main GUI
        mainWindow = guiGetWindowHandle();
        ad = getappdata(mainWindow);
        
        % Get handles of main window
        gh = guihandles(mainWindow);
        
        active = ad.control.spectra.active;
        if isempty(active) && ~active
            return;
        end
        
        % Get line type currently selected (MFoff/MFon/DeltaMF)
        MFElines = cellstr(get(gh.mfe_panel_line_popupmenu,'String'));
        MFEline = MFElines{get(gh.mfe_panel_line_popupmenu,'Value')};
        
        switch action
            case 'markerSize'
                switch MFEline
                    case 'MFoff'
                        ad.data{active}.line.marker.size = ...
                            str2double(strrep(get(source,'String'),',','.'));
                    case 'MFon'
                        ad.data{active}.display.MFon.line.marker.size = ...
                            str2double(strrep(get(source,'String'),',','.'));
                    case 'DeltaMF'
                        ad.data{active}.display.DeltaMF.line.marker.size = ...
                            str2double(strrep(get(source,'String'),',','.'));
                    otherwise
                        disp(['TAgui : guiMFEPanel() : '...
                            'edit_Callback(): Unknown MFElineType '...
                            '"' MFEline '"']);
                end
            otherwise
                disp(['TAgui_MFEwindow() : edit_Callback() : '...
                    'Unknown action "' action '"']);
                return;
        end
        setappdata(mainWindow,'data',ad.data);
        % Update display panel
        update_displayPanel();
        % Update main axis
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