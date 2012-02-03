function platform = platform
%  PLATFORM display general platform dependend information.
%     P = PLATFORM returns the result in a string.

% Copyright (C) 2007 Till Biskup, <till.biskup@fu-berlin.de>
% This file ist free software.
% $Id$

% find platform OS
	
if ( exist('matlabroot') )
	
	if ispc
        platform = [system_dependent('getos'),' ',system_dependent('getwinsys')];
	elseif ( strfind(computer, 'MAC') == 1 )
		[fail, input] = unix('sw_vers');

        if ~fail
            platform = strrep(input, 'ProductName:', '');
			platform = strrep(platform, sprintf('\t'), '');
			platform = strrep(platform, sprintf('\n'), ' ');
			platform = strrep(platform, 'ProductVersion:', ' Version: ');
			platform = strrep(platform, 'BuildVersion:', 'Build: ');
		else
			platform = system_dependent('getos');
		end
	else    
		[fail, input] = unix('uname -srmo');
	    if ~fail
			platform = input;
		else
			platform = system_dependent('getos');
		end		   
	end
else
	if ispc
	   platform = computer();
	elseif findstr('apple', computer)
	    [fail, input] = unix('sw_vers');
	    if ~fail
			platform = strrep(input, 'ProductName:', '');
			platform = strrep(platform, sprintf('\t'), '');
			platform = strrep(platform, sprintf('\n'), ' ');
			platform = strrep(platform, 'ProductVersion:', ' Version: ');
			platform = strrep(platform, 'BuildVersion:', 'Build: ');
		else
			platform = computer();
		end
	else    
		[fail, input] = unix('uname -srmo');
	    if ~fail
			platform = input;
		else
			platform = computer();
		end		   
	end
end

%******
