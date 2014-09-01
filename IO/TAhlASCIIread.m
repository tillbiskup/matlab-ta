function [data,warnings] = TAhlASCIIread(fileName,varargin)
% TAHLASCIIREAD Read somewhat special ASCII files from one user of the TA
% toolbox.
%
% Usage
%   data = TAhlASCIIread(fileName)
%   [data,warnings] = TAhlASCIIread(fileName)
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

% Copyright (c) 2013, Till Biskup
% 2013-11-19

% NOTE: This function uses an internal function to read the actual data.
%       Settings according name of the file format etc. need to be done
%       there. See function "loadData" below.

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('fileName', @(x)ischar(x) || iscell(x) || isstruct(x));
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
        warnings = [warnings warning]; %#ok<AGROW>
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
formatNameString = 'HLASCII';

warnings = cell(0);

% Assign empty structure to output argument
data = TAdataStructure();

% TODO: Check format - however this might be done...

raw = cell(0);
k=1;

% Read data using low-level file functions
try
    fid = fopen(fileName);
    while 1
        tline = fgetl(fid);
        if ~ischar(tline)
            break
        end
        raw{k} = tline;
        k=k+1;
    end
    fclose(fid);
catch exception
    warnings{end+1} = ['An exception occurred in ' ...
        exception.stack(1).name  '.'];
end

% Define where header begins, as this is the line "file info"
headerBeginsWithLine = find(strcmpi(raw,'file info'),1);

if ~isempty(headerBeginsWithLine)
    % Cut data out of raw file
    rawdata = raw(1:headerBeginsWithLine-1);
    
    % Convert into numeric matrix
    rawdata = cell2mat(cellfun(@(x)textscan(x,'%f','Delimiter',','),rawdata));
    
    data.axes.x.values = rawdata(2:end,1);
    data.axes.y.values = rawdata(1,2:end);
    % ATTENTION: Data get transposed here...
    data.data = rawdata(2:end,2:end)';
    
    data.header = raw(headerBeginsWithLine:end);
    
    % Process info contained in file - looks like the following lines
    % file info
    % Date: September 18, 2013
    % Sample: PbS_2dips_ZnO
    % Solvent: solid
    % Pump energy: 200
    % Pump wavelength (nm): 700
    % Cuvette length (mm):
    % Comments: Delay started from 267.000 ps
    % Averaging time: 2.0 s
    % Number of scans: 3
    % Time units: ps
    % Z axis title: dA
    
    % Process date
    data.parameters.date.start = datestr(datenum(...
        data.header{strncmpi('Date: ',data.header,6)}(7:end),...
        'mmmm dd, yyyy'),31);
    data.parameters.date.end = datestr(datenum(...
        data.header{strncmpi('Date: ',data.header,6)}(7:end),...
        'mmmm dd, yyyy'),31);
    
    % Process sample name
    data.sample.name = data.header{strncmpi('Sample: ',data.header,8)}(9:end);
    
    % Process solvent
    data.sample.buffer = data.header{strncmpi('Solvent: ',data.header,9)}(10:end);
    
    % Process pump energy
    data.parameters.pump.power.value = str2double(...
        data.header{strncmpi('Pump energy: ',data.header,13)}(14:end));
    
    % Process pump wavelength
    data.parameters.pump.wavelength.value = str2double(...
        data.header{strncmpi('Pump wavelength (nm): ',data.header,22)}(23:end));
    data.parameters.pump.wavelength.unit = 'nm';
    
    % Process cuvette length
    data.sample.cuvette = data.header{...
        strncmpi('Cuvette length (mm): ',data.header,21)}(22:end);
    
    % Process Comments
    data.comment = data.header{strncmpi('Comments: ',data.header,10)}(11:end);
    
    % Process averaging time
    
    % Process number of scans
    data.parameters.runs = str2double(...
        data.header{strncmpi('Number of scans: ',data.header,17)}(18:end));
    
    % Process time units
    data.axes.x.unit = ...
        data.header{strncmpi('Time units: ',data.header,12)}(13:end);
    
    % Process z axis title
    data.axes.z.measure = ...
        data.header{strncmpi('Z axis title: ',data.header,14)}(15:end);
    
    % Check for correct dimensions of axes and data and if there are
    % inconsistencies, replace with indices
    if length(data.axes.x.values) ~= size(data.data,2)
        data.axes.x.values = 1:1:size(data.data,2);
        warnings{end+1} = ...
            'X axis dimension inconsistent with data. Replaced with indices.';
    end
    if length(data.axes.y.values) ~= size(data.data,1)
        data.axes.y.values = 1:1:size(data.data,1);
        warnings{end+1} = ...
            'Y axis dimension inconsistent with data. Replaced with indices.';
    end
else
    warnings{end+1} = 'File appears to have wrong format. Trying anyway...';

    rawdata = cell2mat(cellfun(@(x)textscan(x,'%f','Delimiter',','),raw));
    data.axes.x.values = rawdata(2:end,1);
    data.axes.y.values = rawdata(1,2:end);
    % ATTENTION: Data get transposed here...
    data.data = rawdata(2:end,2:end)';
end


% Use filename as label
[~,fn,~] = fileparts(fileName);
data.label = fn;

% Set file structure
data.file.name = fileName;
data.file.format = formatNameString;

end
