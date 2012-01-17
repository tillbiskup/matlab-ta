function status = guiConfigApply(guiname)
% GUICONFIGAPPLY Apply configuration parameters to a given GUI window.
%
% Used normally when initialising a GUI. The GUI needs to have a field
% "configuration" in its appdata structure. To actually read configuration
% settings from a file, use guiConfigLoad.
%
% Usage
%   guiConfigApply(guiname)
%
%   guiname - string
%             valid mfilename of a GUI
%             An instance of that GUI must run.
%
% See also GUICONFIGLOAD, INIFILEREAD

% (c) 2011, Till Biskup
% 2011-12-06

status = 0;

% If called without a GUI name, return
if isempty(guiname)
    status = sprintf('GUI "%s" could not be found',guiname);
    return;
end

try
    % Get handle for GUI
    % NOTE: That means that an instance of the GUI must exist.
    handle = guiGetWindowHandle(guiname);
    if isempty(handle) or ~ishandle(handle)
        status = -2;
        return;
    end
    
    % Switch depending on GUI name - use GUI mfilename therefore
    switch lower(guiname)
        case 'tagui'
            ad = getappdata(handle);
            gh = guihandles(handle);

            % Try to load and append configuration
            conf = guiConfigLoad(fullfile(...
                TAinfo('dir'),'GUI','private','conf',[guiname '.ini']));
            if ~isempty(conf)
                confFields = fieldnames(conf);
                for k=1:length(confFields)
                    ad.configuration.(confFields{k}) = conf.(confFields{k});
                end
            end
            
            setappdata(handle,'configuration',ad.configuration);
            
            % NOTE: Be very defensive in general, as we cannot rely on the
            % GUI having loaded a valid config file.
            % This is true in particular due to the fact that only the
            % .ini.dist files get distributed, but not the actual config
            % files.
            
            % Set load panel's settings
            if isfield(ad.configuration.load,'combine')
                set(gh.load_panel_files_combine_checkbox,...
                    'Value',ad.configuration.load.combine);
            end
            if isfield(ad.configuration.load,'loaddir')
                set(gh.load_panel_files_directory_checkbox,...
                    'Value',ad.configuration.load.loaddir);
            end
            if isfield(ad.configuration.load,'AVG')
                set(gh.load_panel_preprocessing_avg_checkbox,...
                    'Value',ad.configuration.load.AVG);
            end
            if isfield(ad.configuration.load,'POC')
                set(gh.load_panel_preprocessing_offset_checkbox,...
                    'Value',ad.configuration.load.POC);
            end
            if isfield(ad.configuration.load,'BGC')
                set(gh.load_panel_preprocessing_background_checkbox,...
                    'Value',ad.configuration.load.BGC);
            end
            if isfield(ad.configuration.load,'labels')
                set(gh.load_panel_axislabels_checkbox,...
                    'Value',ad.configuration.load.labels);
            end
            if isfield(ad.configuration.load,'format')
                % Get value from load_panel_filetype_popupmenu
                fileTypes = ...
                    cellstr(get(gh.load_panel_filetype_popupmenu,'String'));
                for k=1:length(fileTypes)
                    if strcmpi(fileTypes{k},ad.configuration.load.format)
                        set(gh.load_panel_filetype_popupmenu,'Value',k);
                    end
                end
            end
        otherwise
            % That shall not happen normally
            fprintf('Unknown GUI: %s',guiname);
    end
catch exception
    % If this happens, something probably more serious went wrong...
    throw(exception);
end

end
