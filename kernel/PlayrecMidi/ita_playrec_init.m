function ita_playrec_init(varargin)
%ITA_PLAYREC_INIT - Initialize Playrec
%  This function initializes creates a handle for playrec and initialzes
%  playrec and PortAudio.
%
%  Syntax:
%   ita_playrec_init(options)
%
%  Options:
%           'handle'       :   handle to playrec
%           'samplingRate' :   sampling rate of the audio interface
%           'recDeviceID'  :   portaudio device id of the recording device
%           'playDeviceID' :   portaudio device id of the playback device
%
%
%  Example:
%   ita_playrec_init()
%
%  See also:
%   ita_portaudio, ita_portaudio_run, ita_playrec
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_playrec_init">doc ita_playrec_init</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Marco Berzborn -- Email: marco.berzborn@akustik.rwth-aachen.de
% Created:  08-May-2017 

sArgs = struct('handle', [], ...
               'samplingRate', ita_preferences('samplingRate'), ...
               'playDeviceID', ita_preferences('playDeviceID'), ...
               'recDeviceID', ita_preferences('recDeviceID'));
sArgs = ita_parse_arguments(sArgs, varargin);

if isempty(sArgs.handle)
    hPlayRec = ita_playrec;
else
    hPlayRec = sArgs.handle;
end

if ~hPlayRec('isInitialised')
    hPlayRec('init', sArgs.samplingRate, sArgs.playDeviceID, sArgs.recDeviceID);
    ita_verbose_info('Initializing Playrec... waiting 1 second...', 0);
    pause(1);
else
    ita_verbose_info('Playrec is already initialized.',0);
end
%end function
end