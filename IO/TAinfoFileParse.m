function [parameters,warnings] = TAinfoFileParse(filename,varargin)
% TAINFOFILEPARSE Parse Info files of TA spectra and return a structure
% containing all parameters.
%
% Usage
%   parameters = TAinfoFileParse(filename)
%   [parameters,warning] = TAinfoFileParse(filename)
%   [parameters,warning] = TAinfoFileParse(filename,command)
%
% filename   - string
%              Valid filename (of a TA Info file)
% command    - string (OPTIONAL)
%              Additional command controlling what to do with the parsed
%              data.
%              'map' - Map the parsed fields to the TA toolbox structure
%                      and return a structure with these mapped fields
%                      instead of the original parsed fields of the Info
%                      file.
%
% parameters - struct
%              structure containing parameters from the TA Info file
%
%              In case of the optional 'map' command, structure containing
%              the parameters from the TA Info file mapped onto their
%              couterparts of the TA data structure.
%
% warnings   - cell array of strings
%              empty if there are no warnings
%

% (c) 2012, Till Biskup
% 2012-01-24

% If called without parameter, do something useful: display help
if ~nargin && ~nargout
    help TAinfoFileParse
    return;
end

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('filename', @(x)ischar(x));
p.addOptional('command','',@(x)ischar(x));
p.parse(filename,varargin{:});

warnings = cell(0);

% Define identifierString for Info File format
identifierString = 'TA Info file - ';

try
    parameters = struct();

    % If there is no filename specified, return
    if isempty(filename)
        warnings{end+1} = struct(...
            'identifier','TAinfoFileParse:nofile',...
            'message','No filename or file does not exist'...
            );
        return;
    end
    % If filename does not exist, try to add extension
    if  ~exist(filename,'file')
        [fpath,fname,~] = fileparts(filename);
        if exist(fullfile(fpath,[fname '.meta']),'file')
            filename = fullfile(fpath,[fname '.meta']);
        else
            parameters = struct();
            warnings{end+1} = struct(...
                'identifier','TAinfoFileParse:nofile',...
                'message','No filename or file does not exist'...
                );
            return;
        end
    end
    
    % Read file
    fh = fopen(filename);
    % Read content of the par file to cell array
    metaFile = cell(0);
    k=1;
    while 1
        tline = fgetl(fh);
        if ~ischar(tline)
            break
        end
        metaFile{k} = tline;
        k=k+1;
    end
    fclose(fh);
    
    % Check for correct file format
    if ~strfind(metaFile{1},identifierString)
            parameters = struct();
            warnings{end+1} = struct(...
                'identifier','TAinfoFileParse:fileformat',...
                'message','File seems to be of wrong format'...
                );
            return;
    end
    
    % For convenience and easier parsing, get an overview where the blocks
    % start in the metafile.
    
    % Block names are defined in a cell array.
    blockNames = {...
        'GENERAL' ...
        'SAMPLE' ...
        'TRANSIENT' ...
        'SPECTROGRAPH' ...
        'DETECTION' ...
        'RECORDER' ...
        'PUMP' ...
        'PROBE' ...
        'TEMPERATURE' ...
        'MFE' ...
        'TIME PROFILES' ...
        'COMMENT' ...
        };    
    % Assign block names and line numbers where they start to struct
    % The field names of the struct consist of the block names in small
    % letters with spaces removed.
    %
    % NOTE: If a block could not be found, its line number defaults to 1
    %
    % As it is not possible to do a "reverse lookup" in an array, the
    % vector "lineNumbers" holds the line numbers for the blocks
    % separately, if one needs to access them directly, without knowing
    % which block one is looking for.
    blocks = struct();
    lineNumbers = zeros(1,length(blockNames));
    for k = 1:length(blockNames)
        [~,lineNumber] = max(cellfun(@(x) ~isempty(x),...
            strfind(metaFile,blockNames{k})));
        lineNumbers(k) = lineNumber;
        blocks.(str2fieldName(blockNames{k})) = lineNumber;
    end
    
    % How to access the line number of the next block starting with a given
    % block (to find out where the current block ends):
    % min(find(lineNumbers > blocks.blockname))
    
    % Parse every single block, using internal function parseBlocks()
    blocknames = fieldnames(blocks);
    
    for k=1:length(blocknames)
        if strcmpi(blocknames{k},'comment')
            % Assign comment lines to block.comment field
            block.comment = metaFile(...
                blocks.(blocknames{k})+1 : length(metaFile));
        elseif strcmpi(blocknames{k},'timeprofiles')
            % Get number of scans
            blockLines = metaFile(...
                blocks.(blocknames{k})+1 : ...
                lineNumbers(find(...
                lineNumbers > blocks.(blocknames{k}), 1 ))-2 ...
                );
            noScans = length(cell2mat(regexp(blockLines,'^Scan [0-9]*')));
            nLinesSubblock = length(blockLines)/noScans;
            for l = 1:noScans
                block.(blocknames{k})(l) = parseBlocks(metaFile(...
                    blocks.(blocknames{k})+2+((l-1)*nLinesSubblock) : ...
                    blocks.(blocknames{k})+2+((l-1)*nLinesSubblock) + ...
                    nLinesSubblock-2 ...
                    ));
            end
        else
            % Assign block fields generically
            block.(blocknames{k}) = parseBlocks(metaFile(...
                blocks.(blocknames{k})+1 : ...
                lineNumbers(find(...
                lineNumbers > blocks.(blocknames{k}), 1 ))-2 ...
                ));
        end
    end
    
    parameters = block;
    
    if p.Results.command
        switch lower(p.Results.command)
            case 'map'
                parameters = mapToDataStructure(parameters);
            otherwise
                disp(['TAinfoFileParse() : Unknown command "'...
                    p.Results.command '"']);
        end
    end
