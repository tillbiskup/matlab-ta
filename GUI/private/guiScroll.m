function guiScroll(dimension,step)
% GUISCROLL Private function to handle scrolling through datasets
%
% Arguments:
%     dimension - char (x,y,z)
%     step      - scalar|string
%                 if string, one of {'first','last','end'}

% Copyright (c) 2013, Till Biskup
% 2013-07-12

try
    % Get appdata of main window
    mainWindow = TAguiGetWindowHandle();
    ad = getappdata(mainWindow);
    % Get guihandles of main window
    gh = guihandles(mainWindow);
    
    % For convenience and shorter lines
    active = ad.control.spectra.active;
    
    % Get dimension of active dataset
    [y,x] = size(ad.data{active}.data);
    
    % Set position for dataset
    switch lower(dimension)
        case 'x'
            if ischar(step) && strcmpi(step,'first')
                ad.data{active}.display.position.x = 1;
            elseif ischar(step) && any(strcmpi(step,{'last','end'}))
                ad.data{active}.display.position.x = x;
            elseif isscalar(step)
                ad.data{active}.display.position.x = ...
                    ad.data{active}.display.position.x + step;
                % Check for boundaries
                if (ad.data{active}.display.position.x < 1)
                    ad.data{active}.display.position.x = 1;
                end
                if (ad.data{active}.display.position.x > x)
                    ad.data{active}.display.position.x = x;
                end
            else
                return;
            end
        case 'y'
            if ischar(step) && strcmpi(step,'first')
                ad.data{active}.display.position.y = 1;
            elseif ischar(step) && any(strcmpi(step,{'last','end'}))
                ad.data{active}.display.position.y = y;
            elseif isscalar(step)
                ad.data{active}.display.position.y = ...
                    ad.data{active}.display.position.y + step;
                % Check for boundaries
                if (ad.data{active}.display.position.y < 1)
                    ad.data{active}.display.position.y = 1;
                end
                if (ad.data{active}.display.position.y > y)
                    ad.data{active}.display.position.y = y;
                end
            else
                return;
            end
        case 'z'
    end
    
    % Set slider values depending on display type settings
    switch ad.control.axis.displayType
        case '1D along x'
            set(gh.vert1_slider,'Value',ad.data{active}.display.position.y);
        case '1D along y'
            set(gh.vert1_slider,'Value',ad.data{active}.display.position.x);
        otherwise
            st = dbstack;
            TAmsg(...
                [st.name ' :' ...
                'Display type "' ad.control.axis.displayType '" '...
                'currently unsupported'],'warning');
    end
    
    % Update appdata of main window
    setappdata(mainWindow,'data',ad.data);
    
    % Update slider panel
    update_sliderPanel();
    
    %Update main axis
    update_mainAxis();
catch exception
    try
        msgStr = ['An exception occurred in ' ...
            exception.stack(1).name  '.'];
        TAmsg(msgStr,'error');
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
