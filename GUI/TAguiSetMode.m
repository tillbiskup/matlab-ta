function [status,warnings] = TAguiSetMode(mode,varargin)
% TASETMODE Helper function setting the mode of the TA GUI
%
% Usage:
%   TAguiSetMode(mode)
%   [status,warnings] = TAguiSetMode(mode)
%
%   mode    - string (not case sensitive)
%             Mode to set the GUI into
%             Current options are:
%
%               None, Scroll, sCale, Displace, Zoom, Measure, Pick, cOmmand
%
%             Capital letters denote the single letter abbreviation for
%             each mode that may be used as well.
%
%   status  - scalar
%             Return value for the exit status:
%             -1: no TAgui window found
%             -2: TAgui window appdata don't contain necessary fields
%             -3: some other problems
%              0: successfully set mode
%
%  warnings - cell array
%             Contains warnings/error messages if any, otherwise empty

% (c) 2013, Till Biskup
% 2013-07-12

status = 0;
warnings = cell(0);

% If called with no input arguments, just display help and exit
if (nargin==0)
    help TAguiSetMode;
    return;
end

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('mode', @(x)ischar(x));
%p.addOptional('command','',@(x)ischar(x));
p.parse(mode,varargin{:});

% Is there currently a TAgui object?
mainWindow = TAguiGetWindowHandle();
if (isempty(mainWindow))
    warnings{end+1} = 'No TAgui window could be found.';
    status = -1;
    return;
end

% Get appdata from mainwindow
ad = getappdata(mainWindow);
% Get handles from main GUI
gh = guidata(mainWindow);

% Check for availability of necessary fields in appdata
if ~isfield(ad,'control') || ~isfield(ad.control,'status')
    warnings{end+1} = ['TAgui window appdata don''t contain '...
        'necessary fields'];
    status = -2;
    return;
end

% Check whether mode has changed, and if not, return
if strcmpi(ad.control.mode,mode)
    if strcmpi(mode,'command')
        uicontrol(gh.command_panel_edit);
    end
    return;
end

% Handle modes
% Current modes are: None, Scroll, sCale, Displace, Zoom, Measure, Pick
switch lower(mode)
    case {'none','n'}
        GUImode = 'None';
        guiZoom('off');
        guiMeasure('off',0);
        set(gh.command_panel_edit,'Enable','inactive');
        set(gh.command_panel_edit,...
            'String','Enter command - Ctrl-l / Cmd-l for access');
    case {'scroll','s'}
        guiZoom('off');
        guiMeasure('off',0);
        GUImode = 'Scroll';
    case {'scale','c'}
        guiZoom('off');
        guiMeasure('off',0);
        GUImode = 'Scale';
    case {'displace','d'}
        guiZoom('off');
        guiMeasure('off',0);
        GUImode = 'Displace';
    case {'zoom','z'}
        guiMeasure('off',0);
        guiZoom('on');
        GUImode = 'Zoom';
    case {'measure','m'}
        guiZoom('off');
        guiMeasure('on',2);
        GUImode = 'Measure';
    case {'pick','p'}
        guiZoom('off');
        guiMeasure('on',1);
        GUImode = 'Pick';
    case {'command','o'}
        guiZoom('off');
        guiMeasure('off',0);
        GUImode = 'Command';
        set(gh.command_panel_edit,'Enable','on');
        set(gh.command_panel_edit,'String','');
        uicontrol(gh.command_panel_edit);
    otherwise
        warnings{end+1} = sprintf('Unknown mode "%s"\n',mode);
        status = -3;
end

% Get appdata again
ad = getappdata(mainWindow);

% Set mode in main GUI window
ad.control.mode = GUImode;

% Push appdata back to main gui
setappdata(mainWindow,'control',ad.control);

% Set mode display accordingly
set(gh.status_panel_mode_text,'String',GUImode);

% Inform user about mode switching
TAmsg(['Mode switched to "' GUImode '"'],'debug');

end