function [nSamples, fftDegree] = ita_nSamples(value)
%ITA_FFTDEGREE - Distinguish fftDegree and number of Samples
%  This function converts fft degree or number of samples as input argument
%  to even number of samples and corresponding fftDegree (if requested) at the output.
%
%  Syntax:
%   [nSamples fftDegree] = ita_nSamples(value)
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_nSamples">doc ita_nSamples</a>
%
%   See also:
%       ita_fftDegree, itaAudio

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  13-Jun-2012 


%% distinguish
if value < 32 % then we have an fftDegree
    nSamples = 2.^value;
else
    nSamples = value; % we have number of samples given
end
    
%% make it natural and even!
nSamples = round(nSamples / 2) * 2;

%% get corresponding fft degree
fftDegree = log2(nSamples);
    
end