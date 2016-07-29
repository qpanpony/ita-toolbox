function varargout = ita_filter_LiRi(varargin)
%ITA_FILTER_LIRI - Linkwitz Riley Filter
%  This function performs Linkwitz Riley filtering on itaAudio objects.
%
%  Syntax:
%   audioObjOut = ita_filter_LiRi(audioObjIn,freqVvec, options)
%
%   Options (default):
%           'order' (8): filter order
%
%  Example:
%   audioObjOut = ita_filter_LiRi(audioObjIn)
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_filter_LiRi">doc ita_filter_LiRi</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  05-Jan-2010 

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudioFrequency','pos2_freqvec','vector', 'order', 8, 'zerophase',false);
[input,freqvec,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% parse freqvec
if length(freqvec) ~= 2
    error([thisFuncStr 'Frequency Vector is no correct. [low_freq high_freq]'])
end
passType = 'bandpass';
if freqvec(1) == 0
    freqvec = freqvec(2);
    passType = 'low';
elseif freqvec(2) == 0
    freqvec = freqvec(1);
    passType = 'high';
end
%% create LiRi from butterworth

nBins   = input.nBins;
NyqFreq = input.samplingRate/2;

butterorder  = sArgs.order/2; % LiRi-Filter order is twice the butter order
[z,p,k]      = butter(butterorder, freqvec./NyqFreq, passType);
[sos,g]      = zp2sos(z,p,k);	     % Convert to SOS form
Hd           = dfilt.df2tsos(sos,g);   % Create a dfilt object
[butterFilt] = freqz(Hd, nBins); 
liriFilt = butterFilt .* butterFilt;

liriFR   = itaAudio(liriFilt,input.samplingRate,'freq');
liriFR.signalType = 'energy';

if sArgs.zerophase
    liriFR = ita_zerophase(liriFR);
end

%% apply filtering
input = input * liriFR; 

%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {input}; 

%end function
end