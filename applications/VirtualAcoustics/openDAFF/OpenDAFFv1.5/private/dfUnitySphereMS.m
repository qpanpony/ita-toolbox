function [ freqs, mags, metadata ] = dfOmnidirectionalMS( alpha, beta, basepath )
% Omnidirectional magnitude spectrum

% <ITA-Toolbox>
% This file is part of the application openDAFF for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

           
    % Third-octave resolution
    freqs = [20 25 31.5 40 50 63 80 100 125 160 ...
             200 250 315 400 500 630 800 1000 1250 1600 ...
             2000 2500 3150 4000 5000 6300 8000 10000 12500 16000 20000];
    
    channels = 1;
    mags = zeros(channels, length(freqs));
    metadata.desc = 'Omnidirectional magnitude spectrum';
    
    for c=1:channels
        for f=1:length(freqs)
            mags(c,f) = 1;
        end
    end   
end


