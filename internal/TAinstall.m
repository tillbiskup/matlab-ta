function varargout = TAinstall()
% TAINSTALL Installing the TA Toolbox on your system
%
% Usage
%   TAinstall
%   status = TAinstall
%
%   status    - string
%               Empty if everything went fine, otherwise contains message.
%

% (c) 2012-13, Till Biskup
% 2013-07-15

status = 0;

% There are several tasks a good installation program should perform:
%
% 1. Adding the toolbox paths to the Matlab(tm) search path
%
% 2. Checking the configuration files and update to new parameters

% First of all, check whether there is already a toolbox installed
if exist('TAgui','file')
    installed = true;
else
    installed = false;
end

fprintf('\n');
fprintf('==================================================================\n');
fprintf('\n');
if installed
    fprintf(' WELCOME. This will update\n');
else
    fprintf(' WELCOME. This will install\n');
end
fprintf('\n');
fprintf('     TA toolbox\n');
fprintf('     - a Matlab toolbox for transient absorption spectra  \n');
fprintf('\n');
fprintf(' on your system.\n');
fprintf('\n');
fprintf('==================================================================\n');
fprintf('\n');
if installed
    userQuestion = 'Do you want to update the toolbox now? Y/n [Y]: ';
else
    userQuestion = 'Do you want to install the toolbox now? Y/n [Y]: ';
end
reply = input(userQuestion, 's');
if isempty(reply)
    reply = 'Y';
end
if ~strcmpi(reply,'y')
    fprintf('\nInstallation aborted... good-bye.\n\n');
    return;
end

%-------------------------------------------------------------------------
% ADDING TOOLBOX PATHS
paths = getToolboxPaths(TAinfo('dir'));

% Print paths that get added
if installed
    fprintf('\nRefreshing the following paths in the Matlab(tm) search path:\n\n');
else
    fprintf('\nAdding the following paths to the Matlab(tm) search path:\n\n');
end
cellfun(@(x)fprintf('  %s\n',char(x)),paths);

% Actually add
cellfun(@(x)addpath(char(x)),paths);

% Trying to save path
fprintf('\nSaving path... ')
spstatus = savepath;
if spstatus
    fprintf('FAILED!\n');
    % Test whether global pathdef.m is writable
    pathdefFileName = fullfile(matlabroot,'toolbox','local','pathdef.m');
    fh = fopen(pathdefFileName,'w');
    if fh == -1
        fprintf('\n   You have no write permissions to the file\n   %s.\n',...
            pathdefFileName);
        fprintf('   Therefore, you need to manually save the Matlab path.\n');
    else
        close(fh);
    end 
    status = -2;
else
    fprintf('done.\n');
end

%-------------------------------------------------------------------------
% UPDATING CONFIGURATION - only if installed before - otherwise CREATING
if installed
    fprintf('\nUpdating configuration... ');
    confFiles = TAconf('files');
    if isempty(confFiles)
        fprintf('done.\n');
    else
        fprintf('\n\n')
        % Check whether config directory is readable
        [confDir,~,~] = fileparts(confFiles{1});
        [~,attrib] = fileattrib(confDir);
        if ~attrib.UserRead
            fprintf('\nfailed.\n');
            fprintf('Configuration directory not writable:\n\t%s\n%s',...
                confDir,'Please change and retry!');
            status = -1;
        else
            for k=1:length(confFiles)
                tocopy = TAiniFileRead(confFiles{k},'typeConversion',true);
                master = TAiniFileRead([confFiles{k} '.dist'],...
                    'typeConversion',true);
                newConf = structcopy(master,tocopy);
                header = 'Configuration file for TA toolbox';
                TAiniFileWrite(confFiles{k},...
                    newConf,'header',header,'overwrite',true);
                [~,cfname,cfext] = fileparts(confFiles{k});
                fprintf('  merging %s%s\n',cfname,cfext);
            end
            fprintf('\ndone.\n');
        end
    end
else
    fprintf('\Creating config files... ');
    confFiles = TAconf('distfiles');
    if isempty(confFiles)
        fprintf('done.\n');
    else
        fprintf('\n\n')
        % Check whether config directory is readable
        [confDir,~,~] = fileparts(confFiles{1});
        [~,attrib] = fileattrib(confDir);
        if ~attrib.UserRead
            fprintf('\nfailed.\n');
            fprintf('Configuration directory not writable:\n\t%s\n%s\n%s',...
                confDir,'Please change and try again to install/update!',...
                'A writable configuration directory is vital for the toolbox.');
            status = -1;
        else
            TAconf('create');
            fprintf('\ndone.\n');
        end
    end
end

%-------------------------------------------------------------------------
% CHECK FOR CONFIGURATION DIRECTORY
confDir = TAparseDir('~/.ta');
if ~exist(confDir,'dir')
    try
        fprintf('\nCreating local config directory... ');
        mkdir(confDir);
        fprintf('done.\n');
    catch exception
        status = exception.message;
        fprintf('failed!\n');
    end
end
snapshotDir = TAparseDir(fullfile(confDir,'snapshots'));
if ~exist(snapshotDir,'dir')
    mkdir(snapshotDir);
end

fprintf('\nCongratulations! The TA Toolbox has been ')
if installed
    fprintf('updated ')
else
    fprintf('installed ')
end
fprintf('on your system.\n\n');
if status
    fprintf('CAUTION: Please note that were some warnings.\n\n')
end
fprintf('Please, find below a bit of information about the current install.\n\n')

TAinfo;
fprintf('\n');

if nargout
    varargout{1} = status;
end

end

function directories = getToolboxPaths(path)
directories = cell(0);
traverse(path);
    function traverse(directory)
        list = dir(directory);
        for k=1:length(list)
            if list(k).isdir && ~strncmp(list(k).name,'.',1) && ...
                    ~strcmp(list(k).name,'private')
                directories{end+1} = fullfile(directory,list(k).name); %#ok<AGROW>
                traverse(fullfile(directory,list(k).name));
            end
        end
    end
end