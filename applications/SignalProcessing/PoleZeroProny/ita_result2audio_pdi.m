function varargout = ita_result2audio_pdi(varargin)
%ITA_RESULT2AUDIO_PDI - Pole-Zero Interpolation Method
%  This function realizes an interpolation based on pole-zero
%  representation. Therefore it is preferably used for energy signals.
%
%  Syntax:
%   audioObjOut = ita_result2audio_pdi(audioObjIn, options)
%
%   Options (default): TODO HUHU Documentation
%           'sr' (0)                        : samplingRate
%           'fft_degree' (18)               : fftDegree
%           'nPoles' (50)                   : number of poles
%           'nZeros' (0)                    : number of zeros
%           'threshold' (0)                 : description
%           'iterations' (0)                : description
%           'zplane' (false)                : description
%           'mode' ('log')                  : description
%           'yulewalk' (false)              : description
%
% 
%  Example:
%   audioObjOut = ita_result2audio_pdi(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_result2audio_pdi">doc ita_result2audio_pdi</a>

% <ITA-Toolbox>
% This file is part of the application PoleZeroProny for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Pascal -- Email: pdi@akustik.rwth-aachen.de
% Created:  19-Aug-2010


%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','itaSuper', 'sr', 0, 'fft_degree', 18,'nPoles',50,'nZeros',50, 'threshold',0,'iterations',0,'zplane','false','mode','log','yulewalk',false);
[data,sArgs] = ita_parse_arguments(sArgs,varargin);

if sArgs.sr == 0
    % bugfix mpo
    if isa(data, 'itaAudio')
        sArgs.sr = data.samplingRate;
    else
        error([mfilename ':please give a sampling rate in the options.'])
    end
end

%% pole-zero with invfreqz
N_poles = sArgs.nPoles;
N_zeros = sArgs.nZeros;

for ch_idx = 1:data.nChannels
    
    % mode    = 'lin';
    
    switch lower(sArgs.mode)
        case 'lin'
            freqStuetz   = data.freqVector;
            wt = 1./freqStuetz;
            wt(wt == Inf) = 0;
            wt = wt ./ max(wt);
            %         wt = wt / 2 + 0.5;
            
            
        case 'log'
            %             idx1   = log10(data.freqVector(2));
            %             idx2   = log10(data.freqVector(3));
            %             idxEnd = log10(data.samplingRate/2);
            %             freqStuetz = 10.^(idx1*4: (idx2-idx1)/10 :idxEnd);
            %             wt = freqStuetz * 0 + 1;
            
            freqStuetz = data.freqVector;
            %     wt = freqStuetz * 0 + 1;
            
            diff_freq = diff(freqStuetz);
            diff_freq = [diff_freq(1); diff_freq];
            
            wt = diff_freq./freqStuetz;
            wt(wt == Inf) = 0;
            wt = wt ./ max(wt);
            
    end
    
    
    
    freqPi       = freqStuetz / sArgs.sr * 2 * pi;
    token = data.ch(ch_idx);
    freqVals = token.freq(data.freq2index(freqStuetz));
    
    maxValue = max(abs(freqVals));
    
    if sArgs.threshold
        wt(abs(freqVals) < maxValue / 10^(sArgs.threshold/20)) = 0.5;
        freqVals(abs(freqVals) < maxValue / 10^(sArgs.threshold/20)) = 0;
    end
    
    %% Calculation with invfreqz - Iterations?
    if sArgs.yulewalk
        [bb, aa] = yulewalk(max(N_zeros,N_poles), freqPi/pi,freqVals);
    else
        if sArgs.iterations > 0
            [bb, aa] = invfreqz(freqVals, freqPi, N_zeros, N_poles, wt, sArgs.iterations);
        else
            [bb, aa] = invfreqz(freqVals, freqPi, N_zeros, N_poles, wt);
        end
    end
    
    if sArgs.zplane
        ita_plot_zplanepz(bb,aa)
    end
    
    %% reconstruct signal
    recon = itaAudio;
    recon.samplingRate = sArgs.sr;
    recon.fftDegree = sArgs.fft_degree; % bugfix mpo
    recon.freq = freqz(bb, aa, recon.freqVector/sArgs.sr*2*pi);
    
    result(ch_idx) = recon;
end

result = merge(result);

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);
result.signalType = 'energy';

%% Set Output
varargout{1} = result;
if nargout == 3
    varargout{2} = bb;
    varargout{3} = aa;
end

%end function
end