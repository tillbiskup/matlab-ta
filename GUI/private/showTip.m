function varargout = showTip(varargin)
% SHOWTIP Shows a window with a short message, mostly a hint of how to
% use something.
%
% Usage
%   showTip
%   TF = showTip
%
% See also msgbox

% Copyright (c) 2012, Till Biskup
% 2012-04-01

% Make GUI effectively a singleton
singleton = findobj('Tag','showTip');
if (singleton)
    figure(singleton);
    varargout{1} = get(hShowCheckbox,'Value');
    return;
end

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure
p.addParamValue('Position', [115 300], @(x)isnumeric(x));
p.addParamValue('File','',@(x)ischar(x));
p.CaseSensitive = false; % Disable case-sensitive parsing
p.parse(varargin{:});


% Configuration settings
backgroundColor = [1 1 1];
iconSize = [48 48];

% Check whether we have some input parameters
position = p.Results.Position;
if p.Results.File
    if ~exist(p.Results.File,'file')
        fprintf('Problem: File "%s" does not exist.','p.Results.File');
    else
        try
            fContent = load(p.Results.File,'-mat');
            tips = fContent.tips;
        catch %#ok<CTCH>
            % load text file
            tips = importdata(p.Results.File);
            for k = 1:length(tips)
                if k<=length(tips)
                    if isempty(tips{k})
                        tips(k) = [];
                    end
                    if strncmp(tips{k},'%',1)
                        tips(k) = [];
                    end
                end
            end
        end
        clear fContent file
    end
end

if ~exist('tips','var')
    tips = {['<font color="red">'...
        'Sorry, but you haven''t specified a (proper) file.'...
        '<br />Refer to the help for <tt>showTip.m</tt> how to create '...
        ' it and how to call this function properly.</font>']};
end
% Add html tags afterwards (makes strings themselves shorter and easier
tips = cellfun(@(x)cellstr(['<html>' x '</html>']),tips);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hMsgBox = figure('Tag','showTip',...
    'Name','Did you know...?',...
    'Visible','off',...
    'Units','Pixels',...
    'Position',[position,450,150],...
    'Resize','off',...
    'NumberTitle','off', ...
    'KeyPressFcn',@keypress_Callback,...
    'Menu','none','Toolbar','none'...
    );
%    'Color',backgroundColor,...
figPosition = get(hMsgBox,'Position');
figSize = figPosition(3:4);

backgroundColor = get(hMsgBox,'Color');
% bgColor for Java elements
bgColor = num2cell(backgroundColor);

% Display icon
[path,~,~] = fileparts(mfilename('fullpath'));
icon = javax.swing.ImageIcon(fullfile(path,'tip.png'));
jIconLabel = javax.swing.JLabel('');
jIconLabel.setIcon(icon);
javacomponent(jIconLabel,...
    [26,(figSize(2)-iconSize(2)+5)/2,iconSize(1),iconSize(2)],hMsgBox);
jIconLabel.setBackground(java.awt.Color(bgColor{:}));

% Display Text
headerString = '<html><b><i>Did you know...?</b></i></html>';
jHeaderLabel = javaObjectEDT('javax.swing.JLabel',headerString);
javacomponent(jHeaderLabel,[90,115,figSize(1)-110,15],hMsgBox);
jHeaderLabel.setBackground(java.awt.Color(bgColor{:}));
labelStr = '';
jTextLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
javacomponent(jTextLabel,[90,50,figSize(1)-105,55],hMsgBox);
jTextLabel.setBackground(java.awt.Color(bgColor{:}));

% Checkbox for showing tips at startup
hShowCheckbox = uicontrol('Tag','showatstartup_checkbox',...
    'Style','checkbox',...
    'Parent',hMsgBox,...
    'Enable','on',...
    'TooltipString','Untick not to see tips at startup',...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[90 15 80 25],...
    'String','Show tips',...
    'Value',1,...
    'KeyPressFcn',@keypress_Callback...
    );

% Pushbuttons
uicontrol('Tag','close_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMsgBox,...
    'BackgroundColor',backgroundColor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[90+(figSize(1)-100-60)/2 15 60 25],...
    'String','Close',...
    'TooltipString','Close tip window',...
    'KeyPressFcn',@keypress_Callback,...
    'Callback', {@pushbutton_Callback,'close'}...
    );

uicontrol('Tag','prev_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMsgBox,...
    'BackgroundColor',backgroundColor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[figSize(1)-105 15 45 25],...
    'String','<html>&larr;</html>',...
    'TooltipString','<html>Show previous tip (&larr;)</html>',...
    'KeyPressFcn',@keypress_Callback,...
    'Callback', {@pushbutton_Callback,'prev'}...
    );
uicontrol('Tag','next_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMsgBox,...
    'BackgroundColor',backgroundColor,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[figSize(1)-60 15 45 25],...
    'String','<html>&rarr;</html>',...
    'TooltipString','<html>Show next tip (&rarr;)</html>',...
    'KeyPressFcn',@keypress_Callback,...
    'Callback', {@pushbutton_Callback,'next'}...
    );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create random order of tips
[c(:,1),c(:,2)] = unique(randi(length(tips),100,1),'first');
c = sortrows(c,2);
sequence = c(:,1);
positionInSequence = 1;

jTextLabel.setText(tips{sequence(positionInSequence)});

% Finally, make window visible
set(hMsgBox,'Visible','on');

if nargout
    varargout{1} = get(hShowCheckbox,'Value');
end

uiwait;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pushbutton_Callback(~,~,action)
    try
        if isempty(action)
            return;
        end
        switch action
            case 'next'
                if positionInSequence == length(tips)
                    positionInSequence = 1;
                else
                    positionInSequence = positionInSequence+1;
                end
                jTextLabel.setText(tips{sequence(positionInSequence)});
            case 'prev'
                if positionInSequence == 1
                    positionInSequence = length(tips);
                else
                    positionInSequence = positionInSequence-1;
                end
                jTextLabel.setText(tips{sequence(positionInSequence)});
            case 'close'
                closeWindow()
                return;
            otherwise
                return;
        end
    catch exception
        throw(exception);
    end
end

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
                    case 'w'
                        closeWindow()
                end
            end
        end
        switch evt.Key
            case 'escape'
                closeWindow()
                return;
            case 'rightarrow'
                pushbutton_Callback('','','next');
                return;
            case 'leftarrow'
                pushbutton_Callback('','','prev');
                return;
            otherwise
                return;
        end
    catch exception
        throw(exception);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function closeWindow()
    try
        varargout{1} = get(hShowCheckbox,'Value');
        delete(hMsgBox);
    catch exception
        throw(exception);
    end
end


end
