function [fit,fval,message] = TAfit(data,fitFunType,ignorefirstn)
% TAFIT Calculate FIT over a range of points in dataset with the parameters
% provided in parameters.
%
% data       - struct 
%              dataset to perform the fit for
% parameters - struct
%              parameter structure as collected e.g. by the TAgui_fitwindow
%
% fit        - ...

% (c) 2012, Till Biskup
% 2012-02-02

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

% p.addRequired('data', @(x)isstruct(x));
% p.addRequired('parameters', @(x)isstruct(x));
% p.parse(data,parameters);

    function stop = outfun(x, optimValues, state)
        stop = false;
        message{end+1} = sprintf('  %6.0f     %6.0f    %10f  %s',...
            optimValues.iteration,optimValues.funccount,...
            optimValues.fval,optimValues.procedure);
    end
    
    try
        mainWindow = guiGetWindowHandle(mfilename);
        % Get appdata from fit GUI
        ad = getappdata(mainWindow);
        
        x1 = data(1,ignorefirstn+1:size(data,2));
        x2 = data(1,1:size(data,2));
        
        message = cell(0);
        message{end+1} = ...
            sprintf('Iteration  FuncCount    min f(x)   Procedure');
        
        % Set options for fminsearch
        fitopt = optimset(...
            'Display','Off',...
            'OutputFcn', @outfun ... 
            );

        switch fitFunType
            case 'exponential'
                % A1*exp(k1*x)
                fun1 = @(z)z(1)*exp(z(2)*x1+z(3));
                fun2 = @(z)z(1)*exp(z(2)*x2+z(3));
                fitfun = @(z)sum((fun1(z)-data(2,ignorefirstn+1:end)).^2);
                % Fit function
                [Y,fval,exitflag,output] = fminsearch(fitfun,[1 -1 0],fitopt);
                fit = fun2(Y);
            case 'biexponential'
                % A1*exp(k1*x) + A2*exp(k2*x)
                fun1 = @(z)z(1)*exp(z(2)*x1+z(3))+z(4)*exp(z(5)*x1+z(6));
                fun2 = @(z)z(1)*exp(z(2)*x2+z(3))+z(4)*exp(z(5)*x2+z(6));
                fitfun = @(z)sum((fun1(z)-data(2,ignorefirstn+1:end)).^2);
                % Fit function
                [Y,fval,exitflag,output] = fminsearch(fitfun,[1 -1 0 1 -1 0],fitopt);
                fit = fun2(Y);
        end
        
        % Create message
        message{end+1} = ''; % Empty line
        message{end+1} = 'SUMMARY';
        message{end+1} = sprintf('Algorithm: %s',output.algorithm);
        message{end+1} = sprintf('Number of iterations: %i',output.iterations);
        message{end+1} = sprintf('Number of function evaluations: %i',output.funcCount);
        if (exitflag ~= 1)
            message{end+1} = output.message;
        end
    catch exception
        throw(exception);
    end
end