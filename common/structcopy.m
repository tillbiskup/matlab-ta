function structure = structcopy(master,tocopy,varargin)
%STRUCTCOPY Copy struct array contents into another array.
%
% All fields (and contents) from "tocopy" get copied into "master".
% Therefore, this function is particularly useful if you have a "master"
% that has normally more fields than "tocopy" and if you want to preserve
% the information in "tocopy".
%
% Usage
%    struct = structcopy(master,tocopy)
%
% master - struct
%          Master means here master in terms of the available fields, but
%          NOT in terms of their contents.
%
% tocopy - struct
%          The contents of this struct get copied in the struct "master",
%          and if fields of tocopy don't exist in master, they will be
%          created.

% (c) 2012, Till Biskup
% 2012-04-23

if ~nargin
    help structcopy
    return;
end

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('master', @(x)isstruct(x));
p.addRequired('tocopy', @(x)isstruct(x));
p.addParamValue('overwrite',logical(false),@islogical);
p.parse(master,tocopy,varargin{:});



if ~isstruct(master)
    fprintf('%s (master) has wrong type\n',master);
    structure = struct();
    return;
elseif ~isstruct(tocopy) 
    if ~p.Results.overwrite
        fprintf('%s (tocopy) has wrong type\n',tocopy);
        structure = struct();
        return;
    else
        tocopy = struct();
    end
end

[structure,tocopy] = traverse(master,tocopy);

end


function [master,tocopy] = traverse(master,tocopy)

tocopyFieldNames = fieldnames(tocopy);
for k=1:length(tocopyFieldNames)
    if ~isfield(master,tocopyFieldNames{k})
        master.(tocopyFieldNames{k}) = tocopy.(tocopyFieldNames{k});
    elseif length(tocopy.(tocopyFieldNames{k}))>1 ...
            && isstruct(tocopy.(tocopyFieldNames{k})(1))
        for idx = 1:length(tocopy.(tocopyFieldNames{k}))
            [master.(tocopyFieldNames{k})(idx),tocopy.(tocopyFieldNames{k})(idx)] = ...
                traverse(master.(tocopyFieldNames{k})(idx),tocopy.(tocopyFieldNames{k})(idx));
        end
    elseif isstruct(tocopy.(tocopyFieldNames{k}))
        [master.(tocopyFieldNames{k}),tocopy.(tocopyFieldNames{k})] = ...
            traverse(master.(tocopyFieldNames{k}),tocopy.(tocopyFieldNames{k}));
    else
        master.(tocopyFieldNames{k}) = tocopy.(tocopyFieldNames{k});
    end
end

end
