function result = ita_read_soundsolve(filename,varargin)
% Read ITA Sound Solve data. This could be in the format manitude and
% phase, or real and imaginary part. The automatic decision is based on the filename

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich - Aug 2010

if nargin == 0
    result{1}.extension = '.txt';
    result{1}.comment = 'ITA Sound Solve (*.txt)';
    return
else

    
end

%% import data

a = importdata(filename);
result = itaResult;
result.freqVector = a(:,1);
realpart   = a(:,2);

if size(a,2) == 3
    imagpart = a(:,3);
    
    if findstr(filename,'Norm_ph')
        % magnitude and phase
        result.freqData = realpart .* exp(1i*imagpart / 180 * pi);
    else
        % real and imag
        result.freqData = realpart + 1i * imagpart;
    end
end
end
