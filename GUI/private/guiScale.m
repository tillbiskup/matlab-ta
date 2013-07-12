function guiScale(dimension,step)
% GUISCALE Private function to handle displacing of datasets
%
% Arguments:
%     dimension - char (x,y,z)
%     step      - scalar|string
%                 if string, one of {'first','last','end'}

% (c) 2013, Till Biskup
% 2013-07-12

try
    % Get appdata of main window
    mainWindow = TAguiGetWindowHandle();
    ad = getappdata(mainWindow);
    % Get guihandles of main window
    gh = guihandles(mainWindow);
    
    % For convenience and shorter lines
    active = ad.control.spectra.active;
    
    vMax = [0.5 2];
    vStep = 0.001;
    
    % Set position for dataset
    switch lower(dimension)
        case 'x'
            switch ad.control.axis.displayType
                case '1D along x'
                    if ischar(step) && strcmpi(step,'first')
                        ad.data{active}.display.scaling.x = vMax(1);
                    elseif ischar(step) && any(strcmpi(step,{'last','end'}))
                        ad.data{active}.display.scaling.x = vMax(2);
                    elseif isscalar(step)
                        ad.data{active}.display.scaling.x = ...
                            ad.data{active}.display.scaling.x + step*vStep;
                        % Check for boundaries
                        if (ad.data{active}.display.scaling.x < vMax(1))
                            ad.data{active}.display.scaling.x = vMax(1);
                        end
                        if (ad.data{active}.display.scaling.x > vMax(2))
                            ad.data{active}.display.scaling.x = vMax(2);
                        end
                    else
                        return;
                    end
                    if ad.data{active}.display.scaling.x > 1
                        set(gh.horz1_slider,'Value',...
                            ad.data{active}.display.scaling.x-1);
                    elseif ad.data{active}.display.scaling.x < 1
                        set(gh.horz1_slider,'Value',...
                            -2*ad.data{active}.display.scaling.x);
                    else
                        set(gh.horz1_slider,'Value',0);
                    end
                case '1D along y'
                    if ischar(step) && strcmpi(step,'first')
                        ad.data{active}.display.scaling.y = vMax(1);
                    elseif ischar(step) && any(strcmpi(step,{'last','end'}))
                        ad.data{active}.display.scaling.y = vMax(2);
                    elseif isscalar(step)
                        ad.data{active}.display.scaling.y = ...
                            ad.data{active}.display.scaling.y + step*vStep;
                        % Check for boundaries
                        if (ad.data{active}.display.scaling.y < vMax(1))
                            ad.data{active}.display.scaling.y = vMax(1);
                        end
                        if (ad.data{active}.display.scaling.y > vMax(2))
                            ad.data{active}.display.scaling.y = vMax(2);
                        end
                    else
                        return;
                    end
                    if ad.data{active}.display.scaling.y > 1
                        set(gh.horz1_slider,'Value',...
                            ad.data{active}.display.scaling.y-1);
                    elseif ad.data{active}.display.scaling.y < 1
                        set(gh.horz1_slider,'Value',...
                            -2*ad.data{active}.display.scaling.y);
                    else
                        set(gh.horz1_slider,'Value',0);
                    end
            end
        case 'y'
            if ischar(step) && strcmpi(step,'first')
                ad.data{active}.display.scaling.z = vMax(1);
            elseif ischar(step) && any(strcmpi(step,{'last','end'}))
                ad.data{active}.display.scaling.z = vMax(2);
            elseif isscalar(step)
                ad.data{active}.display.scaling.z = ...
                    ad.data{active}.display.scaling.z + (step*vStep);
                % Check for boundaries
                if (ad.data{active}.display.scaling.z < vMax(1))
                    ad.data{active}.display.scaling.z = vMax(1);
                end
                if (ad.data{active}.display.scaling.z > vMax(2))
                    ad.data{active}.display.scaling.z = vMax(2);
                end
            else
                return;
            end
            if ad.data{active}.display.scaling.y > 1
                set(gh.vert2_slider,'Value',...
                    ad.data{active}.display.scaling.y-1);
            elseif ad.data{active}.display.scaling.y < 1
                set(gh.vert2_slider,'Value',...
                    -2*ad.data{active}.display.scaling.y);
            else
                set(gh.vert2_slider,'Value',0);
            end
        case 'z'
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