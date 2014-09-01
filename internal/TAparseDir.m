function dir = TAparseDir(dir)
%TREPRPARSEDIR Parse directory string and replace certain keywords, such as
% "pwd" and "~".

% Copyright (c) 2013, Till Biskup
% 2013-07-15

if any(strcmpi(dir,{'pwd',''}))
    dir = pwd;
end
if strncmp(dir,'~',1)
    if ispc
        userdir = getenv('USERPROFILE');
    else
        userdir = getenv('HOME');
    end
    dir = [ userdir dir(2:end) ];
end

end
