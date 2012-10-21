function status = switchMainPanel(panelName)
% SWITCHMAINPANEL Private function to switch between panels of the main GUI
%
% panelName - string with the name of the panel, i.e. the value of the
%             return value of the buttongroup keypress event (aka the
%             'String' value of the respective button pressed)
%
% status    - return value of the function. Either 0 (OK) or -1 (failed)

% (c) 2011-12, Till Biskup
% 2012-10-21

try
    % Get handles of main window
    mainWindow = TAguiGetWindowHandle;
    gh = guihandles(mainWindow);
    
    panels = [...
        gh.welcome_panel ...
        gh.load_panel ...
        gh.data_panel ...
        gh.slider_panel ...
        gh.measure_panel ...
        gh.display_panel ...
        gh.processing_panel ...
        gh.analysis_panel ...
        gh.mfe_panel ...
        gh.configure_panel ...
        ];
    buttons = [...
        gh.tbLoad ...
        gh.tbDatasets ...
        gh.tbSlider ...
        gh.tbMeasure ...
        gh.tbDisplay ...
        gh.tbProcessing ...
        gh.tbAnalysis ...
        gh.tbMFE ...
        gh.tbConfigure ...
        ];
    
    switch panelName
        case 'Load'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.load_panel,'Visible','on');
            set(gh.tbLoad,'Value',1);
        case 'Datasets'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.data_panel,'Visible','on');
            set(gh.tbDatasets,'Value',1);
            % Update both list boxes
            update_invisibleSpectra();
            update_visibleSpectra();
            update_datasetPanel();
        case 'Slider'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.slider_panel,'Visible','on');
            set(gh.tbSlider,'Value',1);
            % Update slider panel
            update_sliderPanel();
        case 'Measure'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.measure_panel,'Visible','on');
            set(gh.tbMeasure,'Value',1);
            % Update measure panel
            update_measurePanel();
        case 'Display'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.display_panel,'Visible','on');
            set(gh.tbDisplay,'Value',1);
            % Update display panel
            update_displayPanel();
        case 'Processing'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.processing_panel,'Visible','on');
            set(gh.tbProcessing,'Value',1);
            % Update processing panel
            update_processingPanel();
        case 'Analysis'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.analysis_panel,'Visible','on');
            set(gh.tbAnalysis,'Value',1);
        case 'MFE'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.mfe_panel,'Visible','on');
            set(gh.tbMFE,'Value',1);
            % Update MFE panel
            update_MFEPanel();
        case 'Configure'
            set(panels,'Visible','off');
            set(buttons,'Value',0);
            set(gh.configure_panel,'Visible','on');
            set(gh.tbConfigure,'Value',1);
    end
    
    status = 0;
catch exception
    try
        TAgui_bugreportwindow(exception);
    catch exception2
        % If even displaying the bug report window fails, what lasts to do?
        exception = addCause(exception2, exception);
        throw(exception);
    end
    status = -1;
end

end