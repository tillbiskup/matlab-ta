function status = update_mainAxis(varargin)
% UPDATE_MAINAXIS Helper function that updates the main axis
%   of the TA GUI, namely TA_gui_mainwindow.
%
%   handle (optional) - figure handle to plot to
%
%   STATUS: return value for the exit status
%           -1: no tEPR_gui_mainwindow found
%            0: successfully updated main axis

% (c) 11, Till Biskup
% 2011-12-02

% Is there currently a TAgui object?
mainWindow = guiGetWindowHandle();
if (isempty(mainWindow))
    status = -1;
    return;
end

% Get handles from main window
gh = guidata(mainWindow);

% Get appdata from main GUI
ad = getappdata(mainWindow);

% Get handle of main axis
mainAxis = findobj(...
    'Parent',gh.mainAxes_panel,...
    '-and','Type','axes');

% Change enable status of pushbuttons and other elements
mainAxisChildren = findobj(...
    'Parent',gh.mainAxes_panel,...
    '-not','Type','uipanel',...
    '-not','Type','axes');
if isempty(ad.control.spectra.visible)
    set(mainAxisChildren,'Enable','off');
    [path,~,~] = fileparts(mfilename('fullpath'));
    splash = imread(fullfile(path,'splashes','TAtoolboxSplash.png'),'png');
    image(splash);
    axis off          % Remove axis ticks and numbers
    return;
else
    set(mainAxisChildren,'Enable','on');
end

% Set min and max for plots - internal function
setMinMax();

% Get appdata from main GUI
ad = getappdata(mainWindow);

% Set current axes to the main axes of main GUI
if (nargin > 0) && ishandle(varargin{1})
    mainAxes = newplot(varargin{1});
else
    mainAxes = findobj(allchild(gh.mainAxes_panel),...
        'Type','axes','-not','Tag','legend');
    set(mainWindow,'CurrentAxes',mainAxes);
end

% Just to be on the save side, check whether we have a currently active
% spectrum
if ~(ad.control.spectra.active)
    msg = 'update_mainAxis(): No active spectrum';
    add2status(msg);
    return;
end

% IMPORTANT: Set main axis to active axis
axes(mainAxis);

% For shorter and easier to read code:
active = ad.control.spectra.active;

% Plot depending on display type settings
% Be as robust as possible: if there is no axes, default is indices
[y,x] = size(ad.data{active}.data);
x = linspace(1,x,x);
y = linspace(1,y,y);
if (isfield(ad.data{active},'axes') ...
        && isfield(ad.data{active}.axes,'x') ...
        && isfield(ad.data{active}.axes.x,'values') ...
        && not (isempty(ad.data{active}.axes.x.values)))
    x = ad.data{active}.axes.x.values;
end
if (isfield(ad.data{active},'axes') ...
        && isfield(ad.data{active}.axes,'y') ...
        && isfield(ad.data{active}.axes.y,'values') ...
        && not (isempty(ad.data{active}.axes.y.values)))
    y = ad.data{active}.axes.y.values;
