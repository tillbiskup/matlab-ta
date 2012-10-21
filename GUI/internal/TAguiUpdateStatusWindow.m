function status = TAguiUpdateStatusWindow(statusmessages)
% TAGUIUPDATESTATUSWINDOW Helper function that updates the status window
%   of the TA GUI, namely TAgui_statuswindow.
%
%   STATUSMESSAGES: cell array containing the complete status messages
%
%   STATUS: return value for the exit status
%           -1: no tEPRgui_statuswindow found
%            0: successfully updated status window
%
%   Using the findjobj function from Y. Altman, it ensures that always
%   the last (i.e., most current) line of the status window is visible.

% (c) 2011-12, Till Biskup
% 2012-10-21

% Is there currently a TAgui_statuswindow object?
statuswindow = TAguiGetWindowHandle('TAgui_statuswindow');
if (isempty(statuswindow))
    status = -1;
    return;
end

% Get handle for textdisplay
handles = guidata(statuswindow);
textdisplay = handles.status_text;

% Update status display
set(textdisplay,'String',statusmessages);

% Display always the last (i.e., most current) line
% uses findjobj from Yair Altman
% Get the underlying Java control peer (a scroll-pane object)
PWD = pwd;
cd(fileparts(mfilename('fullpath')));
jhEdit = findjobj(textdisplay);
cd(PWD);
% Get the scroll-pane's internal edit control
jEdit = jhEdit.getComponent(0).getComponent(0);
% Now move the caret position to the end of the text
jEdit.setCaretPosition(jEdit.getDocument.getLength);

status = 0;

end