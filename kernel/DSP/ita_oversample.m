function varargout = ita_oversample(varargin)
%ITA_OVERSAMPLE - TODO HUHU Documentation
%  This function TODO HUHU Documentation
%
%  Syntax:
%   audioObjOut = ita_oversample(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_oversample(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_oversample">doc ita_oversample</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Daniel Cragg -- Email: d.cragg@web.de
% Created:  11-Nov-2010


%% Initialization and Input Parsing
sArgs               = struct('pos1_data','itaAudio', 'pos2_value', 'double');
[input,coeff,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% oversampling - cragg version
% % % b           = input;                              % Audiodatei
% % % oldfreqvec  = b.freqVector;
% % % res         = b.freqVector(3)-b.freqVector(2);    % Auflösung der Erweiterung!
% % % newfreqvec  = (0:res:coeff*(max(oldfreqvec)))';
% % % oldfreq     = b.freq;
% % % zeroNo=size (newfreqvec,1)- size (oldfreqvec,1);
% % % newfreq     = [oldfreq; zeros(zeroNo,b.nChannels)];

%% oversampling - pdi version
result  = 0 * input;
newfreq = input.freq(1:end-1,:); %no Nyquist

result.samplingRate = input.samplingRate * coeff;
result.trackLength = double(input.trackLength);
result.freq(1:size(newfreq,1),:) = newfreq;

%% Set Output
varargout(1) = {result};

%end function
end