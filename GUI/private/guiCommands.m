% Script (NOT a function!) including the assignment of GUI command line
% commands to Matlab(tm) functions

% Copyright (c) 2013, Till Biskup
% 2013-07-15

% PLEASE NOTE: All variables from within the context of the calling
% function (normally, this should be "TAguiCommand") are accessible
% within this script. On the other hand, all variables assigned within this
% script will be accessible within the scope of the calling function.
% Therefore, the last task of this script is to tidy up a bit, such as not
% to leave any additional variables that might lead to confusion later on.

% Extended version: cell array allowing for optional arguments
% column 1: string; command as entered on the command line
% column 2: string; actual Matlab command issued
% column 3: additional argument(s) (in case of more than one, cell array)
% column 4: logical; condition (important: set to true by default)
cmdMatch = {...
    'info',   'TAgui_infowindow',             '', true; ...
    'acc',    'TAgui_ACCwindow',              '', true; ...
    'mfe',    'TAgui_MFEwindow',              '', true; ...
    'status', 'TAgui_statuswindow',           '', true; ...
    'combine','TAgui_combinewindow',          '', true; ...
    };

% Tidy up
clear label;
