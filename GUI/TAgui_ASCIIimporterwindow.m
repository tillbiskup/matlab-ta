function varargout = TAgui_ASCIIimporterwindow(varargin)
% TAGUI_ASCIIIMPORTERWINDOW Window for importing (arbitrary) ASCII data and
% specifying some parameters for proper import of these data.
%
% Normally, this window is called from within the TAgui window. 
%
% See also TAGUI, TALOAD

% (c) 2013, Till Biskup
% 2013-07-15

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make GUI effectively a singleton
singleton = findobj('Tag',mfilename);
if (singleton)
    figure(singleton);
    if nargout
        varargout{1} = singleton;
    end
    return;
end

guiPosition = [110,190,850,600];
% Try to get main GUI position
mainGUIHandle = TAguiGetWindowHandle();
if ishandle(mainGUIHandle)
    mainGUIPosition = get(mainGUIHandle,'Position');
    guiPosition = [mainGUIPosition(1)+40,mainGUIPosition(2)+50,...
        guiPosition(3), guiPosition(4)];
else
    disp('No TA GUI main window found. Bye...');
    return;
end

%  Construct the components
hMainFigure = figure('Tag',mfilename,...
    'Visible','off',...
    'Name','TA GUI : ASCII Import',...
    'Units','Pixels',...
    'Position',guiPosition,...
    'Resize','off',...
    'KeyPressFcn',@keypress_Callback,...
    'NumberTitle','off', ...
    'Menu','none','Toolbar','none');

defaultBackground = get(hMainFigure,'Color');
guiSize = get(hMainFigure,'Position');
guiSize = guiSize([3,4]);

p1 = uipanel('Tag','filename_panel',...
    'parent',hMainFigure,...
    'Title','Filename',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','on',...
    'Units','pixels',...
    'Position',[10 guiSize(2)-70 guiSize(1)-290 60] ...
    );
uicontrol('Tag','filename_edit',...
    'Style','edit',...
    'Parent',p1,...
    'BackgroundColor',[1 1 1],...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'Position',[10 10 guiSize(1)-290-60 30],...
    'Enable','on',...
    'FontSize',12,...
    'FontName','Monospaced',...
    'String','');
uicontrol('Tag','chfilename_pushbutton',...
    'Style','pushbutton',...
	'Parent', p1, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','...',...
    'TooltipString','Open file selection dialogue',...
    'pos',[guiSize(1)-290-10-30 10 30 30],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'fileselect'}...
    );

p2 = uipanel('Tag','file_panel',...
    'parent',hMainFigure,...
    'Title','File display',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','on',...
    'Units','pixels',...
    'Position',[10 10 guiSize(1)-290 guiSize(2)-90] ...
    );
hFileDisplay = uicontrol('Tag','file_text',...
    'Style','edit',...
    'Parent',p2,...
    'BackgroundColor',[1 1 1],...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'Position',[10 10 guiSize(1)-290-20 guiSize(2)-120],...
    'Enable','on',...
    'Max',2,'Min',0,...
    'FontSize',12,...
    'FontName','Monospaced',...
    'String','');

p3 = uipanel('Tag','settings_panel',...
    'parent',hMainFigure,...
    'Title','Settings',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','on',...
    'Units','pixels',...
    'Position',[guiSize(1)-270 55 260 guiSize(2)-65] ...
    );
p3p1 = uipanel('Tag','settings_panel_template_panel',...
    'parent',p3,...
    'Title','Template',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','on',...
    'Units','pixels',...
    'Position',[10 guiSize(2)-130 240 50] ...
    );
uicontrol('Tag','settings_panel_template_popupmenu',...
    'Style','popupmenu',...
    'Parent',p3p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 220 20],...
    'String','none',...
    'Value',1 ...
    );
p3p2 = uipanel('Tag','settings_panel_general_panel',...
    'parent',p3,...
    'Title','General',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','on',...
    'Units','pixels',...
    'Position',[10 guiSize(2)-220 240 85] ...
    );
uicontrol('Tag','settings_panel_separator_text',...
    'Style','text',...
    'Parent',p3p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'Units','Pixels',...
    'Position',[10 40 70 20],...
    'String','Separator:'...
    );
uicontrol('Tag','settings_panel_separator_edit',...
    'Style','edit',...
    'Parent',p3p2,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[80 40 40 25],...
    'String','',...
    'TooltipString',sprintf('%s\n%s',...
    'Use "\t" for tabulator.',...
    'Leave blank for automatic determination.'),...
    'Callback',{@edit_Callback,'separator'}...
    );
