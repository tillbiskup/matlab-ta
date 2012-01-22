function varargout = TAsave(filename,struct)
% Save data from the TA toolbox as ZIP-compressed XML files

% (c) 2012, Till Biskup
% 2012-01-22

% Parse input arguments using the inputParser functionality
parser = inputParser;   % Create an instance of the inputParser class.
parser.FunctionName = mfilename; % Function name included in error messages
parser.KeepUnmatched = true; % Enable errors on unmatched arguments
parser.StructExpand = true; % Enable passing arguments in a structure
parser.addRequired('filename', @ischar);
parser.addRequired('struct', @isstruct);
parser.parse(filename,struct);

try
    % Do the real stuff
    [pathstr, name] = fileparts(filename);
    if isfield(struct,'data')
        data = struct.data;
        struct = rmfield(struct,'data');
        save(fullfile(tempdir,[name '.dat']),'data','-ascii');
        [structpathstr, structname] = fileparts(struct.file.name);
        struct.file.name = fullfile(structpathstr,[structname '.zip']);
        docNode = struct2xml(struct);
        xmlwrite(fullfile(tempdir,[name '.xml']),docNode);
        zip(fullfile(pathstr,[name '.zip']),...
            {fullfile(tempdir,[name '.dat']),...
            fullfile(tempdir,[name '.xml'])});
        delete(fullfile(tempdir,[name '.xml']));
        delete(fullfile(tempdir,[name '.dat']));
    else
        [structpathstr, structname] = fileparts(struct.file.name);
        struct.file.name = fullfile(structpathstr,[structname '.zip']);
        docNode = struct2xml(struct);
        xmlwrite(fullfile(tempdir,[name '.xml']),docNode);
        zip(fullfile(pathstr,[name '.zip']),fullfile(tempdir,[name '.xml']));
        delete(fullfile(tempdir,[name '.xml']));
    end
    % Set status
    status = 0;
    % Second parameter is filename with full path
    exception = fullfile(pathstr,[name '.zip']);
catch exception
    status = -1;
end

% Assign output parameters
switch nargout
    case 1
        varargout{1} = status;
    case 2
        varargout{1} = status;
        varargout{2} = exception;
    otherwise
        % Do nothing (and _not_ loop!)
end

end