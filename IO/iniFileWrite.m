function [ warnings ] = iniFileWrite ( fileName, data, varargin )
% iniFileWrite Write a Windows-style ini file and return them as MATLAB(r)
% struct structure. 
%
% Usage
%   iniFileWrite(filename,data)
%   status = iniFileWrite(filename,data)
%   iniFileWrite(filename,data,'<parameter>','<option>')
%
%   filename - string
%              Name of the ini file to write
%
%   data     - struct
%              MATLAB(r) struct structure containing the contents to be
%              written to the ini file
%
%   warnings - string/cell array of strings
%              Contains further information if something went wrong.
%              Otherwise empty.
%
% You can specify optional parameters as key-value pairs. Valid parameters
% and their values are:
%
%   overwrite           - logical (true/false)
%                         Whether to overwrite existing ini file
%
%   header              - string/cell array of strings
%                         Header information that is added on top of the
%                         ini file 
%
%   addModificationDate - logical (true/false)
%                         Whether to add modification date as last line of
%                         header (and if there is no header, then as only
%                         header line)
%
%   commentChar         - char
%                         Character used for comment lines in the ini file
%                         Default: %
%
%   assignmentChar      - char
%                         Character used for the assigning values to keys
%                         Default: =
%
% See also: iniFileRead

% (c) 2008-11, Till Biskup
% 2011-12-08

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure
% Add required input arguments
p.addRequired('fileName', @(x)ischar(x));
p.addRequired('data', @(x)isstruct(x));
% Add a few optional parameters, with default values
p.addParamValue('header',cell(0),@(x) ischar(x) || iscell(x));
p.addParamValue('commentChar','%',@ischar);
p.addParamValue('assignmentChar',' =',@ischar);
p.addParamValue('overwrite',false,@islogical);
p.addParamValue('addModificationDate',true,@islogical);
% Parse input arguments
p.parse(fileName,data,varargin{:});

% Assign parameters from parser
header = p.Results.header;
commentChar = p.Results.commentChar;
assignmentChar = p.Results.assignmentChar;

% headerFirstLine
% headerCreationDate

if isempty(fileName)
    warnings = 'No filename';
    return;
end

% check whether the output file already exists
if exist(fileName,'file') && ~p.Results.overwrite 
    warnings = 'File exists';
    return;
end

% Open file for writing
try
    fh = fopen(fileName,'wt');
catch exception
    throw(exception);
end

% Write header, if any
if ~isempty(header)
    if iscell(header)
        for k=1:length(header)
            fprintf(fh,'%s %s\n',commentChar,header{k});
        end
    else
        fprintf(fh,'%s %s\n',commentChar,header);
    end
end

% Write modification date
if p.Results.addModificationDate
    % If there was a header, leave a blank, though commented, line
    if ~isempty(header)
        fprintf(fh,'%s\n',commentChar);
    end
    fprintf(fh,'%s Last modified: %s\n',commentChar,datestr(now,31));
end

% Print the key:value pairs for each field in data
blockNames = fieldnames(data);
for k = 1 : length(blockNames)
    
    fprintf(fh,'\n[%s]\n',blockNames{k});
    fieldNames = fieldnames(data.(blockNames{k}));
    
    for m = 1 : length(fieldNames)
        fieldValue = data.(blockNames{k}).(fieldNames{m});
        % in case the value is not a string, but numeric
        if isnumeric(fieldValue)
            fieldValue = num2str(fieldValue);
        end
        fprintf(fh,'%s%s %s\n',fieldNames{m},assignmentChar,fieldValue);
    end
    
end

% Close file
try
    status = fclose(fh);
    if status == -1
        warnings = ...
            sprintf('There were some problems closing file %s',fileName);
        return;
    end
catch exception
    throw(exception);
end

end