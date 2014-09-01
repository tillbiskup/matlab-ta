function [status,warnings] = cmdDisp(handle,opt,varargin)
% CMDDISP Command line command of the TA GUI.
%
% Usage:
%   cmdDisp(handle,opt)
%   [status,warnings] = cmdDisp(handle,opt)
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

if isempty(opt)
    warnings{end+1} = ['Command "' lower(cmd) '" needs options.'];
    status = -2;
    return;
end

% Get appdata from handle
ad = getappdata(handle);
% Get handles from handle
% gh = guidata(handle);

switch lower(opt{1})
    case 'x'
        switchDisplayType('1D along x');
        return;
    case 'y'
        switchDisplayType('1D along y');
        return;
    case 'z'
        switchDisplayType('2D plot');
        return;
    case 'grid'
        if length(opt) < 2
            status = -3;
            warnings{end+1} = ['Command ' cmd ': Missing option.'];
            return;
        end
        switch lower(opt{2})
            case {'x','y','minor'}
                if length(opt) < 3
                    if strcmpi(ad.control.axis.grid.(lower(opt{2})),'on')
                        ad.control.axis.grid.(lower(opt{2})) = 'off';
                    else
                        ad.control.axis.grid.(lower(opt{2})) = 'on';
                    end
                else
                    switch lower(opt{3})
                        case 'on'
                            ad.control.axis.grid.(lower(opt{2})) = 'on';
                        case 'off'
                            ad.control.axis.grid.(lower(opt{2})) = 'off';
                        otherwise
                            status = -3;
                            warnings{end+1} = ['Command ' cmd ': Option ' ...
                                opt{3} ' in combination with option ' ...
                                opt{2} ' not understood.'];
                            return;
                    end
                end
            case 'zero'
                if length(opt) < 3
                    if ad.control.axis.grid.zero.visible
                        ad.control.axis.grid.zero.visible = 0;
                    else
                        ad.control.axis.grid.zero.visible = 1;
                    end
                else
                    switch lower(opt{3})
                        case 'on'
                            ad.control.axis.grid.zero.visible = 1;
                        case 'off'
                            ad.control.axis.grid.zero.visible = 0;
                        otherwise
                            status = -3;
                            warnings{end+1} = ['Command ' cmd ': Option ' ...
                                opt{3} ' in combination with option ' ...
                                opt{2} ' not understood.'];
                            return;
                    end
                end
            otherwise
                status = -3;
                warnings{end+1} = ['Command ' cmd ': Option ' opt{2} ...
                    ' not understood.'];
                return;
        end
    case 'legend'
        if length(opt) < 2
            status = -3;
            warnings{end+1} = ['Command ' cmd ': Missing option.'];
            return;
        end
        switch lower(opt{2})
            case 'none'
                ad.control.axis.legend.location = opt{2};
            case {'auto','best'}
                ad.control.axis.legend.location = 'Best';
            case {'nw','northwest'}
                ad.control.axis.legend.location = 'NorthWest';
            case {'ne','northeast'}
                ad.control.axis.legend.location = 'NorthEast';
            case {'sw','southwest'}
                ad.control.axis.legend.location = 'SouthWest';
            case {'se','southeast'}
                ad.control.axis.legend.location = 'SouthEast';
            case 'box'
                if length(opt) < 3
                    if ad.control.axis.legend.box
                        ad.control.axis.legend.box = 0;
                    else
                        ad.control.axis.legend.box = 1;
                    end
                else
                    switch lower(opt{3})
                        case 'on'
                            ad.control.axis.legend.box = 1;
                        case 'off'
                            ad.control.axis.legend.box = 0;
                        otherwise
                            status = -3;
                            warnings{end+1} = ['Command ' cmd ': Option ' ...
                                opt{3} ' in combination with option ' ...
                                opt{2} ' not understood.'];
                            return;
                    end
                end
            otherwise
                status = -3;
                warnings{end+1} = ['Command ' cmd ': Option ' opt{2} ...
                    ' not understood.'];
                return;
        end
    case 'onlyactive'
        if length(opt) < 2
            if ad.control.axis.onlyActive
                ad.control.axis.onlyActive = 0;
            else
                ad.control.axis.onlyActive = 1;
            end
        else
            switch lower(opt{2})
                case 'on'
                    ad.control.axis.onlyActive = 1;
                case 'off'
                    ad.control.axis.onlyActive = 0;
                otherwise
                    status = -3;
                    warnings{end+1} = ['command ' cmd ': option ' opt{2} ...
                        ' not understood.'];
                    return;
            end
        end
    case {'stdev','std'}
        if length(opt) < 2
            if ad.control.axis.stdev
                ad.control.axis.stdev = 0;
            else
                ad.control.axis.stdev = 1;
            end
        else
            switch lower(opt{2})
                case 'on'
                    ad.control.axis.stdev = 1;
                case 'off'
                    ad.control.axis.stdev = 0;
                otherwise
                    status = -3;
                    warnings{end+1} = ['Command ' cmd ': Option ' opt{2} ...
                        ' not understood.'];
                    return;
            end
        end
    case {'norm','normalise','normalize','normalisation','normalization'}
        if length(opt) < 2
            status = -3;
            warnings{end+1} = ['Command ' cmd ': Missing option.'];
            return;
        end
        switch lower(opt{2})
            case {'none','off'}
                ad.control.axis.normalisation = 'none';
            case {'pkpk','peaktopeak','pk2pk','peak2peak'}
                ad.control.axis.normalisation = 'pkpk';
            case {'amp','amplitude'}
                ad.control.axis.normalisation = 'amplitude';
            otherwise
                status = -3;
                warnings{end+1} = ['Command ' cmd ': Option ' opt{2} ...
                    ' not understood.'];
                return;
        end
    case {'limit','limits'}
        if length(opt) < 2
            status = -3;
            warnings{end+1} = ['Command ' cmd ': Missing option.'];
            return;
        end
        switch lower(opt{2})
            case 'auto'
                if length(opt) < 3
                    if ad.control.axis.limits.auto
                        ad.control.axis.limits.auto = 0;
                    else
                        ad.control.axis.limits.auto = 1;
                    end
                else
                    switch lower(opt{3})
                        case 'on'
                            ad.control.axis.limits.auto = 1;
                        case 'off'
                            ad.control.axis.limits.auto = 0;
                        otherwise
                            status = -3;
                            warnings{end+1} = ['Command ' cmd ...
                                ': Option ' opt{3} ...
                                ' in combination with option ' ...
                                opt{2} ' not understood.'];
                            return;
                    end
                end
            case {'x','y','z'}
                if length(opt) < 4
                    status = -3;
                    warnings{end+1} = ['Command ' cmd ': Missing option.'];
                    return;
                end
                if any(isnan(str2double([opt{3:4}])))
                    status = -3;
                    warnings{end+1} = ['Command ' cmd ': Value for '...
                        opt{2} ' has wrong format.'];
                    return;
                end
                ad.control.axis.limits.(opt{2}).min = str2double(opt{3});
                ad.control.axis.limits.(opt{2}).max = str2double(opt{4});
            otherwise
                status = -3;
                warnings{end+1} = ['Command ' cmd ': Option ' opt{2} ...
                    ' not understood.'];
                return;
        end
%     case 'highlight'
%         if length(opt) < 2
%             if ad.control.axis.legend.box
%                 ad.control.axis.legend.box = 0;
%             else
%                 ad.control.axis.legend.box = 1;
%             end
%         else
%             switch lower(opt{2})
%                 case 'on'
%                 case 'off'
%             end
%         end
    otherwise
        return;
end

setappdata(handle,'control',ad.control);
update_displayPanel();
update_mainAxis();

end

