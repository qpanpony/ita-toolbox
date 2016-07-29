function [maa] = maa_midrun_estimation(varargin)
angles = varargin{1};
if nargin==2,    sortOutTurn =varargin{2};
else sortOutTurn =0; end

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

idxFalling = find(diff(angles) ==-1);
idxRaising = find(diff(angles) ==1);
midrunAngles = zeros(1,length(idxFalling));

rememberRaisedIdx = 0;

for k = 1:length(idxFalling)
    %next idx after the actual fall, where angles raises again
    idxRaiseAfterFall = idxRaising(find(idxRaising > idxFalling(k), 1));
    
    %angles ends falling
    if isempty(idxRaiseAfterFall)
        midrunAngles(k) = ( angles(idxFalling(k)) + angles(end) ) / 2;
    %check for multiple fallings in a row
    elseif rememberRaisedIdx ~= idxRaiseAfterFall
        rememberRaisedIdx = [rememberRaisedIdx, idxRaiseAfterFall];    
        midrunAngles(k) = ( angles(idxFalling(k)) + angles(idxRaiseAfterFall) ) / 2;
    end
end

%delete zeros
emptyIdx = find(midrunAngles == 0);
midrunAngles(emptyIdx) = [];

if numel(sortOutTurn)==1
    maa = mean(midrunAngles(1+sortOutTurn:end));
else
%     if numel(midrunAngles)> sortOutTurn(2)-1
%        maa = mean(midrunAngles(2+sortOutTurn(1):sortOutTurn(2)));
%     else
        maa = mean(midrunAngles(sortOutTurn(1)+1:end));
   % end
end