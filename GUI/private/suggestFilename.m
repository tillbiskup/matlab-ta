function filename = suggestFilename(guiHandle)
% SUGGESTFILENAME Create filename suggestion from GUI data and current
% dataset.

% (c) 2013, Till Biskup
% 2013-10-15

% Get appdata and handles
ad = getappdata(guiHandle);
%gh = guihandles(guiHandle);
        
% Get directory where to save files to
if isfield(ad,'control') && isfield(ad.control,'dir') && ...
        isfield(ad.control.dir,'lastFigSave')  && ...
        ~isempty(ad.control.dir.lastFigSave)
    startDir = ad.control.dir.lastFigSave;
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