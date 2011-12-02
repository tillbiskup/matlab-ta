function data = trEPRfilter_boxcar(data,window)
% TREPRFILTER_BOXCAR Filter 1D data with a boxcar filter with given window
% length.
%
%
% Usage
%   data = trEPRfilter_boxcar(data,window)
%
%   data   - data to filter
%
%   window - filter window width
%

% (c) 11, Till Biskup
% 2011-11-27

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
