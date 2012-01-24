function struct = structcopy(master,tocopy)
%STRUCTCOPY Copy struct array contents into another array.
%

% (c) 2012, Till Biskup
% 2012-01-24

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
