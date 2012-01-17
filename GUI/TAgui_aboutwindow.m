function varargout = TAgui_aboutwindow()
% TAGUI_ABOUTWINDOW Brief description of GUI.
%                   Comments displayed at the command line in response 
%                   to the help command. 

% (c) 2011-12, Till Biskup
% 2012-01-16

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make GUI effectively a singleton
singleton = findobj('Tag','TAgui_help_about');
if (singleton)
    varargout{1} = figure(singleton);
    return;
end

info = TAinfo;

title = 'TA Toolbox: About';
message1 = {...
    sprintf('v.%s (%s)',info.version.Version,info.version.Date)...
    ''...
    '(c) 2011-12, Till Biskup'...
    sprintf('<%s>',info.maintainer.email)...
    ''...
    'For more information'...
    'check the corresponding web page:'...
    ''...
    sprintf('%s',info.url)...
    };
position = [170,290,350,320];

%  Construct the components
hMainFigure = figure('Tag','TAgui_help_about',...
    'Visible','off',...
    'Name',title,...
    'Units','Pixels',...
    'Position',position,...
    'Resize','off',...
    'NumberTitle','off', ...
    'Color',[.95 .95 .95],...
    'Menu','none','Toolbar','none',...
    'KeyPressFcn',@keypress_Callback,...
    'CloseRequestFcn',{@closeWindow});

defaultBackground = [1 1 1];
% Set length of scrolling panel depending on the platform
if ~isempty(strfind(platform,'Linux'))
    scrollPanelHeight = position(4)+2750;
else
    scrollPanelHeight = position(4)+2400;
end

hMainPanel = uipanel('Tag','main_panel',...
    'parent',hMainFigure,...
    'Title','',...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Visible','on',...
    'BorderType','none',...
    'Units','pixels',...
    'Position',[0 position(4)-scrollPanelHeight position(3) scrollPanelHeight]...
    );

hLogo = axes(...
    'Tag','logo',...
	'Parent', hMainPanel, ...
    'Units', 'Pixels', ...
    'Position',[round((position(3)-275)/2) scrollPanelHeight-90 275 68]...
    );

uicontrol('Tag','msgwindow_info_text',...
    'Style','text',...
    'Parent',hMainPanel,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'HorizontalAlignment','Center',...
    'Position',[20 scrollPanelHeight-position(4) position(3)-40 position(4)-110],...
    'FontUnits','Pixels',...
    'FontSize',12,...
    'String',message1...
    );

hScrollText = uicontrol('Tag','msgwindow_contributors_text',...
    'Style','text',...
    'Parent',hMainPanel,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'HorizontalAlignment','Center',...
    'Position',[20 position(4) position(3)-40 scrollPanelHeight-(2*position(4))-20],...
    'FontUnits','Pixels',...
    'FontSize',12,...
    'String',''...
    );

hLogo2 = axes(...
    'Tag','logo2',...
	'Parent', hMainPanel, ...
    'Units', 'Pixels', ...
    'Position',[round((position(3)-275)/2) position(4)-90 275 68]...
    );

uicontrol('Tag','msgwindow_info_text2',...
    'Style','text',...
    'Parent',hMainPanel,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'HorizontalAlignment','Center',...
    'Position',[20 0 position(3)-40 position(4)-110],...
    'FontUnits','Pixels',...
    'FontSize',12,...
    'String',message1...
    );

closeBtn = uicontrol('Tag','msgwindow_close_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMainPanel,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[position(3)/2-30 scrollPanelHeight-300 60 30],...
    'String','Close',...
    'TooltipString','Close "about" window',...
    'Callback',{@closeWindow}...
    );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read text for welcome message from file and display it
contributorsMessageFile = fullfile(...
    TAinfo('dir'),'GUI','private','helptexts','main','contributors.txt');
contributorsMessageText = textFileRead(contributorsMessageFile);
set(hScrollText,'String',contributorsMessageText);

% Make the GUI visible.
set(hMainFigure,'Visible','on');

set(hMainFigure,'CurrentAxes',hLogo);
logo = imread(fullfile(...
    TAinfo('dir'),'GUI','private','splashes','TAtoolbox-logo-text.png'),...
    'png');
image(logo);
axis off

set(hMainFigure,'CurrentAxes',hLogo2);
image(logo);
axis off

% Add keypress function to every element that can have one...
handles = findall(...
    allchild(hMainFigure),'style','pushbutton',...
    '-or','style','togglebutton',...
    '-or','style','edit',...
    '-or','style','listbox',...
    '-or','style','slider',...
    '-or','style','popupmenu');
for k=1:length(handles)
    set(handles(k),'KeyPressFcn',@guiKeyBindings);
end

% Define timer for all the fun stuff
t1 = timer( ...
    'StartDelay', 8, ...
    'TasksToExecute', 1, ...
    'ExecutionMode', 'fixedRate');
t1.TimerFcn = @(x,y)startTimer2;
t1.StopFcn =  @(x,y)delete(t1);

t2 = timer( ...
    'StartDelay', 1, ...
    'TasksToExecute', 1, ...
    'ExecutionMode', 'fixedRate');
t2.TimerFcn = @(x,y)startScrollTimer;
t2.StopFcn =  @(x,y)delete(t2);

t3 = timer( ...
    'StartDelay', 2, ...
    'Period', 0.05, ...
    'TasksToExecute', scrollPanelHeight-position(4), ...
    'ExecutionMode', 'fixedRate');

t3.TimerFcn = @(x,y)scrollPanel;
t3.StopFcn =  @(x,y)delete(t3);

start(t1);

if nargout
    varargout{1} = hMainPanel;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function keypress_Callback(src,evt)
        try
            if isempty(evt.Character) && isempty(evt.Key)
                % In case "Character" is the empty string, i.e. only
                % modifier key was pressed...
                return;
            end
            if ~isempty(evt.Modifier)
                if (strcmpi(evt.Modifier{1},'command')) || ...
                        (strcmpi(evt.Modifier{1},'control'))
                    switch evt.Key
                        case 'w'
                            closeWindow(src,evt);
                            return;
                    end
                end
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

    function closeWindow(~,~)
        if exist('t1','var') && isvalid(t1)
            stop(t1);
            delete(t1);
        end
        if exist('t2','var') && isvalid(t2)
            stop(t2);
            delete(t2);
        end
        if exist('t3','var') && isvalid(t3)
            stop(t3);
            delete(t3);
        end
        try
            delete(hMainFigure);
        catch
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function startTimer2(~,~)
        set(closeBtn,'Position',[position(3)/2-30 20 60 30]);
        start(t2);
    end

    function startScrollTimer(~,~)
        uicontrol('Tag','msgwindow_acknowledgements_text',...
            'Style','text',...
            'Parent',hMainPanel,...
            'BackgroundColor',defaultBackground,...
            'Units','Pixels',...
            'HorizontalAlignment','Center',...
            'Position',[20 scrollPanelHeight-300 position(3)-40 30],...
            'FontUnits','Pixels',...
            'FontSize',12,...
            'FontWeight','bold',...
            'String','Acknowledgements...'...
            );
        start(t3);
    end

    function scrollPanel(~,~)
        panelPos = get(hMainPanel,'Position');
        panelPos(2) = panelPos(2)+1;
        set(hMainPanel,'Position',panelPos);
    end

end