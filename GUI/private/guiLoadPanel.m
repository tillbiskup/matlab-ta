function handle = guiLoadPanel(parentHandle,position)
% GUILOADPANEL Add a panel for loading files to a gui
%       Should only be called from within a GUI defining function.
%
%       Arguments: parent Handle and position vector.
%
%       Returns the handle of the added panel.

% (c) 2011-13, Till Biskup
% 2013-06-02

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

defaultBackground = get(parentHandle,'Color');

% Get names of file formats that can be handled by TAload
% Therefore, load TAload.ini and parse for "name" field.
fileFormats = TAiniFileRead(fullfile(TAinfo('dir'),'IO','TAload.ini'));
fileFormatIdentifiers = fieldnames(fileFormats);
fileFormatNames = cell(1,length(fileFormatIdentifiers));
for m=1:length(fileFormatIdentifiers)
    fileFormatNames{m} = fileFormats.(fileFormatIdentifiers{m}).name;
end 

handle = uipanel('Tag','load_panel',...
    'parent',parentHandle,...
    'Title','Load data',...
    'FontWeight','bold',...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','pixels','Position',position);

% Create the "Load data" panel
handle_size = get(handle,'Position');
uicontrol('Tag','load_panel_description',...
    'Style','text',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontUnit','Pixel','Fontsize',12,...
    'FontAngle','oblique',...
    'Position',[10 handle_size(4)-60 handle_size(3)-20 30],...
    'String',{'Load data from file(s)' 'Import data from diverse sources'}...
    );

p1 = uipanel('Tag','load_panel_files_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-140 handle_size(3)-20 70],...
    'FontUnit','Pixel','Fontsize',12,...
    'Title','Files to load'...
    );
handle_comb_cb = uicontrol('Tag','load_panel_files_combine_checkbox',...
    'Style','checkbox',...
    'Parent',p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 30 handle_size(3)-40 20],...
    'String',' Combine multiple files',...
    'TooltipString',sprintf('%s\n%s\n%s',...
    'If a dataset consists of several files',...
    '(e.g., time traces), combine them.','Use carefully.')...
    );
handle_dir_cb = uicontrol('Tag','load_panel_files_directory_checkbox',...
    'Style','checkbox',...
    'Parent',p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-40 20],...
    'String',' Load whole directory',...
    'TooltipString',sprintf('%s\n%s','Load all readable files of a directory.',...
    'Use carefully.')...
    );

p2 = uipanel('Tag','load_panel_infofile_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-200 handle_size(3)-20 50],...
    'Title','Info file'...
    );
handle_infofile_cb = uicontrol('Tag','load_panel_infofile_checkbox',...
    'Style','checkbox',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-40 20],...
    'TooltipString','Try to find, load and apply info file',...
    'String',' Load info file'...
    );

p3 = uipanel('Tag','load_panel_preprocessing_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-260 handle_size(3)-20 50],...
    'Title','Preprocessing on load'...
    );
handle_avg_cb = uicontrol('Tag','load_panel_preprocessing_avg_checkbox',...
    'Style','checkbox',...
    'Parent',p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-40 20],...
    'String',' Average multiple scans',...
    'TooltipString',sprintf('%s\n%s','Average multiple scans',...
    '(if there is more than one scan in a file)')...
    );
% handle_poc_cb = uicontrol('Tag','load_panel_preprocessing_offset_checkbox',...
%     'Style','checkbox',...
%     'Parent',p3,...
%     'BackgroundColor',defaultBackground,...
%     'FontUnit','Pixel','Fontsize',12,...
%     'Units','Pixels',...
%     'Position',[10 30 handle_size(3)-40 20],...
%     'String',' Offset compensation',...
%     'TooltipString',sprintf('%s\n%s','Perform offset compensation',...
%     '(average of pretrigger offset for each time trace set to zero)')...
%     );

p4 = uipanel('Tag','load_panel_axislabels_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-320 handle_size(3)-20 50],...
    'Title','Axis labels'...
    );
handle_axislabels_cb = uicontrol('Tag','load_panel_axislabels_checkbox',...
    'Style','checkbox',...
    'Parent',p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-40 20],...
    'TooltipString','Try to determine axis labels from (last loaded) file',...
    'String',' Determine labels from file'...
    );

