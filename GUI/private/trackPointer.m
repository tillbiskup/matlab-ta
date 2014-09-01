function status = trackPointer(varargin)
% TRACKPOINTER Helper function that tracks the position of the pointer
% within the given axis
%
%   VARARGIN: input arguments
%       As this function is directly set as Callback function for the main
%       GUI figure, the first two parameters are fixed and are "source" and
%       "event". Therefore, starting with the third parameter there might
%       be some user-defined input arguments.
%
%   STATUS: return value for the exit status
%           -1: no tEPRgui window found
%           -2: tEPRgui window doesn't contain necessary elements
%           -3: tEPRgui window appdata don't contain necessary fields
%           -4: no datasets displayed
%            0: successful

% Copyright (c) 2011-12, Till Biskup
% 2012-10-21

% Is there currently a TAgui object?
mainWindow = TAguiGetWindowHandle;
if (isempty(mainWindow))
    status = -1;
    return;
end

% Get handles of mainwindow
gh = guihandles(mainWindow);

% Get appdata of main window
mainWindow = TAguiGetWindowHandle;
ad = getappdata(mainWindow);

% Check for availability of necessary GUI elements
mainAxis = findobj(allchild(gh.mainAxes_panel),'Type','axes');

if isempty(mainAxis)
    status = -2;
end

% Check for availability of necessary fields in appdata
% DO WE REALLY NEED THIS?
if (isfield(ad,'control') == 0) || (isfield(ad.control,'status') == 0)
    status = -3;
    return;
end

% If there is no spectrum currently displayed, return immediately
if (isempty(ad.control.spectra.active)) || (ad.control.spectra.active == 0)
    status = -4;
    return;
end

% Do the actual stuff

% Get position of mainAxis (axis coordinates)
axisPosition = get(mainAxis,'Position');
% As the mainAxis is normally in a panel, add offset
% TODO: Could be figured out programmatically with getting the parent of
% the axis handle and then get its position and traverse that until we
% reach the main figure handle...
axisCoordinatesOffset = [0 55];
% Coordinates are "real" x,y pairs relative to the mainWindow
axisCoordinates = [ ...
    axisPosition(1)+axisCoordinatesOffset(1)-1 ...
    axisPosition(2)+axisCoordinatesOffset(2)-1 ...
    axisPosition(1)+axisCoordinatesOffset(1)+axisPosition(3) ...
    axisPosition(2)+axisCoordinatesOffset(2)+axisPosition(4) ...
    ];

% Get current position of pointer
pointerPosition = get(mainWindow,'CurrentPoint');

% Create CData for custom pointer
pointerShapeCData = ones(16)*nan;
pointerShapeCData([1 8 15],[1:6 10:15]) = 1;
pointerShapeCData([1:6 10:15],[1 8 15]) = 1;

