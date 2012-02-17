function varargout = TAxmlZipRead(filename,varargin)
% TAXMLZIPREAD Read ZIP-compressed XML file and data (if available)
%
% Usage:
%   [data,warning] = xmlZipRead(filename);
%
%   filename - string
%              name of the ZIP archive containing the XML (and data)
%              file(s)
%   data     - struct
%              content of the XML file
%              data.data holds the data read from the ZIP archive
%   warning  - cell array
%              Contains warnings if there are any, otherwise empty
%
% SEE ALSO TAXMLZIPWRITE

% (c) 2011-12, Till Biskup
% 2012-02-17

% Parse input arguments using the inputParser functionality
parser = inputParser;   % Create an instance of the inputParser class.
parser.FunctionName = mfilename; % Function name included in error messages
parser.KeepUnmatched = true; % Enable errors on unmatched arguments
parser.StructExpand = true; % Enable passing arguments in a structure
parser.addRequired('filename', @(x)ischar(x) || iscell(x));
% Note, this is to be compatible with TAload - currently without function!
parser.addParamValue('checkFormat',logical(true),@islogical);
parser.parse(filename);

% Do the real stuff
if iscell(filename)
    data = cell(length(filename),1);
    warning = cell(length(filename),1);
    for k=1:length(filename)
        [data{k},warning{k}] = TAxmlZipRead(filename{k},varargin{:});
    end
    varargout{1} = data;
    varargout{2} = warning;
    return;
end

if ~exist(filename,'file')
    fprintf('"%s" seems not to be a valid filename. Abort.',filename);
    if nargout, varargout{1} = logical(false); end;
    return;
end
[status,message,messageid] = copyfile(filename,tempdir);
if ~status
    fprintf('%s\n%s\n Aborted.\n',messageid,message);
    if nargout, varargout{1} = logical(false); end;
    return;
end
PWD = pwd;
cd(tempdir);
% Unzip and delete ZIP archive afterwards
try
    filenames = unzip(filename);
    [~, name, ext] = fileparts(filename);
    delete(fullfile(tempdir,[name ext]));
catch exception
    warning = sprintf('%s\n%s\n"%s"\n%s\n',...
        exception.identifier,...
        'Problems with unzipping:',...
        filename,...
        'seems not to be a valid zip file. Aborted.');
    if nargout
        varargout{1} = logical(false);
        varargout{2} = warning;
    end
    return;
end
% Read different files of the archive
try
    for k=1:length(filenames)
        [pathstr, name, ext] = fileparts(filenames{k});
        switch ext
            case '.xml'
                xmlFileSerialize(fullfile(pathstr,[name ext]));
                DOMnode = xmlread(fullfile(pathstr,[name ext]));
                struct = xml2struct(DOMnode);
                delete(fullfile(pathstr,[name ext]));
            case '.dat'
                try
                    data = load(fullfile(pathstr,[name ext]));
                catch exception
                    try
                        data = readBinary(fullfile(pathstr,[name ext]));
                    catch exception2
                        exception = addCause(exception2, exception);
                        throw(exception);
                    end
                end
                delete(fullfile(pathstr,[name ext]));
            case '.on'
                try
                    dataMFon = load(fullfile(pathstr,[name ext]));
                catch exception
                    try
                        dataMFon = readBinary(fullfile(pathstr,[name ext]));
                    catch exception2
                        exception = addCause(exception2, exception);
                        throw(exception);
                    end
                end
                delete(fullfile(pathstr,[name ext]));
            otherwise
                delete(fullfile(pathstr,[name ext]));
        end
    end
catch errmsg
    warning = sprintf('%s\n%s\n"%s"\n',...
        errmsg.identifier,...
        'Problems with parsing XML in file:',...
        filename);
    if nargout
        varargout{1} = logical(false);
        varargout{2} = warning;
    end
    cd(PWD);
    return;
end
if exist('data','var')
    % Check whether data have the right dimensions - in case that we read
    % from binary, most probably they have not - in this case, reshape
    xdim = length(struct.axes.x.values);
    ydim = length(struct.axes.y.values);
    [y,x] = size(data);
    if ((x ~= xdim) || (y ~= ydim))  && ~isempty(data)
        data = reshape(data,ydim,xdim);
    end
    struct.data = data;
    clear data
end
if exist('dataMFon','var')
    % Check whether data have the right dimensions - in case that we read
    % from binary, most probably they have not - in this case, reshape
    xdim = length(struct.axes.x.values);
    ydim = length(struct.axes.y.values);
    [y,x] = size(dataMFon);
    if ((x ~= xdim) || (y ~= ydim)) && ~isempty(dataMFon)
        dataMFon = reshape(dataMFon,ydim,xdim);
    end
    struct.dataMFon = dataMFon;
    clear dataMFon
end
if nargout
    varargout{1} = struct;
    varargout{2} = cell(0);
else
    varname=char(DOMnode.getDocumentElement.getNodeName);
    assignin('caller',varname,struct);
end
cd(PWD);
end

function data = readBinary(filename)

fh = fopen(filename);
data = fread(fh,inf,'real*4');
fclose(fh);

end