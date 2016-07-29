function varargout = ita_portaudio(varargin)
%ITA_PORTAUDIO - Manages sound in- and output
%
% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  20-May-2011 

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

%% Check if portaudio exists
persistent portaudioInstalled;
if isempty(portaudioInstalled)
    portaudioInstalled = exist('ita_portaudio_run','file') && exist('playrec','file');
end

%% Main Part
if portaudioInstalled % just run ita_portaudio
    try
        if nargout
            varargout = {ita_portaudio_run(varargin{:})};
        else % just play no record => no output argument
            ita_portaudio_run(varargin{:})
        end
    catch errmsg
        hPlayRec = ita_playrec;
        if hPlayRec('isInitialised')
            hPlayRec('reset'); %Reset on error, does not catch ctrl-c though
        end
        rethrow(errmsg);
    end
else
    if nargout % record 
        ita_verbose_info('Sorry, no audio record supported without playrec/portaudio',0);
        varargout{1} = varargin{1};
    end
    if isa(varargin{1},'itaAudio') % Playback
        if nargin > 1 % Additional arguments given
             ita_verbose_info('ita_portaudio: Dismissing further arguments',1);
        end
        ita_verbose_info('ita_portaudio: Using buildin sound routine',1);
        sound(varargin{1}.timeData,varargin{1}.samplingRate);
    else
        ita_verbose_info('I cannot play that',0);
    end
end

end