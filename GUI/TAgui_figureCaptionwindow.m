function varargout = TAgui_figureCaptionwindow(varargin)
% TAGUI_FIGURECAPTIONWINDOW Editor window for creating a figure caption
% and at the same time displaying information for the displayed datasets.
%
% Normally, this window is called from within the TAgui window. 
%
% See also TAGUI

% Copyright (c) 2013, Till Biskup
% 2013-08-17

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make GUI effectively a singleton
singleton = findobj('Tag',mfilename);
if (singleton)
    figure(singleton);
    if nargout
        varargout{1} = singleton;
    end
    return;
end

if nargin
    figureFileName = varargin{1};
    [p,f,~] = fileparts(figureFileName);
    captionFileName = fullfile(p,f);
    clear p f;
else
    figureFileName = '';
    captionFileName = '';
end

% Set file extension for caption file
captionFileExtension = '.txt';

guiPosition = [110,190,850,600];
% Try to get main GUI position
mainGUIHandle = TAguiGetWindowHandle();
if ishandle(mainGUIHandle)
    mainGUIPosition = get(mainGUIHandle,'Position');
    guiPosition = [mainGUIPosition(1)+40,mainGUIPosition(2)+50,...
        guiPosition(3), guiPosition(4)];
else
    disp('No TA GUI main window found. Bye...');
    return;
end

%  Construct the components
hMainFigure = figure('Tag',mfilename,...
    'Visible','off',...
    'Name','TA GUI : Figure Caption',...
    'Units','Pixels',...
    'Position',guiPosition,...
    'Resize','off',...
    'KeyPressFcn',@keypress_Callback,...
    'NumberTitle','off', ...
    'Menu','none','Toolbar','none');

defaultBackground = get(hMainFigure,'Color');
guiSize = get(hMainFigure,'Position');
guiSize = guiSize([3,4]);

uicontrol('Tag','heading_text',...
    'Style','text',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',14,...
    'HorizontalAlignment','Left',...
    'FontWeight','bold',...
    'Units','Pixels',...
    'Position',[10 guiSize(2)-35 guiSize(1)-220 20],...
    'String','TA GUI: Figure Caption'...
    );

p1 = uipanel('Tag','caption_panel',...
    'parent',hMainFigure,...
    'Title','Figure caption',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','on',...
    'Units','pixels',...
    'Position',[10 guiSize(2)-240 guiSize(1)-20 200] ...
    );
caption = uicontrol('Tag','caption_text',...
    'Style','edit',...
    'Parent',p1,...
    'BackgroundColor',[1 1 1],...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'Position',[10 10 guiSize(1)-40 170],...
    'Enable','on',...
    'Max',2,'Min',0,...
    'FontSize',12,...
    'FontName','Monospaced',...
    'String','');

p2 = uipanel('Tag','information_panel',...
    'parent',hMainFigure,...
    'Title','Information known from datasets currently displayed (read-only)',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','on',...
    'Units','pixels',...
    'Position',[10 120 guiSize(1)-20 guiSize(2)-370] ...
    );
uicontrol('Tag','information_text',...
    'Style','edit',...
    'Parent',p2,...
    'BackgroundColor',[.9 .9 .9],...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'Position',[10 10 guiSize(1)-40 guiSize(2)-400],...
    'Enable','inactive',...
    'Max',2,'Min',0,...
    'FontSize',12,...
    'FontName','Monospaced',...
    'String','');

p3 = uipanel('Tag','filename_panel',...
    'parent',hMainFigure,...
    'Title','File basename for figure and caption',...
    'FontUnit','Pixel','Fontsize',12,...
    'BackgroundColor',defaultBackground,...
    'Visible','on',...
    'Units','pixels',...
    'Position',[10 50 guiSize(1)-20 60] ...
    );
uicontrol('Tag','filename_edit',...
    'Style','edit',...
    'Parent',p3,...
    'BackgroundColor',[1 1 1],...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'Position',[10 10 guiSize(1)-50-80 30],...
    'Enable','on',...
    'FontSize',12,...
    'FontName','Monospaced',...
    'String','');
uicontrol('Tag','chfilename_pushbutton',...
    'Style','pushbutton',...
	'Parent', p3, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Change',...
    'TooltipString','Change filename for figure and caption',...
    'pos',[guiSize(1)-30-80 10 80 30],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'chfilename'}...
    );

