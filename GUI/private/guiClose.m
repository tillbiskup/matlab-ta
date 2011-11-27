function guiClose()
% GUICLOSE Private function to close GUI and at the same time close all
% subwindows that might still be open.

% (c) 11, Till Biskup
% 2011-11-27

try
    % TODO: Check whether there is anything that is not saved...
    
    % Close all GUI windows currently open
    delete(findobj('-regexp','Tag','TAgui_*'));
    
    % Close GUI
    delete(guiGetWindowHandle);
    
catch exception
    % Hm... that should really not happen.
    disp('Sorry, but there were some problems closing the GUI.');
    disp('Try "delete(handle)" with "handle" corresponding to GUI');
    throw(exception);
end

end