% As long as we are inside the mainAxis
if pointerPosition(1) > axisCoordinates(1) && ...
        pointerPosition(1) < axisCoordinates(3) && ...
        pointerPosition(2) > axisCoordinates(2) && ...
        pointerPosition(2) < axisCoordinates(4)
    
    % Get pointer position coordinates relative to axis
    pointerPositionInAxis = ...
        pointerPosition - [axisCoordinates(1) axisCoordinates(2)];
    
    % Set pointer shape
    %set(mainWindow,'Pointer','crosshair');
    set(mainWindow,'Pointer','custom',...
        'PointerShapeCData',pointerShapeCData,...
        'PointerShapeHotSpot',[9 9]);
    
    % Get id of current spectrum (to shorten lines afterwards)
    active = ad.control.spectra.active;
    
    % Get xdata and ydata of currently active dataset
    if (strcmp(ad.control.axis.displayType,'2D plot'))
        xdata = get(findobj('Parent',mainAxis,'-and','Type','image'),'xdata');
        ydata = get(findobj('Parent',mainAxis,'-and','Type','image'),'ydata');
    else
        xdata = get(findobj('Parent',mainAxis,'-and','Type','line'),'xdata');
        ydata = get(findobj('Parent',mainAxis,'-and','Type','line'),'ydata');
    end
    
    % If we are in 1D display mode and there are more than one spectrum
    % and/or a zero line displayed
    if (strcmp(ad.control.axis.displayType,'1D along x') || ...
            strcmp(ad.control.axis.displayType,'1D along y')) 
        xdata = xdata{length(xdata)-find(ad.control.spectra.visible==active)+1};
        ydata = ydata{length(ydata)-find(ad.control.spectra.visible==active)+1};
    end
    
    % Create vectors with indices for xdata and ydata
    % Those are used in case of axis limits <> dataset limits
    xindex = [ 1 : length(xdata) ];
    yindex = [ 1 : length(ydata) ];
    
    % Handle situation that axis limits and dataset limits don't coincide.
    % Therefore, in case of the dataset being smaller than axis limits, pad
    % it with the first/last value to fill xdata/ydata, respectively.
    % Alternatively, the dataset being larger than axis limits, cut out
    % part from the dataset that's currently displayed.
    % To find out how many points to pad, use interp1 to get ending points
    % of dataset in current axis.

    % IMPORTANT: DON'T MESS UP THE CODE BELOW, IF YOU'RE NOT ABSOLUTELY
    % SURE WHAT YOU'RE DOING. I SPEND A WHOLE DAY FIGHTING WITH IT UNTIL IT
    % WORKED SOMEWHAT FINE.
    
    % Get x and y limits of axes
    axisXLim = get(mainAxis,'XLim');
    axisYLim = get(mainAxis,'YLim');
    % Get x and y limits of currently active dataset
    datasetXLim = [ xdata(1) xdata(end) ];
    datasetYLim = [ ydata(1) ydata(end) ];
    
    % Get dataset limits in axis coordinates
    if (axisXLim(1) > datasetXLim(1))
        % In case dataset is larger than current axis limits
        
        % Need to come up with a good variable name for that, but it looks
        % like we get here the position of the axis limit in the data
        % vector, what would be very useful
        newDatasetXmin=interp1(...
            linspace(datasetXLim(1),datasetXLim(2),length(xdata)),...
            linspace(1,length(xdata),length(xdata)),...
            axisXLim(1),'nearest');
        newXdata = xdata(newDatasetXmin:end);
        newXindex = xindex(newDatasetXmin:end);
    else
        newDatasetXmin=interp1(...
            linspace(axisXLim(1),axisXLim(2),length(xdata)),...
            linspace(1,length(xdata),length(xdata)),...
            xdata(1),'nearest');
        newXdata = [ones(1,newDatasetXmin)*xdata(1) xdata];
        newXindex = [ones(1,newDatasetXmin)*xindex(1) xindex];
    end
    if (axisXLim(2) < datasetXLim(2))
        % In case dataset is larger than current axis limits
        
        % Need to come up with a good variable name for that, but it looks
        % like we get here the position of the axis limit in the data
        % vector, what would be very useful
        newDatasetXmax=interp1(...
            linspace(datasetXLim(1),datasetXLim(end),length(xdata)),...
            linspace(1,length(xdata),length(xdata)),...
            axisXLim(2),'nearest');
        newXdata = newXdata(1:end-(length(xdata)-newDatasetXmax));
        newXindex = newXindex(1:end-(length(xindex)-newDatasetXmax));
    else
        newDatasetXmax=interp1(...
            linspace(axisXLim(1),axisXLim(2),length(xdata)),...
            linspace(1,length(xdata),length(xdata)),...
            xdata(end),'nearest');
        newXdata = [newXdata ones(1,length(xdata)-newDatasetXmax)*xdata(end)];
        newXindex = [newXindex ones(1,length(xindex)-newDatasetXmax)*xindex(end)];
    end

    if (strcmp(ad.control.axis.displayType,'2D plot'))
        if (axisYLim(1) > datasetYLim(1))
            % In case dataset is larger than current axis limits
            
            % Need to come up with a good variable name for that, but it looks
            % like we get here the position of the axis limit in the data
            % vector, what would be very useful
            newDatasetYmin=interp1(...
                linspace(datasetYLim(1),datasetYLim(2),length(ydata)),...
                linspace(1,length(ydata),length(ydata)),...
                axisYLim(1),'nearest');
            newYdata = ydata(newDatasetYmin:end);
            newYindex = yindex(newDatasetYmin:end);
        else
            newDatasetYmin=interp1(...
                linspace(axisYLim(1),axisYLim(2),length(ydata)),...
                linspace(1,length(ydata),length(ydata)),...
                ydata(1),'nearest');
            newYdata = [ones(1,newDatasetYmin)*ydata(1) ydata];
            newYindex = [ones(1,newDatasetYmin)*yindex(1) yindex];
        end
        if (axisYLim(2) < datasetYLim(2))
            % In case dataset is larger than current axis limits
            
            % Need to come up with a good variable name for that, but it looks
            % like we get here the position of the axis limit in the data
            % vector, what would be very useful
            newDatasetYmax=interp1(...
                linspace(datasetYLim(1),datasetYLim(end),length(ydata)),...
                linspace(1,length(ydata),length(ydata)),...
                axisYLim(2),'nearest');
            newYdata = newYdata(1:end-(length(ydata)-newDatasetYmax));
            newYindex = newYindex(1:end-(length(yindex)-newDatasetYmax));
        else
            newDatasetYmax=interp1(...
                linspace(axisYLim(1),axisYLim(2),length(ydata)),...
                linspace(1,length(ydata),length(ydata)),...
                ydata(end),'nearest');
            newYdata = [newYdata ones(1,length(ydata)-newDatasetYmax)*ydata(end)];
            newYindex = [newYindex ones(1,length(yindex)-newDatasetYmax)*yindex(end)];
        end
    end
    
    switch ad.control.axis.displayType
        case '2D plot'
            % Get index of current point in dataset
            indx=interp1(...
                linspace(1,axisPosition(3),length(newXdata)),...
                newXindex,...
                pointerPositionInAxis(1),'nearest');
            indy=interp1(...
                linspace(1,axisPosition(4),length(newYdata)),...
                newYindex,...
                pointerPositionInAxis(2),'nearest');
        case '1D along x'
            % Get index of current point in dataset
            indx=interp1(...
                linspace(1,axisPosition(3),length(newXdata)),...
                newXindex,...
                pointerPositionInAxis(1),'nearest');
            indy=indx;
        case '1D along y'
            % Get index of current point in dataset
            indx=interp1(...
                linspace(1,axisPosition(3),length(newXdata)),...
                newXindex,...
                pointerPositionInAxis(1),'nearest');
            indy=indx;
        otherwise
            % That shall never happen!
            disp('trackPointer(): Unrecognised displayType');
            set(mainWindow,'Pointer','arrow');
            return;
    end
    
    % Get value (in units) of current point in dataset
    valx = xdata(indx);
    valy = ydata(indy);
    
    % Set display
    switch ad.control.measure.point
        case 1
            % Update display of first point
            set(gh.measure_panel_point1_x_index_edit,'String',num2str(indx));
            set(gh.measure_panel_point1_x_unit_edit,'String',num2str(valx));
            set(gh.measure_panel_point1_y_index_edit,'String',num2str(indy));
            set(gh.measure_panel_point1_y_unit_edit,'String',num2str(valy));
        case 2
            % Update display of second point
            set(gh.measure_panel_point2_x_index_edit,'String',num2str(indx));
            set(gh.measure_panel_point2_x_unit_edit,'String',num2str(valx));
            set(gh.measure_panel_point2_y_index_edit,'String',num2str(indy));
            set(gh.measure_panel_point2_y_unit_edit,'String',num2str(valy));
            % Update display of Delta between points
            set(gh.measure_panel_distance_x_index_edit,'String',...
                num2str(indx-...
                str2double(get(gh.measure_panel_point1_x_index_edit,'String'))));
            set(gh.measure_panel_distance_x_unit_edit,'String',...
                num2str(valx-...
                str2double(get(gh.measure_panel_point1_x_unit_edit,'String'))));
            set(gh.measure_panel_distance_y_index_edit,'String',...
                num2str(indy-...
                str2double(get(gh.measure_panel_point1_y_index_edit,'String'))));
            set(gh.measure_panel_distance_y_unit_edit,'String',...
                num2str(valy-...
                str2double(get(gh.measure_panel_point1_y_unit_edit,'String'))));
        otherwise
            % That shall never happen!
            disp('trackPointer(): Unrecognised point');
            return;
    end
else
    set(mainWindow,'Pointer','arrow');
end

status = 0;

end