uicontrol('Tag','settings_panel_nheaderlines_text',...
    'Style','text',...
    'Parent',p3p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'Units','Pixels',...
    'Position',[130 40 60 20],...
    'String','Header:'...
    );
uicontrol('Tag','settings_panel_nheaderlines_edit',...
    'Style','edit',...
    'Parent',p3p2,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[190 40 40 25],...
    'String','0',...
    'Tooltip','Number of header lines',...
    'Callback',{@edit_Callback,'nheaderlines'}...
    );
uicontrol('Tag','settings_panel_dimensions_text',...
    'Style','text',...
    'Parent',p3p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'Units','Pixels',...
    'Position',[10 8 40 20],...
    'String','Dim.:'...
    );
uicontrol('Tag','settings_panel_dimensions_popupmenu',...
    'Style','popupmenu',...
    'Parent',p3p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[50 10 70 20],...
    'String',{'X','Y','2D'},...
    'Value',3 ...
    );
uicontrol('Tag','settings_panel_dimensions_transpose_checkbox',...
    'Style','checkbox',...
    'Parent',p3p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[130 10 240-130-10 20],...
    'TooltipString','Transpose dataset (flip x and y dimension)',...
    'String',' Transpose'...
    );
p3p3 = uipanel('Tag','settings_panel_xaxis_panel',...
    'parent',p3,...
    'Title','X Axis',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','on',...
    'Units','pixels',...
    'Position',[10 guiSize(2)-345 240 120] ...
    );
uicontrol('Tag','settings_panel_xaxis_label_text',...
    'Style','text',...
    'Parent',p3p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'Units','Pixels',...
    'Position',[10 75 50 20],...
    'String','Label:'...
    );
uicontrol('Tag','settings_panel_xaxis_measure_edit',...
    'Style','edit',...
    'Parent',p3p3,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 75 110 25],...
    'String','',...
    'TooltipString','Enter x axis measure here',...
    'Callback',{@edit_Callback,'xmeasure'}...
    );
uicontrol('Tag','settings_panel_xaxis_divider_text',...
    'Style','text',...
    'Parent',p3p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Center',...
    'Units','Pixels',...
    'Position',[170 75 10 20],...
    'String','/'...
    );
uicontrol('Tag','settings_panel_xaxis_unit_edit',...
    'Style','edit',...
    'Parent',p3p3,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[180 75 50 25],...
    'String','',...
    'TooltipString','Enter x axis unit here',...
    'Callback',{@edit_Callback,'xunit'}...
    );
uicontrol('Tag','settings_panel_xaxis_values_text',...
    'Style','text',...
    'Parent',p3p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'Units','Pixels',...
    'Position',[10 42 80 20],...
    'String','Values:'...
    );
uicontrol('Tag','settings_panel_xaxis_values_popupmenu',...
    'Style','popupmenu',...
    'Parent',p3p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[90 45 240-10-90 20],...
    'String',{'row/column','range','index'},...
    'Value',3,...
    'Callback',{@popupmenu_Callback,'xvalues'}...
    );
p3p3rowcol = uipanel('Tag','settings_panel_xaxis_values_rowcol_panel',...
    'parent',p3p3,...
    'Title','',...
    'BorderType','none',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'Units','pixels',...
    'Position',[10 10 220 25] ...
    );
uicontrol('Tag','settings_panel_xaxis_values_rowcol_popupmenu',...
    'Style','popupmenu',...
    'Parent',p3p3rowcol,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[80 2 90 20],...
    'String',{'row','column'},...
    'Value',2 ...
    );
uicontrol('Tag','settings_panel_xaxis_values_rowcol_edit',...
    'Style','edit',...
    'Parent',p3p3rowcol,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[170 0 50 25],...
    'String','1',...
    'TooltipString','Enter row/column number for x axis values here',...
    'Callback',{@edit_Callback,'xvaluesrowcol'}...
    );
p3p3range = uipanel('Tag','settings_panel_xaxis_values_range_panel',...
    'parent',p3p3,...
    'Title','',...
    'BorderType','none',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'Units','pixels',...
    'Position',[10 10 220 25] ...
    );
uicontrol('Tag','settings_panel_xaxis_values_start_edit',...
    'Style','edit',...
    'Parent',p3p3range,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[80 0 65 25],...
    'String','0',...
    'TooltipString','Enter x axis measure here',...
    'Callback',{@edit_Callback,'xmeasure'}...
    );