catch exception
    throw(exception);
end

end


% MAPTODATASTRUCTURE Internal function mapping the parameters read to the
%                    TA toolbox data structure.
%
% parameter     - struct
%                 Structure containing the parsed contents of the Info file
%
% dataStructure - Structure containing the fields of the TA toolbox data
%                 structure with mapped information from the input
%
function dataStructure = mapToDataStructure(parameters)
try
    dataStructure = struct();
    
    % Cell array correlating struct fieldnames read from the metafile and
    % from the toolbox data structure.
    % The first entry contains the fieldname generated while parsing the
    % metafile, the second entry contains the corresponding field name of
    % the toolbox data structure struct. The third parameter, 
    % finally, tells the program how to parse the corresponding entry.
    % Here, "numeric" means that the numbers of the field should be treated
    % as numbers, "copy" means to just copy the field unaltered, and
    % "valueunit" splits the field in a numeric value and a string
    % containing the unit.
    matching = {...
        % GENERAL
        % Fields handled separately below: date, timeStart, timeEnd
        'general.filename','file.name','string';...
        'general.operator','parameters.operator','copy';...
        'general.label','label','copy';...
        'general.spectrometer','parameters.spectrometer.name','copy';...
        'general.software','parameters.spectrometer.software','copy';...
        'general.runs','parameters.runs','numeric';...
        % SAMPLE
        'sample.name','sample.name','copy';...
        'sample.description','sample.description','copy';...
        'sample.preparation','sample.preparation','copy';...
        'sample.cuvette','sample.cuvette','copy';...
        % TRANSIENT
        'transient.points','parameters.transient.points','numeric';...
        'transient.triggerPosition','parameters.transient.triggerPosition','numeric';...
        'transient.length','parameters.transient.length','valueunit';...
        % SPECTROGRAPH
        'spectrograph.type','parameters.spectrograph.type','copy';...
        'spectrograph.model','parameters.spectrograph.model','copy';...
        'spectrograph.apertureFront','parameters.spectrograph.aperture.front','valueunit';...
        'spectrograph.apertureBack','parameters.spectrograph.aperture.back','valueunit';...
        % DETECTION
        'detection.type','parameters.detection.type','copy';...
        'detection.model','parameters.detection.model','copy';...
        'detection.powerSupply','parameters.detection.powersupply','copy';...
        'detection.impedance','parameters.detection.impedance','valueunit';...
        'detection.timeConstant','parameters.detection.timeConstant','valueunit';...
        % RECORDER
        'recorder.model','parameters.recorder.model','copy';...
        'recorder.averages','parameters.recorder.averages','numeric';...
        'recorder.sensitivity','parameters.recorder.sensitivity','valueunit';...
        'recorder.bandwidth','parameters.recorder.bandwidth','valueunit';...
        'recorder.timeBase','parameters.recorder.timeBase','valueunit';...
        'recorder.coupling','parameters.recorder.coupling','copy';...
        % PUMP
        'pump.type','parameters.pump.type','copy';...
        'pump.model','parameters.pump.model','copy';...
        'pump.wavelength','parameters.pump.wavelength','valueunit';...
        'pump.power','parameters.pump.power','valueunit';...
        'pump.repetitionRate','parameters.pump.repetitionRate','valueunit';
        'pump.tunableType','parameters.pump.tunable.type','copy';...
        'pump.tunableModel','parameters.pump.tunable.model','copy';...
        'pump.tunableDye','parameters.pump.tunable.dye','copy';...
        % PROBE
        'probe.type','parameters.probe.type','copy';...
        'probe.model','parameters.probe.model','copy';...
        'probe.wavelengthStart','parameters.probe.wavelength.start','numeric';...
        'probe.wavelengthStop','parameters.probe.wavelength.stop','numeric';...
        'probe.wavelengthStep','parameters.probe.wavelength.step','numeric';...
        'probe.wavelengthSequence','parameters.probe.wavelength.sequence','copy';...
        'probe.power','parameters.probe.power','valueunit';...
        'probe.filter','parameters.probe.filter','copy';...
        'probe.background','parameters.probe.background','copy';...
        % TEMPERATURE
        'temperature.temperature','parameters.temperature','valueunit';...
        'temperature.controller','parameters.temperature.controller','copy';...
        'temperature.cryostat','parameters.temperature.cryostat','copy';...
        'temperature.cryogen','parameters.temperature.cryogen','copy';...
        % MFE
        'mfe.field','parameters.MFE.field','valueunit';...
        'mfe.coilType','parameters.MFE.coil.type','copy';...
        'mfe.coilModel','parameters.MFE.coil.model','copy';...
        'mfe.powerSupply','parameters.MFE.powerSupply','copy';...
        'mfe.gaussmeter','parameters.MFE.gaussmeter','copy';...
        % TIME PROFILES
        % Has to be dealt with separately
        % COMMENT
        'comment','comment','copy';...
        };
    
    for k=1:length(matching)
        switch matching{k,3}
            case 'numeric'
                if ischar(getCascadedField(parameters,matching{k,1}))
                    dataStructure = setCascadedField(dataStructure,...
                        matching{k,2},...
                        num2str(getCascadedField(parameters,matching{k,1})));
                else
                    dataStructure = setCascadedField(dataStructure,...
                        matching{k,2},...
                        getCascadedField(parameters,matching{k,1}));
                end
            case 'valueunit'
                if ~isempty(getCascadedField(parameters,matching{k,1}))
                    parts = regexp(...
                        getCascadedField(parameters,matching{k,1}),...
                        ' ','split','once');
                    dataStructure = setCascadedField(dataStructure,...
                        [matching{k,2} '.value'],...
                        str2double(parts{1}));
                    dataStructure = setCascadedField(dataStructure,...
                        [matching{k,2} '.unit'],...
                        parts{2});
                else
                    dataStructure = setCascadedField(dataStructure,...
                        [matching{k,2} '.value'],...
                        []);
                    dataStructure = setCascadedField(dataStructure,...
                        [matching{k,2} '.unit'],...
                        '');
                end
            case 'copy'
                dataStructure = setCascadedField(dataStructure,...
                    matching{k,2},...
                    getCascadedField(parameters,matching{k,1}));
        end
    end
    
    % Handle the special case of date and time that get combined in one
    % field
    dataStructure.parameters.date.start = [...
        parameters.general.date ' ' parameters.general.timeStart];
    dataStructure.parameters.date.end = [...
        parameters.general.date ' ' parameters.general.timeEnd];
    
    % TODO: Handle timeProfiles, especially the filters at different
    %       wavelengths
