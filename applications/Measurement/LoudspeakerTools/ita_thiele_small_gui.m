function varargout = ita_thiele_small_gui(varargin)
%ITA_THIELE_SMALL_GUI - GUI for thiele small
%  This function makes a nice GUI
%
%  Syntax:
%   audioObjOut = ita_thiele_small_gui(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_thiele_small_gui(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_thiele_small_gui">doc ita_thiele_small_gui</a>

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  17-May-2011 


%% GUI

    ele = 1;
    pList{ele}.description = 'Z without mass';
    pList{ele}.helptext    = 'Impedance without additional mass';
    pList{ele}.datatype    = 'itaAudio';
    pList{ele}.default     = '';
    
    ele = 2;
    pList{ele}.description = 'Z with mass';
    pList{ele}.helptext    = 'Impedance with additional mass';
    pList{ele}.datatype    = 'itaAudio';
    pList{ele}.default     = '';
    
    ele = 3;
    pList{ele}.description = 'mass [kg]';
    pList{ele}.helptext    = 'Added mass';
    pList{ele}.datatype    = 'int';
    pList{ele}.default     =  0.005;
    
    ele = 4;
    pList{ele}.description = 'Diameter [m]';
    pList{ele}.helptext    = 'Diameter of the loudspeaker';
    pList{ele}.datatype    = 'int';
    pList{ele}.default     =  0.1;
    
    ele = ele+1;
    pList{ele}.description = 'Freq Range';
    pList{ele}.helptext    = 'Frequency range for the evaluation';
    pList{ele}.datatype    = 'int';
    pList{ele}.default     = [5 1000];
    
    ele = ele+1;
    pList{ele}.description = 'L_e';
    pList{ele}.helptext    = 'Calculate L_e (by curvefitting)';
    pList{ele}.datatype    = 'bool';
    pList{ele}.default     = false;
    
    ele = ele+1;
    pList{ele}.datatype    = 'line';
    
    ele = ele+1;
    pList{ele}.description = 'Name of Result'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
    pList{ele}.datatype    = 'itaAudioResult'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = ['result_' mfilename];
    
    
    
    %call gui
    pList = ita_parametric_GUI(pList,[mfilename ' - Thiele-Small GUI']);
    if ~isempty(pList)
        result = ita_thiele_small(pList{1},pList{2},pList{3},pList{4},'frequency_limits',pList{5},'L_e',pList{6});
        if nargout == 1
            varargout{1} = result;
        end
    end
    return;

%end function
end