uicontrol('Tag','help_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'ForegroundColor',[0 0 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'FontWeight','bold',...
    'String','?',...
    'TooltipString','Display help about using this GUI',...
    'pos',[guiSize(1)-10-25 guiSize(2)-10-25 25 25],...
    'Enable','on',...
    'Callback',@TAgui_figureCaption_helpwindow...
    );

uicontrol('Tag','discard_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Discard',...
    'TooltipString','Discard caption and close window.',...
    'pos',[guiSize(1)-190 10 90 30],...
    'Enable','on',...
    'Callback',{@closeGUI,'discard'}...
    );
uicontrol('Tag','save_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Save',...
    'TooltipString','Save caption and close window',...
    'pos',[guiSize(1)-100 10 90 30],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'save'}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    % Store handles in guidata
    guidata(hMainFigure,guihandles);
    
    % Add keypress function to every element that can have one...
    handles = findall(...
        allchild(hMainFigure),'style','pushbutton',...
        '-or','style','togglebutton',...
        '-or','style','edit',...
        '-or','style','text',...
        '-or','style','listbox',...
        '-or','style','checkbox',...
        '-or','style','slider',...
        '-or','style','popupmenu',...
        '-or','style','panel');
    for k=1:length(handles)
        set(handles(k),'KeyPressFcn',@keypress_Callback);
    end

    % Preset edits with directories
    updateWindow();
    
    % Make the GUI visible.
    set(hMainFigure,'Visible','on');
    TAmsg('Figure Caption window opened.','info');
    
    if (nargout == 1)
        varargout{1} = hMainFigure;
    end

    uicontrol(caption);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pushbutton_Callback(~,~,action)
    try
        if isempty(action)
            return;
        end
        
        switch lower(action)
            case 'chfilename'
                % Ask user for file name
                [captionFileName,pathName] = uiputfile(...
                    sprintf('*%s',captionFileExtension),...
                    'Get filename to save figure caption to',...
                    captionFileName);
                % If user aborts process, return
                if captionFileName == 0
                    return;
                end
                % Create filename with full path
                [~,fileName,~] = fileparts(captionFileName);
                captionFileName = fullfile(pathName,fileName);
            case 'save'
                saveCaption();
                closeGUI('','','saved');
                return;
            otherwise
                disp(['Action ' action ' not understood.'])
                return;
        end
        updateWindow();
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

function keypress_Callback(~,evt)
    try
        if isempty(evt.Character) && isempty(evt.Key)
            % In case "Character" is the empty string, i.e. only modifier
            % key was pressed...
            return;
        end
        
        % Get handles of GUI
        gh = guihandles(hMainFigure);
        
        if ~isempty(evt.Modifier)
            if (strcmpi(evt.Modifier{1},'command')) || ...
                    (strcmpi(evt.Modifier{1},'control'))
                switch evt.Key
                    case 's'
                        % Need to change focus *and* add a short pause to
                        % get string, as GUI elements seem terribly slow...
                        uicontrol(gh.save_pushbutton);
                        pause(0.001);
                        pushbutton_Callback('','','save');
                        return;
                    case 'w'
                        closeGUI();
                        return;
                end
            end
        else
            switch evt.Key
                case 'f1'
                    TAgui_figureCaption_helpwindow();
                    return;
                case 'escape'
                    closeGUI();
                    return;
            end                    
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

function closeGUI(~,~,varargin)
    try
        if nargin == 3
            action = varargin{1};
        else
            action = '';
        end
        % Get handles of GUI
        gh = guihandles(hMainFigure);
        
        % Important: Change focus away from text input, otherwise it will
        % not recognise the string as non-empty/changed
        uicontrol(gh.save_pushbutton);
        % Check whether user has entered some text
        if ~isempty(get(gh.caption_text,'String')) && strcmpi(action,'')
            button = questdlg(...
                'Caption was changed and not saved. Save now to file?',...
                'Save caption?','Save','Discard','Save');
            if strcmpi(button,'save')
                saveCaption();
            end
        end

        delete(hMainFigure);
        TAmsg('Figure Caption window closed.','info');
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

