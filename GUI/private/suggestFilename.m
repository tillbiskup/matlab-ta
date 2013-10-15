function filename = suggestFilename(guiHandle,varargin)
% SUGGESTFILENAME Create filename suggestion from GUI data and current
% dataset.

% (c) 2013, Till Biskup
% 2013-10-15

% Parse input arguments using the inputParser functionality
parser = inputParser;   % Create an instance of the inputParser class.
parser.FunctionName  = mfilename; % Include function name in error messages
parser.KeepUnmatched = true; % Enable errors on unmatched arguments
parser.StructExpand  = true; % Enable passing arguments in a structure

parser.addRequired('guiHandle',@ishandle);
parser.addParamValue('type','file',@ischar);
parser.parse(guiHandle,varargin{:});

% Get appdata and handles
ad = getappdata(guiHandle);

% Handle what to save: figure, file, ...
switch lower(parser.Results.type)
    case 'file'
        directory = 'lastSave';
    case {'fig','figure'}
        directory = 'lastFigSave';
    otherwise
        % This shall never happen
        TAmsg('Damn! Some problem with determining what to save');
        filename = '';
        return;
end
        

% Get directory where to save files to
if isfield(ad,'control') && isfield(ad.control,'dir') && ...
        isfield(ad.control.dir,directory)  && ...
        ~isempty(ad.control.dir.(directory))
    startDir = ad.control.dir.(directory);
else
    startDir = pwd;
end

if ad.control.spectra.visible
    if isfield(ad.configuration,'filenames') && ...
            ad.configuration.filenames.useLabel
        filename = ad.data{ad.control.spectra.active}.label;
    else
        [~,filename,~] = ...
            fileparts(ad.data{ad.control.spectra.active}.file.name);
    end
    if isfield(ad.configuration,'filenames') && ...
            ad.configuration.filenames.sanitise
        % Replace whitespace character with "_"
        filename = regexprep(filename,'\s','_');
    else
        filename = fullfile(startDir,filename);
    end
else
    filename = startDir;
end

end