catch exception
    throw(exception);
end

end

% STR2FIELDNAME Internal function converting strings into valid
%               field names for structs
%
% Currently, spaces are removed, starting with the second word parts of
% the fieldname capitalised, and parentheses "(" and ")" removed.
%
% string    - string
%             string to be converted into a field name
% fieldName - string
%             string containing the valid field name for a struct
function fieldName = str2fieldName(string)

% Eliminate brackets
string = strrep(strrep(string,')',''),'(','');
fieldName = regexp(lower(string),' ','split');
if length(fieldName) > 1
    fieldName(2:end) = cellfun(...
        @(x) [upper(x(1)) x(2:end)],...
        fieldName(2:end),...
        'UniformOutput',false);
    fieldName = [fieldName{:}];
else
    fieldName = fieldName{1};
end

end

% PARSEBLOCKS Internal function parsing blocks of the metafile
%
% A given block is parsed, the lines split by the first appearance of the
% delimiter ":", the first part converted into a field name for a struct
% and  the second part assigned to that field of the struct.
%
% blockData  - cell array of strings
%              block data to be parsed
% parameters - struct
%              structure containing key-value pairs
function parameters = parseBlocks(blockData)

% Assign output parameter
parameters = struct();
blockLines = cellfun(...
    @(x) regexp(x,':','split','once'),...
    blockData,...
    'UniformOutput', false);
