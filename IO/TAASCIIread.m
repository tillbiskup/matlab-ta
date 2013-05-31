function [data,warnings] = TAASCIIread(fileName,varargin)
% TAASCIIREAD Read bare ASCII files
%
% Usage
%   data = TAASCIIread(fileName)
%   [data,warnings] = TAASCIIread(fileName)
%
% fileName    - string|struct|cell array
%               string: name of a valid filename
%               struct: struct with files as returned by "dir"
%               cell array: cell array of strings with filenames
%
% data        - struct / cell array of structs
%               Datasets read from file(s)
%               Each dataset (aka field of the ell array) is a structure
%               complying to the data structure of the TA toolbox.
%
%               If there is only one dataset read, it is a struct rather
%               than a cell array of structs.
% 
% warnings    - cell array of strings
%               empty if there are no warnings
%
% See also: TAload, TAdataStructure

% (c) 2013, Till Biskup
% 2013-05-31

% NOTE: This function uses an internal function to read the actual data.
%       Settings according name of the file format etc. need to be done
%       there. See function "loadData" below.

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('fileName', @(x)ischar(x) || iscell(x) || isstruct(x));
% p.addOptional('parameters','',@isstruct);
p.addParamValue('checkFormat',logical(true),@islogical);
p.addParamValue('sortfiles',logical(true),@islogical);
p.addParamValue('loadInfoFile',logical(false),@islogical);
p.parse(fileName,varargin{:});

% Assign optional arguments from parser
checkFormat = p.Results.checkFormat;
sortfiles = p.Results.sortfiles;
loadInfoFile = p.Results.loadInfoFile;

warnings = cell(0);

% If no filename given
if isempty(fileName)
    data = [];
    warnings{end+1} = 'No filename.';
    return;
end

if iscell(fileName)
    if sortfiles
        sort(fileName);
    end
elseif isstruct(fileName)
    % That might be the case if the user uses "dir" as input for the
    % filenames, as this returns a structure with fields as "name"
    if ~isfield(fileName,'name')
        data = [];
        warnings{end+1} = 'Cannot determine filename(s).';
        return;
    end        
    % Convert struct to cell
    fileName = struct2cell(fileName);
    fileName = fileName(1,:)';
    % Remove files with leading '.', such as '.' and '..'
    fileName(strncmp('.',fileName,1)) = [];
    if sortfiles
        sort(fileName);
    end
else
    % If filename is neither cell nor struct
    % Given the input parsing it therefore has to be a string
    if exist(fileName,'dir')
        % Read directory
        fileName = dir(fileName);
        % Convert struct to cell
        fileName = strut2cell(fileName);
        fileName = fileName(1,:)';
        % Remove files with leading '.', such as '.' and '..'
        fileName(strncmp('.',fileName,1)) = [];
        if sortfiles
            sort(fileName);
        end
    elseif exist(fileName,'file')
        % For convenience, convert into cell array
        fn = fileName;
        fileName = cell(0);
        fileName{1} = fn;
    else
        % If "filename" is neither a directory nor a file...
        % Check whether it's only a basename
        fileName = dir([fileName '*']);
        if isempty(fileName)
            data = [];
            warnings{end+1} = 'No valid filename.';
            return;
        end
        % Convert struct to cell
        fileName = struct2cell(fileName);
        fileName = fileName(1,:)';
        % Remove files with leading '.', such as '.' and '..'
        fileName(strncmp('.',fileName,1)) = [];
        if sortfiles
            sort(fileName);
        end
    end
end

% Try to compress list of files to unique file basenames
% Therefore, first, get filenames with path but excluding extension
fileBaseNames = cell(length(fileName),1);
for k=1:length(fileName)
    [p,f,~] = fileparts(fileName{k});
    fileBaseNames{k} = fullfile(p,f);
end
[~,uniqueIndices,~] = unique(fileBaseNames);

data = cell(length(uniqueIndices),1);
for k=1:length(uniqueIndices)
    [data{k},warning] = loadFile(fileName{uniqueIndices(k)},...
        checkFormat,loadInfoFile);
    if ~isempty(warning)
        warnings{end+1} = warning;
    end
end

if length(data)==1
    data = data{1};
end

end

function [data,warnings] = loadFile(fileName,~,~)
% LOADFILE Load file and return contents. 
%
% fileName     - string
%                Name of a file (normally including full path)
%
% checkFormat  - logical (true/false)
%                Whether to check for proper format
%
% loadInfoFile - logical (true/false)
%                Whether to load accompanying info file (with same
%                basename)
%
% data         - structure
%                According to the toolbox data structure
%
% warnings     - cell array of strings
%                Contains warnings if there are any, otherwise empty.

% As we're called only internally, there's no need for parameter checking.

% A few important settings
% Name of the format as it appears in the file.format field
formatNameString = 'ASCII';

warnings = cell(0);
csv = logical(false);

% Assign empty structure to output argument
data = TAdataStructure();

% First, try to read data with TAB as separator
raw = importdata(fileName,'\t');
% Check if that worked, if not, use COMMA as separator
if ~isfield(raw,'data')
    raw = importdata(fileName,',');
    csv = logical(true);
end
% Check if that worked, if not, try to use bare "load" command
if ~isfield(raw,'data')
    clear raw;
    raw.data = load(fileName);
end


% If there is still no "data" field in "raw", something went wrong...
if ~isfield(raw,'data')
    warnings{end+1} = 'Could not read data...';
    data = [];
    return;
end

% Assign data
data.data = raw.data;

% Assign (remaining) axis values
% x and y values are simply indices of data
data.axes.x.values = 1:1:size(data.data,2);
data.axes.y.values = 1:1:size(data.data,1);

% Set file structure
data.file.name = fileName;
data.file.format = formatNameString;

end