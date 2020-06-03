function sampleStart = ita_start_IR(varargin)
%ITA_START_IR - Find the start of a impulse response
%  This function finds the start of an impulse response, in accordance to
%  standard ISO 3382 A.3.4.
%  The output is given in samples.
%
%  Syntax: sampleStart = ita_start_IR(audioObj,options)
%  Options (default):
%    'threshold' (20):      
% 
%   See also ita_time_shift
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_start_IR">doc ita_start_IR</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Bruno Masiero -- Email: bma@akustik.rwth-aachen.de
% Created:  23-Set-2008

%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudio', 'threshold', 20, 'correlation',false, 'order',2);
[input,sArgs] = ita_parse_arguments(sArgs,varargin); 

if ischar(sArgs.threshold)
    sArgs.threshold = str2double(sArgs.threshold);
    if isnan(sArgs.threshold)
        error('threshold is NaN!')
    end
end

if ~sArgs.correlation
    sampleStart = local_search_ISO3382(input,sArgs);
else
    sampleStart = local_search_minPhase_correlation(input,sArgs);
end

% nonFound = sampleStart == 1;
% sampleStart(nonFound) = local_search_minPhase_correlation(input.ch(nonFound),sArgs);

%% Local Functions
function sampleStart = local_search_ISO3382(input,sArgs)

IRsquare = input.timeData.^2;

% assume the last 10% of the IR is noise, and calculate its noise level
NoiseLevel = mean(IRsquare(round(.9*end):end,:));

% get the maximum of the signal, that is the assumed IR peak
[max_val, max_idx] = max(IRsquare,[],1);

% check if the SNR is enough to assume that the signal is an IR. If not,
% the signal is probably not an IR, so it starts at sample 1
idxNoShift = max_val < 100*NoiseLevel | max_idx > round(0.9.*input.nSamples);% less than 20dB SNR or in the "noisy" part
if  any(idxNoShift) 
    ita_verbose_info('ITA_START_IR:NoiseLevelCheck: The SNR too bad or this is not an impulse response.',1);
%     sampleStart = 1;
%     return
end

% find the first sample that lies under the given threshold
sArgs.threshold = -abs(sArgs.threshold);
sampleStart = ones(size(max_val));
for idx = 1:input.nChannels
    %% TODO - envelope mar/pdi - check!
    
    if idxNoShift(idx)
        continue
    end
    
    % if maximum lies on the first point, then there is no point in searching
    % for the beginning of the IR. Just return this position.
    if max_idx(idx) > 1
        
        abs_dat = 10.*log10(IRsquare(1:max_idx(idx),idx)) - 10.*log10(max_val(idx));
        
        lastBelowThreshold  = find(abs_dat < sArgs.threshold,1,'last');
        if ~isempty(lastBelowThreshold)
            sampleStart(idx) = lastBelowThreshold;
        else
            sampleStart(idx) = 1;
        end
       
        % Check if oscillations exist before the last value below threshold
        % If so, these are part of the RIR and need to be considered.
        idx6dBaboveThreshold = find(abs_dat(1:sampleStart(idx)) > sArgs.threshold + 6);
        if ~isempty(idx6dBaboveThreshold)
             tmp = find(abs_dat(1:idx6dBaboveThreshold(1)) < sArgs.threshold, 1 ,'last');
             if isempty(tmp) % without this if, the function would generate an error, if the oscillation persists until the first sample
                sampleStart(idx) = 1;
            else
                sampleStart(idx) = tmp;
             end
        end
        
    end
end

function sampleStart = local_search_minPhase_correlation(input,sArgs)
%Tamim, Noor Shafiza Mohd; Ghani, Farid (2010): Techniques for optimization in time delay estimation from cross correlation function. In: Int J Eng Technol 10, S. 69�75.


% define polynomial order of approximation. Must be at bigger than 1.
N = sArgs.order;
n = floor((N+1)/2);

input_mp = ita_minimumphase(input);
sampleStart = ones(1,input.nChannels);

A = input.timeData;
B = input_mp.timeData;

for iChannel = 1:input.nChannels
    
    X = xcorr(A(:,iChannel),B(:,iChannel));
    Y = hilbert(X);
    [~, ind] = max(abs(Y));
    y = imag(Y(ind-n:ind+n));
    p = polyfit((-n:n)',y,N);
    r = roots(p);
    if all(isreal(r))
        r = r(abs(r) == min(abs(r)));
        sampleStart(iChannel) = ind + r - input.nSamples;
    else
        sampleStart(iChannel) = 0;
    end
end