for k=1:length(blockLines)
    % Fill parameters structure
    if ~isempty(blockLines{k}{1}) % Prevent empty lines being parsed
        % If not convertible into number - or containing commas
        if isnan(str2double(blockLines{k}{2})) || ...
                any(strfind(blockLines{k}{2},','))
            parameters.(str2fieldName(blockLines{k}{1})) = ...
                strtrim(blockLines{k}{2});
        else
            parameters.(str2fieldName(blockLines{k}{1})) = ...
                str2double(strtrim(blockLines{k}{2}));
        end
    end
end

end

% --- Get field of cascaded struct
function value = getCascadedField (struct, fieldName)
    try
        % Get number of "." in fieldName
        nDots = strfind(fieldName,'.');
        if isempty(nDots)
            value = struct.(fieldName);
        else
            struct = struct.(fieldName(1:nDots(1)-1));
            value = getCascadedField(...
                struct,...
                fieldName(nDots(1)+1:end));
        end
    catch exception
        try
            disp(fieldName);
            disp(struct);
            msgStr = ['An exception occurred. '...
                'The bug reporter should have been opened'];
            add2status(msgStr);
        catch exception2
            exception = addCause(exception2, exception);
            disp(msgStr);
        end
        try
            TAgui_bugreportwindow(exception);
        catch exception3
            % If even displaying the bug report window fails...
            exception = addCause(exception3, exception);
            throw(exception);
        end
    end 
end

% --- Set field of cascaded struct
function struct = setCascadedField (struct, fieldName, value)
    % Get number of "." in fieldName
    nDots = strfind(fieldName,'.');
    if isempty(nDots)
        struct.(fieldName) = value;
    else
        if ~isfield(struct,fieldName(1:nDots(1)-1))
            struct.(fieldName(1:nDots(1)-1)) = [];
        end
        innerstruct = struct.(fieldName(1:nDots(1)-1));
        innerstruct = setCascadedField(...
            innerstruct,...
            fieldName(nDots(1)+1:end),...
            value);
        struct.(fieldName(1:nDots(1)-1)) = innerstruct;
    end
end