uicontrol('Tag','settings_panel_xaxis_values_divider_text',...
    'Style','text',...
    'Parent',p3p3range,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Center',...
    'Units','Pixels',...
    'Position',[145 0 10 20],...
    'String',':'...
    );
uicontrol('Tag','settings_panel_xaxis_values_stop_edit',...
    'Style','edit',...
    'Parent',p3p3range,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[155 0 65 25],...
    'String','1',...
    'TooltipString','Enter x axis unit here',...
    'Callback',{@edit_Callback,'xunit'}...
    );
p3p4 = uipanel('Tag','settings_panel_yaxis_panel',...
    'parent',p3,...
    'Title','Y Axis',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','on',...
    'Units','pixels',...
    'Position',[10 guiSize(2)-470 240 120] ...
    );
uicontrol('Tag','settings_panel_yaxis_label_text',...
    'Style','text',...
    'Parent',p3p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'Units','Pixels',...
    'Position',[10 75 50 20],...
    'String','Label:'...
    );
uicontrol('Tag','settings_panel_yaxis_measure_edit',...
    'Style','edit',...
    'Parent',p3p4,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 75 110 25],...
    'String','',...
    'TooltipString','Enter y axis measure here',...
    'Callback',{@edit_Callback,'ymeasure'}...
    );
uicontrol('Tag','settings_panel_yaxis_divider_text',...
    'Style','text',...
    'Parent',p3p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Center',...
    'Units','Pixels',...
    'Position',[170 75 10 20],...
    'String','/'...
    );
uicontrol('Tag','settings_panel_yaxis_unit_edit',...
    'Style','edit',...
    'Parent',p3p4,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[180 75 50 25],...
    'String','',...
    'TooltipString','Enter y axis unit here',...
    'Callback',{@edit_Callback,'yunit'}...
    );
uicontrol('Tag','settings_panel_yaxis_values_text',...
    'Style','text',...
    'Parent',p3p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'Units','Pixels',...
    'Position',[10 42 80 20],...
    'String','Values:'...
    );
uicontrol('Tag','settings_panel_yaxis_values_popupmenu',...
    'Style','popupmenu',...
    'Parent',p3p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[90 45 240-10-90 20],...
    'String',{'row/column','range','index'},...
    'Value',3,...
    'Callback',{@popupmenu_Callback,'yvalues'}...
    );
p3p4rowcol = uipanel('Tag','settings_panel_yaxis_values_rowcol_panel',...
    'parent',p3p4,...
    'Title','',...
    'BorderType','none',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'Units','pixels',...
    'Position',[10 10 220 25] ...
    );
uicontrol('Tag','settings_panel_yaxis_values_rowcol_popupmenu',...
    'Style','popupmenu',...
    'Parent',p3p4rowcol,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[80 2 90 20],...
    'String',{'row','column'},...
    'Value',2 ...
    );
uicontrol('Tag','settings_panel_yaxis_values_rowcol_edit',...
    'Style','edit',...
    'Parent',p3p4rowcol,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[170 0 50 25],...
    'String','',...
    'TooltipString','Enter row/column number for y axis values here',...
    'Callback',{@edit_Callback,'yvaluesrowcol'}...
    );
p3p4range = uipanel('Tag','settings_panel_yaxis_values_range_panel',...
    'parent',p3p4,...
    'Title','',...
    'BorderType','none',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'Units','pixels',...
    'Position',[10 10 220 25] ...
    );
uicontrol('Tag','settings_panel_yaxis_values_start_edit',...
    'Style','edit',...
    'Parent',p3p4range,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[80 0 65 25],...
    'String','',...
    'TooltipString','Enter y axis measure here',...
    'Callback',{@edit_Callback,'ystart'}...
    );
uicontrol('Tag','settings_panel_yaxis_values_divider_text',...
    'Style','text',...
    'Parent',p3p4range,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Center',...
    'Units','Pixels',...
    'Position',[145 0 10 20],...
    'String',':'...
    );
uicontrol('Tag','settings_panel_yaxis_values_stop_edit',...
    'Style','edit',...
    'Parent',p3p4range,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[155 0 65 25],...
    'String','',...
    'TooltipString','Enter y axis unit here',...
    'Callback',{@edit_Callback,'ystop'}...
    );
p3p5 = uipanel('Tag','settings_panel_zaxis_panel',...
    'parent',p3,...
    'Title','Z Axis',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','on',...
    'Units','pixels',...
    'Position',[10 guiSize(2)-530 240 55] ...
    );
