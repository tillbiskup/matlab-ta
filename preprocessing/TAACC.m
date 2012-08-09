function [accData,accReport] = TAACC(data,parameters)
% TAACC Accumulate datasets given as a cell array in data with the
% parameters provided in parameters.
%
% data       - cell array 
%              datasets to accumulate (at least two datasets)
% parameters - structure
%              parameter structure as collected by the TAgui_ACCwindow
%
% accData    - structure
%              contains both the accumulated data (in accData.data)
%              and all usual parameters of a dataset and the parameters
%              from the accumulation in the history.parameters field
% accReport  - cell array of strings
%              textual report of the accumulation process
%              used for the TAgui_ACCwindow
%              a copy is copied to the history.info field

% (c) 2011-12, Till Biskup
% 2012-08-09

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('data', @(x)iscell(x));
p.addRequired('parameters', @(x)isstruct(x));
p.parse(data,parameters);

try
    if (length(data) < 2)
        accData = [];
        accReport = {...
            'Accumulation FAILED!'...
            ' '...
            'PROBLEM:  Too few datasets.'...
            'SOLUTION: Try to accumulate at least two datasets.'...
            };
        return;
    end
    
    % Assign masterId, i.e. the position of the master dataset in the list
    % of datasets instead of the index corresponding to the total number of 
    % datasets 
    masterId = find(parameters.datasets==parameters.master);
    
    % First step: Check whether axes overlap, and if not, return with error
    % Get axes limits (and other things, minimising for loops) for datasets
    xMin = zeros(1,length(data));
    xMax = zeros(1,length(data));
    yMin = zeros(1,length(data));
    yMax = zeros(1,length(data));
    xStep = zeros(1,length(data));
    yStep = zeros(1,length(data));
    accLabels = cell(1,length(data));
    interpolate = false;
    for k=1:length(data)
        xMin(k) = data{k}.axes.x.values(1);
        xMax(k) = data{k}.axes.x.values(end);
        yMin(k) = data{k}.axes.y.values(1);
        yMax(k) = data{k}.axes.y.values(end);
        [y,x] = size(data{k}.data);
        if x > 1
            xStep(k) = ...
                data{k}.axes.x.values(end)-data{k}.axes.x.values(end-1);
        else
            xStep(k) = 0;
        end
        if y > 1
            yStep(k) = data{k}.axes.y.values(2)-data{k}.axes.y.values(1);
        else
            yStep(k) = 0;
        end
        % Helping Matlab not making silly rounding mistakes, or at least
        % make them somewhat equal
        xStep(k) = round(xStep(k)*1e12)/1e12;
        yStep(k) = round(yStep(k)*1e12)/1e12;
        accLabels{k} = data{k}.label;
        if (k ~= parameters.master) && ...
                ((min(ismember(data{k}.axes.x.values,...
                data{masterId}.axes.x.values)==0)) || ...
                (min(ismember(data{k}.axes.y.values,...
                data{masterId}.axes.y.values)==0)))
            interpolate = true;
        end
    end
        
    if ((max(xMin) > min(xMax)) || (max(yMin) > min(yMax)))
        accData = [];
        accReport = {...
            'Accumulation FAILED!'...
            ' '...
            'PROBLEM:  Axes not overlapping.'...
            'SOLUTION: Check axis dimensions of datasets involved.'...
            };
        return;
    end

    % Predefine fields for accData
    accData = TAdataStructure;
    % label - string
    accData.label = parameters.label;
    
    % Additional fields for dataset in GUI
    addFields = TAguiDataStructure('datastructure');
    addFieldsNames = fieldnames(addFields);
    for k=1:length(addFieldsNames)
        accData.(addFieldsNames{k}) = addFields.(addFieldsNames{k});
    end

    % Set fields that can be taken from master dataset
    accData.line = data{masterId}.line;
    accData.parameters = data{masterId}.parameters;
    if isfield(data{masterId},'display')
        accData.display = data{masterId}.display;
    end
    
    fprintf('\n%s: l. 120\n',mfilename);

    % Handle sample parameters
    sampleFieldNames = fieldnames(accData.sample);
    for k=1:length(sampleFieldNames)
        if isempty(data{masterId}.sample.(sampleFieldNames{k}))
            accData.sample.(sampleFieldNames{k}) = ...
                data{masterId}.sample.(sampleFieldNames{k});
        elseif sum(strcmpi(data{masterId}.sample.(sampleFieldNames{k}),...
                cellfun(@(x)x.sample.(sampleFieldNames{k}),...
                data,'UniformOutput',false))) == length(data)
            accData.sample.(sampleFieldNames{k}) = ...
                data{masterId}.sample.(sampleFieldNames{k});
        else
            accData.sample.(sampleFieldNames{k}) = 'N/A';
        end
    end
        
    % Check for axes steppings and handle interpolation accordingly.
    if ((min(xStep) ~= max(xStep)) || (min(yStep) ~= max(yStep))) || ...
            interpolate
        % If no interpolation method is set, default is linear
        if strcmp(parameters.interpolation,'none')
            parameters.interpolation = 'linear';
        end
        
        % Step 1: Define size of master dataset to be used for accumulation
        % Use 1D table lookup to do so
        
        % x axis
        if xMin(masterId) < max(xMin)
            xLimits(1) = interp1(...
                data{masterId}.axes.x.values,...
                data{masterId}.axes.x.values,...
                max(xMin),...
                'nearest');
            % Account for the situation of linear interpolation and limits
            % of the master dataset that are still larger than one or more
            % of the other datasets (produces NaN otherwise).
            if strcmp(parameters.interpolation,'linear') && ...
                    (xLimits(1) < max(xMin))
                xLimits(1) = xLimits(1) + xStep(masterId);
            end
        else
            xLimits(1) = xMin(masterId);
        end
        if xMax(masterId) > min(xMax)
            xLimits(2) = interp1(...
                data{masterId}.axes.x.values,...
                data{masterId}.axes.x.values,...
                min(xMax),...
                'nearest');
            % Account for the situation of linear interpolation and limits
            % of the master dataset that are still larger than one or more
            % of the other datasets (produces NaN otherwise).
            if strcmp(parameters.interpolation,'linear') && ...
                    (xLimits(2) > min(xMax))
                xLimits(2) = xLimits(2) - xStep(masterId);
            end
        else
            xLimits(2) = xMax(masterId);
        end
        % y axis
        if yMin(masterId) < max(yMin)
            yLimits(1) = interp1(...
                data{masterId}.axes.y.values,...
                data{masterId}.axes.y.values,...
                max(yMin),...
                'nearest');
            % Account for the situation of linear interpolation and limits
            % of the master dataset that are still larger than one or more
            % of the other datasets (produces NaN otherwise).
            if strcmp(parameters.interpolation,'linear') && ...
                    (yLimits(1) < max(yMin))
                yLimits(1) = yLimits(1) + yStep(masterId);
            end
        else
            yLimits(1) = yMin(masterId);
        end
        if yMax(masterId) > min(yMax)
            yLimits(2) = interp1(...
                data{masterId}.axes.y.values,...
                data{masterId}.axes.y.values,...
                min(yMax),...
                'nearest');
            % Account for the situation of linear interpolation and limits
            % of the master dataset that are still larger than one or more
            % of the other datasets (produces NaN otherwise).
            if strcmp(parameters.interpolation,'linear') && ...
                    (yLimits(2) > min(yMax))
                yLimits(2) = yLimits(2) - yStep(masterId);
            end
        else
            yLimits(2) = yMax(masterId);
        end
    else
        % Cut data dimensions to respective size
        % TODO: Account for master dataset
        xLimits = [ max(xMin) min(xMax) ];
        yLimits = [ max(yMin) min(yMax) ];
    end

    % Make axes of final accumulated dataset
    accData.axes.x.values = linspace(xLimits(1),xLimits(2),...
        int32((xLimits(2)-xLimits(1))/xStep(1))+1);
    accData.axes.x.measure = ...
        data{masterId}.axes.x.measure;
    accData.axes.x.unit = ...
        data{masterId}.axes.x.unit;
    accData.axes.y.values = linspace(yLimits(1),yLimits(2),...
        int32((yLimits(2)-yLimits(1))/yStep(1))+1);
    accData.axes.y.measure = ...
        data{masterId}.axes.y.measure;
    accData.axes.y.unit = ...
        data{masterId}.axes.y.unit;
    
    % Preallocate accData.data space 
    % (Here, make it a 3D matrix. Makes life much more easy for summing)
    accData.data = zeros(...
        length(accData.axes.y.values),...
        length(accData.axes.x.values),...
        length(data));
    
    if isfield(data{masterId},'dataMFon')
        accData.dataMFon = accData.data;
    end
    
    % Check for axes steppings and handle interpolation accordingly, or,
    % for the time being, complain that interpolation is not supported yet.
    if ((min(xStep) ~= max(xStep)) || (min(yStep) ~= max(yStep))) || ...
            interpolate
        % Step 2: Perform 2D interpolation
        % ZI = interp2(X,Y,Z,XI,YI,method)
        % X and Y must be monotonic, and have the same format ("plaid") as
        % if they were produced by meshgrid. 
        % Matrices X and Y must be the same size as Z.
        %
        % [X,Y] = meshgrid(x,y)        
        [mXgrid,mYgrid] = meshgrid(...
            data{masterId}.axes.x.values(...
            find(data{masterId}.axes.x.values==xLimits(1)):...
            find(data{masterId}.axes.x.values==xLimits(2))),...
            data{masterId}.axes.y.values(...
            find(data{masterId}.axes.y.values==yLimits(1)):...
            find(data{masterId}.axes.y.values==yLimits(2))));
        accData.data(:,:,masterId) = ...
            data{masterId}.data(...
            find(data{masterId}.axes.y.values==yLimits(1)):...
            find(data{masterId}.axes.y.values==yLimits(2)),...
            find(data{masterId}.axes.x.values==xLimits(1)):...
            find(data{masterId}.axes.x.values==xLimits(2)));
        if isfield(data{masterId},'dataMFon')
            accData.dataMFon = accData.data;
        end
        size(accData.data(:,:,masterId))
        for k=1:length(data)
            if k ~= masterId
                [xgrid,ygrid] = meshgrid(...
                    data{k}.axes.x.values,...
                    data{k}.axes.y.values);
                accData.data(:,:,k) = interp2(...
                    xgrid,...
                    ygrid,...
                    data{k}.data,...
                    mXgrid,...
                    mYgrid,...
                    parameters.interpolation);
                if isfield(data{masterId},'dataMFon')
                    accData.dataMFon(:,:,k) = interp2(...
                        xgrid,...
                        ygrid,...
                        data{k}.dataMFon,...
                        mXgrid,...
                        mYgrid,...
                        parameters.interpolation);
                end
            end
        end
    else
        for k=1:length(data)
            % For now, make it easy, first get the indices, then cut the
            % matrix 
            xmini = find(data{k}.axes.x.values==xLimits(1));
            xmaxi = find(data{k}.axes.x.values==xLimits(2));
            ymini = find(data{k}.axes.y.values==yLimits(1));
            ymaxi = find(data{k}.axes.y.values==yLimits(2));
            accData.data(:,:,k) = data{k}.data(ymini:ymaxi,xmini:xmaxi);
            if isfield(data{masterId},'dataMFon')
                accData.dataMFon(:,:,k) = ...
                    data{k}.dataMFon(ymini:ymaxi,xmini:xmaxi);
            end
        end
    end
    
    switch parameters.method
        case 'cumulative'
            accData.data = sum(accData.data,3)/length(data);
            if isfield(data{masterId},'dataMFon')                
                accData.dataMFon = sum(accData.dataMFon,3)/length(data);
            end
            % Handle number of averages
            accData.parameters.recorder.averages = ...
                sum(cellfun(@(x)x.parameters.recorder.averages,data));
        case 'weighted'
            accData = [];
            accReport = {...
                'Accumulation FAILED!'...
                ' '...
                'PROBLEM:  Accumulation method "weighted" not supported yet.'...
                'SOLUTION: File bug report (see bug #32).'...
                };
            return;
        otherwise
            accData = [];
            accReport = {...
                'Accumulation FAILED!'...
                ' '...
                sprintf('PROBLEM:  Unknown accumulation method "%s".',...
                parameters.method)...
                'SOLUTION: File bug report.'...
                };
            return;
    end
    
    % Tell user that accumulation succeeded and (finally) give details
    % accReport will end in being a cell array
    % The maximum line length for accReport is 56 characters (in Linux)
    accReport = {...
        sprintf('Accumulation of %i datasets successful',length(data))...
        ' '...
        'Label for accumulated dataset:'...
        parameters.label...
        };
    accReport = [...
        accReport ...
        {...
        ' '...
        'The following datasets have been accumulated:'...
        }...
        accLabels ...
        {...
        ' '...
        'Master dataset:'...
        data{masterId}.label...
        ' '...
        'Dimensions of accumulated dataset:'...
        sprintf('size (x,y): %i x %i',fliplr(size(accData.data)))...
        sprintf('x axis:     %s : %s : %s',...
        num2str(xLimits(1)),num2str(xStep(1)),num2str(xLimits(2)))...
        sprintf('y axis:     %s : %s : %s',...
        num2str(yLimits(1)),num2str(yStep(1)),num2str(yLimits(2)))...
        ' '...
        sprintf('Accumulation method: %s',parameters.method)...
        }...
        ];
    if (strcmpi(parameters.method,'weighted'))
        accReport = [...
            accReport ...
            {...
            ' '...
            'Weights '...
            }...
            ];
    end
    % In case interpolation was set but not used
    if ~interpolate
        parameters.interpolation = 'none';
    end
    accReport = [...
        accReport ...
        {...
        ' '...
        sprintf('Interpolation method: %s',parameters.interpolation)...
        }...
        ];
        
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
    history.system.TA = TAinfo('version');
    
    
    % Fiddle around with parameters structure, as it gets to hold all
    % information about the accumulated datasets as well
    history.parameters = parameters;
    history.parameters = rmfield(history.parameters,'datasets');
    for k=1:length(data)
        % Assemble structure that holds all necessary information about the
        % accumulated datasets
        history.parameters.datasets{k}.axes = data{k}.axes;
        history.parameters.datasets{k}.label = data{k}.label;
        history.parameters.datasets{k}.filename = data{k}.file.name;
        history.parameters.datasets{k}.header = data{k}.header;
        history.parameters.datasets{k}.history = data{k}.history;
    end
    
    % Assign complete accReport to info field of history
    history.info = accReport;
    
    % Assign history to dataset of accumulated data
    accData.history{end+1} = history;
    
catch exception
    throw(exception);
end

end