end
switch ad.control.axis.displayType
    case '2D plot'
        % Disable slider
        sliderHandles = findobj(...
            'Parent',gh.mainAxes_panel,...
            'style','slider');
        set(sliderHandles,'Enable','off');
        set(gh.reset_button,'Enable','off');
        data = ad.data{active}.data;
        % Apply thresholds
        if ad.data{active}.display.threshold.min.enable
            data(data<ad.data{active}.display.threshold.min.value) = ...
                ad.data{active}.display.threshold.min.value;
        end
        if ad.data{active}.display.threshold.max.enable
            data(data>ad.data{active}.display.threshold.max.value) = ...
                ad.data{active}.display.threshold.max.value;
        end
        % Do the actual plotting
        imagesc(...
            x,...
            y,...
            data...
            );
        set(gca,'YDir','normal');
        set(gca,'Tag','mainAxis');
        % Plot axis labels
        xlabel(gca,...
            sprintf('{\\it %s} / %s',...
            ad.control.axis.labels.x.measure,...
            ad.control.axis.labels.x.unit));
        ylabel(gca,...
            sprintf('{\\it %s} / %s',...
            ad.control.axis.labels.y.measure,...
            ad.control.axis.labels.y.unit));
        % Set limits of axis
        if (ad.control.axis.limits.x.min==ad.control.axis.limits.x.max)
            xLimits = [ad.control.axis.limits.x.min-1 ad.control.axis.limits.x.max+1];
        else
            xLimits = [ad.control.axis.limits.x.min ad.control.axis.limits.x.max];
        end
        if (ad.control.axis.limits.y.min==ad.control.axis.limits.y.max)
            yLimits = [ad.control.axis.limits.y.min-1 ad.control.axis.limits.y.max+1];
        else
            yLimits = [ad.control.axis.limits.y.min ad.control.axis.limits.y.max];
        end
        set(gca,...
            'XLim',xLimits,...
            'YLim',yLimits...
            );
    case '1D along x' % time profile
        % Enable sliders
        sliderHandles = findobj(...
            'Parent',gh.mainAxes_panel,...
            'style','slider');
        set(sliderHandles,'Enable','on');
        % Enable displacement slider
        set(gh.vert3_slider,...
            'Enable','on',...
            'Min',-(max(max(ad.data{active}.data))-...
            min(min(ad.data{active}.data))),...
            'Max',(max(max(ad.data{active}.data))-...
            min(min(ad.data{active}.data))),...
            'SliderStep',[0.001 0.01]...
            );
        set(gh.horz2_slider,...
            'Enable','on',...
            'Min',-length(x),'Max',length(x),...
            'SliderStep',[1/(2*length(x)) 10/(2*length(x))]...
            );
        set(gh.reset_button,'Enable','on');
        % Enable position slider only if second axis has more than one value
        if (length(y)>1)
            set(gh.vert1_slider,...
                'Enable','on',...
                'Min',1,'Max',length(y),...
                'SliderStep',[1/(length(y)) 10/(length(y))],...
                'Value',ad.data{active}.display.position.y...
                );
        else
            set(gh.vert1_slider,...
                'Enable','off'...
                );
        end
        % Do the actual plotting
        cla(mainAxes,'reset');
        hold(mainAxes,'on');
        for l = 1 : length(ad.control.spectra.visible)
            k = ad.control.spectra.visible(l);
            [~,x] = size(ad.data{k}.data);
            x = linspace(1,x,x);
            if (isfield(ad.data{k},'axes') ...
                    && isfield(ad.data{k}.axes,'x') ...
                    && isfield(ad.data{k}.axes.x,'values') ...
                    && not (isempty(ad.data{k}.axes.x.values)))
                x = ad.data{k}.axes.x.values;
            end
            y = ad.data{k}.data(...
                ad.data{k}.display.position.y,...
                :);
            % In case that we loaded 1D data...
            if isscalar(x)
                x = [x x+1];
            end
            if isscalar(y)
                y = [y y+1];
            end
            % Apply displacement if necessary
            if (ad.data{k}.display.displacement.x ~= 0)
                x = x + (x(2)-x(1)) * ad.data{k}.display.displacement.x;
            end
            if (ad.data{k}.display.displacement.z ~= 0)
                y = y + ad.data{k}.display.displacement.z;
            end
            % Apply thresholds
            if ad.data{active}.display.threshold.min.enable
                y(y<ad.data{active}.display.threshold.min.value) = ...
                    ad.data{active}.display.threshold.min.value;
            end
            if ad.data{active}.display.threshold.max.enable
                y(y>ad.data{active}.display.threshold.max.value) = ...
                    ad.data{active}.display.threshold.max.value;
            end
            % Normalise if necessary
            switch ad.control.axis.normalisation
                case 'pkpk'
                    y = y/(max(max(ad.data{k}.data))-min(min(ad.data{k}.data)));
                case 'amplitude'
                    y = y/max(max(ad.data{k}.data));
            end
            % Apply filter if necessary
            if (ad.data{k}.display.smoothing.x.value > 1)
                filterfun = str2func(ad.data{k}.display.smoothing.x.filterfun);
                y = filterfun(y,ad.data{k}.display.smoothing.x.value);
            end
            % Apply scaling if necessary
            if (ad.data{k}.display.scaling.x ~= 0)
                x = linspace(...
                    (((x(end)-x(1))/2)+x(1))-((x(end)-x(1))*ad.data{k}.display.scaling.x/2),...
                    (((x(end)-x(1))/2)+x(1))+((x(end)-x(1))*ad.data{k}.display.scaling.x/2),...
                    length(x));
            end
            if (ad.data{k}.display.scaling.z ~= 0)
                y = y * ad.data{k}.display.scaling.z;
            end
            currLine = plot(...
                mainAxes,...
                x,...
                y,...
                'Color',ad.data{k}.line.color,...
                'LineStyle',ad.data{k}.line.style,...
                'Marker',ad.data{k}.line.marker,...
                'LineWidth',ad.data{k}.line.width...
                );
            if (k == active) && ...
                    ~isempty(ad.control.axis.highlight.method)
                set(currLine,...
                    ad.control.axis.highlight.method,...
                    ad.control.axis.highlight.value...
                    );
            end
        end     
        hold(mainAxes,'off');
        if (ad.control.axis.grid.zero)
            line(...
                [ad.control.axis.limits.x.min ad.control.axis.limits.x.max],...
                [0 0],...
                'Color',[0.5 0.5 0.5],'LineStyle','--',...
                'Parent',mainAxes);
        end
        % Set limits of axis
        if (ad.control.axis.limits.x.min==ad.control.axis.limits.x.max)
            xLimits = [ad.control.axis.limits.x.min-1 ad.control.axis.limits.x.max+1];
        else
            xLimits = [ad.control.axis.limits.x.min ad.control.axis.limits.x.max];
        end
        if (ad.control.axis.limits.z.min==ad.control.axis.limits.z.max)
            yLimits = [ad.control.axis.limits.z.min-1 ad.control.axis.limits.z.max+1];
        else
            yLimits = [ad.control.axis.limits.z.min ad.control.axis.limits.z.max];
        end
        set(mainAxes,...
            'XLim',xLimits,...
            'YLim',yLimits...
            );
        % Plot axis labels
        xlabel(mainAxes,...
            sprintf('{\\it %s} / %s',...
            ad.control.axis.labels.x.measure,...
            ad.control.axis.labels.x.unit));
        ylabel(mainAxes,...
            sprintf('{\\it %s} / %s',...
            ad.control.axis.labels.z.measure,...
            ad.control.axis.labels.z.unit));
        % Display legend - internal function
        display_legend();
    case '1D along y' % B0 spectrum
        % Enable sliders
        sliderHandles = findobj(...
            'Parent',gh.mainAxes_panel,...
            'style','slider');
        set(sliderHandles,'Enable','on');
        % Enable displacement slider
        set(gh.vert3_slider,...
            'Enable','on',...
            'Min',-(max(max(ad.data{active}.data))-...
            min(min(ad.data{active}.data))),...
            'Max',(max(max(ad.data{active}.data))-...
            min(min(ad.data{active}.data))),...
            'SliderStep',[0.001 0.01]...
            );
        set(gh.horz2_slider,...
            'Enable','on',...
            'Min',-length(y),'Max',length(y),...
            'SliderStep',[1/(2*length(y)) 10/(2*length(y))]...
            );
        set(gh.reset_button,'Enable','on');
        % Enable position slider only if second axis has more than one value
        if (length(x)>1)
            set(gh.vert1_slider,...
                'Enable','on',...
                'Min',1,'Max',length(x),...
                'SliderStep',[1/(length(x)) 10/(length(x))],...
                'Value',ad.data{active}.display.position.x...
                );
        else
            set(gh.vert1_slider,...
                'Enable','off'...
                );
        end
        % Do the actual plotting
        cla(mainAxes,'reset');
        hold(mainAxes,'on');
        for l = 1 : length(ad.control.spectra.visible)
            k = ad.control.spectra.visible(l);
            [y,~] = size(ad.data{k}.data);
            y = linspace(1,y,y);
            if (isfield(ad.data{k},'axes') ...
                    && isfield(ad.data{k}.axes,'y') ...
                    && isfield(ad.data{k}.axes.y,'values') ...
                    && not (isempty(ad.data{k}.axes.y.values)))
                y = ad.data{k}.axes.y.values;
            end
            x = ad.data{k}.data(...
                :,...
                ad.data{k}.display.position.x...
                );
            % In case that we loaded 1D data...
            if isscalar(x)
                x = [x x+1];
            end
            if isscalar(y)
                y = [y y+1];
            end
            % Apply displacement if necessary
            if (ad.data{k}.display.displacement.y ~= 0)
                y = y + (y(2)-y(1)) * ad.data{k}.display.displacement.y;
            end
            if (ad.data{k}.display.displacement.z ~= 0)
                x = x + ad.data{k}.display.displacement.z;
            end
            % Apply thresholds
            if ad.data{active}.display.threshold.min.enable
                x(x<ad.data{active}.display.threshold.min.value) = ...
                    ad.data{active}.display.threshold.min.value;
            end
            if ad.data{active}.display.threshold.max.enable
                x(x>ad.data{active}.display.threshold.max.value) = ...
                    ad.data{active}.display.threshold.max.value;
            end
            % Normalise if necessary
            switch ad.control.axis.normalisation
                case 'pkpk'
                    x = x/(max(max(ad.data{k}.data))-min(min(ad.data{k}.data)));
                case 'amplitude'
                    x = x/max(max(ad.data{k}.data));
            end
            % Apply filter if necessary
            if (ad.data{k}.display.smoothing.y.value > 1)
                filterfun = str2func(ad.data{k}.display.smoothing.y.filterfun);
                x = filterfun(x,ad.data{k}.display.smoothing.y.value);
            end
            % Apply scaling if necessary
            if (ad.data{k}.display.scaling.y ~= 0)
                y = linspace(...
                    (((y(end)-y(1))/2)+y(1))-((y(end)-y(1))*ad.data{k}.display.scaling.y/2),...
                    (((y(end)-y(1))/2)+y(1))+((y(end)-y(1))*ad.data{k}.display.scaling.y/2),...
                    length(y));
            end
            if (ad.data{k}.display.scaling.z ~= 0)
                x = x * ad.data{k}.display.scaling.z;
            end
            currLine = plot(...
                mainAxes,...
                y,...
                x,...
                'Color',ad.data{k}.line.color,...
                'LineStyle',ad.data{k}.line.style,...
                'Marker',ad.data{k}.line.marker,...
                'LineWidth',ad.data{k}.line.width...
                );
            if (k == active) && ...
                    ~isempty(ad.control.axis.highlight.method)
                set(currLine,...
                    ad.control.axis.highlight.method,...
                    ad.control.axis.highlight.value...
                    );
            end
        end     
        if (ad.control.axis.grid.zero)
            line(...
                [ad.control.axis.limits.y.min ad.control.axis.limits.y.max],...
                [0 0],...
                'Color',[0.5 0.5 0.5],'LineStyle','--',...
                'Parent',mainAxes);
        end
        hold(mainAxes,'off');
        % Set limits of axis
        if (ad.control.axis.limits.y.min==ad.control.axis.limits.y.max)
            xLimits = [ad.control.axis.limits.y.min-1 ad.control.axis.limits.y.max+1];
        else
            xLimits = [ad.control.axis.limits.y.min ad.control.axis.limits.y.max];
        end
        if (ad.control.axis.limits.z.min==ad.control.axis.limits.z.max)
            yLimits = [ad.control.axis.limits.z.min-1 ad.control.axis.limits.z.max+1];
        else
            yLimits = [ad.control.axis.limits.z.min ad.control.axis.limits.z.max];
        end
        set(mainAxes,...
            'XLim',xLimits,...
            'YLim',yLimits...
            );
        % Plot axis labels
        xlabel(mainAxes,...
            sprintf('{\\it %s} / %s',...
            ad.control.axis.labels.y.measure,...
            ad.control.axis.labels.y.unit));
        ylabel(mainAxes,...
            sprintf('{\\it %s} / %s',...
            ad.control.axis.labels.z.measure,...
            ad.control.axis.labels.z.unit));
        % Display legend - internal function
        display_legend();
    otherwise
        msg = sprintf('Display type %s currently unsupported',displayType);
        add2status(msg);    
