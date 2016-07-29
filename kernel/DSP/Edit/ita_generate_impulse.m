function varargout = ita_generate_impulse(varargin)
%ITA_GENERATE_IMPULSE - Generate a dirac impulse
%  This function generates a dirac delta impulse 
%
%  Syntax:
%   audioObjOut = ita_generate_sweep(audioObjIn, options)
%
%   Options (default):
%           'fftDegree' (16):               fftDegree / or number of samples
%           'samplingRate' (44100):         samplingRate
%  See also:
%   ita_generate, ita_generate_sweep
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_generate_sweep">doc ita_generate_sweep</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  20-Apr-2011

%% Initialization and Input Parsing
sArgs      = struct('fftDegree', ita_preferences('fftDegree'),'samplingRate',ita_preferences('samplingRate'),'gui',false);
[sArgs]    = ita_parse_arguments(sArgs,varargin);

if sArgs.gui %automatic gui
    sArgs.varname = 'outputVariableName';
    [sArgs] = ita_parse_arguments_gui(sArgs);
    if isempty(sArgs) % user has cancelled
        ita_verbose_info('Operation cancelled by user',1);
        return;
    end
end

%% generate impulse and settings for itaAudio
audioObj = itaAudio;
audioObj.samplingRate = sArgs.samplingRate;
audioObj.fftDegree    = sArgs.fftDegree;
audioObj.time         = audioObj.timeVector.*0;
audioObj.time(1)      = 1;

audioObj.comment         = 'Dirac Impulse';
audioObj.channelNames{1} = audioObj.comment;
audioObj.signalType = 'energy';

%% Add history line
audioObj = ita_metainfo_add_historyline(audioObj,mfilename,varargin);

%% Set Output
if sArgs.gui
   ita_setinbase(sArgs.varname,audioObj); 
end
varargout(1) = {audioObj};

%end function
end