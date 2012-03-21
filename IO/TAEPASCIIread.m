function [data,warnings] = TAEPASCIIread(fileName,varargin)
% TAEPASCIIREAD Read TA files from Edinburgh Photonics LP920 series (ASCII)
%
% Usage
%   data = TAEPASCIIread(fileName)
%   [data,warnings] = TAEPASCIIread(fileName)
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
% You can pass optional parameters. For details see below.
%
% Parameters
%
% checkFormat - logical (true/false)
%               Whether to check for proper file format.
%               Uses a rather dirty trick that might break in the future.
%               Default: true
%
% See also: TAload, TAdataStructure

% (c) 2011-12, Till Biskup
% 2012-03-21

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
p.parse(fileName,varargin{:});

% Assign optional arguments from parser
checkFormat = p.Results.checkFormat;
sortfiles = p.Results.sortfiles;

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
    [data{k},warning] = loadFile(fileName{uniqueIndices(k)},checkFormat);
    if ~isempty(warning)
        warnings{end+1} = warning;
    end
end

if length(data)==1
    data = data{1};
end

end

function [data,warnings] = loadFile(fileName,checkFormat)
% LOADFILE Load file and return contents. 
%
% fileName    - string
%               Name of a file (normally including full path)
%
% checkFormat - logical (true/false)
%               Whether to check for proper format
%
% data        - structure
%               According to the toolbox data structure
%
% warnings    - cell array of strings
%               Contains warnings if there are any, otherwise empty.

% As we're called only internally, there's no need for parameter checking.

% A few important settings
% Name of the format as it appears in the file.format field
formatNameString = 'Edinburgh Photonics TA data (ASCII)';
% Maximum number of lines of the header
nLinesTestHeaderLength = 20;

warnings = cell(0);

% Assign empty structure to output argument
data = TAdataStructure();

% Read first n lines and try to determine length of header
% How to do: The header is separated by an empty line from the data.
% Therefore, the last empty line "wins".
headerLength = 0;

fh = fopen(fileName);
for k=1:nLinesTestHeaderLength
    tline = fgetl(fh);
    if k==1
        firstHeaderLine = tline;
    end
    if ~ischar(tline)
        break
    end
    if isempty(tline)
        headerLength = k;
    end
end
fclose(fh);

% Use the first line to determine whether we have the correct file type.
% This is done using a rather dirty trick that might break easily in the
% future: The first line contains normally the filename without extension.
if checkFormat
    [~,basename,~] = fileparts(fileName);
    if ~strcmp(firstHeaderLine,basename)
        warnings{end+1} = 'Wrong file format.';
        data = [];
        return;
    end
end

% First, try to read data with TAB as separator
raw = importdata(fileName,'\t',headerLength);
% Check if that worked, if not, use COMMA as separator
if ~isfield(raw,'data')
    raw = importdata(fileName,',',headerLength);
end

% If there is still no "data" field in "raw", something went wrong...
if ~isfield(raw,'data')
    warnings{end+1} = 'Could not read data...';
    data = [];
    return;
end

% Assign data
% NOTE: The first column holds the x axis
% NOTE: The data are columnwise, for the display we need it rowwise
data.data = raw.data(:,2:end)';

% Assign header
data.header = raw.textdata(1:end-1,1);

% Assign label (filename without extension, first header line)
data.label = raw.textdata{1,1};

% Parse header lines
% 1st step: split lines into single strings
headerLines = cellfun(...
    @(x) regexp(x,'\t','split'),...
    data.header,...
    'UniformOutput', false);

for k=1:length(headerLines)
    if length(headerLines{k})>1
        headerInfo.(strrep(headerLines{k}{1},'/','')) = ...
            strtrim(headerLines{k}{2});
    end
    switch lower(headerLines{k}{1})
        case 'labels'
            % Create y axis values vector
            wl = cellfun(@(x) regexp(x,'\d*\s*([\d.]*)*','tokens'),...
                headerLines{k}(2:end-1),'UniformOutput',false);
            for m=1:length(wl)
                if isnan(str2double(wl{1,m}{2}))
                    data.axes.y.values(m) = str2double(wl{1,m}{1});
                else
                    data.axes.y.values(m) = str2double(wl{1,m}{2});
                end
            end
            % Try to read unit
            unit = regexp(headerLines{k}{2},'\d*\s*[\d.]*\s*([A-Za-z]*)','tokens');
            data.axes.y.unit = char(unit{1}{1});
        case 'xaxis'
            data.axes.x.measure = lower(headerLines{k}{2});
        case 'yaxis'
            data.axes.z.measure = headerLines{k}{2};
    end
end

% Assign (remaining) axis values
data.axes.x.values = raw.data(:,1);
data.axes.x.unit = 'ns';
data.axes.y.measure = 'wavelength';
data.axes.z.unit = '';

% Assign parameters.transient values
data.parameters.transient.points = size(data.data,2);
data.parameters.transient.length = ...
    data.axes.x.values(end)/(size(data.data,2)-1)*size(data.data,2);
data.parameters.transient.unit = data.axes.x.unit;

% Set file structure
data.file.name = fileName;
data.file.format = formatNameString;

end