uicontrol('Tag','settings_panel_zaxis_label_text',...
    'Style','text',...
    'Parent',p3p5,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Left',...
    'Units','Pixels',...
    'Position',[10 10 50 20],...
    'String','Label:'...
    );
uicontrol('Tag','settings_panel_zaxis_measure_edit',...
    'Style','edit',...
    'Parent',p3p5,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[60 10 110 25],...
    'String','',...
    'TooltipString','Enter z axis measure here',...
    'Callback',{@edit_Callback,'zmeasure'}...
    );
uicontrol('Tag','settings_panel_zaxis_divider_text',...
    'Style','text',...
    'Parent',p3p5,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','Center',...
    'Units','Pixels',...
    'Position',[170 10 10 20],...
    'String','/'...
    );
uicontrol('Tag','settings_panel_zaxis_unit_edit',...
    'Style','edit',...
    'Parent',p3p5,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[180 10 50 25],...
    'String','',...
    'TooltipString','Enter z axis unit here',...
    'Callback',{@edit_Callback,'zunit'}...
    );
p3p6 = uipanel('Tag','settings_panel_saveastemplate_panel',...
    'parent',p3,...
    'Title','Save settings as template',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','on',...
    'Units','pixels',...
    'Position',[10 guiSize(2)-590 240 55] ...
    );
uicontrol('Tag','settings_panel_savetemplate_edit',...
    'Style','edit',...
    'Parent',p3p6,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 150 25],...
    'String','',...
    'TooltipString','Enter name for template',...
    'Callback',{@edit_Callback,'template'}...
    );
uicontrol('Tag','settings_panel_savetemplate_pushbutton',...
    'Style','pushbutton',...
	'Parent', p3p6, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Save',...
    'TooltipString','Save template from settings above',...
    'pos',[170 10 60 25],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'savetemplate'}...
    );

uicontrol('Tag','help_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'ForegroundColor',[0 0 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'FontWeight','bold',...
    'String','?',...
    'TooltipString','Display help about using this GUI',...
    'pos',[guiSize(1)-270 10 25 25],...
    'Enable','on',...
    'Callback',@TAgui_ASCIIimporter_helpwindow...
    );

uicontrol('Tag','cancel_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Cancel',...
    'TooltipString','Cancel import and close window.',...
    'pos',[guiSize(1)-150 10 70 35],...
    'Enable','on',...
    'Callback',{@closeGUI,'cancel'}...
    );
uicontrol('Tag','import_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Import',...
    'TooltipString','Import data and close window',...
    'pos',[guiSize(1)-80 10 70 35],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'import'}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    % Store handles in guidata
    guidata(hMainFigure,guihandles);
    
    % Add keypress function to every element that can have one...
    handles = findall(...
        allchild(hMainFigure),'style','pushbutton',...
        '-or','style','togglebutton',...
        '-or','style','edit',...
        '-or','style','text',...
        '-or','style','listbox',...
        '-or','style','checkbox',...
        '-or','style','slider',...
        '-or','style','popupmenu',...
        '-or','style','panel');
    for hInd=1:length(handles)
        set(handles(hInd),'KeyPressFcn',@keypress_Callback);
    end

    % Preset edits with directories
    updateWindow();
    
    % Make the GUI visible.
    set(hMainFigure,'Visible','on');
    TAmsg('ASCII Importer window opened.','info');

    % Set file edit control stuff
    % Get the Java scroll-pane container reference
    jScrollPane = findjobj(hFileDisplay);
    jViewPort = jScrollPane.getViewport;
    jEditbox = jViewPort.getComponent(0);
    jEditbox.setWrapping(false);  % do *NOT* use set(...)!!!
    set(jScrollPane,'HorizontalScrollBarPolicy',32);
    jEditbox.setCaretPosition(0)
    
    if (nargout == 1)
        varargout{1} = hMainFigure;
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function edit_Callback(source,~,action)
    try        
        % Get appdata and gui handles
        ad = getappdata(hMainFigure);
        gh = guidata(hMainFigure);

        switch lower(action)
            case ''
            otherwise
                return;
        end
        
