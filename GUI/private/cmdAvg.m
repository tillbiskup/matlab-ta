function [status,warnings] = cmdAvg(handle,opt,varargin)
% CMDHELP Command line command of the TA GUI.
%
% Usage:
%   cmdAvg(handle,opt)
%   [status,warnings] = cmdAvg(handle,opt)
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
cmd = lower(cmd(4:end));

% Is there the GUI requested?
if (isempty(handle))
    warnings{end+1} = 'No GUI window could be found.';
    status = -1;
    return;
end

% Get appdata from handle
ad = getappdata(handle);

% For convenience and shorter lines
active = ad.control.spectra.active;

% If there is no active dataset, return
if ~active
    warnings{end+1} = sprintf('Command "%s": No active dataset.',cmd);
    status = -3;
    return;
end

% Create some structure for AVG parameters
avg = struct();

if ~isempty(opt)
    % Check for minumum number of options
    if length(opt) < 2
        warnings{end+1} = sprintf(...
            'Command "%s": Not enough options. Use "help %s" to get some help.',cmd,cmd);
        status = -2;
        return;
    end
        
    % Check whether first option is numeric (-> dataset no) or char (dim)
    if ~isnan(str2double(opt{1}))
        avg.dataset = str2double(opt{1});
        % Remove first option
        opt(1) = [];
    else
        avg.dataset = active;
    end
    % Check for dimension
    if any(strcmpi(opt{1},{'x','y'}))
        avg.dimension = lower(opt{1});
    else
        warnings{end+1} = sprintf(...
            'Command "%s": Wrong dimension "%s".',cmd,lower(opt{1}));
        status = -3;
        return;
    end
    % Check for start:stop vs center,width
    if strfind(opt{2},':')
        % We have a range
        [avg.start,conversion1Status] = TAguiSanitiseNumericInput(...
            opt{2}(1:strfind(opt{2},':')-1),...
            ad.data{active}.axes.(avg.dimension).values,...
            'map',true,'index',true);
        [avg.stop,conversion2Status] = TAguiSanitiseNumericInput(...
            opt{2}(strfind(opt{2},':')+1:end),...
            ad.data{active}.axes.(avg.dimension).values,...
            'map',true,'index',true);
        if isnan(avg.start) || isnan(avg.stop) || conversion1Status ...
                || conversion2Status
            warnings{end+1} = sprintf(...
                'Command "%s": Problems with averaging window "%s".',...
                cmd,lower(opt{2}));
            status = -3;
            return;
        end
    elseif strfind(opt{2},';')
        % We have center;width
        % Convert center and width value to numeric values
        [center,conversion1Status] = TAguiSanitiseNumericInput(...
            opt{2}(1:strfind(opt{2},';')-1));
        [width,conversion2Status] = TAguiSanitiseNumericInput(...
            opt{2}(strfind(opt{2},';')+1:end));
        % Transform center;width into start:stop and map to dataset axis
        [avg.start,conversion3Status] = TAguiSanitiseNumericInput(...
            num2str(center-width/2),...
            ad.data{active}.axes.(avg.dimension).values,...
            'map',true,'index',true);
        [avg.stop,conversion4Status] = TAguiSanitiseNumericInput(...
            num2str(center+width/2),...
            ad.data{active}.axes.(avg.dimension).values,...
            'map',true,'index',true);
        if isnan(avg.start) || isnan(avg.stop) || conversion1Status ...
                || conversion2Status || conversion3Status || conversion4Status
            warnings{end+1} = sprintf(...
                'Command "%s": Problems with averaging window "%s".',...
                cmd,lower(opt{2}));
            status = -3;
            return;
        end
    else
        warnings{end+1} = sprintf(...
            'Command "%s": Wrong averaging window "%s".',cmd,lower(opt{2}));
        status = -3;
        return;
    end
    % In case we have additional options, this should be a label
    if length(opt) > 2
        avg.label = opt{3};
    end
    
    % Perform actual averaging
    avgData = TAAVG(ad.data{active},avg);
    
    % Add dataset to main GUI
    status = TAappendDatasetToMainGUI(avgData,'modified',true);
    if status
        warnings{end+1} = sprintf(...
            'Command "%s": Some problems appending accumulated data.',cmd);
        status = -3;
    end
else
    TAgui_AVGwindow();
end

end