p5 = uipanel('Tag','load_panel_filetype_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-380 handle_size(3)-20 50],...
    'Title','File type'...
    );
uicontrol('Tag','load_panel_filetype_popupmenu',...
    'Style','popupmenu',...
    'Parent',p5,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-40 20],...
    'String',['automatic' fileFormatNames],...
    'Value',1 ...
    );

uicontrol('Tag','load_panel_load_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[handle_size(3)-70 handle_size(4)-470 60 40],...
    'String','Load',...
    'TooltipString',sprintf('%s\n%s','Pressing the button opens the',...
    'file selection dialogue'),...
    'Callback', {@load_pushbutton_Callback}...
    );

uicontrol('Tag','load_panel_asciiimport_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-470 60 40],...
    'String','<html>ASCII<br />import</html>',...
    'TooltipString',sprintf('%s\n%s','If none of the above formats fits,',...
    'try using the interactive ASCII importer'),...
    'Callback', {@TAgui_ASCIIimporterwindow}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function load_pushbutton_Callback(~,~)
    try
        state = struct();
        
        % Get appdata and guihandles of main window
        mainWindow = TAguiGetWindowHandle;
        ad = getappdata(mainWindow);
        gh = guihandles(mainWindow);
        
        % Get value from load_panel_filetype_popupmenu
        fileTypes = cellstr(get(gh.load_panel_filetype_popupmenu,'String'));
        fileType = fileTypes{get(gh.load_panel_filetype_popupmenu,'Value')};

        if strcmpi(fileType,'automatic')
            FilterSpec = '*.*';
        else
            fileExtensions = fileFormats.(fileFormatIdentifiers{...
                strcmpi(fileType,fileFormatNames)}).fileExtension;
            FilterSpec = ['*.' strrep(fileExtensions,'|',';*.')];
        end
      
        % Set directory where to load files from
        if isfield(ad,'control') && isfield(ad.control,'dirs') && ...
                isfield(ad.control.dirs,'lastLoad')  && ...
                ~isempty(ad.control.dirs.lastLoad)
            startDir = ad.control.dirs.lastLoad;
        else
            startDir = pwd;
        end
        
        if (get(handle_dir_cb,'Value') == 1)
            state.dir = true;
        else
            state.dir = false;
        end
        if (get(handle_comb_cb,'Value') == 1)
            state.comb = true;
        else
            state.comb = false;
        end
        
        if (state.dir)
            FileName = uigetdir(...
                startDir,...
                'Select directory to load'...
                );
            PathName = '';
        else
            [FileName,PathName,~] = uigetfile(...
                FilterSpec,...
                'Select file(s) to load',...
                'MultiSelect','on',...
                startDir...
                );
        end
        
        % If the user cancels file selection, print status message and return
        if isequal(FileName,0)
            msg = 'Loading dataset(s) cancelled by user.';
            % Update status
            TAmsg(msg,'info');
            return;
        end

        % In case of files, not a directory, add path to filename
        if exist(PathName,'dir')
            % In case of multiple files
            if iscell(FileName)
                for k = 1 : length(FileName)
                    FileName{k} = fullfile(PathName,FileName{k});
                end
            else
                FileName = fullfile(PathName,FileName);
            end
        end
        
        % Set lastLoadDir in appdata
        if exist(PathName,'dir')
            ad.control.dirs.lastLoad = PathName;
        else
            if iscell(FileName)
                ad.control.dirs.lastLoad = FileName{1};
            else
                ad.control.dirs.lastLoad = FileName;
            end
        end
        setappdata(mainWindow,'control',ad.control);
        
        if strcmpi(fileType,'automatic')
            fileFormat = fileType;
        else
            fileFormat = ...
                fileFormatIdentifiers{strcmpi(fileType,fileFormatNames)};
        end
        
        % Adding status line
        msgStr = cell(0);
        msgStr{length(msgStr)+1} = 'Calling TAload and trying to load';
        msg = [ msgStr FileName];
        TAmsg(msg,'info');
        clear msgStr msg;
        
        busyWindow('start','Trying to load spectra...<br />please wait.');
        
        if (get(handle_avg_cb,'Value') == 1)
            average = true;
        else
            average = false;
        end
        
        if (get(handle_infofile_cb,'Value') == 1)
            loadInfoFile = true;
        else
            loadInfoFile = false;
        end
        
        [data,warnings] = TAload(FileName,'format',fileFormat,...
            'combine',state.comb,'average',average,...
            'loadInfoFile',loadInfoFile);
        
        if isequal(data,0) || isempty(data)
            msg = 'Data could not be loaded.';
            TAmsg(msg,'error');
            busyWindow('stop','Trying to load spectra...<br /><b>failed</b>.');
            return;
        end
        
        % Check whether data{n}.data is numeric (very basic test for format)
        fnNoData = cell(0);
        nNoData = [];
        if iscell(data)
            for k=1:length(data)
                if not(isfield(data{k},'data'))
                    fnNoData{k} = 'unknown';
                    nNoData = [ nNoData k ]; %#ok<AGROW>
                elseif not(isnumeric(data{k}.data))
                    fnNoData{k} = data{k}.file.name;
                    nNoData = [ nNoData k ]; %#ok<AGROW>
                end
            end
            % Remove datasets from data cell array
            data(nNoData) = [];
        else
            if ~isnumeric(data.data)
                fnNoData = data.file.name;
                data = [];
            end
        end
        
        % Add status line
        if ~isempty(fnNoData)
            msgStr = cell(0);
            msgStr{length(msgStr)+1} = ...
                'The following files contained no numerical data (and were DISCARDED):';
            msg = [msgStr fnNoData];
            TAmsg(msg,'warning');
            TAmsg('TAload returned the following message:','warning');
            TAmsg(warnings,'warning');
            clear msgStr msg;
        end
        
        if isempty(data)
            busyWindow('stop','Trying to load spectra...<br /><b>failed</b>.');
            return;
        end
        
        % Get names of successfully loaded files
        % In parallel, add additional fields to each dataset
        guiDataStruct = TAguiDataStructure('datastructure');
        % Important: Delete "history" field not to overwrite history
        guiDataStruct = rmfield(guiDataStruct,'history');
        guiDataStructFields = fieldnames(guiDataStruct);
        if iscell(data)
            fileNames = cell(0);
            for k = 1 : length(data)
                [p,fn,ext] = fileparts(data{k}.file.name);
                fileNames{k} = fullfile(p,[fn ext]);
                if ~isfield(data{k},'label') || isempty(data{k}.label)
                    data{k}.label = [fn ext];
                end
                for l=1:length(guiDataStructFields)
                    data{k}.(guiDataStructFields{l}) = ...
                        guiDataStruct.(guiDataStructFields{l});
                end
                if ~isfield(data{k},'history')
                    data{k}.history = cell(0);
                end
                % Set default thresholds to minima and maxima of dataset
                data{k}.display.threshold.min.value = min(min(data{k}.data));
                data{k}.display.threshold.max.value = max(max(data{k}.data));
                % For compatibility with old versions of TAread and for
                % consistency with the naming of all other structures
                if (isfield(data{k},'axes') && isfield(data{k}.axes,'xaxis'))
                    data{k}.axes.x = data{k}.axes.xaxis;
                    data{k}.axes = rmfield(data{k}.axes,'xaxis');
                end
                if (isfield(data{k},'axes') && isfield(data{k}.axes,'yaxis'))
                    data{k}.axes.y = data{k}.axes.yaxis;
                    data{k}.axes = rmfield(data{k}.axes,'yaxis');
                end
            end
        else
            fileNames = data.file.name;
            [~,fn,ext] = fileparts(data.file.name);
            if ~isfield(data,'label') || isempty(data.label)
                data.label = [fn ext];
            end
            for l=1:length(guiDataStructFields)
                data.(guiDataStructFields{l}) = ...
                    guiDataStruct.(guiDataStructFields{l});
            end
            if ~isfield(data,'history')
                data.history = cell(0);
            end
            % Set default thresholds to minima and maxima of dataset
            data.display.threshold.min.value = min(min(data.data));
            data.display.threshold.max.value = max(max(data.data));
            % For compatibility with old versions of TAread and for
            % consistency with the naming of all other structures
            if (isfield(data,'axes') && isfield(data.axes,'xaxis'))
                data.axes.x = data.axes.xaxis;
                data.axes = rmfield(data.axes,'xaxis');
            end
            if (isfield(data,'axes') && isfield(data.axes,'yaxis'))
                data.axes.y = data.axes.yaxis;
                data.axes = rmfield(data.axes,'yaxis');
            end
        end
        
        % Get indices of new datasets
        % Necessary in case of further corrections applied to datasets
        % after loading
        newDataIdx = length(ad.data)+1 : 1 : length(ad.data)+length(data);
        
        % Add data to main GUI (appdata)
        if size(data,2) > 1
            ad.data = [ ad.data data ];
            ad.origdata = [ ad.origdata data ];
        else
            ad.data = [ ad.data data' ];
            ad.origdata = [ ad.origdata data' ];
        end
        
        setappdata(mainWindow,'data',ad.data);
        setappdata(mainWindow,'origdata',ad.origdata);
        
        % Adding status line
        msgStr = cell(0);
        msgStr{end+1} = ...
            sprintf('%i data set(s) successfully loaded:',length(data));
        msg = [msgStr fileNames];
        TAmsg(msg,'info');
        clear msgStr msg;
        
        if ~isempty(warnings)
            msgStr = cell(0);
            msgStr{end+1} = 'Some warnings occurred while reading files:';
            msg = [msgStr warnings{:}];
            TAmsg(msg,'warning');
            clear msgStr msg;
        end

        busyWindow('stop','Trying to load spectra...<br /><b>done</b>.');
        
        % Get appdata again after making changes to it before
        ad = getappdata(mainWindow);
        
        % Add new loaded spectra to "invisible"
        ad.control.spectra.invisible = [...
            ad.control.spectra.invisible ...
            newDataIdx...
            ];
        setappdata(mainWindow,'control',ad.control);
        
        update_invisibleSpectra;
        
%         % Handle dataset corrections when checked
%         % pretrigger offset compensation
%         if (get(handle_poc_cb,'Value') == 1)
%             for k=1:length(newDataIdx)
%                 guiProcessingPOC(newDataIdx(k));
%             end
%         end
        
        % Try to load axis labels from file
        if (get(handle_axislabels_cb,'Value') == 1)
            if (isfield(ad.data{newDataIdx(end)},'axes'))
                if (isfield(ad.data{newDataIdx(end)}.axes,'x') && ...
                        isfield(ad.data{newDataIdx(end)}.axes.x,'measure'))
                    ad.control.axis.labels.x.measure = ...
                        ad.data{newDataIdx(end)}.axes.x.measure;
                end
                if (isfield(ad.data{newDataIdx(end)}.axes,'x') && ...
                        isfield(ad.data{newDataIdx(end)}.axes.x,'unit'))
                    ad.control.axis.labels.x.unit = ...
                        ad.data{newDataIdx(end)}.axes.x.unit;
                end
                if (isfield(ad.data{newDataIdx(end)}.axes,'y') && ...
                        isfield(ad.data{newDataIdx(end)}.axes.y,'measure'))
                    ad.control.axis.labels.y.measure = ...
                        ad.data{newDataIdx(end)}.axes.y.measure;
                end
                if (isfield(ad.data{newDataIdx(end)}.axes,'y') && ...
                        isfield(ad.data{newDataIdx(end)}.axes.y,'unit'))
                    ad.control.axis.labels.y.unit = ...
                        ad.data{newDataIdx(end)}.axes.y.unit;
                end
                if (isfield(ad.data{newDataIdx(end)}.axes,'z') && ...
                        isfield(ad.data{newDataIdx(end)}.axes.z,'measure'))
                    ad.control.axis.labels.z.measure = ...
                        ad.data{newDataIdx(end)}.axes.z.measure;
                end
                if (isfield(ad.data{newDataIdx(end)}.axes,'z') && ...
                        isfield(ad.data{newDataIdx(end)}.axes.z,'unit'))
                    ad.control.axis.labels.z.unit = ...
                        ad.data{newDataIdx(end)}.axes.z.unit;
                end
            end
            setappdata(mainWindow,'control',ad.control);
        end
    catch exception
        try
            msgStr = ['An exception occurred in ' ...
                exception.stack(1).name  '.'];
            TAmsg(msgStr,'error');
        catch exception2
            exception = addCause(exception2, exception);
            disp(msgStr);
        end
        try
            TAgui_bugreportwindow(exception);
        catch exception3
            % If even displaying the bug report window fails...
            exception = addCause(exception3, exception);
            throw(exception);
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end