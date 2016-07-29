function varargout = ita_tpa_AudioMatrix2Double(A_audio)
%This test function takes a matrix of itaAudio and converts in a matrix of
%frequency double values. 
% varargout = ita_tpa_AudioMatrix2Double(A_audio)
% Lian Gomes - 15/7/2011
% lian.cercal.gomes@gmailcom

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

A_double = zeros(size(A_audio,1),size(A_audio,2),A_audio(1,1).nBins);

for idx = 1:size(A_double,1)
    for jdx = 1:size(A_double,2)
        
        A_double(idx,jdx,:) = A_audio(idx,jdx).freq;
        
    end
end

varargout{1} = A_double;

end