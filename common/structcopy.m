function struct = structcopy(master,tocopy)
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
% 2012-02-05

if ~nargin
    help structcopy
    return;
end

if ~isstruct(master)
    fprintf('%s has wrong type',master);
    return;
elseif ~isstruct(tocopy)
    fprintf('%s has wrong type',tocopy);
    return;
end

[struct,tocopy] = traverse(master,tocopy);

end


function [master,tocopy] = traverse(master,tocopy)

tocopyFieldNames = fieldnames(tocopy);
for k=1:length(tocopyFieldNames)
    if ~isfield(master,tocopyFieldNames{k})
        master.(tocopyFieldNames{k}) = tocopy.(tocopyFieldNames{k});
    elseif isstruct(tocopy.(tocopyFieldNames{k}))
        [master.(tocopyFieldNames{k}),tocopy.(tocopyFieldNames{k})] = ...
            traverse(master.(tocopyFieldNames{k}),tocopy.(tocopyFieldNames{k}));
    else
        master.(tocopyFieldNames{k}) = tocopy.(tocopyFieldNames{k});
    end
end

end