function saveCaption()
    try
        % Get handles of GUI
        gh = guihandles(hMainFigure);
        % Get appdata of main GUI
        mainGuiWindow = TAguiGetWindowHandle();
        if (mainGuiWindow)
            admain = getappdata(mainGuiWindow);
            sysinfo = admain.control.system;
        else
            sysinfo = struct();
        end

        if isempty(captionFileName)
            % Ask user for file name
            [captionFileName,pathName] = uiputfile(...
                sprintf('*%s',captionFileExtension),...
                'Get filename to save figure caption to',...
                '');
            % If user aborts process, return
            if captionFileName == 0
                return;
            end
            % Create filename with full path
            captionFileName = fullfile(pathName,captionFileName);
        else
            % Otherwise append file extension to file name
            captionFileName = [captionFileName captionFileExtension];
        end
        % Collect contents for file
        fileContents = cell(0);
        fileContents{end+1,1} = 'GENERAL';
        [~,fn,ext] = fileparts(figureFileName);
        fileContents{end+1,1} = sprintf('Figure file:     %s',[fn ext]);
        fileContents{end+1,1} = sprintf('Date:            %s',datestr(now,31));
        if ~isempty(sysinfo)
            fileContents{end+1,1} = sprintf('Operator:        %s',sysinfo.username);
            fileContents{end+1,1} = sprintf('Platform:        %s',sysinfo.platform);
            fileContents{end+1,1} = sprintf('Matlab version:  %s',sysinfo.matlab);
            fileContents{end+1,1} = sprintf('Toolbox version: %s',sysinfo.TA);
        end
        fileContents{end+1,1} = '';
        fileContents{end+1,1} = 'CAPTION';
        fileContents = [fileContents ; cellstr(get(gh.caption_text,'String'))];
        fileContents{end+1,1} = '';
        fileContents{end+1,1} = 'INFORMATION ABOUT DATASETS';
        fileContents = [fileContents ; get(gh.information_text,'String')];
        % Write contents to text file
        status = textFileWrite(captionFileName,fileContents);
        if ~isempty(status)
            TAmsg(status,'warn');
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

function updateWindow()
    try
        % Get handles of GUI
        gh = guihandles(hMainFigure);
        % Write filename in appropriate edit box
        set(gh.filename_edit,'String',captionFileName);        

        % Get appdata of main GUI
        mainGuiWindow = TAguiGetWindowHandle();
        % If there is no main GUI window, return, otherwise get its appdata
        if ~mainGuiWindow
            return;
        end
        adm = getappdata(mainGuiWindow);
        % If there is no active dataset, return
        if isempty(adm.control.spectra.active) || ...
                ~adm.control.spectra.active
            return;
        end
        infoText = cell(0);
        % Check whether "Show only active" is set or only one active
        % dataset
        if adm.control.axis.onlyActive || ...
                length(adm.control.spectra.visible) == 1
            infoText{end+1,1} = sprintf('No. of datasets: %i',1);
            infoText{end+1,1} = '';
            infoText{end+1,1} = 'DATASET #1';
            infoText{end+1,1} = '';
            % Get info file output for currently active dataset and apply
            % it to the respective edit field
            datasetInfo = TAinfoFileCreate(...
                adm.data{adm.control.spectra.active});
            % Remove info file identification header
            datasetInfo(1:2) = [];
            datasetInfo = ...
                cellfun(@(x)['  ' x],datasetInfo,'UniformOutput',false);
            infoText = [ infoText ; datasetInfo' ];
            set(gh.information_text,'String',infoText);
        else
            infoText = cell(0);
            infoText{end+1,1} = sprintf('No. of datasets: %i',...
                length(adm.control.spectra.visible));
            infoText{end+1,1} = '';
            for idx=1:length(adm.control.spectra.visible)
                infoText{end+1,1} = sprintf('DATASET #%i',idx); %#ok<*AGROW>
                infoText{end+1,1} = '';
                datasetInfo = TAinfoFileCreate(...
                    adm.data{adm.control.spectra.visible(idx)});
                % Remove info file identification header
                datasetInfo(1:2) = [];
                datasetInfo = ...
                    cellfun(@(x)['  ' x],datasetInfo,'UniformOutput',false);
                infoText = [ infoText ; datasetInfo' ]; %#ok<AGROW>
                infoText{end+1,1} = '';
            end
            set(gh.information_text,'String',infoText);
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

end
