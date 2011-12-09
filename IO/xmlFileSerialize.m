function xmlFileSerialize(filename)
% Parse input arguments using the inputParser functionality
parser = inputParser;   % Create an instance of the inputParser class.
parser.FunctionName = mfilename; % Function name included in error messages
parser.KeepUnmatched = true; % Enable errors on unmatched arguments
parser.StructExpand = true; % Enable passing arguments in a structure
parser.addRequired('filename', @(x)ischar(x) || iscell(x));
parser.parse(filename);
% Do the real stuff
if ~exist(filename,'file')
    fprintf('"%s" seems not to be a valid filename. Abort.',filename);
    return;
end
txt = textFileRead(filename);
fid2 = fopen(filename,'wt');
for k=1:length(txt)
    fprintf(fid2,'%s',strtrim(txt{k}));
end
fclose(fid2);
end