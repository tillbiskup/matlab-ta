% TAOXREAD Read Oxford TA files (binary)
%
% Usage
%   data = TAOXread(fileName)
%
% fileName  - string
%             Name of the file containing Oxford TA data (binary)
%
% data      - struct
%

% (c) 2011, Till Biskup
% 2011-12-02

function data = TAOXread(fileName)

% If no filename, return
if isempty(fileName)
    data = [];
    return;
end

% Separate fileName into its parts
[fPath,fName,~] = fileparts(fileName);

% Check whether necessary files exists
if ~exist(fullfile(fPath,[fName '.off']),'file') ...
        || ~exist(fullfile(fPath,[fName '.par']),'file')
    disp('Necessary files don''t exist...')
    data = [];
    return;
end

% Read and parse parameters file
fh = fopen(fullfile(fPath,[fName '.par']));
% Read content of the par file to cell array
data.header = cell(0);
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
data.parameters.recorder = struct(...
    'sensitivity',struct(...
    'value',parameters.VoltDiv.value,...
    'unit',parameters.VoltDiv.unit),...
    'timeBase',struct(...
    'value',parameters.SamplInterval.value,...
    'unit',lower(parameters.SamplInterval.unit)),...
    'averages',parameters.AveNum...
    );
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
data.axes.y.measure = 'wavelength';
data.axes.y.unit = 'nm';

% Write values for z axis (intensity)
data.axes.z.measure = 'intensity';
data.axes.z.unit = data.parameters.recorder.sensitivity.unit;

% Set file structure
data.file.name = fullfile(fPath,fName);
data.file.format = 'Oxford TA data';

% Handle situation that there is more than one measurement in the file
if parameters.MagPiont > 1
    data.data.off = reshape(...
        data.data,...
        parameters.TimePoint,...
        parameters.MagPiont);
    if isfield(data,'dataMFon')
        data.dataMFon = reshape(...
            data.dataMFon,...
            parameters.TimePoint,...
            parameters.MagPiont);
    end
    mData = struct();
    for k = 1:parameters.MagPiont
        mData(k).data = data.data(:,k);
        mData(k).axes = data.axes;
        mData(k).file = data.file;
        mData(k).parameters = data.parameters;
        mData(k).header = data.header;
        if isfield(data,'dataMFon')
            mData(k).dataMFon = data.dataMFon(:,k);
        end
    end
    data = mData;
end

end