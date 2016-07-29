function ita_roomacoustics_IACC_gui
%ITA_ROOMACOUSTICS_IACC_GUI - GUI for ita_roomacoustics_IACC
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   ita_roomacoustics_IACC() - Calls this GUI
%
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_roomacoustics_IACC_gui">doc ita_roomacoustics_IACC_gui</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  16-May-2011


ele = 1;
pList{ele}.description = 'First itaAudio';
pList{ele}.helptext    = 'This is the input itaAudio';
pList{ele}.datatype    = 'itaAudio';
pList{ele}.class       = 'itaAudio';
pList{ele}.default     = '';

ele = ele + 1;
pList{ele}.description = 'Name of Result'; %this text will be shown in the GUI
pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
pList{ele}.datatype    = 'itaAudioResult'; %based on this type a different row of elements has to drawn in the GUI
pList{ele}.default     = 'IACC_early';

% ele = ele + 1;
% pList{ele}.description = 'Shift IR';
% pList{ele}.helptext    = 'Shift the IR according to ISO 3382 ?' ;
% pList{ele}.datatype    = 'bool';
% pList{ele}.default     = false;





output = ita_parametric_GUI(pList, 'Interaural cross correlation');
%%
if ~isempty(output)
    %     tmp = ita_roomacoustics_IACC(output{1} , 'shift', output{3});
    tmp = ita_roomacoustics_IACC(output{1} );
    ita_setinbase(output{2}, tmp );
end





%end function
end