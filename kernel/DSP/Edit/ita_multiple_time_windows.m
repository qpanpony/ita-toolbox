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

nWindow = sArgs.blocksize;
if sArgs.overlap < 1
    nOverlap  = round(nWindow*sArgs.overlap);
else
    nOverlap = round(sArgs.overlap);
end

nSegments = ceil(a.nSamples / (nWindow - nOverlap)) + 1;
nNewLength = (nSegments - 1) * (nWindow - nOverlap) + nWindow;
if nNewLength-nWindow > a.nSamples
    a = ita_extend_dat(a,nNewLength - nWindow,'forcesamples');
end

% half a window length at beginning and end
ext_zeros = zeros(nWindow/2,a.nChannels);
data = [ext_zeros; a.time; ext_zeros];

%% generate window
win_vec = window(sArgs.window,nWindow+1);
win_vec(end) = [];

resultDummy = a;
resultDummy.data = zeros(1,a.nChannels);

result = repmat(resultDummy,nSegments,1);
for idx = 1:nSegments
    sliceIds = (idx-1)*(nWindow-nOverlap) + (1:nWindow);
    result(idx).time = bsxfun(@times,data(sliceIds,:),win_vec);
end

%%
varargout{1} = result;

end