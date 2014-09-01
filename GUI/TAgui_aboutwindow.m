function varargout = TAgui_aboutwindow()
% TAGUI_ABOUTWINDOW Brief description of GUI.
%                   Comments displayed at the command line in response 
%                   to the help command. 

% Copyright (c) 2011-14, Till Biskup
% 2014-04-28

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make GUI effectively a singleton
singleton = TAguiGetWindowHandle(mfilename);
if (singleton)
    varargout{1} = figure(singleton);
    return;
end

info = TAinfo;

title = 'TA Toolbox: About';
toolboxNameString = 'TA Toolbox';
versionString = ...
    sprintf('v.%s (%s)',info.version.Version,info.version.Date);
copyrightInfo = {...
    sprintf('(c) 2011-14, Till Biskup, <%s>',info.maintainer.email)...
    ''...
    sprintf('%s',info.url)...
    };
position = [70,290,528,300];

%  Construct the components
hMainFigure = figure('Tag',mfilename,...
    'Visible','off',...
    'Name',title,...
    'Units','Pixels',...
    'Position',position,...
    'Resize','off',...
    'NumberTitle','off', ...
    'Menu','none','Toolbar','none',...
    'KeyPressFcn',@keypress_Callback,...
    'CloseRequestFcn',{@closeWindow}...
    );

defaultBackground = get(hMainFigure,'Color');

% Set icon (jLabel)
[path,~,~] = fileparts(mfilename('fullpath'));
icon = javax.swing.ImageIcon(fullfile(path,'TAtoolbox-logo-128x128.png'));
jLabel = javax.swing.JLabel('');
jLabel.setIcon(icon);
bgcolor = num2cell(get(hMainFigure, 'Color'));
jLabel.setBackground(java.awt.Color(bgcolor{:}));
javacomponent(jLabel,[20 position(4)-128-20 128 128],hMainFigure);

% Set length of scrolling panel depending on the platform
if any(strfind(platform,'Linux'))
    scrollPanelHeight = position(4)+1560;
elseif any(strfind(platform,'Windows'))
    scrollPanelHeight = position(4)+1310;
else % In case we are on a Mac
    scrollPanelHeight = position(4)+1730;
end

hPanel = uipanel('Parent',hMainFigure,...
    'Title','',...
    'FontUnit','Pixel','Fontsize',12,...
    'Visible','on',...
    'Units','Pixels',...
    'Position',[168 140-scrollPanelHeight 350 scrollPanelHeight],...
    'BackgroundColor',defaultBackground,...
    'BorderType','none'...
    );

% Read text for welcome message from file and display it
contributorsMessageFile = fullfile(...
    TAinfo('dir'),'GUI','private','helptexts','main','contributors.html');
contributorsMessageText = textFileRead(contributorsMessageFile);
% Convert text into one single string
contributorsText = cellfun(@(x) [char(x) ' '],contributorsMessageText,...
    'UniformOutput',false);
contributorsText = [ contributorsText{:} ];

jTextLabel = javaObjectEDT('javax.swing.JLabel',contributorsText);
jTextLabel.setBackground(java.awt.Color(bgcolor{:}));
jTextLabel.setVerticalAlignment(jTextLabel.TOP);
javacomponent(jTextLabel,[1 0 349 scrollPanelHeight],hPanel);

uicontrol('style','text',...
    'Units','Pixels',...
    'Position',[168 140 350 165],...
    'BackgroundColor',defaultBackground...
    );

uicontrol('style','text',...
    'Units','Pixels',...
    'Position',[168 240 350 40],...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',32,...
    'String',toolboxNameString...
    );

uicontrol('style','text',...
    'Units','Pixels',...
    'Position',[168 215 350 20],...
    'BackgroundColor',defaultBackground,...
    'FontWeight','bold',...
    'FontUnit','Pixel','Fontsize',14,...
    'String',versionString...
    );

uicontrol('style','text',...
    'Units','Pixels',...
    'Position',[168 150 350 55],...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',13,...
    'String',copyrightInfo...
    );

uicontrol('style','text',...
    'Units','Pixels',...
    'Position',[168 0 350 20],...
    'BackgroundColor',defaultBackground...
    );

uicontrol('Tag','website_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[(128+40-90)/2 70 90 30],...
    'TooltipString','Open website of the TA toolbox (in system webbrowser)',...
    'String','Website',...
    'Callback',{@startBrowser,TAinfo('url')}...
    );

uicontrol('Tag','close_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[(128+40-90)/2 20 90 30],...
    'String','Close',...
    'TooltipString','Close "about" window',...
    'Callback',{@closeWindow}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make the GUI visible.
set(hMainFigure,'Visible','on');


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
t2 = timer( ...
    'StartDelay', 2, ...
    'Period', 0.05, ...
    'TasksToExecute', scrollPanelHeight-130, ...
    'ExecutionMode', 'fixedRate');

t1.TimerFcn = @(x,y)start(t2);
t1.StopFcn =  @(x,y)delete(t1);

t2.TimerFcn = @(x,y)scrollPanel;
t2.StopFcn =  @(x,y)delete(t2);

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
            switch evt.Key
                case 'escape'
                    closeWindow()
                    return;
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

    function closeWindow(~,~)
        if exist('t1','var') && isvalid(t1)
            stop(t1);
            delete(t1);
        end
        if exist('t2','var') && isvalid(t2)
            stop(t2);
            delete(t2);
        end
        try
            delete(hMainFigure);
        catch
            msgStr = ['Something serious went wrong trying to close '...
                mfilename];
            TAmsg(msgStr,'warning');
        end
    end

    function startBrowser(~,~,url)
        if any(strfind(platform,'Windows'))
            dos(['start ' url]);
        else
            web(url,'-browser');
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function scrollPanel(~,~)
        panelPos = get(hPanel,'Position');
        panelPos(2) = panelPos(2)+1;
        set(hPanel,'Position',panelPos);
    end

end
