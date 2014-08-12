function status = TAexport2D(dataset,filename,varargin)
% TAEXPORT2D Export dataset as 2D ASCII data.
%
% Usage:
%   TAexport2D(dataset,filename)
%   status = TAexport2D(dataset,filename)
%
%   dataset  - struct
%              Structure in compliance with TA dataset structure
%
%   filename - string
%              Name of file to save the ASCII data to
%
%
% Optional parameters that can be set:
%
%   includeAxes - boolean
%                 Whether to include axes as first row/column
%                 Default: true
%
%   commentChar - string
%                 Comment character used for header lines
%                 Default: "%" (Matlab comment character)
%
%   delimiter   - string
%                 Delimiter used to separate values in export
%                 Default: "\t" (tabulator)
%
%   precision   - string
%                 Precision format string used for dlmwrite
%                 Default: "%.4f"
%
% See also: TAexport1D

% Copyright (c) 2014, Till Biskup
% 2014-08-12

% If called without parameter, display help
if ~nargin && ~nargout
    help TAexport2D
    return;
end

status = '';

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('dataset',@(x)isstruct(x));
    p.addRequired('filename',@(x)ischar(x));
    p.addParamValue('commentChar','%',@(x)ischar(x));
    p.addParamValue('delimiter','\t',@(x)ischar(x));
    p.addParamValue('precision','%.4f',@(x)ischar(x));
    p.addParamValue('includeAxes',true,@(x)islogical(x));
    p.parse(dataset,filename,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

try
    header{1} = ['Label:          ' dataset.label];
    header{2} = ['Date of export: ' datestr(now)];
    % TODO: Add info file as comment header here
    
    % Add comment characters to header
    header = cellfun(@(x){[p.Results.commentChar ' ' x]},header);
    
    % Write header to output file
    dlmwrite(filename,header{1},'delimiter','');
    for headerLines=2:length(header)
        dlmwrite(filename,header{headerLines},'delimiter','','-append');
    end
    
    % Add axes if requested
    if p.Results.includeAxes
        % Write column headers
        dlmwrite (filename,[NaN dataset.axes.y.values],...
            'delimiter',p.Results.delimiter,...
            'precision',p.Results.precision,'-append');
        % Add row headers to data
        matrix(:,1) = dataset.axes.x.values;
        matrix(:,2:size(dataset.data,1)+1) = dataset.data';
        % Write data
    else
        matrix = dataset.data';
    end
    
    % Write data to output file
    dlmwrite(filename,matrix,...
        'delimiter',p.Results.delimiter,...
        'precision',p.Results.precision,'-append');

catch exception
    status = getReport(exception, 'extended', 'hyperlinks', 'off');
    TAexceptionHandling(exception);
end

end