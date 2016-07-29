% TODO HUHU Documenatation

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

function [folderInfo, polarSPK] = ita_make_spheredata(audioCell, frequencyVector)

folderInfo = ita_check4polardata(audioCell);

% if it is polar data...
if exist('folderInfo','var') && strcmp(folderInfo.type, 'polar')
    
    freqs = audioCell{1}.freqVector;
    if numel(frequencyVector) < 1
        folderInfo.usedFreqs = logspace(log10(20),log10(freqs(end)-1), ...
            round(12*log2(freqs(end)/freqs(2)))); % -1 to avois error
    else
        folderInfo.usedFreqs = frequencyVector;
    end
    
    index = zeros(1,length(folderInfo.usedFreqs));
    disp('TO DO: set the frequencies (now in half tone steps from 20 Hz on)')
    
    for n=1:length(folderInfo.usedFreqs)
        index(n) = find(folderInfo.usedFreqs(n) < freqs,1);
    end;
    
    polarSPK = zeros([size(folderInfo.theta) length(folderInfo.usedFreqs)]);
    
    for n = 1:numel(audioCell)
        [V,H] = ...
            find(strcmp(audioCell{n}.Filename, folderInfo.VxxxHxxx));

        if numel(V)==1 && numel(H)==1
            polarSPK(V,H,:) = audioCell{n}.spk(index);
            
            if V==1 && H==1 % use comment of V000H000
                folderInfo.comment = audioCell{n}.comment;
            end
        end
    end
end