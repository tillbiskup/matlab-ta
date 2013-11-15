function varargout = TAbusyWindow(varargin)
% TABUSYWINDOW Show window with message and spinning dots using JAVA.
%
% Usage:
%   TAbusyWindow(action);
%   TAbusyWindow(action,description);
%   TAbusyWindow(action,description,<parameter>,<value>);
%   handle = TAbusyWindow(...);
%
%   action      - string
%                 one of: start, stop, fail, delete, deletedelayed
%
%   description - string
%                 
% Additional parameter-value pairs can be passed at the function call.
% Currently, the following parameters are possible:
%
%   position    - vector
%                 four-element vector determining the window position

% (c) 2012-13, Till Biskup
% 2013-11-15

title = 'Processing...';
position = [220,350,270,120];

% Delay time for closing window (in seconds)
closeDelayTime = 2;

description = ['Neque porro quisquam est qui dolorem ipsum '...
    'quia dolor sit amet, consectetur, adipisci velit...'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parameters = struct();
action = 'start';
if nargin
    action = varargin{1};
    if nargin >= 2 && ~isempty(varargin{2})
        description = varargin{2};
    end
    if nargin >2 && ~mod(nargin,2)
        for k=3:2:(nargin)
            parameters.(lower(varargin{k})) = varargin{k+1};
        end
    end
end

if isfield(parameters,'position')
    position = parameters.position;
end

description = ['<html>' description '</html>'];

% Make GUI effectively a singleton
singleton = findobj('Tag','TAbusyWindow');
if ~isempty(singleton)
    if ~nargin
        varargout{1} = figure(singleton);
        return;
    else
        hMainFigure = figure(singleton);
        if nargin>=2
            setappdata(hMainFigure,'description',description);
        end
    end
else
    % Create main figure
    hMainFigure = figure('Tag','TAbusyWindow',...
        'Visible','off',...
        'WindowStyle','modal',...
        'Name',title,...
        'Units','Pixels',...
        'Position',position,...
        'Resize','off',...
        'NumberTitle','off', ...
        'Menu','none','Toolbar','none',...
        'CloseRequestFcn',{@closeWindow}...
        );
    setappdata(hMainFigure,'position',position);
    setappdata(hMainFigure,'description',description);
end

ad = getappdata(hMainFigure);

defaultBackground = get(hMainFigure,'Color');
% bgColor for Java elements
bgColor = num2cell(defaultBackground);

% Text label for general description
jTextLabel1 = javaObjectEDT('javax.swing.JLabel',ad.description);
jTextLabel1.setBackground(java.awt.Color(bgColor{:}));
javacomponent(jTextLabel1,[90 50 ad.position(3)-90-10 ad.position(4)-50-10],hMainFigure);

% Close button
hBtn = uicontrol('Tag','close_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[90+floor((ad.position(3)-100-90)/2) 10 90 30],...
    'String','Close',...
    'TooltipString','Close message window',...
    'Callback',{@closeWindow}...
    );

% Spinning dots
iconsClassName = 'com.mathworks.widgets.BusyAffordance$AffordanceSize';
iconsSizeEnums = javaMethod('values',iconsClassName);
% iconsSizeEnums(1) = 16x16; (2) = 32x32
jObj = com.mathworks.widgets.BusyAffordance(iconsSizeEnums(2),'Busy...');
javacomponent(jObj.getComponent,[10,floor((ad.position(4)-60)/2),80,80],gcf);
jObj.getComponent.setBackground(java.awt.Color(bgColor{:}));
jObj.setPaintsWhenStopped(true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make the GUI visible.
set(hMainFigure,'Visible','on');
set(hBtn,'Visible','off');

switch action
    case 'start'
        if isfield(parameters,'title')
            set(hMainFigure,'Name',parameters.title);
        end
        jObj.start;
        drawnow;
    case 'stop'
        jObj.stop;
        try
            jObj.setBusyText('Done');
        catch exception
            TAmsg(exception.message,'error');
        end
        set(hBtn,'Visible','on');
        set(hMainFigure,'KeyPressFcn',@keypress_Callback);
        if isfield(parameters,'title')
            set(hMainFigure,'Name',parameters.title);
        else
            set(hMainFigure,'Name','Completed.');
        end
        clear('jObj');
    case 'fail'
        jObj.stop;
        try
            jObj.setBusyText('Failed');
        catch exception
            trEPRmsg(exception.message);
        end
        set(hBtn,'Visible','on');
        set(hMainFigure,'KeyPressFcn',@keypress_Callback);
        if isfield(parameters,'title')
            set(hMainFigure,'Name',parameters.title);
        else
            set(hMainFigure,'Name','Failed.');
        end
        clear('jObj');
    case 'delete'
        jObj.stop;
        clear('jObj');
        delete(hMainFigure);
    case 'deletedelayed'
        jObj.stop;
        clear('jObj');
        % Set timer to automatically close the busyWindow.
        % IMPORTANT: Use "StopFcn" for timer that deletes the timer itself
        closeBusyWindowTimer = timer(...
            'TimerFcn',sprintf(...
            'delete(%i)',hMainFigure),...
            'StartDelay',closeDelayTime,...
            'TasksToExecute',1,...
            'Name','busyWindowTimer',...
            'StopFcn','delete(timerfind(''Name'',''busyWindowTimer''))' ...
            );
        start(closeBusyWindowTimer);
    otherwise
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
        clear('jObj');
        try
            delete(hMainFigure);
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