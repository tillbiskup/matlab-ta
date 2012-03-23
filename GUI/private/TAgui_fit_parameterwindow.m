function varargout = TAgui_fit_parameterwindow(varargin)
% TAGUI_FIT_PARAMETERWINDOW Parameter window for the Fit GUI.
%
% Normally, this window is called from within the TAgui_fitwindow window.
%
% See also TAGUI_FITWINDOW

% (c) 2012, Till Biskup
% 2012-03-23

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make GUI effectively a singleton
singleton = findobj('Tag','TAgui_fit_parameterwindow');
if (singleton)
    figure(singleton);
    if nargin
        varargout{1} = varargin{1};
    end
    return;
end

%  Construct the components
hMainFigure = figure('Tag','TAgui_fit_parameterwindow',...
    'Visible','off',...
    'Name','TA GUI : Fit : Parameter Window',...
    'Units','Pixels',...
    'Position',[840,240,350,500],...
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
    'Position',[10 guiSize(2)-35 guiSize(1)-20 20],...
    'String','Fit parameters'...
    );

p1 = uipanel('Tag','fitroutine_panel',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 guiSize(2)-90 guiSize(1)-20 50],...
    'Title','Fit routine'...
    );
uicontrol('Tag','fitroutine_popupmenu',...
    'Style','popupmenu',...
    'Parent',p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 guiSize(1)-40 20],...
    'String','fminsearch|lsqnonneg',...
    'Callback', {@popupmenu_Callback,'fitroutine'}...
    );

p2 = uipanel('Tag','fitparameters_panel',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 guiSize(2)-250 guiSize(1)-20 150],...
    'Title','Fit parameters'...
    );
uitable('Tag','fitparameters_table',...
    'Parent',p2,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 (guiSize(1)-40) 120],...
    'ColumnName', {'Value'},...
    'ColumnFormat',{'numeric'},...
    'ColumnWidth',{guiSize(1)-170},...
    'Data',{ '200*numberofvariables'; '200*numberofvariables'; ...
    '1e-4';  '1e-4'; 'off'},...
    'RowName',{'MaxFunEvals'; 'MaxIter'; 'TolFun'; 'TolX'; 'FunValCheck'},...
    'ColumnEditable', true ,...
    'CellEditCallback',{@tableCellEdit_Callback,'fitparameters'} ...
    );

p3 = uipanel('Tag','fitfunction_panel',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 guiSize(2)-320 guiSize(1)-20 60],...
    'Title','Fit function'...
    );
uicontrol('Tag','fitfunction_edit',...
    'Style','edit',...
    'Parent',p3,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'HorizontalAlignment','left',...
    'Units','Pixels',...
    'Position',[10 10 guiSize(1)-40 25],...
    'String','c(1)*x+c(2)',...
    'Enable','inactive',...
    'Callback',{@edit_Callback,'fitfunction'}...
    );

p4 = uipanel('Tag','coefficients_panel',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 guiSize(2)-450 guiSize(1)-20 120],...
    'Title','Coefficients'...
    );
uitable('Tag','coefficients_table',...
    'Parent',p4,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 (guiSize(1)-40) 90],...
    'ColumnName', {'Initial','Lower','Upper'},...
    'ColumnFormat',{'numeric','numeric','numeric'},...
    'ColumnWidth',{(guiSize(1)-90)/3 (guiSize(1)-90)/3 (guiSize(1)-90)/3},...
    'Data',{1 [] []; 1 [] []; 1 [] []; 1 [] []; 1 [] []; 1 [] []},...
    'RowName',1:6,...
    'ColumnEditable', [true true true],...
    'CellEditCallback',{@tableCellEdit_Callback,'coefficients'}...
    );

uicontrol('Tag','help_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'ForegroundColor',[0 0 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'FontWeight','bold',...
    'String','?',...
    'TooltipString','Display help for how to operate the fit GUI',...
    'pos',[10 12 25 25],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'Help'}...
    );

uicontrol('Tag','defaults_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Apply',...
    'TooltipString','Close fit GUI Help window',...
    'pos',[guiSize(1)-190 10 60 30],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'Apply'}...
    );
uicontrol('Tag','defaults_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Reset',...
    'TooltipString','Close fit GUI Help window',...
    'pos',[guiSize(1)-130 10 60 30],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'Reset'}...
    );
