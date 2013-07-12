function varargout = TAgui_cmd_helpwindow(varargin)
% TAGUI_CMD_HELPWINDOW Help window for the command line feature of the
% main GUI.
%
% Normally, this window is called from within the TAgui window. 
%
% See also TAGUI

% (c) 2013, Till Biskup
% 2013-07-12

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

guiPosition = [160,240,850,450];
% Try to get main GUI position
mainGUIHandle = TAguiGetWindowHandle();
if ishandle(mainGUIHandle)
    mainGUIPosition = get(mainGUIHandle,'Position');
    guiPosition = [mainGUIPosition(1)+40,mainGUIPosition(2)+150,...
        guiPosition(3), guiPosition(4)];
end

%  Construct the components
hMainFigure = figure('Tag',mfilename,...
    'Visible','off',...
    'Name','TA GUI : Command Line : Help Window',...
    'Units','Pixels',...
    'Position',guiPosition,...
    'Resize','off',...
    'KeyPressFcn',@keypress_Callback,...
    'NumberTitle','off', ...
    'Menu','none','Toolbar','none');

defaultBackground = get(hMainFigure,'Color');
guiSize = get(hMainFigure,'Position');
guiSize = guiSize([3,4]);

% Create button group.
hButtonGroup = uibuttongroup('Tag','buttonGroup',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'BorderType','none',...
    'Units','Pixels',...
    'Position', [10 guiSize(2)-35 200 25],...
    'Visible','on',...
    'SelectionChangeFcn',{@buttongroup_Callback,'topics'}...
    );

hGeneralButton = uicontrol('Tag','bg_general_pushbutton',...
    'Parent',hButtonGroup,...
    'Style','togglebutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','General',...
    'TooltipString',...
    'General help with the command line feature of the TA GUI',...
    'Position',[0 0 95 25],...
    'HandleVisibility','off',...
    'Value',1 ...
    );
hCommandButton = uicontrol('Tag','bg_commands_pushbutton',...
    'Parent',hButtonGroup,...
    'Style','togglebutton',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Commands',...
    'TooltipString',...
    'Alphabetic list of commands help is available for',...
    'Position',[95 0 95 25],...
    'HandleVisibility','off',...
    'Value',0 ...
    );


uicontrol('Tag','heading_text',...
    'Style','text',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',14,...
    'HorizontalAlignment','Left',...
    'FontWeight','bold',...
    'Units','Pixels',...
    'Position',[210 guiSize(2)-35 guiSize(1)-220 20],...
    'String','How to Use the Command Line of the TA GUI?'...
    );

p1 = uipanel('Tag','topic_panel',...
    'parent',hMainFigure,...
    'Title','',...
    'FontUnit','Pixel','Fontsize',12,...
    'BorderType','none',...
    'BackgroundColor',defaultBackground,...
    'Visible','on',...
    'Units','pixels',...
    'Position',[10 50 190 guiSize(2)-90] ...
    );
% Create listbox with help topics
hHelpTopicListbox = uicontrol('Tag','helptopic_listbox',...
    'Style','listbox',...
    'Parent',p1,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',14,...
    'Units','Pixels',...
    'Position',[0 0 190 guiSize(2)-90],...
    'String','',...
    'Callback',{@listbox_Callback,'general'}...
    );

p2 = uipanel('Tag','commandlist_panel',...
    'parent',hMainFigure,...
    'Title','',...
    'FontUnit','Pixel','Fontsize',12,...
    'BorderType','none',...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'Units','pixels',...
    'Position',[10 50 190 guiSize(2)-90] ...
    );
% Create listbox with help topics
hCommandListListbox = uicontrol('Tag','commands_listbox',...
    'Style','listbox',...
    'Parent',p2,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',14,...
    'Units','Pixels',...
    'Position',[0 0 190 guiSize(2)-90],...
    'String','',...
    'Callback',{@listbox_Callback,'commands'}...
    );

% Create the message window
% NEW: Use a Java Browser object to display HTML
jObject = com.mathworks.mlwidgets.html.HTMLBrowserPanel;
[browser,container] = javacomponent(jObject, [], hMainFigure);
set(container,...
    'Units','Pixels',...
    'Position',[210 50 guiSize(1)-220 guiSize(2)-90]...
    );

