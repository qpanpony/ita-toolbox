function varargout = pinv(a , varargin)
% Get the pseudo-inverse with regularization. If you do not set the
% regularization parameter, the alghritm will choose the best tolerance for
% each frequency bin.
%
% audioObj = pinv(audioObjMatrix, tol)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Lian Gomes / Pascal Dietrich
% TODO: add documentation

%% Init
t      = cputime;
data   = zeros(size(a,1),size(a,2),a(1,1).nBins); %init
ILayer = zeros(size(a,2),size(a,1),a(1,1).nBins);

%% get correct final units
finalUnits = ita_unit_inv(a.unit);

%% get data 
for idx = 1:size(a,1)
    for jdx = 1:size(a,2)
        data(idx,jdx,:) = a(idx,jdx).freq;
    end
end

%% find tolerance
if nargin == 2
    tol = varargin{1};
    if numel(tol) == 1;
        tol = repmat(tol,1,a(1,1).nBins);
    end
else
    maxi = max(size(data(:,:,1)));
    tol = 0*data(1,1,:);
    ita_verbose_info('itaSuper.pinv::selecting best tolerance parameter automatically',1)
    for hdx = 1:a(1,1).nBins
        tol(hdx) = maxi*norm(data(:,:,hdx))*eps*10^8;
    end
end

%% do inversion
for hdx = 1:a(1,1).nBins
    ILayer(:,:,hdx) = pinv(data(:,:,hdx),tol(hdx));
end

%% convert back to itaSuper Matrix
% % % audioObj = itaAudio;
% % % audioObj.fftDegree = a(1,1).fftDegree ;
% % % audioObj.samplingRate = a(1,1).samplingRate ;
audioObj = a(1,1); %pdi: fixed
audioObj = repmat(audioObj,size(a,2),size(a,1));

for idx = 1:size(ILayer,1)
    for jdx = 1:size(ILayer,2)
        audioObj(idx,jdx).freq = squeeze(ILayer(idx,jdx,:));
        audioObj(idx,jdx).channelUnits{1} = finalUnits(idx,jdx).unit;
    end
end

ita_verbose_info(['Invertation done in ' num2str(cputime-t) ' seconds'],1)

varargout{1} = audioObj;

end