uicontrol('Tag','close_pushbutton',...
    'Style','pushbutton',...
	'Parent', hMainFigure, ...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'String','Close',...
    'TooltipString','Close fit GUI Help window',...
    'pos',[guiSize(1)-70 10 60 30],...
    'Enable','on',...
    'Callback',{@pushbutton_Callback,'Close'}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    % Store handles in guidata
    guidata(hMainFigure,guihandles);
    
    % Set fit structure
    ad.fit = struct();
    if nargin && isstruct(varargin{1})
        ad.fit = varargin{1};
    end
    setappdata(hMainFigure,'fit',ad.fit);
    
    % Set fitRoutine popup menu
    gh = guihandles(hMainFigure);
    set(gh.fitroutine_popupmenu,'String',fieldnames(ad.fit.fitRoutines));
    
    updatePanels();
    
    % Make the GUI visible.
    set(hMainFigure,'Visible','on');
    
    guidata(hMainFigure,guihandles);
    if (nargout == 1)
        if nargin
            varargout{1} = ad.fit;
        else
            varargout{1} = hMainFigure;
        end
    end

    % Important for the return parameter. Otherwise Matlab will throw
    % errors or at least not update the return parameter accordingly.
    uiwait;
catch exception
    try
        msgStr = ['An exception occurred. '...
            'The bug reporter should have been opened'];
        add2status(msgStr);
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
        mainWindow = guiGetWindowHandle(mfilename);
        ad = getappdata(mainWindow);
        switch lower(action)
            case 'help'
                TAgui_fit_helpwindow('parameters');
                return;
            case 'apply'
                % Apply ad.fit to main Fit GUI
                setappdata(guiGetWindowHandle('TAgui_fitwindow'),...
                    'fit',ad.fit);
                return;
            case 'reset'
                if isfield(ad.fit,'options')
                    ad.fit = rmfield(ad.fit,'options');
                end
                if isfield(ad.fit,'coeff')
                    ad.fit = rmfield(ad.fit,'coeff');
                end
                if isfield(ad.fit,'bounds')
                    ad.fit = rmfield(ad.fit,'bounds');
                end
                setappdata(mainWindow,'fit',ad.fit);
                updatePanels();
                return;
            case 'close'
                delete(hMainFigure);
                varargout{1} = ad.fit;
            otherwise
                fprintf('%s : %s\n  Unknown action "%s"\n',...
                    mfilename,'pushbutton_Callback()',action);
                return;
        end
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
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

function popupmenu_Callback(source,~,action)
    try
        if isempty(action)
            return;
        end
        
        % Get appdata of main window
        mainWindow = guiGetWindowHandle(mfilename);
        ad = getappdata(mainWindow);
        
        % Get handles of main window
        gh = guihandles(mainWindow);
        
        values = cellstr(get(source,'String'));
        value = values{get(source,'Value')};
        
        switch lower(action)
            case 'fitroutine'
                ad.fit.fitRoutine = value;
                setappdata(mainWindow,'fit',ad.fit);
                updatePanels();
            otherwise
                disp('Unknown popupmenu')
                disp(action);
        end

    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
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

function tableCellEdit_Callback(~,eventdata,action)
    try
        if isempty(action)
            return;
        end
        
        % Get appdata of main window
        mainWindow = guiGetWindowHandle(mfilename);
        ad = getappdata(mainWindow);
        
        % Get handles of main window
        gh = guihandles(mainWindow);
        
        % If an error occurred, return
        if eventdata.Error
            updatePanels();
            return;
        end
        
        %eventdata
        
        switch lower(action)
            case 'fitparameters'
                paramNames = ...
                    fieldnames(ad.fit.fitRoutines.(ad.fit.fitRoutine));
                paramName = paramNames{eventdata.Indices(1)};
                % In case this is the first change of options, copy
                % complete defaults to options structure to preserve
                % non-standard settings from config file
                % NOTE: That might not be necessary in terms of optimset
                %       and its syntax opt = optimset(old,new) - but it is
                %       clearly convenient for internal purposes of the Fit
                %       GUI.
                if ~isfield(ad.fit,'options')
                    ad.fit.options = ad.fit.fitRoutines.(ad.fit.fitRoutine);
                end
                if isnumeric(ad.fit.fitRoutines.(ad.fit.fitRoutine).(paramName))
                    ad.fit.options.(paramName) = ...
                        str2num(strrep(eventdata.NewData,',','.')); %#ok<ST2NM>
                else
                    ad.fit.options.(paramName) = eventdata.NewData;
                end
                setappdata(mainWindow,'fit',ad.fit);
            case 'coefficients'
                fitFunctionNames = ...
                    structfun(@(x) cellstr(x.name),ad.fit.fitFunctions);
                fitFunAbbrevs = fieldnames(ad.fit.fitFunctions);
                fitFunAbbrev = fitFunAbbrevs{...
                    strcmpi(fitFunctionNames,ad.fit.fitFunction)};
                eventdata.NewData = ...
                    str2num(strrep(eventdata.NewData,',','.')); %#ok<ST2NM>
                switch num2str(eventdata.Indices(2))
                    case '1'
                        if ~isfield(ad.fit,'coeff')
                            ad.fit.coeff = ...
                                ad.fit.fitFunctions.(fitFunAbbrev).coeff;
                        end
                        ad.fit.coeff(eventdata.Indices(1)) = ...
                            eventdata.NewData;
                    case '2'
                        if ~isfield(ad.fit,'bounds')
                            ad.fit.bounds = ...
                                ad.fit.fitFunctions.(fitFunAbbrev).bounds;
                        end
                        if isempty(ad.fit.bounds.lower)
                            ad.fit.bounds.lower = zeros(1,...
                                ad.fit.fitFunctions.(fitFunAbbrev).ncoeff);
                        end
                        if isempty(ad.fit.bounds.upper)
                            ad.fit.bounds.upper = zeros(1,...
                                ad.fit.fitFunctions.(fitFunAbbrev).ncoeff);
                        end
                        ad.fit.bounds.lower(eventdata.Indices(1)) = ...
                            eventdata.NewData;
                    case '3'
                        if ~isfield(ad.fit,'bounds')
                            ad.fit.bounds = ...
                                ad.fit.fitFunctions.(fitFunAbbrev).bounds;
                        end
                        if isempty(ad.fit.bounds.upper)
                            ad.fit.bounds.upper = zeros(1,...
                                ad.fit.fitFunctions.(fitFunAbbrev).ncoeff);
                        end
                        if isempty(ad.fit.bounds.lower)
                            ad.fit.bounds.lower = zeros(1,...
                                ad.fit.fitFunctions.(fitFunAbbrev).ncoeff);
                        end
                        ad.fit.bounds.upper(eventdata.Indices(1)) = ...
                            eventdata.NewData;
                end
                setappdata(mainWindow,'fit',ad.fit);
            otherwise
                disp('Unknown popupmenu')
                disp(action);
        end
        setappdata(mainWindow,'fit',ad.fit);
        updatePanels();
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
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
            % In case "Character" is the empty string, i.e. only modifier key
            % was pressed...
            return;
        end
        if ~isempty(evt.Modifier)
            if (strcmpi(evt.Modifier{1},'command')) || ...
                    (strcmpi(evt.Modifier{1},'control'))
                switch evt.Key
                    case 'w'
                        delete(hMainFigure);
                        return;
                end
            end
        end
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
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

function updatePanels()
    try
        % Get appdata and handles
        mainWindow = guiGetWindowHandle(mfilename);
        ad = getappdata(mainWindow);
        gh = guihandles(mainWindow);
        
        % Set fit routine popupmenu
        fitRoutineNames = fieldnames(ad.fit.fitRoutines);
        set(gh.fitroutine_popupmenu,'Value',...
            find(strcmpi(ad.fit.fitRoutine,fitRoutineNames)));
        
        % Set fit parameters table
        fitParameterNames = fieldnames(...
            ad.fit.fitRoutines.(ad.fit.fitRoutine));
        if ~isfield(ad.fit,'options')
            fitParameters = structfun(@(x) cellstr(num2str(x)),...
                ad.fit.fitRoutines.(ad.fit.fitRoutine));
        else
            fitParameters = structfun(@(x) cellstr(num2str(x)),...
                ad.fit.options);
        end
        set(gh.fitparameters_table,'Data',fitParameters);
        set(gh.fitparameters_table,'RowName',fitParameterNames);
        
        % Set fit function display
        fitFunctionNames = ...
            structfun(@(x) cellstr(x.name),ad.fit.fitFunctions);
        fitFunAbbrevs = fieldnames(ad.fit.fitFunctions);
        fitFunAbbrev = fitFunAbbrevs{...
            strcmpi(fitFunctionNames,ad.fit.fitFunction)};
        set(gh.fitfunction_edit,'String',...
            ad.fit.fitFunctions.(fitFunAbbrev).function);
        
        % Set coefficients table
        coeffs = cell(ad.fit.fitFunctions.(fitFunAbbrev).ncoeff,3);
        if ~isfield(ad.fit,'coeff')
            coeffs(:,1) = num2cell(...
                reshape(ad.fit.fitFunctions.(fitFunAbbrev).coeff,...
                ad.fit.fitFunctions.(fitFunAbbrev).ncoeff,1));
        else
            coeffs(:,1) = num2cell(reshape(ad.fit.coeff,...
                ad.fit.fitFunctions.(fitFunAbbrev).ncoeff,1));
        end
        if length(ad.fit.fitFunctions.(fitFunAbbrev).bounds.lower) == ...
                ad.fit.fitFunctions.(fitFunAbbrev).ncoeff
            coeffs(:,2) = num2cell(...
                reshape(ad.fit.fitFunctions.(fitFunAbbrev).bounds.lower,...
                ad.fit.fitFunctions.(fitFunAbbrev).ncoeff,1));
        end
        if length(ad.fit.fitFunctions.(fitFunAbbrev).bounds.lower) == ...
                ad.fit.fitFunctions.(fitFunAbbrev).ncoeff
            coeffs(:,3) = num2cell(...
                reshape(ad.fit.fitFunctions.(fitFunAbbrev).bounds.lower,...
                ad.fit.fitFunctions.(fitFunAbbrev).ncoeff,1));
        end
        if isfield(ad.fit,'bounds')
            coeffs(:,2) = num2cell(reshape(ad.fit.bounds.lower,...
                ad.fit.fitFunctions.(fitFunAbbrev).ncoeff,1));
            coeffs(:,3) = num2cell(reshape(ad.fit.bounds.upper,...
                ad.fit.fitFunctions.(fitFunAbbrev).ncoeff,1))';
        end
        set(gh.coefficients_table,'Data',coeffs);
        set(gh.coefficients_table,'RowName',...
            1:ad.fit.fitFunctions.(fitFunAbbrev).ncoeff);
        
    catch exception
        try
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
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