% uicontrol('Tag','back_pushbutton',...
%     'Style','pushbutton',...
% 	'Parent', hMainFigure, ...
%     'BackgroundColor',defaultBackground,...
%     'FontUnit','Pixel','Fontsize',12,...
%     'String','<html>&larr;</html>',...
%     'TooltipString','Go to previous page in browser history',...
%     'pos',[10 10 40 30],...
%     'Enable','on',...
%     'Callback',{@pushbutton_Callback,'browserback'} ...
%     );
% uicontrol('Tag','back_pushbutton',...
%     'Style','pushbutton',...
% 	'Parent', hMainFigure, ...
%     'BackgroundColor',defaultBackground,...
%     'FontUnit','Pixel','Fontsize',12,...
%     'String','<html>&rarr;</html>',...
%     'TooltipString','Go to next page in browser history',...
%     'pos',[50 10 40 30],...
%     'Enable','on',...
%     'Callback',{@pushbutton_Callback,'browserforward'} ...
%     );

uicontrol('Tag','close_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Close',...
    'TooltipString','Close Net Polarisation GUI Help window',...
    'pos',[guiSize(1)-70 10 60 30],...
    'Enable','on',...
    'Callback',{@closeGUI}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    % Store handles in guidata
    guidata(hMainFigure,guihandles);
    
    % Load guiCommands script
    % To do that, preassign a few variables
    active = 0; %#ok<NASGU>
    label = ''; %#ok<NASGU>
    guiCommands;
    cmds = sort(cmdMatch(:,1)); %#ok<NODEF>
    % FIX for the time being - should be done properly later, with one file
    % containing all available commands
    % Get commands with regular file name
    cmds2 = dir(fullfile(TAinfo('dir'),'GUI','private','cmd*.m'));
    cmds2 = cellfun(@(x)lower(x(4:strfind(x,'.')-1)),{cmds2.name},...
        'UniformOutput',false);
    cmds = sort([ '?' cmds' cmds2 ]);
    set(hCommandListListbox,'String',cmds);
    % Tidy up
    clear active label;
    
    % Load general help topics, use therefore directory listing
    topics = dir(fullfile(TAinfo('dir'),...
        'GUI','private','helptexts','cmd','general','*.html'));
    topics = cellfun(@(x)[upper(x(1)) x(2:strfind(x,'.')-1)],...
        {topics.name},'UniformOutput',false);
    set(hHelpTopicListbox,'String',topics);

    % Read text for welcome message from file and display it
    helpTextFile = fullfile(TAinfo('dir'),...
        'GUI','private','helptexts','cmd','general','introduction.html');
    browser.setCurrentLocation(helpTextFile);

    if nargin && ischar(varargin{1})
        if any(strcmpi(varargin{1},cmds))
            set([p1 p2],'Visible','off');
            set(hGeneralButton,'Value',0);
            set(hCommandButton,'Value',1);
            set(p2,'Visible','on');
            set(hCommandListListbox,'Value',find(strcmpi(varargin{1},cmds)))
            % Handle special characters, such as "?" command
            if strcmpi(varargin{1},'?')
                varargin{1} = 'questionmark';
            end
            helpTextFile = fullfile(TAinfo('dir'),...
                'GUI','private','helptexts','cmd','cmd',...
                [varargin{1} '.html']);
            browser.setCurrentLocation(helpTextFile);
        elseif any(strcmpi(varargin{1},topics))
            set([p1 p2],'Visible','off');
            set(hGeneralButton,'Value',1);
            set(hCommandButton,'Value',0);
            set(p1,'Visible','on');
            set(hHelpTopicListbox,'Value',find(strcmpi(varargin{1},topics)))
            helpTextFile = fullfile(TAinfo('dir'),...
                'GUI','private','helptexts','cmd','general',...
                [varargin{1} '.html']);
            browser.setCurrentLocation(helpTextFile);
        else
            switch lower(varargin{1})
                case 'general'
                    set([p1 p2],'Visible','off');
                    set(hGeneralButton,'Value',1);
                    set(hCommandButton,'Value',0);
                    set(p1,'Visible','on');
                case 'commands'
                    set([p1 p2],'Visible','off');
                    set(hGeneralButton,'Value',0);
                    set(hCommandButton,'Value',1);
                    set(p2,'Visible','on');
            end
        end
    end
    
    % Add keypress function to every element that can have one...
    handles = findall(...
        allchild(hMainFigure),'style','pushbutton',...
        '-or','style','togglebutton',...
        '-or','style','edit',...
        '-or','style','listbox',...
        '-or','style','checkbox',...
        '-or','style','slider',...
        '-or','style','popupmenu',...
        '-not','tag','command_panel_edit');
    for k=1:length(handles)
        set(handles(k),'KeyPressFcn',@keypress_Callback);
    end
    
    % Make the GUI visible.
    set(hMainFigure,'Visible','on');
    TAmsg('Command line help window opened.','info');
    
    guidata(hMainFigure,guihandles);
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

function listbox_Callback(source,~,action)
    try
        if isempty(action)
            return;
        end
        
        values = cellstr(get(source,'String'));
        if isempty(values)
            value = 0;
            return;
        else
            value = values{get(source,'Value')};
        end
        
        switch action
            case 'general'
                helpTextFile = fullfile(TAinfo('dir'),...
                    'GUI','private','helptexts','cmd','general',[value '.html']);
                if exist(helpTextFile,'file')
                    % Read text from file and display it
                    browser.setCurrentLocation(helpTextFile);
                else
                    % That shall never happen
                    TAmsg('guiHelpPanel(): Unknown helptext','info');
                    htmlText = ['<html>' ...
                        '<h1>' value '</h1>'...
                        '<p>Sorry, no help available (yet) for this topic.</p>'...
                        '</html>'];
                    browser.setHtmlText(htmlText);
                end
            case 'commands'
                % Handle special case of special characters used as
                % command, such as the "?" command, that would lead to
                % rather problematic file names.
                if strcmpi(value,'?')
                    value = 'questionmark';
                end
                helpTextFile = fullfile(TAinfo('dir'),...
                    'GUI','private','helptexts','cmd','cmd',[value '.html']);
                if exist(helpTextFile,'file')
                    % Read text from file and display it
                    browser.setCurrentLocation(helpTextFile);
                else
                    % That shall never happen
                    TAmsg('guiHelpPanel(): Unknown helptext','info');
                    htmlText = ['<html>' ...
                        '<h1>' value '</h1>'...
                        '<p>Sorry, no help available (yet) for this command.</p>'...
                        '</html>'];
                    browser.setHtmlText(htmlText);
                end
            otherwise
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

function buttongroup_Callback(source,~,action)
    try
        if isempty(action)
            return;
        end
        
        switch action
            case 'topics'
                panels = [p1, p2];
                val = get(get(source,'SelectedObject'),'String');
                switch lower(val)
                    case 'general'
                        set(panels,'Visible','off');
                        set(p1,'Visible','on');
                        listbox_Callback(hHelpTopicListbox,'','general');
                    case 'commands'
                        set(panels,'Visible','off');
                        set(p2,'Visible','on');
                        listbox_Callback(hCommandListListbox,'','commands');
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

% function pushbutton_Callback(~,~,action)
%     try
%         if isempty(action)
%             return;
%         end
%         switch action
%             case 'browserback'
%                 browser.executeScript('javascript:history.back()');
%             case 'browserforward'
%                 browser.executeScript('javascript:history.forward()');
%         end
%     catch exception
%         try
%             msgStr = ['An exception occurred in ' ...
%                 exception.stack(1).name  '.'];
%             TAmsg(msgStr,'error');
%         catch exception2
%             exception = addCause(exception2, exception);
%             disp(msgStr);
%         end
%         try
%             TAgui_bugreportwindow(exception);
%         catch exception3
%             % If even displaying the bug report window fails...
%             exception = addCause(exception3, exception);
%             throw(exception);
%         end
%     end
% end

function keypress_Callback(~,evt)
    try
        if isempty(evt.Character) && isempty(evt.Key)
            % In case "Character" is the empty string, i.e. only modifier
            % key was pressed...
            return;
        end
        if ~isempty(evt.Modifier)
            if (strcmpi(evt.Modifier{1},'command')) || ...
                    (strcmpi(evt.Modifier{1},'control'))
                switch evt.Key
                    case '1'
                        set(hGeneralButton,'Value',1);
                        set(hCommandButton,'Value',0);
                        buttongroup_Callback(hButtonGroup,'','topics');
                        return;
                    case '2'
                        set(hGeneralButton,'Value',0);
                        set(hCommandButton,'Value',1);
                        buttongroup_Callback(hButtonGroup,'','topics');
                        return;
                    case 'w'
                        closeGUI();
                        return;
                end
            end
        else
            switch evt.Key
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function closeGUI(~,~)
    try
        clear('jObject');
        delete(hMainFigure);
        TAmsg('Command line help window closed.','info');
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
