function data = TAFRASCIIread(fileName)
% TAFRASCIIREAD Read Freiburg TA files (ASCII)
%
% Usage
%   data = TAFRASCIIread(fileName)
%
% fileName  - string
%             Name of the file containing Oxford TA data (binary)
%
% data      - struct
%

% (c) 2011, Till Biskup
% 2011-12-03

% If no filename, return
if isempty(fileName)
    data = [];
    return;
end

% Assign empty structure to output argument
data = TAdataStructure();

% Read first n lines and try to determine length of header
% How to do: The header is separated by an empty line from the data.
% Therefore, the last empty line "wins".
nLinesTestHeaderLength = 20;
headerLength = 0;

fh = fopen(fileName);
for k=1:nLinesTestHeaderLength
    tline = fgetl(fh);
    if ~ischar(tline)
        break
    end
    if isempty(tline)
        headerLength = k;
    end
end
fclose(fh);

% First, try to read data with TAB as separator
raw = importdata(fileName,'\t',headerLength);
% Check if that worked, if not, use COMMA as separator
if ~isfield(raw,'data')
    raw = importdata(fileName,',',headerLength);
end

% If there is still no "data" field in "raw", something went wrong...
if ~isfield(raw,'data')
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
            wl = cellfun(@(x) regexp(x,'\d*\s*([\d.]*).*','tokens'),...
                headerLines{k}(2:end-1),'UniformOutput',false);
            for m=1:length(wl)
                data.axes.y.values(m) = str2double(wl{1,m}{1});
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

end