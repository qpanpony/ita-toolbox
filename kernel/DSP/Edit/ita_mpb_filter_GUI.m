function varargout = ita_mpb_filter_GUI(varargin)
%ITA_MPB_FILTER_GUI - Filtering audio data.
%  see also: ita_mpb_filter

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>



%% Generate GUI
if nargin == 0 % generate GUI
    ele = 1;
    pList{ele}.description = 'itaAudio';
    pList{ele}.helptext    = 'This is the itaAudio Object for amplification or attenuation';
    pList{ele}.datatype    = 'itaAudio';
    pList{ele}.default     = '';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Low Frequency';
    pList{ele}.helptext    = 'Low cutoff frequency, could also be 0, then it is a lowpass';
    pList{ele}.datatype    = 'int';
    pList{ele}.default     = 20;
    
    ele = length(pList) + 1;
    pList{ele}.description = 'High Frequency';
    pList{ele}.helptext    = 'High cutoff frequency, could also be 0, then it is a highpass';
    pList{ele}.datatype    = 'int';
    pList{ele}.default     = 16000;
    
    ele = length(pList) + 1;
    pList{ele}.datatype    = 'line';
    
    ele = length(pList) + 1;
    pList{ele}.datatype    = 'text';
    pList{ele}.description = 'Advanced Settings';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Order';
    pList{ele}.helptext    = 'Specify Filter Order';
    pList{ele}.datatype    = 'int';
    pList{ele}.default     = 12;
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Class';
    pList{ele}.helptext    = 'Specify Filter Class 0,1 or 2';
    pList{ele}.datatype    = 'int';
    pList{ele}.default     = 0;
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Type';
    pList{ele}.helptext    = 'Specify Filter Type - Sorry, currently under construction!';
    pList{ele}.datatype    = 'char_popup';
    pList{ele}.default     = 'Butterworth';
    pList{ele}.list        = 'Butterworth';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Zerophase';
    pList{ele}.helptext    = 'Filter without applying a change in the phase (zerophase filter). This has a symmetric IR! (acausal)';
    pList{ele}.datatype    = 'bool';
    pList{ele}.default     = false;

    ele = length(pList) + 1;
    pList{ele}.datatype    = 'line';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Name of Result'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
    pList{ele}.datatype    = 'itaAudioResult'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = ['result_' mfilename];
    
    %call gui
    pList = ita_parametric_GUI(pList,[mfilename ' - Bandpass Filter for itaAudio objects']);
    if ~isempty(pList)
        if pList{7}
            result = ita_mpb_filter(pList{1},[pList{2} pList{3}],'order',pList{4},'class',pList{5},'zerophase');
        else
            result = ita_mpb_filter(pList{1},[pList{2} pList{3}],'order',pList{4},'class',pList{5});
        end
        if nargout == 1
            varargout{1} = result;
        end
        ita_setinbase(pList{8}, result);
    end
end

%% Output
if nargout == 1
    varargout{1} = result;
end