function varargout = ita_multiple_time_windows(varargin)
% ITA_MULTIPLE_TIME_WINDOWS - Split signal into blocks
% This functions splits a signal into several time windowed blocks.
%  Syntax:
%   audioObjOut = test(audioObjIn, options)
%
%   Options (default):
%           'window' (@hann):    choose windowType
%           'overlap' (0.5):     overlaps between segments
%           'blocksize' (1024):  nBins
%
%
%  See also:
%   ita_stfft, ita_istfft, ita_time_window, ita_frequency_dependent_time_window
%
%   Reference page in Help browser 
%        <a href="matlab:doc test">doc test</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


sArgs   = struct('pos1_a','itaAudioTime','blocksize',1024,'window',@hann,'overlap',0.5);
[a,sArgs] = ita_parse_arguments(sArgs,varargin); 
b = sArgs.blocksize;

nWindow   = b;
if sArgs.overlap < 1
    nOverlap  = round(nWindow*sArgs.overlap);
else
    nOverlap = round(sArgs.overlap);
end

nSegments = ceil(a.nSamples / nWindow * 2 + 1);
nNewLength = (nSegments -1) * nWindow / 2;
if nNewLength > a.nSamples
    a = ita_extend_dat(a,nNewLength,'forcesamples');
end

%% generate window
win_vec = window(sArgs.window,nWindow+1).';
win_vec(end) = [];

ext_zeros = zeros(a.nChannels,nWindow/2);

data = [ext_zeros a.dat(:,:) ext_zeros];

resultDummy = a;
resultDummy.data = zeros(1,a.nChannels);

result = repmat(resultDummy,nSegments,1);

for idx = 1:nSegments
    iLow = (idx-1)*(nWindow-nOverlap)+1;
    iHigh = iLow+nWindow-1;
    slice  = bsxfun(@times,data(:,iLow:iHigh),win_vec);
    result(idx).time = slice.'; 
end

%%
varargout{1} = result;

end