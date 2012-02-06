function varargout = xmlRead(filename)
% XMLREAD Read XML file
%
% Usage:
%   [data,warning] = xmlRead(filename);
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
% SEE ALSO XMLZIPREAD

% (c) 2011-12, Till Biskup
% 2012-02-06

% Parse input arguments using the inputParser functionality
parser = inputParser;   % Create an instance of the inputParser class.
parser.FunctionName = mfilename; % Function name included in error messages
parser.KeepUnmatched = true; % Enable errors on unmatched arguments
parser.StructExpand = true; % Enable passing arguments in a structure
parser.addRequired('filename', @(x)ischar(x) || iscell(x));
% Note, this is to be compatible with TAload - currently without function!
p.addParamValue('checkFormat',logical(true),@islogical);
parser.parse(filename);
% Do the real stuff
if ~exist(filename,'file')
    if nargout
        varargout{1} = [];
        varargout{2} = ...
            sprintf('"%s" seems not to be a valid filename.',filename);
    end
    return;
end
% Test whether file is really an xml file
fid = fopen(filename);
firstLine = fgetl(fid);
fclose(fid);
if ~strcmp(firstLine,'<?xml version="1.0" encoding="utf-8"?>')
    if nargout
        varargout{1} = [];
        varargout{2} = ...
            sprintf('"%s" seems not to be a valid XML file.',filename);
    end
    return;
end    
[status,message,messageid] = copyfile(filename,tempdir);
if ~status
    if nargout
        varargout{1} = [];
        varargout{2} = sprintf('Problems copying file %s.',filename);
    end
    return;
end
PWD = pwd;
cd(tempdir);
[pathstr, name, ext] = fileparts(filename);
xmlFileSerialize([name ext]);
DOMnode = xmlread([name ext]);
if nargout
    varargout{1} = xml2struct(DOMnode);
    varargout{2} = cell(0);
else
    varname=char(DOMnode.getDocumentElement.getNodeName);
    varval = xml2struct(DOMnode);
    assignin('caller',varname,varval);
end
delete([name ext]);
cd(PWD);
end