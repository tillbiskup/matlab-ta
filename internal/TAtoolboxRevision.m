% TATOOLBOXREVISION Return TA toolbox revision number and date
%
% Usage
%   TAtoolboxRevision
%   [revision] = TAtoolboxRevision;
%   [revision,date] = TAtoolboxRevision;
%
% revision - string
%            version number of the TA toolbox
% date     - string
%            date of the TA toolbox
%

% (c) 2007-11, Till Biskup
% 2011-09-11

function [ varargout ] = TAtoolboxRevision
	
% This is the place to centrally manage the revision number and date.
%
% THIS VALUES SHOULD ONLY BE CHANGED BY THE OFFICIAL MAINTAINER OF THE
% TOOLBOX! 
%
% If you have questions, call the TAinfo routine at the command prompt and
% contact the maintainer via the email address given there.

TAtoolboxRevisionNumber = '0.0.1';
TAtoolboxRevisionDate = '2011-09-11';

if (nargout == 1)
    % in case the function is called with one output parameter
    
    varargout{1} = TAtoolboxRevisionNumber;
    
elseif (nargout == 2)
    % in case the function is called with two output parameters
    
    varargout{1} = TAtoolboxRevisionNumber;
    varargout{2} = TAtoolboxRevisionDate;
    
else
    % in case the function is called without output parameters
    
    fprintf('%s %s\n',TAtoolboxRevisionNumber,TAtoolboxRevisionDate);
    
end

end