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
% 2013-06-04

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
p.addParamValue('parameters',struct(),@isstruct);
p.parse(fileName,varargin{:});

% Assign optional arguments from parser
checkFormat = p.Results.checkFormat;
sortfiles = p.Results.sortfiles;
loadInfoFile = p.Results.loadInfoFile;
parameters = p.Results.parameters;

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
        checkFormat,loadInfoFile,parameters);
    if ~isempty(warning)
        warnings{end+1} = warning;
    end
end

if length(data)==1
    data = data{1};
end

end

function [data,warnings] = loadFile(fileName,~,~,parameters)
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
% parameters   - struct
%                Parameters determining how to read the file
%                Normally retrieved from TAgui_ASCIIimporterwindow
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

% Assign empty structure to output argument
data = TAdataStructure();

% Read data
% If parameters is an empty structure (default)
if isempty(fieldnames(parameters))
    % First, try to read data with TAB as separator
    raw = importdata(fileName,'\t');
    % Check if that worked, if not, use COMMA as separator
    if ~isfield(raw,'data')
        raw = importdata(fileName,',');
    end
    % Check if that worked, if not, try to use bare "load" command
    if ~isfield(raw,'data')
        clear raw;
        raw.data = load(fileName);
    end
% If we have parameters
else
    % First, try to read data
    if ~isempty(parameters.separator) && parameters.nHeaderLines
        raw = importdata(fileName,...
            parameters.separator,parameters.nHeaderLines);
        % If something went wrong, try with other delimiters
        if ~isfield(raw,'data')
            % First, try to read data with TAB as separator
            raw = importdata(fileName,'\t',parameters.nHeaderLines);
            % Check if that worked, if not, use COMMA as separator
            if ~isfield(raw,'data')
                raw = importdata(fileName,',',parameters.nHeaderLines);
            end
            % Check if that worked, if not, use SEMICOLON as separator
            if ~isfield(raw,'data')
                raw = importdata(fileName,';',parameters.nHeaderLines);
            end
            % Check if that worked, if not, use space as separator
            if ~isfield(raw,'data')
                raw = importdata(fileName,' ',parameters.nHeaderLines);
            end
        end
    elseif ~isempty(parameters.separator)
        raw = importdata(fileName,parameters.separator);
        % If something went wrong, try with automatic detection of
        % delimiter
        if ~isfield(raw,'data')
            raw.data = importdata(fileName);
        end
    elseif parameters.nHeaderLines
        % First, try to read data with TAB as separator
        raw = importdata(fileName,'\t',parameters.nHeaderLines);
        % Check if that worked, if not, use COMMA as separator
        if ~isfield(raw,'data')
            raw = importdata(fileName,',',parameters.nHeaderLines);
        end
        % Check if that worked, if not, use SEMICOLON as separator
        if ~isfield(raw,'data')
            raw = importdata(fileName,';',parameters.nHeaderLines);
        end
        % Check if that worked, if not, use space as separator
        if ~isfield(raw,'data')
            raw = importdata(fileName,' ',parameters.nHeaderLines);
        end
    else
        raw.data = load(fileName);
    end
end

% If there is still no "data" field in "raw", something went wrong...
if ~isfield(raw,'data')
    warnings{end+1} = 'Could not read data...';
    data = [];
    return;
end

% Assign data
data.data = raw.data;

% As we are now sure that we have some data, handle rest of parameters, if
% we have some
if isempty(fieldnames(parameters))
    % Assign (remaining) axis values
    % x and y values are simply indices of data
    data.axes.x.values = 1:1:size(data.data,2);
    data.axes.y.values = 1:1:size(data.data,1);
else
    % Deal with X axes
    data.axes.x.measure = parameters.axis.x.measure;
    data.axes.x.unit = parameters.axis.x.unit;
    switch lower(parameters.axis.x.values.type)
        case 'index'
            data.axes.x.values = 1:1:size(data.data,2);
        case 'row/column'
            if parameters.axis.x.values.row
                data.axes.x.values = ...
                    data.data(parameters.axis.x.values.row,:);
                % Remove row from data
                data.data(parameters.axis.x.values.row,:) = [];
            elseif parameters.axis.x.values.column
                data.axes.x.values = ...
                    data.data(:,parameters.axis.x.values.column);
                % Remove column from data
                data.data(:,parameters.axis.x.values.column) = [];
            end
        case 'range'
            % Assume equal spacing
            data.axes.x.values = linspace(...
                parameters.axis.x.values.start,parameters.axis.x.values.stop,...
                size(data.data,2));
    end
    % Deal with Y axes
    data.axes.y.measure = parameters.axis.y.measure;
    data.axes.y.unit = parameters.axis.y.unit;
    switch lower(parameters.axis.y.values.type)
        case 'index'
            data.axes.y.values = 1:1:size(data.data,1);
        case 'row/column'
            if parameters.axis.y.values.row
                data.axes.y.values = ...
                    data.data(parameters.axis.y.values.row,:);
                % Remove row from data
                data.data(parameters.axis.y.values.row,:) = [];
            elseif parameters.axis.y.values.column
                data.axes.y.values = ...
                    data.data(:,parameters.axis.y.values.column);
                % Remove column from data
                data.data(:,parameters.axis.y.values.column) = [];
            end
        case 'range'
            % Assume equal spacing
            data.axes.y.values = linspace(...
                parameters.axis.y.values.start,parameters.axis.y.values.stop,...
                size(data.data,1));
    end
    % Deal with Z axes
    data.axes.z.measure = parameters.axis.z.measure;
    data.axes.z.unit = parameters.axis.z.unit;
    % Deal with transposing data
    if parameters.transpose
        data.data = data.data';
    end
end

% Use filename as label
[~,fn,~] = fileparts(fileName);
data.label = fn;

% Set file structure
data.file.name = fileName;
data.file.format = formatNameString;

end