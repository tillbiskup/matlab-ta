function datasets = TAsplit(dataset,varargin)
% TASPLIT Split dataset consisting of multiple measurements in separate
% datasets.
%
% Usage:
%   datasets = TAsplit(dataset)
%
%   dataset  - struct
%              TA dataset complying to TA dataset structure
%
%   datasets - cell array (of structs)
%              cell array of TA datasets complying to TA dataset structure
%
% If dataset (the original one) does not contain multiple measurements (or
% at least TAsplit cannot detect it), the unaltered dataset will be
% returned as first and only element of datasets.
%
% NOTE: This is a special case that was originally developed for the
% situation with an Edinburgh Instruments LP900 spectrometer and software
% as new as 2014. It stores several datasets in one ASCII export file
% concatenated along the wavelength axis.

% Copyright (c) 2015, Till Biskup
% 2015-06-01

datasets = cell(0);

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('dataset', @(x)isstruct(x));
    p.parse(dataset,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Find where and if to split
splitPoints = find(dataset.axes.y.values==dataset.axes.y.values(1));
if length(splitPoints) < 2
    datasets{1} = dataset;
    return;
end

datasets = cell(length(splitPoints),1);
lengthYaxis = diff(splitPoints([1,2]));

for spectrum = 1:length(splitPoints)
    datasets{spectrum} = dataset;
    datasets{spectrum}.data = dataset.data(...
        splitPoints(spectrum):splitPoints(spectrum)+lengthYaxis-1,:);
    datasets{spectrum}.axes.y.values = dataset.axes.y.values(...
        splitPoints(spectrum):splitPoints(spectrum)+lengthYaxis-1);
end

end