function display(this)
%show the Obj

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

if isnan(this.samplingRate)
    result = ['The sampling rate is not yet set. Set it to ' ...
        '<a href = " matlab: ' lastDiplayedVariableName '.samplingRate = 44100">44100</a> or ' ...
        '<a href = " matlab: ' lastDiplayedVariableName '.samplingRate = 48000">48000</a>.\n'];
    fprintf(1, result)
else
   
    if ita_preferences('dispVerboseFunctions')
        
        display_line4commands({'have a look ......', {'plot(__.'')'}, {'plot(__'')'},{'builtin(''disp'',__)','Show Inside of Class'}},lastDiplayedVariableName);
        display_line4commands({'cursors plots ....', {'__.plot_time'}, {'__.plot_time_dB'}, {'__.plot_freq'}, {'__.plot_freq_phase'}, {'__.plot_all'}},lastDiplayedVariableName);
        display_line4commands({'clean up .........', {'ccx'}, {'clc'}, {'close all'}, {'__.showHistory'},...
            {'ita_preferences(''dispVerboseFunctions'',0); display(__)', 'Hide all this...!'}}, lastDiplayedVariableName);
        %
    else
        display_line4commands({'                                                      ', ...
            {'ita_preferences(''dispVerboseFunctions'',1); display(__)', 'What to do...?'}}, lastDiplayedVariableName);
    end
end
end
