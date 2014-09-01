function mfe = TAMFE(data,parameters)
% TAMFE Calculate MFE over a range of points in dataset with the parameters
% provided in parameters.
%
% data       - struct 
%              dataset to perform the averaging for
% parameters - struct
%              parameter structure as collected by the TAgui_MFEwindow
%              start     - scalar
%                          position in axis to start the averaging at
%              stop      - scalar
%                          position in axis to end the averaging at
%
% mfe        - structure
%              contains the parameters from calculating the MFE for each
%              wavelength
%              fields: mfe, stdev

% Copyright (c) 2012, Till Biskup
% 2012-01-29

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('data', @(x)isstruct(x));
p.addRequired('parameters', @(x)isstruct(x));
p.parse(data,parameters);

try
    % Assign output parameter
    mfe = struct();

    % Check for required fields in data
    if ~isfield(data,'data') || ~isfield(data,'dataMFon') || ...
            ~isnumeric(data.data) || ~isnumeric(data.dataMFon)
        disp('Dataset has not the correct format for calculating MFE.');
        return;
    end
    % Calculate MFE...
    [y,x] = size(data.data);
    mfe.mfe = zeros(y,1);
    mfe.stdev = zeros(y,1);
    mfe.report = {};
    for k=1:y
        deltaMF = (data.dataMFon(k,parameters.start:parameters.stop)-...
            data.data(k,parameters.start:parameters.stop));
        MFoff = data.data(k,parameters.start:parameters.stop);
        % Multiply with sign(mean(MFoff)) rather than applying abs to MFoff
        % to prevent noisy data from getting distorted (noisy being too
        % close to zero, already with the MFoff trace).
        mfe.mfe(k) = mean(deltaMF./MFoff)*sign(mean(MFoff));
        mfe.stdev(k) = std(deltaMF./MFoff);
        mfe.report{end+1} = sprintf('Wavelength: %i %s',...
            data.axes.y.values(k),data.axes.y.unit);
        mfe.report{end+1} = '';
        mfe.report{end+1} = sprintf('MFE:  %+6.4f +/- %6.4f',...
            mfe.mfe(k),mfe.stdev(k));
        mfe.report{end+1} = sprintf('Area: %s - %s %s',...
            num2str(data.axes.x.values(parameters.start)),...
            num2str(data.axes.x.values(parameters.stop)),...
            data.axes.x.unit);
        mfe.report{end+1} = sprintf('      (%s %s)',...
            num2str(data.axes.x.values(parameters.stop)-...
            data.axes.x.values(parameters.start)),...
            data.axes.x.unit);
        mfe.report{end+1} = sprintf('      %i points',...
            parameters.delta);
        mfe.report{end+1} = '';
    end
    
catch exception
    throw(exception);
end

end
