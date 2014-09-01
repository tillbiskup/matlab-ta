function [data,warnings] = TAOXread(fileName,varargin)
% TAOXREAD Read Oxford TA files (binary)
%
% Usage
%   data = TAOXread(fileName)
%   [data,warnings] = TAOXread(fileName)
%   data = TAOXread(fileName,...)
%
% fileName  - string|struct|cell array
%             string: name of a valid filename
%             struct: struct with files as returned by "dir"
%             cell array: cell array of strings with filenames
%
% data      - struct / cell array of structs
%             Datasets read from file(s)
%             Each dataset (aka field of the ell array) is a structure
%             complying to the data structure of the TA toolbox.
%
%             If there is only one dataset read, it is a struct rather than
%             a cell array of structs.
%
% warnings  - cell array of strings
%             empty if there are no warnings
%
% You can pass optional parameters. For details see below.
%
% Parameters
%
% combine   - logical (true/false)
%             Whether to combine files.
%             Default: false
%
% sortfiles - logical (true/false)
%             Whether to sort files (prior to combining them)
%             Sort is done by the MATLAB(r) command "sort", performing
%             sorting of the filenames according to the ASCII table.
%             Default: true
%
% average   - logical (true/false)
%             Whether to average multiple scans in one file.
%             Default: false
%
% skip      - vector
%             Scans to skip when averaging (useful if something went wrong
%             with one scan).
%             Default: []
%
% Combining
%
% If you set "combine" to "true", the function will try to combine your
% datasets. Therefore, make sure that you only try to combine datasets that
% make sense to be combined, as the function is unable to tell the
% difference.
%
% See also: TAload, TAdataStructure

% Copyright (c) 2011-12, Till Biskup
% 2012-08-17

% TODO: Combining - Handle different parameters for each time trace
% properly, especially different filters etc.

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
p.addParamValue('combine',logical(false),@islogical);
p.addParamValue('average',logical(false),@islogical);
p.addParamValue('skip',[],@isnumeric);
p.addParamValue('sortfiles',logical(true),@islogical);
% Note, this is to be compatible with TAload - currently without function!
p.addParamValue('checkFormat',logical(true),@islogical);
p.parse(fileName,varargin{:});

% Assign optional arguments from parser
combine = p.Results.combine;
sortfiles = p.Results.sortfiles;
average = p.Results.average;
skip = p.Results.skip;

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
    [data{k},warning] = loadFile(fileName{uniqueIndices(k)},average,skip);
    if ~isempty(warning)
        warnings{end+1} = warning;
    end
end

if length(data)==1
    data = data{1};
elseif combine
    % Preallocate some variables
    cdata = zeros(length(data),length(data{1}.data));
    cdataMFon = zeros(length(data),length(data{1}.data));
    caxes_y_values = zeros(1,length(data));
    for k=1:length(data)
        % TODO: Account for different settings for each time trace, such as
        % filters etc.
        cdata(k,:) = data{k}.data;
        cdataMFon(k,:) = data{k}.dataMFon;
        caxes_y_values(k) = data{k}.axes.y.values;
    end
    data = data{1};
    data.data = cdata;
    data.dataMFon = cdataMFon;
    data.axes.y.values = caxes_y_values;
end

end

function [data,warnings] = loadFile(fileName,average,skip)
% LOADFILE Load file and return contents. 
%
% fileName    - string
%               Name of a file (normally including full path)
%
% average     - logical
%               Whether or not to average multiple scans in one file
%
% skip        - vector
%               Scans to skip when averaging
%
% data        - structure
%               According to the toolbox data structure
%
% warnings    - cell array of strings
%               Contains warnings if there are any, otherwise empty.

% As we're called only internally, there's no need for parameter checking.

% A few important settings
% Name of the format as it appears in the file.format field
formatNameString = 'Oxford TA/MFE binary';

warnings = cell(0);

% Separate fileName into its parts
[fPath,fName,~] = fileparts(fileName);

% Check whether necessary files exists
if ~exist(fullfile(fPath,[fName '.off']),'file') ...
        || ~exist(fullfile(fPath,[fName '.par']),'file')
    warnings = sprintf('Problems reading file "%s": %s',...
        fName,'Necessary files don''t exist.');
    data = [];
    return;
end

% Assign empty structure to output argument
data = TAdataStructure('structure');

% Read and parse parameters file
fh = fopen(fullfile(fPath,[fName '.par']));
% Read content of the par file to cell array
k=1;
while 1
    tline = fgetl(fh);
    if ~ischar(tline)
        break
    end
    data.header{k} = tline;
    k=k+1;
end
fclose(fh);

% Parse parameter file entries
% 1st step: split lines into single strings
parameterFileLines = cellfun(...
    @(x) regexp(x,'\s*','split'),...
    data.header,...
    'UniformOutput', false);

parameters = struct();

