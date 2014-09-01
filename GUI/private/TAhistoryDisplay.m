function [parameters,report] = TAhistoryDisplay(history)
% TAHISTORYDISPLAY Take a history structure of a TA toolbox dataset
% and transform the parameters in a format that can be nicely read and
% displayed.
%
% history - struct 
%           parameter structure of a TA toolbox dataset history entry
%
% parameters - cell array
%              Human readable formatting of the parameters of the performed
%              action described in the given history struct
%
% report     - cell array
%              Any additional information that gets displayed in the
%              "Report" panel of the info window

% Copyright (c) 2012, Till Biskup
% 2012-04-10

try
    parameters = cell(0);
    report = cell(0);
    switch history.method
        case 'TAPOC'
            parameters{end+1} = sprintf('triggerPosition: %i',...
                history.parameters.triggerPosition);
        case 'TABGC'
            parameters{end+1} = sprintf('numBGprofiles: %i %i',...
                history.parameters.numBGprofiles);
        case 'TAACC'
            parameters{end+1} = sprintf('master:        %i',...
                history.parameters.master);
            parameters{end+1} = sprintf('method:        ''%s''',...
                history.parameters.method);
            parameters{end+1} = 'weights:';
            parameters{end+1} = sprintf('          min: %f',...
                history.parameters.weights.min);
            parameters{end+1} = sprintf('          max: %f',...
                history.parameters.weights.max);
            parameters{end+1} = 'noise:';
            parameters{end+1} = '       x:';
            parameters{end+1} = sprintf('          min: %i',...
                history.parameters.noise.x.min);
            parameters{end+1} = sprintf('          max: %i',...
                history.parameters.noise.x.max);
            parameters{end+1} = '       y:';
            parameters{end+1} = sprintf('          min: %i',...
                history.parameters.noise.y.min);
            parameters{end+1} = sprintf('          max: %i',...
                history.parameters.noise.y.max);
            parameters{end+1} = sprintf('interpolation: ''%s''',...
                history.parameters.interpolation);
            parameters{end+1} = sprintf('label:         ''%s''',...
                history.parameters.label);
            parameters{end+1} = sprintf('\nDATASETS');
            for k = 1:length(history.parameters.datasets)
                parameters{end+1} = sprintf('\nDataset no. %i\n',k);
                parameters{end+1} = sprintf('label:         ''%s''',...
                    history.parameters.datasets{k}.label);
                parameters{end+1} = sprintf('filename:      ''%s''',...
                    history.parameters.datasets{k}.filename);
                parameters{end+1} = 'history:';
                if ~isempty(history.parameters.datasets{k}.history)
                    for l=1:length(history.parameters.datasets{k}.history)
                        parameters{end+1} = sprintf('       method: %s',...
                            history.parameters.datasets{k}.history{l}.method);
                        parameters{end+1} = sprintf('         date: %s',...
                            history.parameters.datasets{k}.history{l}.date);
                    end
                end
            end
        case 'TAAVG'
            parameters{end+1} = sprintf('dimension: ''%c''',...
                history.parameters.dimension);
            parameters{end+1} = sprintf('start:     %i',...
                history.parameters.start);
            parameters{end+1} = sprintf('stop:      %i',...
                history.parameters.stop);
            parameters{end+1} = sprintf('label:     ''%s''',...
                history.parameters.label);
        case 'TABLC'
        case 'TAcombine'
            parameters{end+1} = sprintf('label: ''%s''',...
                history.parameters.label);
            report{end+1} = 'Names of the files that were combined:';
            filenames = cell(1,length(history.info.filenames));
            for k=1:length(history.info.filenames)
                [~,fn,fext] = fileparts(history.info.filenames{k});
                if isempty(fext)
                    filenames{k} = sprintf('  %s',fn);
                else
                    filenames{k} = sprintf('  %s.%s',fn,fext);
                end
            end
            report = [ report filenames ];
        case 'TAscale'
            parameters{end+1} = sprintf('               method: ''%s''',...
                history.parameters.method);
            parameters{end+1} = sprintf('               master: %i',...
                history.parameters.master);
            parameters{end+1} = sprintf('overlappingWavelength: %i',...
                history.parameters.overlappingWavelength);
            parameters{end+1} = sprintf('           parameters: [1x1 struct]');
            parameters{end+1} = sprintf('               factor: %f',...
                history.parameters.factor);
            parameters{end+1} = sprintf('           scaledArea: %i-%i',...
                history.parameters.scaledArea([1 end]));
            parameters{end+1} = '';
            parameters{end+1} = sprintf('  parameters.avg');
            parameters{end+1} = sprintf('                index: [%i %i]',...
                history.parameters.parameters.avg.index);
            parameters{end+1} = sprintf('               values: [%f %f]',...
                history.parameters.parameters.avg.values);
            parameters{end+1} = sprintf('                 unit: ''%s''',...
                history.parameters.parameters.avg.unit);
            parameters{end+1} = '';
            parameters{end+1} = sprintf('  parameters.smoothing');
            parameters{end+1} = sprintf('               method: ''%s''',...
                history.parameters.parameters.smoothing.method);
            parameters{end+1} = sprintf('                index: %i',...
                history.parameters.parameters.smoothing.index);
        case 'TAalgebra'
            parameters{end+1} = sprintf('operation: %s',...
                history.parameters.operation);
            report = history.info;
            if strcmpi(history.parameters.operation,'scaling')
                parameters{end+1} = sprintf('scaling factor: %f',...
                    history.parameters.scalingFactor);
            end
        otherwise
            parameters{end+1} = 'No parameters to display currently';
    end
catch exception
    throw(exception);
end

end
