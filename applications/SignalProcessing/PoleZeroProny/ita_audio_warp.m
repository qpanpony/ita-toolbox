function varargout = ita_audio_warp(varargin)
%ITA_AUDIO_WARP => Adapted from:
% %WARP_IMPRES - Computation of a warped impulse response
% %
% % y = warp_impres(x,lambda,n)
% %
% % warp a signal or impulse response (sig) (by allpass1 with lambda)
% % n = number of samples in the result always stable.
% % This function uses the dewarping technique, which is more
% % suitable for warping of an impulse response than longchain
% % function.
% %
% % This function is a part of WarpTB - a Matlab toolbox for
% % warped signal processing (http://www.acoustics.hut.fi/software/warp/).
% % See 'help WarpTB' for related functions and examples
% % 
% % Authors: Matti Karjalainen, Aki Härmä
% % Helsinki University of Technology, Laboratory of Acoustics and
% % Audio Signal Processing

% Author: Bruno Masiero -- Email: bma@akustik.rwth-aachen.de
% Created:  02-Sep-2010 
% Bugfix filtfilt -> filter: Stefan Liebich (IKS) -- Email: liebich@iks.rwth-aachen.de
%  Modified:  07-Mar-2019

% For some more help read the wiki available at
% (https://www.akustik.rwth-aachen.de/ITA-Toolbox/wiki)

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','itaAudio','pos2_lambda','numeric','length',[],'cyclic',false);
[input,lambda,sArgs] = ita_parse_arguments(sArgs,varargin); 

if sArgs.cyclic
   input = ita_time_shift(input,input.nSamples/2,'samples'); 
end

if lambda == 0
    return
end

if isempty(sArgs.length)
    sArgs.length = input.nSamples;
end

% implements dewarping
bw = [lambda 1]'; 
aw = [1 lambda]'; 
% implements warping
% bw = [-lambda 1]'; 
% aw = [1 -lambda]'; 
signal = input.timeData;
out = zeros(size(signal));

for idx = 1:input.nChannels
    temp = [1; zeros(sArgs.length-1,1)];
    out(:,idx) = signal(1,idx)*temp;
    for jdx = 2:sArgs.length
        temp = filter(bw,aw,temp); % SL: WarpTB contains filter not filtfilt
%         temp = filtfilt(bw,aw,temp); % does not create a shift
        out(:,idx) = out(:,idx) + signal(jdx,idx)*temp;
    end
end
input.timeData = out;

if sArgs.cyclic
   input = ita_time_shift(input,-input.nSamples/2,'samples'); 
end

%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {input}; 

%end function
end