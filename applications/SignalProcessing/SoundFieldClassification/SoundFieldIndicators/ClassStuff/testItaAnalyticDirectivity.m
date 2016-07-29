%test: itaAnalyticDirectivity

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


a = itaAnalyticDirectivity;
a.freq = zeros(513,1,2); % currently necessary
a.channelCoordinates = itaCoordinates([0 0.1 0; 0 -0.1 0],'cart');
a.functionHandle = @ita_analytic_directivity_sample_function;

a.getNearestFreq(itaCoordinates([2 pi/2 pi/2],'sph'));