%         % If value is empty or NaN after conversion to numeric, restore
%         % previous entry and return
%         if isempty(value) || isnan(value)
%             % Update slider panel
%             update_sliderPanel();
%             return;
%         end
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
        
        %Get handles of GUI
        gh = guihandles(hMainFigure);
        
        switch lower(action)
            case 'fileselect'
                % Ask user for file name
                [fileName,pathName] = uigetfile(...
                    '*.*',...
                    'Get filename for ASCII file to be imported');
                % If user aborts process, return
                if fileName == 0
                    return;
                end
                % Create filename with full path
                fileName = fullfile(pathName,fileName);
                set(gh.filename_edit,'String',fileName);
                text = textFileRead(fileName);
                lineNumbers = cellstr(num2str((1:length(text))'));
                ntext = cell(size(text));
                for k=1:length(text)
                    ntext{k} = [lineNumbers{k} ': ' text{k}];
                end
                % To speed up display of large files, cut file after n
                % lines
                maxLines = 100;
                if length(ntext) > maxLines
                    ntext = ntext(1:maxLines);
                    ntext{maxLines+1} = sprintf(...
                    'Preview truncated after %i lines...',maxLines);
                end
                set(hFileDisplay,'String',ntext);
                jScrollPane = findjobj(hFileDisplay);
                jViewPort = jScrollPane.getViewport;
                jEditbox = jViewPort.getComponent(0);
                jEditbox.setCaretPosition(0)
            case 'import'
                parameters = getParameters();
                [data,warnings] = TAASCIIread(...
                    get(gh.filename_edit,'String'),'parameters',parameters);
                % Append warnings to status messages
                if ~isempty(warnings)
                    TAmsg(warnings,'warning');
                end
                % Append data to toolbox
                if ~isempty(data)
                    status = TAappendDatasetToMainGUI(data);
                    if status
                        TAmsg('Something went wrong appending the dataset','warning');
                    end
                else
                    % Present message dialogue to user telling him that
                    % something went wrong...
                end
                closeGUI('','','saved');
                return;
            otherwise
                disp(['Action ' action ' not understood.'])
                return;
        end
        updateWindow();
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

function keypress_Callback(~,evt)
    try
        if isempty(evt.Character) && isempty(evt.Key)
            % In case "Character" is the empty string, i.e. only modifier
            % key was pressed...
            return;
        end
        
        % Get handles of GUI
        gh = guihandles(hMainFigure);
        
        if ~isempty(evt.Modifier)
            if (strcmpi(evt.Modifier{1},'command')) || ...
                    (strcmpi(evt.Modifier{1},'control'))
                switch evt.Key
                    case 's'
                        % Need to change focus *and* add a short pause to
                        % get string, as GUI elements seem terribly slow...
                        uicontrol(gh.save_pushbutton);
                        pause(0.001);
                        pushbutton_Callback('','','save');
                        return;
                    case 'w'
                        closeGUI();
                        return;
                end
            end
        else
            switch evt.Key
                case 'f1'
                    TAgui_ASCIIimporter_helpwindow();
                    return;
                case 'escape'
                    closeGUI();
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
        
        switch lower(action)
            case 'xvalues'
                switch lower(value)
                    case 'index'
                        set(p3p3range,'Visible','off');
                        set(p3p3rowcol,'Visible','off');
                    case 'range'
                        set(p3p3range,'Visible','on');
                        set(p3p3rowcol,'Visible','off');
                    case 'row/column'
                        set(p3p3range,'Visible','off');
                        set(p3p3rowcol,'Visible','on');
                    otherwise
                        disp([mfilename '() : popupmenu_Callback() : '...
                            'Unknown value "' value '" in action "'...
                            action '".']);
                        return;
                end
            case 'yvalues'
                switch lower(value)
                    case 'index'
                        set(p3p4range,'Visible','off');
                        set(p3p4rowcol,'Visible','off');
                    case 'range'
                        set(p3p4range,'Visible','on');
                        set(p3p4rowcol,'Visible','off');
                    case 'row/column'
                        set(p3p4range,'Visible','off');
                        set(p3p4rowcol,'Visible','on');
                    otherwise
                        disp([mfilename '() : popupmenu_Callback() : '...
                            'Unknown value "' value '" in action "'...
                            action '".']);
                        return;
                end
            otherwise
                disp([mfilename '() : popupmenu_Callback() : '...
                    'Unknown action "' action '"']);
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

function closeGUI(~,~,varargin)
    try
%         if nargin == 3
%             action = varargin{1};
%         else
%             action = '';
%         end

        delete(hMainFigure);
        TAmsg('ASCII Importer window closed.','info');
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

function params = getParameters()
    try
        % Get handles of GUI
        gh = guihandles(hMainFigure);
        
        params.separator = get(gh.settings_panel_separator_edit,'String');
        params.nHeaderLines = ...
            str2double(get(gh.settings_panel_nheaderlines_edit,'String'));
        dimensionalities = ...
            cellstr(get(gh.settings_panel_dimensions_popupmenu,'String'));
        params.dimensionality = dimensionalities{...
            get(gh.settings_panel_dimensions_popupmenu,'Value')};
        params.transpose = logical(...
            get(gh.settings_panel_dimensions_transpose_checkbox,'Value'));
        % Get parameters for x axis
        params.axis.x.measure = ...
            get(gh.settings_panel_xaxis_measure_edit,'String');
        params.axis.x.unit = ...
            get(gh.settings_panel_xaxis_unit_edit,'String');
        xvaluestypes = ...
            cellstr(get(gh.settings_panel_xaxis_values_popupmenu,'String'));
        params.axis.x.values.type = xvaluestypes{...
            get(gh.settings_panel_xaxis_values_popupmenu,'Value')};
        params.axis.x.values.row = 0;
        params.axis.x.values.column = 0;
        if strcmpi(params.axis.x.values.type,'row/column')
            rowcols = cellstr(...
                get(gh.settings_panel_xaxis_values_rowcol_popupmenu,'String'));
            rowcol = rowcols{...
                get(gh.settings_panel_xaxis_values_rowcol_popupmenu,'Value')};
            switch lower(rowcol)
                case 'row'
                    params.axis.x.values.row = str2double(...
                        get(gh.settings_panel_xaxis_values_rowcol_edit,'String'));
                case 'column'
                    params.axis.x.values.column = str2double(...
                        get(gh.settings_panel_xaxis_values_rowcol_edit,'String'));
            end
        end
        params.axis.x.values.start = 0;
        params.axis.x.values.stop = 0;
        if strcmpi(params.axis.x.values.type,'range')
            params.axis.x.values.start = str2double(...
                get(gh.settings_panel_xaxis_values_start_edit,'String'));
            params.axis.x.values.stop = str2double(...
                get(gh.settings_panel_xaxis_values_stop_edit,'String'));
        end
        % Get parameters for y axis
        params.axis.y.measure = ...
            get(gh.settings_panel_yaxis_measure_edit,'String');
        params.axis.y.unit = ...
            get(gh.settings_panel_yaxis_unit_edit,'String');
        yvaluestypes = ...
            cellstr(get(gh.settings_panel_yaxis_values_popupmenu,'String'));
        params.axis.y.values.type = yvaluestypes{...
            get(gh.settings_panel_yaxis_values_popupmenu,'Value')};
        params.axis.y.values.row = 0;
        params.axis.y.values.column = 0;
        if strcmpi(params.axis.y.values.type,'row/column')
            rowcols = cellstr(...
                get(gh.settings_panel_yaxis_values_rowcol_popupmenu,'String'));
            rowcol = rowcols{...
                get(gh.settings_panel_yaxis_values_rowcol_popupmenu,'Value')};
            switch lower(rowcol)
                case 'row'
                    params.axis.y.values.row = str2double(...
                        get(gh.settings_panel_yaxis_values_rowcol_edit,'String'));
                case 'column'
                    params.axis.y.values.column = str2double(...
                        get(gh.settings_panel_yaxis_values_rowcol_edit,'String'));
            end
        end
        params.axis.y.values.start = 0;
        params.axis.y.values.stop = 0;
        if strcmpi(params.axis.x.values.type,'range')
            params.axis.y.values.start = str2double(...
                get(gh.settings_panel_yaxis_values_start_edit,'String'));
            params.axis.y.values.stop = str2double(...
                get(gh.settings_panel_yaxis_values_stop_edit,'String'));
        end
        % Get parameters for z axis
        params.axis.z.measure = ...
            get(gh.settings_panel_zaxis_measure_edit,'String');
        params.axis.z.unit = ...
            get(gh.settings_panel_zaxis_unit_edit,'String');
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

function updateWindow()
    try
        % Get handles of GUI
%         gh = guihandles(hMainFigure);

        % Get appdata of main GUI
        mainGuiWindow = TAguiGetWindowHandle();
        % If there is no main GUI window, return, otherwise get its appdata
        if ~mainGuiWindow
            return;
        end
        adm = getappdata(mainGuiWindow);
        % If there is no active dataset, return
        if isempty(adm.control.spectra.active) || ...
                ~adm.control.spectra.active
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

end