end

% Set grid
set(gca,'XGrid',ad.control.axis.grid.x);
set(gca,'YGrid',ad.control.axis.grid.y);
if (isequal(ad.control.axis.grid.x,'on'))
    set(gca,'XMinorGrid',ad.control.axis.grid.minor);
end
if (isequal(ad.control.axis.grid.y,'on'))
    set(gca,'YMinorGrid',ad.control.axis.grid.minor);
end

status = 0;

end


function display_legend()

mainWindow = guiGetWindowHandle;
% Get handles from main window
gh = guidata(mainWindow);

% Get appdata from main GUI
ad = getappdata(mainWindow);

mainAxes = findobj(allchild(gh.mainAxes_panel),'Type','axes');

% If there is no legend to be displayed
if (isequal(ad.control.axis.legend.location,'none'))
    legend('off');
    return;
end

legendLabels = cell(1,length(ad.control.spectra.visible));
for k = 1 : length(ad.control.spectra.visible)
    legendLabels{k} = strrep(ad.data{k}.label,'_','\_');
end

legend(mainAxes,legendLabels,'Location',ad.control.axis.legend.location);

end

function setMinMax()

% Get appdata from main GUI
mainWindow = guiGetWindowHandle;
ad = getappdata(mainWindow);

if (isempty(ad.control.spectra.visible))
    return;
