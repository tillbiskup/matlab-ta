function guiKeyBindings(src,evt)
% GUIKEYBINDINGS Private function to handle keypress events in the GUI and
% its windows/elements
%
% Arguments:
%     src - handle of calling source
%     evt - actual event, struct with fields "Character", "Modifier", "Key"

% (c) 2011-12, Till Biskup
% 2012-02-09

try
    if isempty(evt.Character) && isempty(evt.Key)
        % In case "Character" is the empty string, i.e. only modifier key
        % was pressed...
        return;
    end
    
    % Get appdata and handles of main window
    mainWindow = guiGetWindowHandle;
    ad = getappdata(mainWindow);
    gh = guihandles(mainWindow);
    
    % Use "src" to distinguish between callers - may be helpful later on
    
    if ~isempty(evt.Modifier)
        if (strcmpi(evt.Modifier{1},'command')) || ...
                (strcmpi(evt.Modifier{1},'control'))
            switch evt.Key
                case 'w'
                    guiClose();
                    return;
                case '1'
                    status = switchMainPanel('Load');
                    if status
                        % Something went wrong...
                        msgStr = 'Something went wrong with switching the panels.';
                        add2status(msgStr);
                    end
                    return;
                case '2'
                    status = switchMainPanel('Datasets');
                    if status
                        % Something went wrong...
                        msgStr = 'Something went wrong with switching the panels.';
                        add2status(msgStr);
                    end
                    return;
                case '3'
                    status = switchMainPanel('Slider');
                    if status
                        % Something went wrong...
                        msgStr = 'Something went wrong with switching the panels.';
                        add2status(msgStr);
                    end
                    return;
                case '4'
                    status = switchMainPanel('Measure');
                    if status
                        % Something went wrong...
                        msgStr = 'Something went wrong with switching the panels.';
                        add2status(msgStr);
                    end
                    return;
                case '5'
                    status = switchMainPanel('Display');
                    if status
                        % Something went wrong...
                        msgStr = 'Something went wrong with switching the panels.';
                        add2status(msgStr);
                    end
                    return;
                case '6'
                    status = switchMainPanel('Processing');
                    if status
                        % Something went wrong...
                        msgStr = 'Something went wrong with switching the panels.';
                        add2status(msgStr);
                    end
                    return;
                case '7'
                    status = switchMainPanel('Analysis');
                    if status
                        % Something went wrong...
                        msgStr = 'Something went wrong with switching the panels.';
                        add2status(msgStr);
                    end
                    return;
                case '8'
                    status = switchMainPanel('MFE');
                    if status
                        % Something went wrong...
                        msgStr = 'Something went wrong with switching the panels.';
                        add2status(msgStr);
                    end
                    return;
                case '9'
                    status = switchMainPanel('Configure');
                    if status
                        % Something went wrong...
                        msgStr = 'Something went wrong with switching the panels.';
                        add2status(msgStr);
                    end
                    return;
                % SWITCH DISPLAY MODE: Ctrl/Cmd+x/y/z
                case 'x'
                    switchDisplayType('1D along x');
                    return;
                case 'y'
                    switchDisplayType('1D along y');
                    return;
                case 'z'
                    switchDisplayType('2D plot');
                    return;
                % Other commands
                case 'i'
                    if ad.control.spectra.active ~= 0
                        TAgui_infowindow();
                    end
                    return;
            end
        end
    end
    switch evt.Key
        case 'f1'
            TAgui_helpwindow();
            return;
        case 'f2'
            TAgui_aboutwindow();
            return;
        case 'f3'
            TAgui_infowindow();
            return;
        case 'f4'
            TAgui_ACCwindow();
            return;
        case 'f5'
            TAgui_AVGwindow();
            return;
        case 'f6'
            TAgui_MFEwindow();
            return;
        case 'f7'
            TAgui_fitwindow();
            return;
        case 'f10'
            TAgui_statuswindow();
            return;
        case 'delete'
            if ~ad.control.spectra.active
                return;
            end
            if src == gh.data_panel_visible_listbox
                if ~isempty(evt.Modifier) && (strcmpi(evt.Modifier{1},'shift'))
                    [status,message] = removeDatasetFromMainGUI(...
                        ad.control.spectra.active,'force',true);
                    if status
                        disp(message);
                    end
                else
                    [status,message] = removeDatasetFromMainGUI(...
                        ad.control.spectra.active);
                    if status
                        disp(message);
                    end
                end
            end
        case 'backspace'
            if ~ad.control.spectra.active
                return;
            end
            if src == gh.data_panel_visible_listbox
                if ~isempty(evt.Modifier) && (strcmpi(evt.Modifier{1},'shift'))
                    [status,message] = removeDatasetFromMainGUI(...
                        ad.control.spectra.active,'force',true);
                    if status
                        disp(message);
                    end
                else
                    [status,message] = removeDatasetFromMainGUI(...
                        ad.control.spectra.active);
                    if status
                        disp(message);
                    end
                end
            end
        otherwise
%             disp(evt);
%             fprintf('       Caller: %i\n\n',src);
            return;
    end
catch exception
    try
        TAgui_bugreportwindow(exception);
    catch exception2
        % If even displaying the bug report window fails...
        exception = addCause(exception2, exception);
        throw(exception);
    end
end


end