function data = TAfilter_boxcar(data,window)
% TREPRFILTER_BOXCAR Filter 1D data with a boxcar filter with given window
% length.
%
%
% Usage
%   data = TAfilter_boxcar(data,window)
%
%   data   - data to filter
%
%   window - filter window width
%

% Copyright (c) 2011-12, Till Biskup
% 2012-01-19

[x,y] = size(data);
if (x == 1) % data is column vector
    filter = ones(1,window)/window;
    % padding data to avoid artefacts
    data = [...
        ones(1,window)*data(1) ...
        data ...
        ones(1,window)*data(end) ...
        ];
elseif (y == 1) % data is row vector
    filter = ones(window,1)/window;
    % padding data to avoid artefacts
    data = [...
        ones(window,1)*data(1); ...
        data; ...
        ones(window,1)*data(end); ...
        ];
end
data = convn(data,filter,'same');
data = data(window+1:1:end-window);

end
