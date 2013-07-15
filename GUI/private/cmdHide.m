function [status,warnings] = cmdHide(handle,opt,varargin)
% CMDHIDE Command line command of the TA GUI.
%
% Usage:
%   cmdHide(handle,opt)
%   [status,warnings] = cmdHide(handle,opt)
%
%   handle  - handle
%             Handle of the window the command should be performed for
%
%   opt     - cell array
%             Options of the command
%
%   status  - scalar
%             Return value for the exit status:
%              0: command successfully performed
%             -1: GUI window found
%             -2: missing options
%             -3: some other problems
%
%  warnings - cell array
%             Contains warnings/error messages if any, otherwise empty

% (c) 2013, Till Biskup
% 2013-07-15

status = 0;
warnings = cell(0);

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('handle', @(x)ishandle(x));
p.addRequired('opt', @(x)iscell(x));
%p.addOptional('opt',cell(0),@(x)iscell(x));
p.parse(handle,opt,varargin{:});
handle = p.Results.handle;
opt = p.Results.opt;

% Get command name from mfilename
cmd = mfilename;
cmd = cmd(4:end);

% Is there the GUI requested?
if (isempty(handle))
    warnings{end+1} = 'No GUI window could be found.';
    status = -1;
    return;
end

% Get appdata from handle
ad = getappdata(handle);
% Get handles from handle
gh = guidata(handle);

% For convenience and shorter lines
active = ad.control.spectra.active;

if isempty(ad.data)
    warnings{end+1} = ['Command "' lower(cmd) '" needs datasets.'];
    return;
end

if isempty(opt)
    if ~isempty(ad.control.spectra.visible)
        % Get selected item of listbox
        selected = get(gh.data_panel_visible_listbox,'Value');
        
        % Be on the save side if user is faster than Matlab
        if selected == 0
            return;
        end
        
        selectedId = ad.control.spectra.visible(selected);
        
        % Move to invisible
        ad.control.spectra.invisible = [...
            ad.control.spectra.invisible ...
            ad.control.spectra.visible(selected) ...
            ];
        
        % Delete in visible
        ad.control.spectra.visible(selected) = [];
        
        % Toggle active entry
        if (selected > length(ad.control.spectra.visible))
            if (selected == 1)
                ad.control.spectra.active = 0;
            else
                ad.control.spectra.active = ad.control.spectra.visible(end);
            end
        else
            ad.control.spectra.active = ad.control.spectra.visible(selected);
        end
        
        % Update appdata of main window
        setappdata(handle,'control',ad.control);
        
        % Add status message (mainly for debug reasons)
        % IMPORTANT: Has to go AFTER setappdata
        msgStr = cell(0,1);
        msgStr{end+1} = sprintf(...
            'Moved dataset %i to invisible',selectedId);
        msgStr{end+1} = ['Label: ' ...
            ad.data{selectedId}.label];
        invStr = sprintf('%i ',ad.control.spectra.invisible);
        visStr = sprintf('%i ',ad.control.spectra.visible);
        msgStr{end+1} = sprintf(...
            'Currently invisible: [ %s]; currently visible: [ %s]; total: %i',...
            invStr,visStr,length(ad.data));
        TAmsg(msgStr,'debug');
        
        % Update both list boxes
        update_invisibleSpectra();
        update_visibleSpectra();
        
        %Update main axis
        update_mainAxis();
        return;
    end
end

switch lower(opt{1})
    case 'all'
        % If there are no visible datasets, return immediately
        if isempty(ad.control.spectra.visible)
            return;
        end
        % Move to invisible
        ad.control.spectra.invisible = [...
            ad.control.spectra.invisible ...
            ad.control.spectra.visible ...
            ];
        
        % Delete in visible
        ad.control.spectra.visible = [];
        
        % Reset active entry
        ad.control.spectra.active = 0;
        
        % Update appdata of main window
        setappdata(handle,'control',ad.control);
        
        % Add status message (mainly for debug reasons)
        % IMPORTANT: Has to go AFTER setappdata
        msgStr = cell(0,1);
        msgStr{end+1} = 'Moved all datasets to invisible';
        invStr = sprintf('%i ',ad.control.spectra.invisible);
        visStr = sprintf('%i ',ad.control.spectra.visible);
        msgStr{end+1} = sprintf(...
            'Currently invisible: [ %s]; currently visible: [ %s]; total: %i',...
            invStr,visStr,length(ad.data));
        TAmsg(msgStr,'debug');
        
        % Update both list boxes
        update_invisibleSpectra();
        update_visibleSpectra();
        
        %Update main axis
        update_mainAxis();
        return;
    otherwise
        status = -3;
        warnings{end+1} = ['Option ' opt{1} ' not understood.'];
        return;
end
end

