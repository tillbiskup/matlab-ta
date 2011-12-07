function varargout = TAconf(action)
% TACONF Handling configuration of TA toolbox
%
% Usage
%   TAconf(action)
%
%   action - string
%            Action to perform. Currently only 'create'
%
% Actions
%
%   create - Creating TA toolbox configuration files from distributed
%            templates.

% (c) 2011, Till Biskup
% 2011-12-07

% If none or the wrong input parameter, display help and exit
if nargin == 0 || isempty(action) || ~ischar(action)
    help TAconf;
    return;
end

try
    % Save current directory
    PWD = pwd;
    switch lower(action)
        case 'create'
            % Change to config directory
            cd(fullfile(TAinfo('dir'),'GUI','private','conf'));
            % Do stuff
            confDistFiles = dir('*.ini.dist');
            for k=1:length(confDistFiles)
                % Check whether ini file exists already, and if not, create
                % it by copying from the "ini.dist" file.
                if ~exist(confDistFiles(k).name(1:end-5),'file')
                    conf = iniFileRead(confDistFiles(k).name);
                    % NOTE: Needs to be changed as soon as iniFileWrite got
                    % rewritten.
                    parms = struct(...
                        'assignmentChar',' =',...
                        'commentChar','%',...
                        'headerFirstLine','% Configuration file for TA toolbox');
                    iniFileWrite(confDistFiles(k).name(1:end-5),conf,parms);
                end
            end
            % Change directory back to original directory
            cd(PWD);
        case 'files'
            confFiles = dir(...
                fullfile(TAinfo('dir'),'GUI','private','conf','*.ini'));
            if isempty(confFiles)
                varargout{1} = cell(0);
                return;
            end
            confFileNames = cell(length(confFiles),1);
            for k=1:length(confFiles)
                confFileNames{k} = fullfile(...
                    TAinfo('dir'),'GUI','private','conf',confFiles(k).name);
            end
            varargout{1} = confFileNames;
        otherwise
            fprintf('%s: Unknown action: %s\n',mfilename,action);
    end
catch exception
    % Be kind: Try to change directory back
    if exist('PWD','var')
        cd(PWD);
    end
    throw(exception);
end
