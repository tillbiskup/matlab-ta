function [data,warnings] = TAsumMFE(data)
% TASUMMFE Add MFon data to MFoff data (and divide by two).
%
% data       - struct
%              Dataset that should (ideally) contain both MFoff and MFon
%              data
%
% data       - struct
%              Dataset with both MFoff and MFon data added together.
% warnings   - string
%              Empty if everything went well, otherwise contains message.

% Copyright (c) 2012, Till Biskup
% 2012-02-17

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('data', @(x)isstruct(x));
p.parse(data);

try
    warnings = '';
    
    if ~isfield(data,'dataMFon')
        warnings = 'No MFon data found. Dataset unaltered';
        return;
    end
    
    data.data = (data.dataMFon+data.data)./2;
    data = rmfield(data,'dataMFon');
    
    % Write history
    history = struct();
    history.date = datestr(now,31);
    history.method = mfilename;
    % Get username of current user
    % In worst case, username is an empty string. So nothing should really
    % rely on it.
    % Windows style
    history.system.username = getenv('UserName');
    % Unix style
    if isempty(history.system.username)
        history.system.username = getenv('USER');
    end
    history.system.platform = platform;
    history.system.matlab = version;
    history.system.TA= TAinfo('version');
    
    % Assign history to dataset of accumulated data
    data.history{end+1} = history;
    
catch exception
    throw(exception);
end

end
