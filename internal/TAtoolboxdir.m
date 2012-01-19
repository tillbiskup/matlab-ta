function path = TAtoolboxdir()

[path,~,~] = fileparts(mfilename('fullpath'));
path = path(1:end-9);

end