function varargout = ita_roomacoustics_filterGUI(varargin)
%ITA_ROOMACOUSTICS_FILTERGUI - octave or third band filter
%  This function provides a GUI for third or octave band filtering
%
%  Syntax:
%   audioObjOut = ita_roomacoustics_filterGUI()
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_roomacoustics_filterGUI">doc ita_roomacoustics_filterGUI</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Jonathan Oberreuter -- Email: jonathan.oberreuter@akustik.rwth-aachen.de
% Created:  25-Jun-2010 



%% Variables to use from ita_preferences
freqrange = ita_preferences('freqRange');
%% GUI
pList = {};
name = 'Filter';

ele = length(pList) + 1;
pList{ele}.description = 'First itaAudio';
pList{ele}.helptext    = 'This is the first itaAudio for addition';
pList{ele}.datatype    = 'itaAudio';
pList{ele}.default     = '';

ele = length(pList) + 1;
pList{ele}.description = 'Low Frequency';
pList{ele}.helptext    = 'Low cutoff frequency, could also be 0, then it is a lowpass';
pList{ele}.datatype    = 'int';
pList{ele}.default     = freqrange(1);

ele = length(pList) + 1;
pList{ele}.description = 'High Frequency';
pList{ele}.helptext    = 'High cutoff frequency, could also be 0, then it is a highpass';
pList{ele}.datatype    = 'int';
pList{ele}.default     = freqrange(2);

ele = length(pList) + 1;
pList{ele}.datatype    = 'line';

ele = length(pList) + 1;
pList{ele}.datatype    = 'text';
pList{ele}.description = 'Advanced Settings';

    
ele = length(pList) + 1;
pList{ele}.description = 'Bands per Octave';
pList{ele}.helptext    = 'Octave or Third' ;
pList{ele}.datatype    = 'int';
pList{ele}.default     = ita_preferences('bandsperoctave');
    
ele = length(pList) + 1;
pList{ele}.description = 'Name of Result'; %this text will be shown in the GUI
pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
pList{ele}.datatype    = 'itaAudioResult'; %based on this type a different row of elements has to drawn in the GUI
pList{ele}.default     = ['result_bandfiltered' ];

ele = length(pList) + 1;
pList{ele}.description = 'zerophase'; %this text will be shown in the GUI
pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
pList{ele}.datatype    = 'bool'; %based on this type a different row of elements has to drawn in the GUI
pList{ele}.default     = true;

ele = length(pList) + 1;
pList{ele}.description = 'Order'; %this text will be shown in the GUI
pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
pList{ele}.datatype    = 'int'; %based on this type a different row of elements has to drawn in the GUI
pList{ele}.default     = 8;


%% Call GUI
pOutList = ita_parametric_GUI(pList,name);

if ~isempty(pOutList)
    var = ita_mpb_filter(pOutList{1},'oct',pOutList{2} ,'zerophase','order',pOutList{4});
    ita_setinbase(pOutList{3},var);
else
    varargout{1} = [];
end    
end