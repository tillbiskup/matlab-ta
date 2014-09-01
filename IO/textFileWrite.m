function status = textFileWrite(filename,text)
% TEXTFILEWRITE Write cell array as text to file. 
%
% Usage:
%   status = textFileWrite(filename,text);
%
%   filename - string
%              name of a valid (text) file to read
%   text     - cell array
%              contains the text that shall get written to the file
%

% Copyright (c) 2012, Till Biskup
% 2012-01-29

% Parse input arguments using the inputParser functionality
parser = inputParser;   % Create an instance of the inputParser class.
parser.FunctionName = mfilename; % Function name included in error messages
parser.KeepUnmatched = true; % Enable errors on unmatched arguments
parser.StructExpand = true; % Enable passing arguments in a structure
parser.addRequired('filename', @ischar);
parser.addRequired('text', @iscell);
parser.parse(filename,text);

status = '';
fid = fopen(filename,'w+');
if fid < 0
    status = 'Problems opening file';
    return
end

for k=1:length(text)
    if ischar(text{k})
        fprintf(fid,'%s\n',text{k});
    end
end

fclose(fid);
