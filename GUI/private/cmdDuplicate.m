function [status,warnings] = cmdDuplicate(handle,opt,varargin)
% CMDDUPLICATE Command line command of the TA GUI.
%
% Usage:
%   cmdDuplicate(handle,opt)
%   [status,warnings] = cmdDuplicate(handle,opt)
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

% Copyright (c) 2013, Till Biskup
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
    % Get selected item of listbox
    selected = get(gh.data_panel_visible_listbox,'Value');
    
    % Create label for duplicate
    % That is, add number in brackets at the end: (n)
    % But check whether there is already such a number in brackets in
    % any of the visible spectra with the same label.
    expression = sprintf('\\((\\d+)\\)$',ad.data{selected}.label);
    l = 0;
    token = [];
    for k=1:length(ad.control.spectra.visible)
        tokens = regexp(...
            ad.data{ad.control.spectra.visible(k)}.label,...
            expression,'tokens');
        if ~isempty(tokens)
            l=l+1;
            token(l) = str2double(char(tokens{1}));
        end
    end
    if ~isempty(token)
        if (regexp(ad.data{selected}.label,' \((\d+)\)$'))
            duplicateLabel = regexprep(...
                ad.data{selected}.label,...
                ' \((\d+)\)$',sprintf(' (%i)',max(token)+1));
        else
            duplicateLabel = sprintf('%s (%i)',...
                ad.data{selected}.label,max(token)+1);
        end
    else
        duplicateLabel = sprintf('%s (1)',ad.data{selected}.label);
    end
    
    % Actually duplicate the dataset
    duplicate = ad.data{selected};
    % Set label of duplicate
    duplicate.label = duplicateLabel;
    % IMPORTANT: Set the filename of the duplicate to empty string
    duplicate.file.name = '';
    
    nSpectra = length(ad.data);
    
    ad.data{end+1} = duplicate;
    ad.origdata{end+1} = duplicate;
    
    ad.control.spectra.visible(end+1) = nSpectra+1;
    ad.control.spectra.modified(end+1) = nSpectra+1;
    
    % Update appdata of main window
    setappdata(handle,'control',ad.control);
    setappdata(handle,'data',ad.data);
    setappdata(handle,'origdata',ad.origdata);
    
    % Add status message (mainly for debug reasons)
    % IMPORTANT: Has to go AFTER setappdata
    msgStr = cell(0,1);
    msgStr{end+1} = ...
        sprintf(...
        'Data set "%s" duplicated as %s',...
        ad.data{selected}.label,...
        duplicateLabel);
    invStr = sprintf('%i ',ad.control.spectra.invisible);
    visStr = sprintf('%i ',ad.control.spectra.visible);
    msgStr{end+1} = sprintf(...
        'Currently invisible: [ %s]; currently visible: [ %s]; total: %i',...
        invStr,visStr,length(ad.data));
    TAmsg(msgStr,'debug');
    clear msgStr;
    
    % Update both list boxes
    update_invisibleSpectra();
    update_visibleSpectra();
    
    %Update main axis
    update_mainAxis();
end
end

