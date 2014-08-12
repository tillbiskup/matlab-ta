function TAexceptionHandling(exception)
% TAEXCEPTIONHANDLING Helper function for GUI handling exception in
% try-catch construct.
%
% Usage:
%   TAexceptionHandling(exception)
%
%   exception - MException object
%               exception catched by "catch" statement
%
% Example:
%   try
%       % some code...
%   catch exception
%       TAexceptionHandling(exception);
%   end
%
% See also: TAgui_bugreportwindow, TAmsg, MException

% Copyright (c) 2014, Till Biskup
% 2014-08-12

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
