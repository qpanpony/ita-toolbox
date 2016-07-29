function [fftDegree, nSamples] = ita_fftDegree(value)
%ITA_FFTDEGREE - Distinguis fftDegree and number of Samples
%  This function converts fft degree or number of samples as input argument
%  to the fftDegree corresponding to an even number of samples .
%
%  Syntax:
%   [fftDegree] = ita_fftDegree(value)
%   [fftDegree nSamples] = ita_fftDegree(value)
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_fftDegree">doc ita_fftDegree</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  13-Jun-2012 


%% Call nSamples and get fftDegree
[nSamples, fftDegree] = ita_nSamples(value);
    
end