for k=1:length(parameterFileLines)
    switch length(parameterFileLines{k})
        case 1
            % Most probably, this is one of the two headings
        case 2
            % This should be a measure/value pair without unit
            % Crude workaround: prevent invalid field names (special cases)
            % 1st: Field names with brackets - use only part before the
            % brackets
            tmpStr = regexp(parameterFileLines{k}{1},'(','split');
            parameterFileLines{k}{1} = tmpStr{1};
            % 2nd: Prevent "headings" starting with "#" to be parsed
            if ~strcmp(parameterFileLines{k}{1}(1),'#')
                % Fill parameters structure
                if isnan(str2double(parameterFileLines{k}{2}))
                    parameters.(strrep(parameterFileLines{k}{1},':','')) = ...
                        parameterFileLines{k}{2};
                else
                    parameters.(strrep(parameterFileLines{k}{1},':','')) = ...
                        str2double(parameterFileLines{k}{2});
                end
            end
        case 3
            % This should be a measure/value pair with unit
            % Crude workaround: prevent invalid field names (special cases)
            % 1st: Field names with brackets - use only part before the
            % brackets
            tmpStr = regexp(parameterFileLines{k}{1},'(','split');
            parameterFileLines{k}{1} = tmpStr{1};
            % 2nd: Prevent "headings" starting with "#" to be parsed
            if ~strcmp(parameterFileLines{k}{1}(1),'#')
                % Fill parameters structure
                if isnan(str2double(parameterFileLines{k}{3}))
                    parameters = setfield(parameters,...
                        parameterFileLines{k}{1},...
                        'unit',...
                        regexprep(parameterFileLines{k}{2},{'/',':'},'')...
                        );
                    parameters = setfield(parameters,...
                        parameterFileLines{k}{1},...
                        'value',parameterFileLines{k}{3}...
                        );
                else
                    parameters = setfield(parameters,...
                        parameterFileLines{k}{1},...
                        'unit',...
                        regexprep(parameterFileLines{k}{2},{'/',':'},'')...
                        );
                    parameters = setfield(parameters,...
                        parameterFileLines{k}{1},...
                        'value',str2double(parameterFileLines{k}{3})...
                        );
                end
            end
        otherwise
            % That shall never happen...
            disp('Something strange happened parsing the parameters file');
    end
end

%data.params = parameters;

% Assign values to parameters struct
data.parameters.runs = parameters.MagPiont;
data.parameters.recorder.sensitivity = struct(...
    'value',parameters.VoltDiv.value,...
    'unit',parameters.VoltDiv.unit);
data.parameters.recorder.timeBase = struct(...
    'value',parameters.SamplInterval.value,...
    'unit',lower(parameters.SamplInterval.unit));
data.parameters.recorder.averages = parameters.AveNum;
% ATTENTION: Don't rely on the parameters "OsiroDataPoint" and "TrigDelay",
% as they get added manually to the parameters file and are NOT
% automatically read from the transient recorder. Therefore, the only
% reliable way to get the length of the time trace (and therefore the right
% axes) is to use "TimePoint".
data.parameters.transient = struct(...
    'points',parameters.TimePoint,...
    'triggerPosition',parameters.TrigDelay/parameters.OsiroDataPoint...
    *parameters.TimePoint,...
    'length',parameters.SamplInterval.value*parameters.TimePoint,...
    'unit',lower(parameters.TimeDiv.unit)...
    );

% Read (first) data file (with field off)
fh = fopen(fullfile(fPath,[fName '.off']));
data.data = fread(fh,inf,'real*4');
fclose(fh);
% Swap rows and cols
data.data = data.data';

% Check for field on file and if exists, read it as well
if exist(fullfile(fPath,[fName '.on']),'file')
    fh = fopen(fullfile(fPath,[fName '.on']));
    data.dataMFon = fread(fh,inf,'real*4');
    fclose(fh);
end
% Swap rows and cols
data.dataMFon = data.dataMFon';

% Set x axis parameters
% 1. Get relative position of trigger point
relTrigPtPos = ...
    data.parameters.transient.triggerPosition/parameters.TimePoint;
data.axes.x.values = linspace(...
    -(data.parameters.transient.length*relTrigPtPos)+...
    parameters.SamplInterval.value,...
    data.parameters.transient.length*(1-relTrigPtPos),...
    parameters.TimePoint...
    );
% Workaround for silly Matlab: Set time point of trigger to zero
data.axes.x.values(parameters.TrigDelay) = 0;
data.axes.x.measure = 'time';
data.axes.x.unit = lower(parameters.TimeDiv.unit);

% Try to determine wavelength
% (by convention last three characters of the file basename)
data.axes.y.values = str2double(fName(end-2:end));
% If that is not the case, for whatever reason, set to default to prevent
% further errors.
if isnan(data.axes.y.values)
    data.axes.y.values = 0;
    warnings{end+1} = 'WARNING: Wavelengh could not be detected!';
end
data.axes.y.measure = 'wavelength';
data.axes.y.unit = 'nm';

% Write values for z axis (intensity)
data.axes.z.measure = 'intensity';
data.axes.z.unit = data.parameters.recorder.sensitivity.unit;

% Set file structure
data.file.name = fullfile(fPath,fName);
data.file.format = formatNameString;

data.label = fName;

% Handle situation that there is more than one measurement in the file
if parameters.MagPiont > 1
    data.data = reshape(...
        data.data,...
        parameters.TimePoint,...
        parameters.MagPiont);
    if isfield(data,'dataMFon')
        data.dataMFon = reshape(...
            data.dataMFon,...
            parameters.TimePoint,...
            parameters.MagPiont);
    end
    % Skip measurements provided by vector "skip"
    if ~isempty(skip)
        for k=1:length(skip)
            if skip(k)<1 || skip(k) > parameters.MagPiont
                skip(k) = [];
            end
        end
        data.data(:,skip) = [];
        data.dataMFon(:,skip) = [];
    end
    if average
        data.data = mean(data.data,2)';
        data.dataMFon = mean(data.dataMFon,2)';
    else
        mData = cell(0);
        for k = 1:size(data.data,2)
            mData{k} = data;
            mData{k}.data = data.data(:,k);
            mData{k}.data = mData{k}.data';
            mData{k}.axes = data.axes;
            mData{k}.file = data.file;
            mData{k}.parameters = data.parameters;
            mData{k}.header = data.header;
            if isfield(data,'dataMFon')
                mData{k}.dataMFon = data.dataMFon(:,k);
                mData{k}.dataMFon = mData{k}.dataMFon';
            end
            mData{k}.label = sprintf('(%i/%i) %s',...
                k,size(data.data,2),data.label);
        end
        data = mData;
    end
end

end
