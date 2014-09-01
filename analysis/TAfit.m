function [fit,fval,message] = TAfit(data,parameters)
% TAFIT Calculate FIT over a range of points in dataset with the parameters
% provided in parameters.
%
% data       - struct 
%              dataset to perform the fit for
% parameters - struct
%              parameter structure as collected e.g. by the TAgui_fitwindow
%
% fit        - ...

% Copyright (c) 2012, Till Biskup
% 2012-02-05

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

% p.addRequired('data', @(x)isstruct(x));
% p.addRequired('parameters', @(x)isstruct(x));
% p.parse(data,parameters);

    function stop = outfun(~, optimValues, ~)
        stop = false;
        message{end+1} = sprintf('  %6.0f     %6.0f    %10f  %s',...
            optimValues.iteration,optimValues.funccount,...
            optimValues.fval,optimValues.procedure);
    end
    
    try
        % Assign output parameters
        fit = [];
        fval = [];
        message = {};

        %structdisp(parameters)
        
        % Read config files
        [path,~,~] = fileparts(mfilename('fullpath'));
        fitRoutinesConfigFileName = 'TAfit_fitroutines.ini';
        fitFunctionsConfigFileName = 'TAfit_fitfunctions.ini';
        % Check for availability of configuration files
        % If configuration files don't exist, create them from distributed
        % configuration files.
        if ~exist(fullfile(path,fitRoutinesConfigFileName),'file')
            fprintf('%s\n%s',...
                'Configuration for fit routines doesn''t exist.',...
                'Trying to create...');
            conf = TAiniFileRead(...
                fullfile(path,[fitRoutinesConfigFileName '.dist']),...
                'typeConversion',true);
            header = 'Configuration file for TAfit function of TA toolbox';
            TAiniFileWrite(fullfile(path,fitRoutinesConfigFileName),...
                conf,'header',header,'overwrite',true);
            fprintf(' done\n');
        end
        if ~exist(fullfile(path,fitFunctionsConfigFileName),'file')
            fprintf('%s\n%s',...
                'Configuration for fit functions doesn''t exist.',...
                'Trying to create...');
            conf = TAiniFileRead(...
                fullfile(path,[fitFunctionsConfigFileName '.dist']),...
                'typeConversion',true);
            header = 'Configuration file for TAfit function of TA toolbox';
            TAiniFileWrite(fullfile(path,fitFunctionsConfigFileName),...
                conf,'header',header,'overwrite',true);
            fprintf(' done\n');
        end
        [fitRoutines,warnings] = TAiniFileRead(...
            fullfile(path,fitRoutinesConfigFileName),...
            'typeConversion',true);
        if ~isempty(warnings)
            message = warnings;
            return;
        end
        [fitFunctions,warnings] = TAiniFileRead(...
            fullfile(path,'TAfit_fitfunctions.ini'),...
            'typeConversion',true);
        if ~isempty(warnings)
            message = warnings;
            return;
        end
        
        % Test whether fit routine is known
        fitRoutineNames = fieldnames(fitRoutines);
        if ~any(strcmpi(fitRoutineNames,parameters.fitRoutineName))
            message = sprintf('Fit routine "%s" unknown.',...
                parameters.fitRoutineName);
            return;
        end
        
        % Test whether fit routine does exist in current Matlab
        % installation
        if ~exist(parameters.fitRoutineName,'file')
            message = sprintf('Fit routine "%s" does not exist.',...
                parameters.fitRoutineName);
            return;
        end
        
        % Test whether fit function is known
        fitFunctionNames = structfun(@(x) cellstr(x.name),fitFunctions);
        if ~any(strcmpi(fitFunctionNames,parameters.fitFunName))
            message = sprintf('Fit function "%s" unknown.',...
                parameters.fitFunName);
            return;
        end
        
        fitFunAbbrevs = fieldnames(fitFunctions);
        fitFunAbbrev = fitFunAbbrevs{...
            strcmpi(fitFunctionNames,parameters.fitFunName)};
        
        % Get data vectors for x1 and x
        % Set data dependend on MFE display type
        switch parameters.mfetrace
            case 'MFoff'
                X = data.data;
            case 'MFon'
                X = data.dataMFon;
            case 'DeltaMF'
                X = data.dataMFon-data.data;
            case 'sum(MFoff,MFon)'
                X = (data.dataMFon+data.data)./2;
            otherwise
                message = sprintf('Unknown MFE trace "%s"',...
                    parameters.mfetrace);
                return;
        end
        switch lower(parameters.dimension)
            case 'x'
                x1 = X(...
                    parameters.position,...
                    parameters.area.start:parameters.area.stop);
                x = (1:length(x1));
            case 'y'
                x1 = X(...
                    parameters.area.start:parameters.area.stop,...
                    parameters.position)';
                x = (1:length(x1));
        end
        
        message = cell(0);
        message{end+1} = ...
            '--------------------------------------------------------';
        message{end+1} = 'Output of fit function:';
        message{end+1} = '';
        message{end+1} = ...
            sprintf('Iteration  FuncCount    min f(x)   Procedure');
        
        % Set options for fit routine
        if isfield(parameters,'options')
            fitopt = parameters.options;
        else
            fitopt = fitRoutines.(parameters.fitRoutineName);
        end
        % Handle problems with silly Matlab not accepting nice options
        if ischar(fitopt.MaxFunEvals)
            fitopt.MaxFunEvals = str2num(strrep(...
                fitopt.MaxFunEvals,'numberofvariables',...
                num2str(fitFunctions.(fitFunAbbrev).ncoeff))); %#ok<ST2NM>
        end
        if ischar(fitopt.MaxIter)
            fitopt.MaxIter = str2num(strrep(...
                fitopt.MaxIter,'numberofvariables',...
                num2str(fitFunctions.(fitFunAbbrev).ncoeff))); %#ok<ST2NM>
        end

        % Adjust TolX and TolFun: Normalise with maximum of function value
        fitopt.TolX = fitopt.TolX * max(abs(x1));
        fitopt.TolFun = fitopt.TolFun * max(abs(x1));
        % Set display and outputfun options
        fitopt.Display = 'off';
        fitopt.OutputFcn = @outfun;
        
        % Set coefficients for fit function
        if isfield(parameters,'coeff')
            fitcoeff = parameters.coeff;
        else
            fitcoeff = fitFunctions.(fitFunAbbrev).coeff;
        end

        % Assign fit routine name
        fitRoutine = str2func(parameters.fitRoutineName);
        
        % Create fit function
        fun = str2func(sprintf('@(c,x)%s',...
            fitFunctions.(fitFunAbbrev).function));
        fitfun = @(c)sum((fun(c,x)-x1).^2);
        % Fit function
        [Y,fval,exitflag,output] = fitRoutine(fitfun,fitcoeff,fitopt);
        % Preassign fit matrix
        fit = zeros(length(x1),2);
        switch lower(parameters.dimension)
            case 'x'
                fit(:,1) = data.axes.x.values(...
                    parameters.area.start:parameters.area.stop);
            case 'y'
                fit(:,1) = data.axes.y.values(...
                    parameters.area.start:parameters.area.stop);
        end
        fit(:,2) = fun(Y,x);
        
        % Create message
        message{end+1} = ''; % Empty line
        message{end+1} = 'SUMMARY';
        message{end+1} = sprintf('Algorithm: %s',output.algorithm);
        message{end+1} = sprintf('Number of iterations: %i',output.iterations);
        message{end+1} = sprintf('Number of function evaluations: %i',output.funcCount);
        if (exitflag ~= 1)
            message{end+1} = output.message;
        end

        % Add header to message
        header = cell(0);
        [~,datafname,datafext] = fileparts(data.file.name);
        header{end+1} = sprintf('File: %s%s',datafname,datafext);
        header{end+1} = sprintf('Fit function: "%s"',parameters.fitFunName);
        header{end+1} = '';
        header{end+1} = sprintf('   %s',...
            fitFunctions.(fitFunAbbrev).function);
        header{end+1} = '';
        header{end+1} = 'Coefficients:';
        for k=1:length(Y)
            header{end+1} = sprintf(' c(%i)\t%f',k,Y(k));
        end
        header{end+1} = '';
        
        message = [header message];

    catch exception
        throw(exception);
    end
end
