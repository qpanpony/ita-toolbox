function [outPlus,outMinus] = ita_wiener_hopf_factorization(varargin)
%ITA_WIENER_HOPF_FACTORIZATION - Do Wiener-Hopf Factorization
%  This function returns to audio objects, one strictly causal and the
%  other strictly non-causal, that when convolved result in the original
%  data given.
%
%  Syntax:
%   [outPlus,outMinus] = ita_wiener_hopf_factorization(audioObjIn)
%
%  Option
%   invert [false]      This option returns the signals inverted in the
%                       frequency domain. Useful, if the factorized signals
%                       are to later go in the denominator of a division.
%
% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Bruno Masiero -- Email: bma@akustik.rwth-aachen.de
% Created:  23-Aug-2011 




%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','itaAudio','invert',false);
[input,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% Do separation in the cepstral domain
N = input.nSamples;
M = floor(N/2);

origTime = input.timeData;
origFreq = fft(origTime);
unwrapedPhase = unwrap(angle(origFreq(1:M+1,:)),[],1);
if rem(N,2) == 0
    origFreq_exp = log(abs(origFreq))+1i*[unwrapedPhase; -unwrapedPhase(end-1:-1:2,:)];
else
    origFreq_exp = log(abs(origFreq))+1i*[unwrapedPhase; -unwrapedPhase(end:-1:2,:)];
end

if sArgs.invert
    % This option returns the signals inverted in the frequency domain
    origCeps = ifft(-origFreq_exp);
else
    origCeps = ifft(origFreq_exp);
end
plusCeps = zeros(size(origCeps));
minusCeps = plusCeps;


plusCeps(2:M,:) = origCeps(2:M,:);
plusCeps(1,:) = origCeps(1,:)/2;

minusCeps(end-M+2:end,:) = origCeps(end-M+2:end,:);
minusCeps(1,:) = origCeps(1,:)/2;

if rem(N,2) == 0
    plusCeps(M+1,:) = origCeps(M+1,:)/2;
    minusCeps(M+1,:) = origCeps(M+1,:)/2;
end

plusFreq_exp = fft(plusCeps);
minusFreq_exp = fft(minusCeps);

plusFreq = exp(plusFreq_exp);
minusFreq = exp(minusFreq_exp);

outPlus = input;
outMinus = outPlus;

outPlus.timeData = ifft(plusFreq,[],1,'symmetric');
outMinus.timeData = ifft(minusFreq,[],1,'symmetric');

%% Do separation using Hilbert transform
% origTime = input.timeData;
% origFreq = fft(origTime);
% origFreq(origFreq == 0) = 10*eps; %to avoyd infinite values and NaN
% origFreq_exp = log(abs(origFreq));
% 
% plusFreq_exp = hilbert(origFreq_exp/2);
% plusFreq = exp(conj(plusFreq_exp));
% minusFreq = origFreq./plusFreq;
% 
% outPlus = input;
% outMinus = outPlus;
% 
% outPlus.timeData = ifft(plusFreq,[],1,'symmetric');
% outMinus.timeData = ifft(minusFreq,[],1,'symmetric');

%% Treat effect of second half peak
win = round([0.5 1]*outPlus.nBins);
outPlus_win = ita_time_window(outPlus,win,'samples');
outMinus_win = conj(ita_time_window(conj(outMinus),win,'samples'));

outPlus.freqAmp = abs(outPlus.freqAmp).*exp(1i*angle(outPlus_win.freqAmp));
outMinus.freqAmp = abs(outMinus.freqAmp).*exp(1i*angle(outMinus_win.freqAmp));

%% Add history line
outPlus = ita_metainfo_add_historyline(outPlus,mfilename,varargin);
outMinus = ita_metainfo_add_historyline(outMinus,mfilename,varargin);

%end function
end