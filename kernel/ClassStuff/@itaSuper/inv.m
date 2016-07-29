function varargout = inv(varargin)
% Get the inverse of a matrix
%
% audioObj = inv(audioObjMatrix)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Lian Gomes / Pascal Dietrich
% TODO: add documentation

%% Init
t     = cputime; 
a     = varargin{1};
Layer = zeros(size(a,1),size(a,2),a(1,1).nBins); %speed reasons
unit  = repmat(itaValue(),size(a,1), size(a,2));

%% get data
for ind = 1:size(a,2)
    for jnd = 1:size(a,2)
        Layer(ind,jnd,:) = a(ind,jnd).freq;
        unit(ind,jnd) = 1/itaValue(1,a(ind,jnd).channelUnits{1});
    end
end

[m n p] = size(Layer);  

if m ~= n
    error('Matrix i x j x k must have i = j')
end

i  = repmat(reshape(1:m*p,m,1,p),[1 n 1]); % matrix of indexes i to sparse
j  = repmat(reshape(1:n*p,1,n,p),[m 1 1]); % matrix of indexes k to sparse

Sp = sparse(i(:),j(:),Layer(:)); %sparse matrix

Id = reshape(repmat(reshape(eye(m,n), m, 1, []), [1 p 1]), m*p,[]); %various identity matrixes
q  = size(Id,2);
k  = 0; %eps*1000;
X  = permute(reshape(Sp \ (Id + k), [n p q]),[1 3 2]); %invertation

% % % audioObj = itaAudio ; %back to itaAudio
% % % audioObj.fftDegree = a(1,1).fftDegree ;
audioObj = a(1,1); %pdi: fixed for itaSuper

for idx = 1:size(a,2)
    for jdx = 1:size(a,2)
        audioObj(idx,jdx).freq = squeeze(X(idx,jdx,:));
        audioObj(idx,jdx).channelUnits = unit(jdx,idx).unit;
    end
end

varargout{1}=audioObj;

ita_verbose_info(['Invertation done in ' num2str(cputime-t) ' seconds'],1)

end





