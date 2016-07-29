% interpolate modelling data and set data to zero outside of modeling range

% <ITA-Toolbox>
% This file is part of the application Impedance_Calculator for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

function [interpData] = interp_zeroextrap(freq, data, newFreq, modus)

if (size(data,1)==1) || (size(data,2)==1)
    % Make sure all vectors are row vectors
    freqHelp(1,:)    = freq;
    dataHelp(1,:)    = data;
    newFreqHelp(1,:) = newFreq;
    freq             = freqHelp;
    data             = dataHelp;
    newFreq          = newFreqHelp;
    
    lenF             = length(freq);
    lenNF            = length(newFreq);
    idxS             = 1;
    idxE             = lenNF;
    interpData       = zeros(1, lenNF);
    
    % Append zeros where impedance data is not available
    while newFreq(idxS) < min(freq)
        idxS = idxS+1;
    end
    while newFreq(idxE) > max(freq)
        idxE = idxE-1;
    end
    interpData(idxS:idxE) = interp1(freq, data, newFreq(idxS:idxE), modus);
else
    error('FUNCTION:INTERP_ZEROEXTRAP: Invalid first input argument.');
end
