function status = guiConfigApply(guiname)
% GUICONFIGAPPLY Apply configuration parameters to a given GUI window.
%
% Used normally when initialising a GUI. The GUI needs to have a field
% "configuration" in its appdata structure.
%
% Usage
%   guiConfigApply(guiname)
%
%   guiname - string
%             valid mfilename of a GUI
%             An instance of that GUI must run.
%
% See also GUICONFIGLOAD, INIFILEREAD

% (c) 2011-12, Till Biskup
% 2012-04-12

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
    ad = getappdata(handle);
    gh = guihandles(handle);
    
    % Try to load and append configuration
    conf = TAiniFileRead(confFile,'typeConversion',true);
    if isempty(conf)
        status = -1;
        return;
    end
    
    ad.configuration = conf;
    setappdata(handle,'configuration',ad.configuration);

    % Switch depending on GUI name - use GUI mfilename therefore
    switch lower(guiname)
        case 'tagui'
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
            if isfield(ad.configuration.load,'infofile')
                set(gh.load_panel_infofile_checkbox,...
                    'Value',ad.configuration.load.infofile);
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
            
            % Set display panel's settings
            if isfield(ad.configuration.display,'thresholdMin')
                set(gh.display_panel_threshold_min_checkbox,...
                    'Value',ad.configuration.display.thresholdMin);
            end
            if isfield(ad.configuration.display,'thresholdMax')
                set(gh.display_panel_threshold_max_checkbox,...
                    'Value',ad.configuration.display.thresholdMax);
            end
            if isfield(ad.configuration.display,'thresholdAll')
                set(gh.display_panel_threshold_all_checkbox,...
                    'Value',ad.configuration.display.thresholdAll);
            end
            
            % Copy grid settings from configuration to control
            if ad.configuration.display.grid.x
                ad.control.axis.grid.x = 'on';
            else
                ad.control.axis.grid.x = 'off';
            end
            if ad.configuration.display.grid.y
                ad.control.axis.grid.y = 'on';
            else
                ad.control.axis.grid.y = 'off';
            end
            ad.control.axis.grid.zero = structcopy(...
                ad.control.axis.grid.zero,...
                ad.configuration.display.grid.zero);
            
            % Copy axis legend settings from configuration to control
            ad.control.axis.legend = structcopy(ad.control.axis.legend,...
                ad.configuration.display.legend);
            
            % Apply config settings to control structure
            ad.control.axis.onlyActive = ...
                ad.configuration.datasets.onlyActive;
            setappdata(handle,'configuration',ad.configuration);
            setappdata(handle,'control',ad.control);
            
            % Update axis
            update_mainAxis();
        otherwise
            return;
    end
catch exception
    % If this happens, something probably more serious went wrong...
    throw(exception);
end

end
