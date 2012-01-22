function varargout = TAscale(varargin)
% TACOMBINE Scale two datasets contained in the input parameter with
% respect to each other.
%
% Usage
%                           [...] = TAcombine(command,...)
%                        scalable = TAcombine('check',datasets)
%           [scalable,wavelength] = TAcombine('check',datasets)
%           [datasets,parameters] = TAcombine('scale',datasets,parameters)
%   [datasets,parameters,history] = TAcombine('scale',datasets,parameters)
%                      parameters = TAcombine('factor',datasets,parameters)
%                      parameters = TAcombine('parameters')
%
% command    - string
%              The first parameter; for a description see below.
%              options: 'check','scale','factor','parameters'
%              default: 'parameters'
%
% datasets   - cell array
%              Cell array of (two) datasets in TA toolbox format
%
%              As an output parameter, scaled datasets, with the
%              overlapping trace removed from the non-master dataset.
%
% parameters - struct
%              Structure containing all parameters necessary to perform the
%              scaling.
%              For a sample structure, call the function with command
%              'parameters'.
%
%              As an output parameter, structure with the parameters used
%              to perform the given action.
%
% scalable   - boolean
%              logical(true) if datasets overlap, logical(false) otherwise
%
% wavelength - scalar
%              Wavelength the two datasets share.
%              Empty vector if none.
%
% history    - struct
%              Structure holding a complete record of the performed action,
%              as used within the TA toolbox.
%
% Commands
%
% The function uses "commands" as its first parameter, defining what to do.
% In the following a short description of each of the available commands:
%
% check      - Check whether the two datasets overlap and whether it's
%              therefore possible to scale them.
%
%              Returns a boolean parameter (true/false).
%
%              If called with two return parameters, the second will hold
%              the wavelength both datasets have in common.
%
% scale      - Perform the actual scaling of the two datasets.
%
%              Returns a parameter structure and the two datasets, one of
%              them scaled onto the other.
%
% factor     - Determine the scaling factor, but don't perform the scaling
%              of the datasets.
%
%              Returns a parameter structure with the parameters of the
%              scaling.
%
% parameters - Return a sample parameter structure necessary for 'scale'
%              and 'factor' commands.
%

% (c) 2012, Till Biskup
% 2012-01-22

% If there is no input parameter, display help and return
if ~nargin
    help TAscale;
    return;
end

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addOptional('command','parameters', @(x)strcmpi(x,'check') || ...
    strcmpi(x,'scale') || strcmpi(x,'factor') || strcmpi(x,'parameters'));
p.addOptional('datasets',cell(0), @(x)iscell(x));
p.addOptional('parameters',struct(), @(x)isstruct(x));
p.parse(varargin{:});

try
    parameters = struct(...
        'method','time avg',...
        'master',1, ...
        'factor',1,...
        'parameters',struct(...
            'avg',struct(...
                'index',[],...
                'values',[],...
                'unit',''...
                ),...
            'smoothing',struct(...
                'method','',...
                'index',[],...
                'value',[],...
                'unit',''...
                )...
            )...
        );
    switch p.Results.command
        case 'check'
            % Check whether the two datasets overlap
            
            % Check for input
            if isempty(p.Results.datasets)
                disp('Not enough datasets for checking...');
                varargout{1} = logical(false);
                return;
            end
            % Check whether structures validate
            [miss1,wrong1] = TAdataStructure('check',p.Results.datasets{1});
            [miss2,wrong2] = TAdataStructure('check',p.Results.datasets{2});
            if ~isempty(miss1) || ~isempty(miss2) || ...
                    ~isempty(wrong1) || ~isempty(wrong2)
                disp('At least one dataset does not validate...');
                varargout{1} = logical(false);
                return;
            end
            
            % Actual check for overlapping
            [overlapping,wavelength] = checkOverlap(p.Results.datasets);
            varargout{1} = overlapping;
            varargout{2} = wavelength;
        case 'scale'
            % Perform the actual scaling of the two datasets.
            
            % Check for input
            if isempty(p.Results.datasets)
                disp('Not enough datasets for scaling...');
                varargout{1} = logical(false);
                return;
            end
            % Check whether structures validate
            [miss1,wrong1] = TAdataStructure('check',p.Results.datasets{1});
            [miss2,wrong2] = TAdataStructure('check',p.Results.datasets{2});
            if ~isempty(miss1) || ~isempty(miss2) || ...
                    ~isempty(wrong1) || ~isempty(wrong2)
                disp('At least one dataset does not validate...');
                varargout{1} = logical(false);
                return;
            end
            % Check for parameters
            if isempty(fieldnames(p.Results.parameters))
                disp('Parameters structure is missing...');
                varargout{1} = logical(false);
                return;
            else
                parameters = p.Results.parameters;
            end
            
            % Actual scaling
            parameters = scalingFactor(p.Results.datasets,parameters);

            datasets = p.Results.datasets;
            if parameters.master == 1
                datasets{2}.data = datasets{2}.data*parameters.factor;
                % Remove overlapping trace from non-master dataset
               datasets{2}.data(datasets{2}.axes.y.values==...
                   parameters.overlappingWavelength,:) = [];
               datasets{2}.axes.y.values(datasets{2}.axes.y.values==...
                   parameters.overlappingWavelength) = [];
            else
                datasets{1}.data = datasets{1}.data*parameters.factor;
                % Remove overlapping trace from non-master dataset
               datasets{1}.data(datasets{1}.axes.y.values==...
                   parameters.overlappingWavelength,:) = [];
               datasets{1}.axes.y.values(datasets{1}.axes.y.values==...
                   parameters.overlappingWavelength) = [];
            end
            
            % Write history record
            history = struct(...
                'date',datestr(now,31),...
                'method',mfilename,...
                'system',struct(...
                    'username','',...
                    'platform',deblank(platform),...
                    'matlab',version,...
                    'TA',TAinfo('version')...
                ),...
                'parameters',parameters,...
                'info',''...
                );

            % Get username of current user
            % In worst case, username is an empty string. So nothing should
            % really rely on it.
            % Windows style
            history.system.username = getenv('UserName');
            % Unix style
            if isempty(history.system.username)
                history.system.username = getenv('USER');
            end
            
            varargout{1} = datasets;
            varargout{2} = parameters;
            varargout{3} = history;
        case 'factor'
            % Determine the scaling factor, but don't perform the scaling

            % Check for input
            if isempty(p.Results.datasets)
                disp('Not enough datasets for scaling...');
                varargout{1} = 0;
                return;
            end
            % Check whether structures validate
            [miss1,wrong1] = TAdataStructure('check',p.Results.datasets{1});
            [miss2,wrong2] = TAdataStructure('check',p.Results.datasets{2});
            if ~isempty(miss1) || ~isempty(miss2) || ...
                    ~isempty(wrong1) || ~isempty(wrong2)
                disp('At least one dataset does not validate...');
                varargout{1} = logical(false);
                return;
            end
            % Check for parameters
            if isempty(fieldnames(p.Results.parameters))
                disp('Parameters structure is missing...');
                varargout{1} = logical(false);
                return;
            else
                parameters = p.Results.parameters;
            end
            
            % Actual determining of scaling factor
            parameters = scalingFactor(p.Results.datasets,parameters);

            varargout{1} = parameters;
        case 'parameters'
            % Return sample parameter struct for 'scale' and 'factor'
            varargout{1} = parameters;
    end
