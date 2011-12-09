function xmlZipWrite(filename,docNode)
% Parse input arguments using the inputParser functionality
parser = inputParser;   % Create an instance of the inputParser class.
parser.FunctionName = mfilename; % Function name included in error messages
parser.KeepUnmatched = true; % Enable errors on unmatched arguments
parser.StructExpand = true; % Enable passing arguments in a structure
parser.addRequired('filename', @(x)ischar(x));
parser.addRequired('docNode', @(x)isa(x,'org.apache.xerces.dom.DocumentImpl'));
parser.parse(filename,docNode);
% Do the real stuff
[pathstr, name] = fileparts(filename);
xmlwrite(fullfile(pathstr,[name '.xml']),docNode);
zip(fullfile(pathstr,[name '.zip']),fullfile(pathstr,[name '.xml']));
delete(fullfile(pathstr,[name '.xml']));
end