function H_lift = ita_lifter(H,varargin)
%ITA_LIFTER - A filter that operates on a Cepstrum domain is called a lifter
%  This function applies a low pass lifter, that is similar to a low pass
%  filter in the frequency domain. It is implemented by multiplying by a
%  window in the cepstral domain resulting in a smoother signal.
%
%  Syntax:
%   audioObjOut = ita_lifter(itaAudio,options)
%
%   Options (default):
%           'n' (length(H)/4) : window length
%           'alpha' (0)       : parameter that specifies the ratio of taper
%                               to constant sections (0 < alpha < 1). 
%                               1 -> hann window
%                               0 -> rectangular window
%
%  Example:
%   audioObjOut = ita_lifter(audioObjIn)
%   audioObjOut = ita_lifter(audioObjIn,16)
%   audioObjOut = ita_lifter(audioObjIn,32,.5)
%
%  See also:
%   ita_cepstrum, ita_filter, ita_time_window
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_lifter">doc ita_lifter</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Bruno Masiero -- Email: bma@akustik.rwth-aachen.de
% Created:  02-Feb-2012 


%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
H_lift = H;
nSamples = H(1,1).nSamples;
% window size
if nargin < 2
    N = ceil(nSamples/4);
else
    N = varargin{1};
end

if N >= ceil(nSamples/2)
    warning('LIFTING:WindowSize','No lifting will be done. Window length is too long.');
    return
end

% tukey window alpha factor:
% 1 - hanning window
% 0 - rectangular window
if nargin < 3
    alpha = 0;
else
    alpha = varargin{2};
end

%% prepare window
win = tukeywin(2*N+1,alpha);
win = [win; zeros(nSamples-2*N-1,1)];
win = circshift(win,-N);

%% Lifting operation
for jdx = 1:numel(H)
    flag_shift = 0;
    Data = H(jdx);   
    
    % shift IR to reduce phase wrapping and allow a better unwrapping.
    if strcmp(Data.signalType,'energy')
        id = ita_start_IR(Data,'threshold',10);
        Data = ita_time_shift(Data,-id,'samples');
        Data = ita_time_window(Data,ceil([.5 1]*Data.nSamples/2),'samples','symmetric');
        flag_shift = 1;
    end
        
    % calculate cepstrum
    [C,delay] = ita_cepstrum(Data);
    
    % do the liftering
    C.timeData = bsxfun(@times,C.timeData,win);
    
    % inverse cepstrum
    H_lift(jdx) = ita_icepstrum(C,delay);
    
    if flag_shift
        H_lift(jdx) = ita_time_shift(H_lift(jdx),id,'samples');
    end
    
    %% Add history line
    H_lift(jdx) = ita_metainfo_add_historyline(H_lift(jdx),mfilename,varargin);
end

%end function
end