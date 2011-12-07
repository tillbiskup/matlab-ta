function [ data, warnings ] = iniFileRead ( fileName, varargin )
% INIFILEREAD Read a Windows-style ini file and return them as MATLAB(r)
% struct structure. 
%
% Usage
%   data = iniFileRead(filename)
%   [data,warnings] = iniFileRead(filename)
%   data = iniFileRead(filename,'<parameter>','<option>')
%
%   filename - string
%              Name of the ini file to read
%
%   data     - struct
%              MATLAB(r) struct structure containing the contents of the
%              ini file read
%
%   warnings - string/cell array of strings
%              Contains further information if something went wrong.
%              Otherwise empty.
%
% You can specify optional parameters as key-value pairs. Valid parameters
% and their values are:
%
%   commentChar    - char
%                    Character used for comment lines in the ini file
%                    Default: %
%
%   assignmentChar - char
%                    Character used for the assignment of values to keys
%                    Default: =
%
%   blockStartChar - char
%                    Character used for starting a block
%                    Default: [
%

% (c) 2008-11, Till Biskup
% 2011-12-07

% TODO
%	* Change handling of whitespace characters (subfunctions) thus that it
%	  is really all kinds of whitespace that is dealt with, not only spaces.

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure
% Add required input arguments
p.addRequired('fileName', @(x)ischar(x));
% Add a few optional parameters, with default values
p.addParamValue('commentChar','%',@ischar);
p.addParamValue('assignmentChar','=',@ischar);
p.addParamValue('blockStartChar','[',@ischar);
% Parse input arguments
p.parse(fileName,varargin{:});

% Assign parameters from parser
commentChar = p.Results.commentChar;
assignmentChar = p.Results.assignmentChar;
blockStartChar = p.Results.blockStartChar;

if isempty(fileName)
    warnings = 'No filename';
    data = struct();
    return;
end

if ~exist(fileName,'file')
    warnings = 'File does not exist';
    data = struct();
    return;
end

warnings = cell(0);
data = struct();

try
    fh = fopen(fileName);
    iniFileContents = cell(0);
    k=1;
    while 1
        tline = fgetl(fh);
        if ~ischar(tline)
            break
        end
        iniFileContents{k} = tline;
        k=k+1;
    end
    fclose(fh);
catch exception
    warnings = sprintf('Problems reading ini file %s',fileName);
    throw(exception);
end

% read parameters to structure

blockname = '';
for k=1:length(iniFileContents)
    if ~isempty(iniFileContents{k}) ...
            && ~strcmp(iniFileContents{k}(1),commentChar)
        if strcmp(iniFileContents{k}(1),blockStartChar)
            % set blockname
            % assume thereby that blockname resides within brackets
            blockname = iniFileContents{k}(2:end-1);
        else
            [names] = regexp(iniFileContents{k},...
                '(?<key>[a-zA-Z0-9._-]+)\s*=\s*(?<val>.*)',...
                'names');
            if isfield(data,blockname)
                if isfield(data.(blockname),names.key)
                    % print warning message telling the user that the field
                    % gets overwritten and printing the old and the new
                    % field value for comparison 
                    fprintf(...
                        ['WARNING: Field ''%s.%s'' already exists'...
                        ' and will get overwritten.\n\toriginal '...
                        'value: ''%s''\n\tnew value     : ''%s''\n'],...
                        blockname,key,oldFieldValue,val);
                end
            end
            data.(blockname).(names.key) = names.val;
        end
    end
end

end % end of main function