end

% set min and max for spectra
if (ad.control.axis.limits.auto)
    xmin = zeros(length(ad.control.spectra.visible),1);
    xmax = zeros(length(ad.control.spectra.visible),1);
    ymin = zeros(length(ad.control.spectra.visible),1);
    ymax = zeros(length(ad.control.spectra.visible),1);
    zmin = zeros(length(ad.control.spectra.visible),1);
    zmax = zeros(length(ad.control.spectra.visible),1);
    for k=1:length(ad.control.spectra.visible)
        % For better code readability:
        idx = ad.control.spectra.visible(k);
        % be as robust as possible: if there is no axes, default is indices
        [y,x] = size(ad.data{idx}.data);
        x = linspace(1,x,x);
        y = linspace(1,y,y);
        if (isfield(ad.data{idx},'axes') ...
                && isfield(ad.data{idx}.axes,'x') ...
                && isfield(ad.data{idx}.axes.x,'values') ...
                && not (isempty(ad.data{idx}.axes.x.values)))
            x = ad.data{idx}.axes.x.values;
        end
        if (isfield(ad.data{idx},'axes') ...
                && isfield(ad.data{idx}.axes,'y') ...
                && isfield(ad.data{idx}.axes.y,'values') ...
                && not (isempty(ad.data{idx}.axes.y.values)))
            y = ad.data{idx}.axes.y.values;
        end
        xmin(k) = x(1);
        xmax(k) = x(end);
        ymin(k) = y(1);
        ymax(k) = y(end);
        % Apply thresholds
        if ad.data{idx}.display.threshold.min.enable
            ad.data{idx}.data(ad.data{idx}.data<...
                ad.data{idx}.display.threshold.min.value) = ...
                ad.data{idx}.display.threshold.min.value;
        end
        if ad.data{idx}.display.threshold.max.enable
            ad.data{idx}.data(ad.data{idx}.data>...
                ad.data{idx}.display.threshold.max.value) = ...
                ad.data{idx}.display.threshold.max.value;
        end
        switch ad.control.axis.normalisation
            case 'pkpk'
                zmin(k) = min(min(...
                    ad.data{idx}.data/...
                    (max(max(ad.data{idx}.data))-...
                    min(min(ad.data{idx}.data)))));
                zmax(k) = max(max(...
                    ad.data{idx}.data/...
                    (max(max(ad.data{idx}.data))-...
                    min(min(ad.data{idx}.data)))));
            case 'amplitude'
                zmin(k) = min(min(ad.data{idx}.data/...
                    max(max(ad.data{idx}.data))));
                zmax(k) = max(max(ad.data{idx}.data/...
                    max(max(ad.data{k}.data))));
            otherwise
                zmin(k) = ...
                    min(min(ad.data{idx}.data));
                zmax(k) = ...
                    max(max(ad.data{idx}.data));
        end
    end
    ad.control.axis.limits.x.min = min(xmin);
    ad.control.axis.limits.x.max = max(xmax);
    ad.control.axis.limits.y.min = min(ymin);
    ad.control.axis.limits.y.max = max(ymax);
    % Adjust z limits so that the axis limits are a bit wider than the
    % actual z limits
    zAmplitude = max(zmax)-min(zmin);
    ad.control.axis.limits.z.min = min(zmin)-0.025*zAmplitude;
    ad.control.axis.limits.z.max = max(zmax)+0.025*zAmplitude;
