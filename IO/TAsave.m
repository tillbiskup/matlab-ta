function varargout = TAsave(filename,struct)
% Save data from the TA toolbox as ZIP-compressed XML files

% (c) 2012, Till Biskup
% 2012-02-03

% Parse input arguments using the inputParser functionality
parser = inputParser;   % Create an instance of the inputParser class.
parser.FunctionName = mfilename; % Function name included in error messages
parser.KeepUnmatched = true; % Enable errors on unmatched arguments
parser.StructExpand = true; % Enable passing arguments in a structure
parser.addRequired('filename', @ischar);
parser.addRequired('struct', @isstruct);
parser.parse(filename,struct);

try
    % Set file extensions
    zipext = '.taz';
    xmlext = '.xml';
    offext = '.dat';
    onext  = '.on';
    % Set status
    status = cell(0);
    % Do the real stuff
    [pathstr, name] = fileparts(filename);
    if isfield(struct,'data')
        data = struct.data;
        struct = rmfield(struct,'data');
        %save(fullfile(tempdir,[name offext]),'data','-ascii');
        stat = writeBinary(fullfile(tempdir,[name offext]),data);
        if ~isempty(stat)
            status{end+1} = sprintf(...
                'Problems writing file %s%s:\n   %s',...
                name,offext,stat);
        end
        if isfield(struct,'dataMFon')
            dataMFon = struct.dataMFon;
            struct = rmfield(struct,'dataMFon');
            if ~isempty(dataMFon) && isnumeric(dataMFon)
                %save(fullfile(tempdir,[name onext]),'dataMFon','-ascii');
                status = writeBinary(fullfile(tempdir,[name onext]),dataMFon);
                if ~isempty(stat)
                    status{end+1} = sprintf(...
                        'Problems writing file %s%s:\n   %s',...
                        name,offext,stat);
                end
            else
                clear dataMFon;
            end
        end
        [structpathstr, structname] = fileparts(struct.file.name);
        struct.file.name = fullfile(structpathstr,[structname zipext]);
        docNode = struct2xml(struct);
        xmlwrite(fullfile(tempdir,[name xmlext]),docNode);
        if exist('dataMFon','var')
            zip(fullfile(pathstr,[name zipext]),...
                {fullfile(tempdir,[name offext]),...
                fullfile(tempdir,[name onext]),...
                fullfile(tempdir,[name xmlext])});
            movefile([fullfile(pathstr,[name zipext]) '.zip'],...
                fullfile(pathstr,[name zipext]));
            delete(fullfile(tempdir,[name onext]));
        else
            zip(fullfile(pathstr,[name zipext]),...
                {fullfile(tempdir,[name offext]),...
                fullfile(tempdir,[name xmlext])});
            movefile([fullfile(pathstr,[name zipext]) '.zip'],...
                fullfile(pathstr,[name zipext]));
        end
        delete(fullfile(tempdir,[name xmlext]));
        delete(fullfile(tempdir,[name offext]));
    else
        [structpathstr, structname] = fileparts(struct.file.name);
        struct.file.name = fullfile(structpathstr,[structname zipext]);
        docNode = struct2xml(struct);
        xmlwrite(fullfile(tempdir,[name xmlext]),docNode);
        zip(fullfile(pathstr,[name zipext]),fullfile(tempdir,[name xmlext]));
        movefile([fullfile(pathstr,[name zipext]) '.zip'],...
            fullfile(pathstr,[name zipext]));
        delete(fullfile(tempdir,[name xmlext]));
    end
    % Second parameter is filename with full path
    exception = fullfile(pathstr,[name zipext]);
catch exception
    status{end+1} = 'A problem occurred:';
    status{end+1} = exception.message;
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

function status = writeBinary(filename,data)
% WRITEBINARY Writing given data to given file as binary (real*4)

% Set status
status = '';

% Open file for (only) writing
fh = fopen(filename,'w');

% Write data
count = fwrite(fh,data,'real*4');

% Close file
fclose(fh);

% Check whether all elements have been written
[y,x] = size(data);
if count ~= x*y
    status = sprintf('Problems with writing: %i of %i elements written',...
        count,x*y);
end

end