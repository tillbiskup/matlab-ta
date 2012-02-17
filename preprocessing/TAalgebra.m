function [resdata,warnings] = TAalgebra(data,operation,varargin)
% TAALGEBRA Perform algebraic operation on two given datasets.
%
% Usage
%   data = TAalgebra(data,operation);
%   [data,warnings] = TAalgebra(data,operation);
%
% data       - struct
%              Dataset that should (ideally) contain both MFoff and MFon
%              data
% operation  - string
%              Operation to be performed on the two datasets.
%              Currently only '+' or '-' and the pendants 'add' and
%              'subtract'
%
% data       - struct
%              Dataset resulting from the algebraic operation.
% warnings   - string
%              Empty if everything went well, otherwise contains message.

% (c) 2012, Till Biskup
% 2012-02-17

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('data', @(x)iscell(x));
p.addRequired('operation', @(x)ischar(x));
p.parse(data,operation);

try
    warnings = '';
    resdata = [];
    
    if size(data) ~= 2
        warnings = 'Other than two datasets, therefore no operation done';
        return;
    end

    % Convert operations
    if strfind(lower(operation),'add')
        operation = '+';
    end
    if strfind(lower(operation),'sub')
        operation = '-';
    end
    
    
    % Perform all (temporary) operations such as displacement, scaling,
    % smoothing
    for k=1:length(data)
        if isfield(data{k},'display')
            
            % Displacement
            if isfield(data{k}.display,'displacement')
                if isfield(data{k}.display.displacement,'z')
                    data{k}.data = data{k}.data + ...
                        data{k}.display.displacement.z;
                    if isfield(data{k},'dataMFon')
                        data{k}.dataMFon = data{k}.dataMFon + ...
                            data{k}.display.displacement.z;
                    end
                end
                % TODO: Displacement in x, y
            end
            
            % Scaling
            if isfield(data{k}.display,'scaling')
                if isfield(data{k}.display.scaling,'z')
                    data{k}.data = data{k}.data * ...
                        data{k}.display.scaling.z;
                    if isfield(data{k},'dataMFon')
                        data{k}.dataMFon = data{k}.dataMFon * ...
                            data{k}.display.displacement.z;
                    end
                end
                % TODO: Scaling in x, y
            end
            
            % Smoothing
            if isfield(data{k}.display,'smoothing')
                [dimy,dimx] = size(data{k}.data);
                if isfield(data{k}.display.smoothing,'x') ...
                        && (data{k}.display.smoothing.x.value > 1) ...
                        && isfield(data{k}.display.smoothing.x,'filterfun')
                    filterfun = str2func(data{k}.display.smoothing.x.filterfun);
                    for l=1:dimy
                        data{k}.data(l,:) = filterfun(...
                            data{k}.data(l,:),...
                            data{k}.display.smoothing.x.value);
                    end
                    if isfield(data{k},'dataMFon')
                        for l=1:dimy
                            data{k}.dataMFon(l,:) = filterfun(...
                                data{k}.dataMFon(l,:),...
                                data{k}.display.smoothing.x.value);
                        end
                    end
                end
                if isfield(data{k}.display.smoothing,'y') ...
                        && (data{k}.display.smoothing.y.value > 1) ...
                        && isfield(data{k}.display.smoothing.y,'filterfun')
                    filterfun = str2func(data{k}.display.smoothing.y.filterfun);
                    for l=1:dimx
                        data{k}.data(:,l) = filterfun(...
                            data{k}.data(:,l),...
                            data{k}.display.smoothing.x.value);
                    end
                    if isfield(data{k},'dataMFon')
                        for l=1:dimx
                            data{k}.dataMFon(:,l) = filterfun(...
                                data{k}.dataMFon(:,l),...
                                data{k}.display.smoothing.x.value);
                        end
                    end
                end
            end
        end
    end
    
    % Assign dataset1 to output
    resdata = data{1};
    
    % Perform actual arithmetic functions
    switch operation
        case '+'
            resdata.data = data{1}.data + data{2}.data;
            if isfield(data{1},'dataMFon')
                if isfield(data{2},'dataMFon')
                    resdata.dataMFon = data{1}.dataMFon + data{2}.dataMFon;
                else
                    resdata.dataMFon = data{1}.dataMFon + data{2}.data;
                end
            end
        case '-'
            resdata.data = data{1}.data - data{2}.data;
            if isfield(data{1},'dataMFon')
                if isfield(data{2},'dataMFon')
                    resdata.dataMFon = data{1}.dataMFon - data{2}.dataMFon;
                else
                    resdata.dataMFon = data{1}.dataMFon - data{2}.data;
                end
            end
        otherwise
            warnings = sprintf('Operation "%s" not understood.',operation);
            return;
    end
    
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
    
    % Add parameters
    history.parameters.operation = operation;
    
    % Assign complete accReport to info field of history
    history.info = cell(0);
    history.info{end+1} = sprintf('Primary dataset: %s',data{1}.label);
    history.info{end+1} = sprintf('Secondary dataset: %s',data{2}.label);
    
    % Assign history to dataset of accumulated data
    resdata.history{end+1} = history;
    
catch exception
    throw(exception);
end

end