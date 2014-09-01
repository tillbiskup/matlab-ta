function conf = guiConfigLoad(guiname)
% GUICONFIGLOAD Read configuration parameters for a given GUI window.
%
% The idea is to minimise the files that contain the actual path to the
% config files, such as to make life easier if this changes.
%
% Usage
%   conf = guiConfigLoad(guiname)
%
%   guiname - string
%             Valid mfilename of a GUI
%
%   conf    - struct
%             Contains all configuration parameters of the given GUI
%             Empty if no configuration could be read.
%
% See also GUICONFIGWRITE, GUICONFIGAPPLY, TAINIFILEREAD, TAINIFILEWRITE

% Copyright (c) 2011-12, Till Biskup
% 2012-02-05

try

    % Define config file
    confFile = fullfile(...
        TAinfo('dir'),'GUI','private','conf',[guiname '.ini']);
    % If that file does not exist, try to create it from the
    % distributed config file sample
    if ~exist(confFile,'file')
        fprintf('Config file\n  %s\nseems not to exist. %s\n',...
            confFile,'Trying to create it from distributed file.');
        TAconf('create','overwrite',true,'file',confFile);
    end
    
    % Try to load and append configuration
    conf = TAiniFileRead(confFile,'typeConversion',true);
    if isempty(conf)
        return;
    end

catch exception
    % If this happens, something probably more serious went wrong...
    throw(exception);
end

end
