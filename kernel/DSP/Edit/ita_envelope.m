function varargout = ita_envelope(varargin)
%ita_envelope - Get envelope of a time signal
%  This function calculates the envelope of a time signal by using the
%  hilbert transformation.
%
%  Syntax: audioObj = ita_envelope(asData)
%
%   See also ita_uncle_hilbert, ita_minimumphase, ita_zerophase.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_envelope">doc ita_envelope</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  01-Oct-2008 

%% Initialization
narginchk(1,1);
data = varargin{1};
if ~isa(data, 'itaAudio')
    error('wrong input (itaAudio expected)')
end

%% Calculate envelope function

% old
% tmp         = hilbert(data.time, data.nSamples*2); 
% data.time   = abs(tmp(1:data.nSamples,:));

 % 6% faster
nFFT    = data.nSamples*2;
if rem(nFFT,2)
    error('odd samples not supported')
end
spk     = fft(data.timeData, nFFT);
win     = zeros(nFFT,1);
win([1 nFFT/2+1]) = 1;
win(2:nFFT/2) = 2;
tmp = ifft(bsxfun(@times, spk, win));
data.timeData = abs(tmp(1:data.nSamples,:));

%% Add history line
data = ita_metainfo_add_historyline(data,mfilename,varargin);

%% Find output parameters
varargout(1) = {data};
%end function
end