function [data,warnings] = TAload(fileName, varargin)
% TALOAD Load files or scans whole directories for readable files
%
% Usage
%   TAload(filename)
%   data = TAload(filename)
%   [data,warnings] = TAload(filename)
%   data = TAload(filename,...)
%
%   filename - string|struct|cell array
%              string: name of a valid filename
%              struct: struct with files as returned by "dir"
%              cell array: cell array of strings with filenames
%
%   data     - struct
%              structure containing data and additional fields
%
%   warnings - cell array of strings
%              empty if there are no warnings
%
%   You can pass optional parameters. For details see below.
%
% Parameters
%
%   format   - string
%              One of the formats that are recognised. For a full list, see
%              the 'TAload.ini' configuration file.
%              If set to 'automatic', the function will try to
%              automatically determine the file format.
%              Default: 'automatic'
%
%   combine  - logical (true/false)
%              Whether to combine files.
%              Default: false
%
%   average  - logical (true/false)
%              Whether to average multiple scans in one file.
%              Default: false
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

% (c) 2011-12, Till Biskup
% 2012-01-20

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('filename', @(x)ischar(x) || iscell(x) || isstruct(x));
% p.addOptional('parameters','',@isstruct);
p.addParamValue('format','automatic',@ischar);
p.addParamValue('combine',logical(false),@islogical);
p.addParamValue('average',logical(false),@islogical);
p.parse(fileName,varargin{:});

% Assign optional arguments from parser
format = p.Results.format;
combine = p.Results.combine;
average = p.Results.average;

warnings = cell(0);

% If no filename given
if isempty(fileName)
    data = [];
    warnings{end+1} = 'No filename.';
    return;
end

if iscell(fileName)
    sort(fileName);
elseif isstruct(fileName)
    % That might be the case if the user uses "dir" as input for the
    % filenames, as this returns a structure with fields as "name"
    if ~isfield(fileName,'name')
        data = [];
        warnings{end+1} = 'Cannot determine filename(s).';
    end        
    % Convert struct to cell
    fileName = struct2cell(fileName);
    fileName = fileName(1,:)';
    % Remove '.' and '..'
    [~,ind] = max(strcmp('.',fileName));
    fileName(ind) = [];
    [~,ind] = max(strcmp('..',fileName));
    fileName(ind) = [];
    sort(fileName);
else
    % If filename is neither cell nor struct
    % Given the input parsing it therefore has to be a string
    if exist(fileName,'dir')
        % Read directory
        fileName = dir(fileName);
        % Convert struct to cell
        fileName = struct2cell(fileName);
        fileName = fileName(1,:)';
        % Remove '.' and '..'
        [~,ind] = max(strcmp('.',fileName));
        fileName(ind) = [];
        [~,ind] = max(strcmp('..',fileName));
        fileName(ind) = [];
        sort(fileName);
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
            data = 0;
            warnings{end+1} = 'No valid filename.';
            return;
        end
        % Convert struct to cell
        fileName = struct2cell(fileName);
        fileName = fileName(1,:)';
        % Remove '.' and '..'
        [~,ind] = max(strcmp('.',fileName));
        fileName(ind) = [];
        [~,ind] = max(strcmp('..',fileName));
        fileName(ind) = [];
        sort(fileName);
    end
end

% Get file formats from ini file
fileFormats = iniFileRead([mfilename('fullpath') '.ini']);
formatNames = fieldnames(fileFormats);
        
data = [];

if strcmpi(format,'automatic')
    % Now we have the nice task to try to determine the file type - from
    % basically nothing than the file itself, with no reliable information,
    % neither from the extension nor from the first two lines of a file (if
    % it were an ASCII file). Life is hard and unfair...
    %
    % Therefore, we simply try to first determine whether we have a binary
    % or an ascii file, and then apply sequentially each of the formats we
    % know of until one of them returns data.
    
    % Get list of file extensions from ini file, and at the same time get a
    % list of all ascii and binary file formats
    fileExtensions = cell(0);
    fileExtensionIndices = [];
    asciiFileFormats = cell(0);
    binaryFileFormats = cell(0);
    for k = 1:length(formatNames)
        if isfield(fileFormats.(formatNames{k}),'fileExtension')
            exts = regexp(...
                fileFormats.(formatNames{k}).fileExtension,'\|','split');
            fileExtensionIndices = [ ...
                fileExtensionIndices ones(1,length(exts))*k ];
            fileExtensions = [ fileExtensions exts ];
        end
        switch fileFormats.(formatNames{k}).type
            case 'ascii'
                asciiFileFormats{end+1} = formatNames{k};
            case 'binary'
                binaryFileFormats{end+1} = formatNames{k};
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

    for k=1:length(uniqueIndices)
        % FIRST STEP: Determine whether we have a binary or an ascii file
        % At the same time, if ascii, get first (or second) line of file.
        % Open file
        fid = fopen(fileName{uniqueIndices(k)});
        % Initialize switch resembling binary or ascii data
        isBinary = false;
        % Read first characters of the file and try to determine whether it
        % is binary 
        firstChars = fread(fid,5);
        for m=1:length(firstChars)
            if firstChars(m) < 32 && firstChars(k) ~= 10 ...
                    && firstChars(m) ~= 13
                isBinary = true;
            end
        end
        % Reset file pointer, then read first line and try to determine
        % the filetype from that.
        % PROBLEM: Some files tend to have a single empty comment line as
        % the first line. Therefore, check whether the first line is too
        % short for an identifier string, and in this case, read a second
        % line.
        fseek(fid,0,'bof');
        firstLine = fgetl(fid);
        if isempty(regexp(firstLine,'[a-zA-Z]','once'))
            % If first line does not contain any characters necessary for
            % an identifier string (problem with fsc2 files, see comment
            % above), read another line.
            firstLine = fgetl(fid);
        end
        % Close file
        fclose(fid);
        
        % Get file extension from filename
        [~,~,ext] = fileparts(fileName{1});
        
        if isBinary
            for m = 1 : length(binaryFileFormats)
                functionHandle = str2func(...
                    fileFormats.(binaryFileFormats{m}).function);
                [data{k},warnings{k}] = ...
                    functionHandle(fileName{uniqueIndices(k)},...
                    'average',average);
                if ~isempty(data{k})
                    break;
                end
            end
        else
            % else try to find a matching function from the ini file
            for m = 1 : length(asciiFileFormats)
                functionHandle = str2func(...
                    fileFormats.(asciiFileFormats{m}).function);
                [data{k},warnings{k}] = ...
                    functionHandle(fileName{uniqueIndices(k)},...
                    'average',average);
                if ~isempty(data{k})
                    break;
                end
            end
        end
    end
    
elseif max(strcmpi(format,formatNames))
    % Basically that means that "format" has been found in the formats
    functionHandle = str2func(fileFormats.(format).function);
    [data,warnings] = functionHandle(fileName,'combine',combine,...
        'average',average);
else
    warnings{end+1} = sprintf('File format %s not recognised.',format);
end

if ~exist('data','var') && nargout
    data = 0;
    warnings{end+1} = 'No data could be read.';
end

    
end
