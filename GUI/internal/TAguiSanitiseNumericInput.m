function [value,status,warnings] = TAguiSanitiseNumericInput(value,varargin)
% TAGUISANITISENUMERICINPUT Helper function sanitising numerical input
% from GUI edit fields and converting comma->dot for numbers 
%
% Usage:
%   value = TAguiSanitiseNumericInput(value)
%   value = TAguiSanitiseNumericInput(value,vector)
%   [value,status] = TAguiSanitiseNumericInput(value,vector)
%   [value,status,warnings] = TAguiSanitiseNumericInput(value,vector)
%
%   value = sanitiseNumericInput(value,vector,...)
%
%   value   - string
%             Normally directly the string from the edit field, as
%             accessible via "get(source,'String')"
%
%   vector  - numeric,vector (OPTIONAL)
%             Vector to map/interpolate data to or to test for boundaries
%             If you don't specify a vector as input, the input will only
%             be converted into a numeric value and comma replaced by dot
%             before.
%
%   status  - scalar
%             Return value for the exit status:
%             -2: Problems with boundaries
%             -1: value not numeric after conversion
%              0: successfully sanitised value
%
%  warnings - cell array
%             Contains warnings/error messages if any, otherwise empty
%
%  Additional parameters
%
%  round    - boolean
%             Whether to round value.
%             Default: false
%
%  map      - boolean
%             Whether to map value to elements of vector.
%             Default: false
%
%  index    - boolean
%             Whether to return index to matching value of vector.
%             Default: false

% Copyright (c) 2013, Till Biskup
% 2013-07-15

status = 0;
warnings = cell(0);

% If called with no input arguments, just display help and exit
if (nargin==0)
    help sanitiseInput;
    return;
end

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('value', @(x)ischar(x));
p.addOptional('vector',[],@(x)isvector(x));
p.addParamValue('round',false, @(x)islogical(x));
p.addParamValue('interp',false, @(x)islogical(x));
p.addParamValue('map',false, @(x)islogical(x));
p.addParamValue('index',false, @(x)islogical(x));
p.parse(value,varargin{:});

vector = p.Results.vector;

if ~isempty(vector)
    % Replace keyword "end" with end of vector
    if any(strcmpi(value,{'end','$'}))
        value = vector(end);
        return;
    end
    
    % Replace keyword "end" with end of vector
    if any(strcmpi(value,{'start','begin','^'}))
        value = vector(1);
        return;
    end
end

% Replace comma->dot
value = strrep(value,',','.');

% Convert into double
value = str2double(value);

% Handle situation that conversion into number went wrong
if isnan(value)
    status = -1;
    warnings{end+1} = 'Value cannot be converted into number';
    return;
end

% Handle rounding
if p.Results.round
    value = round(value);
end

if ~isempty(vector)
    % Check for correct boundaries
    if value > vector(end)
        value = vector(end);
        status = -2;
        warnings{end+1} = 'Value larger than largest value in vector';
    end
    if value < vector(1)
        value = vector(1);
        status = -2;
        warnings{end+1} = 'Value smaller than smallest value in vector';
    end
    
    % Handle mapping of value to vector
    if any([p.Results.map,p.Results.interp,p.Results.index])
        value = vector(interp1(vector,1:length(vector),value,'nearest'));
        if p.Results.index
            value = find(vector==value);
        end
    end
end

end
