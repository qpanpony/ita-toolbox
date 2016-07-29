function display(this)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


global lastDiplayedVariableName
lastDiplayedVariableName = inputname(1);

display@itaSuper(this);

% only continue if it is a single instance
if numel(this) > 1
    return;
end

if ita_preferences('dispVerboseFunctions')
    if isFreq(this)
        display_line4commands({'overloaded plots..', {'__.plot'},{'__.bar'}},lastDiplayedVariableName);
        display_line4commands({'cursors plots.....', {'__.plot_freq'}, {'__.plot_freq_phase'}, {'__.plot_freq_groupdelay'}},lastDiplayedVariableName);
    else
        display_line4commands({'overloaded plots..', {'__.plot'},{'hist(__)'}},lastDiplayedVariableName);
        display_line4commands({'cursors plots.....', {'__.plot_time'}, {'__.plot_time_dB'}},lastDiplayedVariableName);
    end
        display_line4commands({'some GUIs.........', {'ita_write'}, {'ita_read'}, {'ita_generate'},{'ita_preferences'}},lastDiplayedVariableName);

    %     display_line4commands({'clean up..........', {'ccx'}, {'clc'}, {'close all'}, {'dbquit all'}, {'why'}});
    display_line4commands({'clean up..........', {'ccx'}, {'clc'}, {'close all'}, {'dbquit all'},{'ita_preferences(''dispVerboseFunctions'',0); display(__)', 'Hide all this...!'}}, lastDiplayedVariableName);
    
    %     display_line4commands({'                                                      ', ...
    %         {'ita_preferences(''dispVerboseFunctions'',0); display(__)', 'Hide all this...!'}}, lastDiplayedVariableName);
else
    display_line4commands({'                                                      ', ...
        {'ita_preferences(''dispVerboseFunctions'',1); display(__)', 'What to do...?'}}, lastDiplayedVariableName);
end
end
