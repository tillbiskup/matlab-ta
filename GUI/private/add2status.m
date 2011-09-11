function status = add2status(statusmessage)
% ADD2STATUS Helper function that adds a status message to the status cell 
%   array of the trEPR GUI
%
%   STATUSMESSAGE: string/cell array containing the status message
%
%   STATUS: return value for the exit status
%           -1: no trEPRgui window found
%           -2: trEPRgui window appdata don't contain necessary fields
%            0: successfully updated status

% Is there currently a trEPRgui object?
mainwindow = findobj('Tag','trepr_gui_mainwindow');
if (isempty(mainwindow))
    status = -1;
    return;
end

% Get appdata from mainwindow
ad = getappdata(mainwindow);

% Check for availability of necessary fields in appdata
if (isfield(ad,'control') == 0) || (isfield(ad.control,'status') == 0)
    status = -2;
    return;
end

% Prepend date and time to statusmessage
if ischar(statusmessage)
    statusmessage = sprintf('(%s) %s',datestr(now,31),statusmessage);
elseif iscell(statusmessage)
    statusmessage{1} = ...
        sprintf('(%s) %s',datestr(now,31),statusmessage{1});
    if (length(statusmessage) > 1)
        for k=2:length(statusmessage)
            statusmessage{k} = sprintf(' %s',statusmessage{k});
        end
    end
end

% Append status message to cell array of status messages
ad.control.status = [ ad.control.status statusmessage ];

% Push appdata back to main gui
setappdata(mainwindow,'control',ad.control);

% Update status window
% As MATLAB(TM) had some problems with calling a private function in some
% special context, change the directory to the "private" dir, call the
% function that's located there, and afterwards return to original dir.
PWD = pwd;
cd(fileparts(mfilename('fullpath')));
update_statuswindow(ad.control.status);
cd(PWD);

status = 0;

end