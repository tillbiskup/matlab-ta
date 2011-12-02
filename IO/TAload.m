function varargout = TAload(filename, varargin)
% TALOAD Load files or scans whole directories for readable files
%
% Usage
%   TAload(filename)
%   [data] = TAload(filename)
%   [data,warnings] = TAload(filename)
%
%   filename - string
%              name of a valid filename (of a fsc2 file)
%   data     - struct
%              structure containing data and additional fields
%
%   warnings - cell array of strings
%              empty if there are no warnings
%
% If no data could be loaded, data is an empty struct.
% In such case, warning may hold some further information what happened.
%
% If called with no output argument, the data are written to variables
% in the workspace that have the same* name as the file(s) read.
%
% The function is in principle only a wrapper for other functions that
% are specialized to read the different kinds of input files.
% Configuration of these functions via the file 'TAload.ini' - see
% there for details. Only if it is an ascii file and no function is
% found from the configuration file, 'importdata' is called to try to
% handle the data.
%
% *Same means here that a regexprep is performed removing all
% non-allowed characters for MATLAB variables from the filename.
%
% See also TAOXREAD, TADATASTRUCTURE.

% (c) 2011, Till Biskup
% 2011-11-27

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('filename', @(x)ischar(x) || iscell(x) || isstruct(x));
% p.addOptional('parameters','',@isstruct);
p.addParamValue('format','automatic',@ischar);
p.addParamValue('combine',logical(false),@islogical);
p.parse(filename,varargin{:});

if iscell(filename)
    sort(filename);
elseif isstruct(filename)
    % That might be the case if the user uses "dir" as input for the
    % filenames, as this returns a structure with fields as "name"
    if ~isfield(filename,'name')
        varargout{1} = 0;
        varargout{2} = 'Cannot determine filename(s).';
    end        
    % Convert struct to cell
    filename = struct2cell(filename);
    filename = filename(1,:)';
    % Remove '.' and '..'
    [~,ind] = max(strcmp('.',filename));
    filename(ind) = [];
    [~,ind] = max(strcmp('..',filename));
    filename(ind) = [];
    sort(filename);
else
    % If filename is neither cell nor struct
    % Given the input parsing it therefore has to be a string
end

if ~exist('content','var') && nargout
    varargout{1} = 0;
    varargout{2} = [];
end

    
end