catch exception
    throw(exception);
end

end

function [overlapping,wavelength] = checkOverlap(datasets)
    if any(datasets{1}.axes.y.values(1) == ...
            datasets{2}.axes.y.values)
        overlapping = logical(true);
        wavelength = datasets{1}.axes.y.values(1);
    elseif any(datasets{1}.axes.y.values(end) == ...
            datasets{2}.axes.y.values)
        overlapping = logical(true);
        wavelength = datasets{1}.axes.y.values(end);
    else
        overlapping = logical(false);
        wavelength = [];
    end
end

function parameters = scalingFactor(datasets,parameters)
    % Get overlapping wavelength
    [~,wavelength] = checkOverlap(datasets);
    parameters.overlappingWavelength = wavelength;

    % Create traces from data
    scaleTraces(1,:) = ...
        datasets{1}.data(datasets{1}.axes.y.values==wavelength,:);
    scaleTraces(2,:) = ...
        datasets{2}.data(datasets{2}.axes.y.values==wavelength,:);
    
    switch parameters.method
        case 'time avg'
            % Check for value of index - and if <= 1, assume that it is
            % percentage rather than real indices
            if parameters.parameters.avg.index(1) <= 1 && ...
                    parameters.parameters.avg.index(1) <= 1
                parameters.parameters.avg.index(1) = ...
                    round(length(scaleTraces(1,:))*...
                    parameters.parameters.avg.index(1));
                parameters.parameters.avg.index(2) = ...
                    round(length(scaleTraces(1,:))*...
                    parameters.parameters.avg.index(2));
            end
            parameters.parameters.avg.values = ...
                datasets{1}.axes.x.values(...
                parameters.parameters.avg.index);
            parameters.parameters.avg.unit = datasets{1}.axes.x.unit;
            if parameters.master == 1
                parameters.factor = mean(scaleTraces(1,...
                    parameters.parameters.avg.index(1):...
                    parameters.parameters.avg.index(2))) / ...
                    mean(scaleTraces(2,...
                    parameters.parameters.avg.index(1):...
                    parameters.parameters.avg.index(2)));
                parameters.scaledArea = datasets{2}.axes.y.values;
            else
                parameters.factor = mean(scaleTraces(2,...
                    parameters.parameters.avg.index(1):...
                    parameters.parameters.avg.index(2))) / ...
                    mean(scaleTraces(1,...
                    parameters.parameters.avg.index(1):...
                    parameters.parameters.avg.index(2)));
                parameters.scaledArea = datasets{1}.axes.y.values;
            end
        case 'min(diff)'
            % TODO: Add functionality
            disp(['Sorry, method "' parameters.method ...
                '" not yet supported...'])
        otherwise
            disp(['TAscale() : unknown method "' ...
                parameters.method '"']);
            return;
    end
end