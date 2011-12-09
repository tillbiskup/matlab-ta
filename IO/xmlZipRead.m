function varargout = xmlZipRead(filename)
% XMLZIPREAD Read ZIP-compressed XML file and data (if available)
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

% (c) 2011, Till Biskup
% 2011-11-05

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
try
    filenames = unzip(filename);
catch
    err = lasterror;
    warning = sprintf('%s\n%s\n"%s"\n%s\n',...
        err.identifier,...
        'Problems with unzipping:',...
        filename,...
        'seems not to be a valid zip file. Aborted.');
    if nargout
        varargout{1} = logical(false);
        varargout{2} = warning;
    end
    return;
end
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
                data = load(fullfile(pathstr,[name ext]));
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
    struct.data = data;
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