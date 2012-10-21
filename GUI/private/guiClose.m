function guiClose()
% GUICLOSE Private function to close GUI and at the same time close all
% subwindows that might still be open.

% (c) 2011-12, Till Biskup
% 2012-10-21

try
    % Get appdata of main window
    mainWindow = guiGetWindowHandle;
    ad = getappdata(mainWindow);

    % TODO: Check whether there is anything that is not saved...
    if ~isempty(ad.control.spectra.modified)
        answer = questdlg(...
            {'There are modified and still unsaved datasets. Close anyway?'...
            ' '...
            'Note that "Close" means that you loose the changes you made.'...
            ' '...
            'Other options: "Cancel".'},...
            'Warning: Modified Datasets...',...
            'Close','Cancel',...
            'Cancel');
        switch answer
            case 'Close'
            case 'Cancel'
                msgStr = {'Closing GUI aborted by user. ' ...
                    'Reason: Modified and unsaved datasets'};
                TAmsg(msgStr,'info');
                return;
            otherwise
                return;
        end
    end
    
    % Close all GUI windows currently open
    delete(findobj('-regexp','Tag','TAgui_*'));
    delete(findobj('-regexp','Tag','TA_gui_*'));
    
    % Close GUI
    delete(guiGetWindowHandle);
    
catch exception
    % Hm... that should really not happen.
    disp('Sorry, but there were some problems closing the GUI.');
    disp('Try "delete(handle)" with "handle" corresponding to GUI');
    throw(exception);
end

end