else
%     ad.control.axis.limits.x.min = ...
%         ad.data{active}.axes.x.values(1);
%     ad.control.axis.limits.x.max = ...
%         ad.data{active}.axes.x.values(end);
%     ad.control.axis.limits.y.min = ...
%         ad.data{active}.axes.y.values(1);
%     ad.control.axis.limits.y.max = ...
%         ad.data{active}.axes.y.values(end);
%     switch ad.control.axis.normalisation
%         case 'pkpk'
%             ad.control.axis.limits.z.min = ...
%                 min(min(...
%                 ad.data{active}.data/...
%                 (max(max(ad.data{active}.data))-...
%                 min(min(ad.data{active}.data)))));
%             ad.control.axis.limits.z.max = ...
%                 max(max(...
%                 ad.data{active}.data/...
%                 (max(max(ad.data{active}.data))-...
%                 min(min(ad.data{active}.data)))));
%         case 'amplitude'
%             ad.control.axis.limits.z.min = ...
%                 min(min(ad.data{active}.data/...
%                 max(max(ad.data{active}.data))));
%             ad.control.axis.limits.z.max = ...
%                 max(max(ad.data{active}.data/...
%                 max(max(ad.data{active}.data))));
%         otherwise
%             ad.control.axis.limits.z.min = ...
%                 min(min(ad.data{active}.data));
%             ad.control.axis.limits.z.max = ...
%                 max(max(ad.data{active}.data));
%     end
end

% update appdata of main window
setappdata(mainWindow,'control',ad.control);    

end