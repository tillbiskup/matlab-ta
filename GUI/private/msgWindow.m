function varargout = msgWindow(varargin)
% MSGWINDOW Brief description of GUI.
%           Comments displayed at the command line in response 
%           to the help command. 

% input arguments: (Message,Title,Icon,CreateMode,ShowButton)
% output argument: handle

% TODO: 
% - Better handling of icons (different sizes) - exchange with others?
% - Better handling of window size (automatically depending on size of the
%   text)
% - Add basic error handling
% - Better check of input parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make GUI effectively a singleton
singleton = findobj('Tag','messagewindow');
if (singleton)
    if nargout
        figure(singleton);
        varargout{1} = singleton;
    else
        figure(singleton);
    end
    return;
end

% Check for input parameters
if (nargin >= 5)
    showButton = varargin{5};
else
    showButton = 1;
end
if (nargin >= 4)
    createMode = varargin{4};
else
    createMode = 'normal';
end
if (nargin >= 3)
    icon = varargin{3};
else
    icon = 'help';
end
if (nargin >= 2)
    title = varargin{2};
else
    title = 'Message';
end
if (nargin >= 1)
    message = varargin{1};
else
    message = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';
end

position = [300,300,350,120];

%  Construct the components
hMainFigure = figure('Tag','messagewindow',...
    'Visible','off',...
    'Name',title,...
    'Units','Pixels',...
    'Position',position,...
    'Resize','off',...
    'NumberTitle','off', ...
    'Menu','none','Toolbar','none',...
    'WindowStyle',createMode);

defaultBackground = get(hMainFigure,'Color');
guiSize = get(hMainFigure,'Position');
guiSize = guiSize([3,4]);

imgAxis = axes(...         % the axes for plotting selected plot
    'Tag','imgAxis',...
	'Parent', hMainFigure, ...
    'Units', 'Pixels', ...
    'Position',[20 (position(4)/2)-24+20 48 48]);

a = load('dialogicons.mat');
switch icon
    case 'info'
        IconData=a.lightbulbIconData;
        a.lightbulbIconMap(6,:)=get(hMainFigure,'Color');
        IconCMap=a.lightbulbIconMap;
    case 'help'
        IconData=a.helpIconData;
        a.helpIconMap(256,:)=get(hMainFigure,'Color');
        IconCMap=a.helpIconMap;
    case 'question'
        IconData=a.questIconData;
        a.questIconMap(256,:)=get(hMainFigure,'Color');
        IconCMap=a.questIconMap;
    case 'error'
        IconData=a.errorIconData;
        a.errorIconMap(146,:)=get(hMainFigure,'Color');
        IconCMap=a.errorIconMap;
    case 'warn'
        IconData=a.warnIconData;
        a.warnIconMap(256,:)=get(hMainFigure,'Color');
        IconCMap=a.warnIconMap;
    otherwise
        IconData=a.helpIconData;
        a.helpIconMap(256,:)=get(hMainFigure,'Color');
        IconCMap=a.helpIconMap;
end

%[IconData, IconCMap] = imread('info.png');
%IconCMap(256,:) = get(hMainFigure,'Color');
image(IconData);
set(imgAxis,'Visible','off');
set(hMainFigure, 'Colormap', IconCMap);
axis off;
axis equal; 

textbox = uicontrol('Tag','msgwindow_text',...
    'Style','text',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'Position',[80 60 guiSize(1)-100 guiSize(2)-80],...
    'String',message...
    );

button = uicontrol('Tag','msgwindow_button',...
    'Style','pushbutton',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[(guiSize(1)/2)-30 20 60 30],...
    'String','OK',...
    'Visible','off',...
    'Callback',{@delete,hMainFigure}...
    );

% Create the message window

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Store handles in guidata
guidata(hMainFigure,guihandles);

% Make the GUI visible.
set(hMainFigure,'Visible','on');
if showButton
    set(button,'Visible','on');
else
    set(button,'Visible','off');
end
drawnow;

varargout{1} = hMainFigure;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
