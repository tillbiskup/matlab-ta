% TA3DREPRESENTATION Generate 3D representation of given 2D data (matrix)
%
% Usage
%   TA3Drepresentation(data,parameters);
%   figHandle = TA3Drepresentation(data,parameters);
%
% data       - struct
%              data to plot
% parameters - struct
%              parameters controlling the type of 3D representation
%              If no parameters are given, the function assumes a set of
%              standard parameters (type: surf; no reduction of points)
%
% figHandle  - handle
%              Handle of the Matlab figure
%              0 if some problems occurred
%

% Copyright (c) 2011-12, Till Biskup
% 2012-03-01

function figHandle = TA3Drepresentation(data,parameters)

try
    if ~isfield(data,'data') || isempty(data.data)
        figHandle = 0;
        return;
    end
    
    % Check for type in parameters, otherwise set default
    % WHY? Function should run even if only data are supplied (convenience)
    if ~isfield(parameters,'type') || isempty(parameters.type)
        parameters.type = 'surf';
    end

    % Reduce data points if necessary
    if isfield(parameters,'size') && ~isempty(parameters.size)
        % If size is too small, return
        if (parameters.size.x < 10) || (parameters.size.y < 10)
            figHandle = 0;
            return;
        end
        % Handle offset
        if isfield(parameters,'offset') ...
                && isfield(parameters.offset,'type')
            switch parameters.offset.type
                case 'left'
                    % Handle situation that offset is too large
                    [dimy,dimx] = size(data.data);
                    if (parameters.offset.x > dimx-parameters.size.x)
                        parameters.offset.x = dimx-parameters.size.x;
                    end
                    if (parameters.offset.y > dimy-parameters.size.y)
                        parameters.offset.y = dimy-parameters.size.y;
                    end
                    [dimy,dimx] = size(data.data(...
                        1+parameters.offset.y:end,...
                        1+parameters.offset.x:end));
                    stepx = floor(dimx/parameters.size.x);
                    stepy = floor(dimy/parameters.size.y);
                    offsetx = parameters.offset.x;
                    offsety = parameters.offset.y;
                case 'right'
                    % Handle situation that offset is too large
                    [dimy,dimx] = size(data.data);
                    if (parameters.offset.x > dimx-parameters.size.x)
                        parameters.offset.x = dimx-parameters.size.x;
                    end
                    if (parameters.offset.y > dimy-parameters.size.y)
                        parameters.offset.y = dimy-parameters.size.y;
                    end
                    [dimy,dimx] = size(data.data(...
                        1:end-parameters.offset.y,...
                        1:end-parameters.offset.x));
                    stepx = floor(dimx/parameters.size.x);
                    stepy = floor(dimy/parameters.size.y);
                    offsetx = dimx-(parameters.size.x*stepx);
                    offsety = dimy-(parameters.size.y*stepy);
                otherwise
                    [dimy,dimx] = size(data.data);
                    stepx = floor(dimx/parameters.size.x);
                    stepy = floor(dimy/parameters.size.y);
                    offsetx = floor(mod(dimx,parameters.size.x)/2);
                    offsety = floor(mod(dimy,parameters.size.y)/2);
            end
        else
            offsetx = 0;
            offsety = 0;
        end
        x = data.axes.x.values(offsetx+1:stepx:end);
        y = data.axes.y.values(offsety+1:stepy:end);
        z = data.data(offsety+1:stepy:end,offsetx+1:stepx:end);
    else
        x = data.axes.x.values;
        y = data.axes.y.values;
        z = data.data;
    end
    
    % Set default parameters for display
    if isfield(parameters,'surface')
        if ~isfield(parameters.surface,'EdgeColor')
            parameters.surface.EdgeColor = [0.7 0.7 0.7];
        end
        if ~isfield(parameters.surface,'MeshStyle')
            switch parameters.type
                case 'surf'
                    parameters.surface.MeshStyle = 'row';
                case 'surfc'
                    parameters.surface.MeshStyle = 'row';
                case 'mesh'
                    parameters.surface.MeshStyle = 'both';
            end
        end
        if ~isfield(parameters.surface,'LineStyle')
            switch parameters.type
                case 'surf'
                    parameters.surface.LineStyle = '-';
                case 'surfc'
                    parameters.surface.LineStyle = '-';
                case 'trisurf'
                    parameters.surface.LineStyle = 'none';
            end
        end
    else
        parameters.surface.EdgeColor = [0.7 0.7 0.7];
        switch parameters.type
            case 'surf'
                parameters.surface.MeshStyle = 'row';
                parameters.surface.LineStyle = '-';
            case 'surfc'
                parameters.surface.MeshStyle = 'row';
                parameters.surface.LineStyle = '-';
            case 'mesh'
                parameters.surface.MeshStyle = 'both';
            case 'trisurf'
                parameters.surface.LineStyle = 'none';
        end
    end
    
    % Open new figure window
    figHandle = figure();
    hAxes = newplot(figHandle);
    
    switch parameters.type
        case 'surf'
            hSurf = surf(hAxes,x,y,z);
            set(hSurf,'EdgeColor',parameters.surface.EdgeColor);
            set(hSurf,'MeshStyle',parameters.surface.MeshStyle);
            set(hSurf,'LineStyle',parameters.surface.LineStyle);
        case 'surfc'
            hSurfC = surfc(hAxes,x,y,z,...
                'MeshStyle',parameters.surface.MeshStyle,...
                'EdgeColor',parameters.surface.EdgeColor);
            set(hSurfC,'LineStyle',parameters.surface.LineStyle);
        case 'mesh'
            hMesh = mesh(hAxes,x,y,z);
            set(hMesh,'MeshStyle',parameters.surface.MeshStyle);
        case 'trisurf'
            [xx,yy]=meshgrid(x,y);
            tri = delaunay(xx,yy);
            hSurf = trisurf(tri,xx,yy,z);
            set(hSurf,'LineStyle',parameters.surface.LineStyle);
        case 'trimesh'
            [xx,yy]=meshgrid(x,y);
            tri = delaunay(xx,yy);
            hMesh = trimesh(tri,xx,yy,z);
        otherwise
            % That shall not happen
    end

    % Set viewport
    view(hAxes,[75 15]);
    
    % Set axes limits
    set(hAxes,'XLim',[x(1) x(end)]);
    set(hAxes,'YLim',[y(1) y(end)]);
    
    % Disable z axis
    set(hAxes,'ZTick',[]);
    
    % Set axes labels
    if isfield(data.axes.x,'measure') && isfield(data.axes.x,'unit')
        xAxisLabel = sprintf('{\\it%s} / %s',...
            data.axes.x.measure,data.axes.x.unit);
        xlabel(xAxisLabel);
    end
    if isfield(data.axes.y,'measure') && isfield(data.axes.y,'unit')
        yAxisLabel = sprintf('{\\it%s} / %s',...
            data.axes.y.measure,data.axes.y.unit);
        ylabel(yAxisLabel);
    end
    
catch exception
    throw(exception);
end

end
