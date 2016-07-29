function varargout = ita_audio2zpk(varargin)
%ITA_AUDIO2ZPK - pole zero analysis
%  This function TODO HUHU Documentation
%
%  Syntax:
%   audioObjOut = ita_audio2zpk(audioObjIn, options)
%
%   Options (default):
%           'degree' (50)           : description
%           'threshold' (0)         : description
%           'iterations' (0)        : description
%           'zplane' ('false')      : description
%           'mode' ('log')          : description
%           'yulewalk' (false)      : description
%           'freqRange' ([])        : description
%           'dist' (0)              : description
%
%  Example:
%   audioObjOut = ita_audio2zpk(audioObjIn)
%
%  See also:
%   ita_zpk2audio
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_audio2zpk">doc ita_audio2zpk</a>

% <ITA-Toolbox>
% This file is part of the application PoleZeroProny for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Pascal -- Email: pdi@akustik.rwth-aachen.de
% Created:  30-Aug-2010 


sArgs        = struct('pos1_data','itaSuper','degree',50,'threshold',0,'iterations',0,'zplane','false','mode','log','yulewalk',false,'freqRange',[],'dist',0);
[data,sArgs] = ita_parse_arguments(sArgs,varargin);

sArgs.sr = data.samplingRate;

%% tf (pole-zero) polynom with invfreqz
N_poles = sArgs.degree;
N_zeros = sArgs.degree;

for ch_idx = 1:data.nChannels
    
    % mode    = 'lin';
    
    switch lower(sArgs.mode)
        case 'lin'
            freqStuetz   = data.freqVector;
            wt = 1./freqStuetz;
            wt(wt == Inf) = 0;
            wt = wt ./ max(wt);
            
        case 'log'
            freqStuetz = data.freqVector;
            diff_freq = diff(freqStuetz);
            diff_freq = [diff_freq(1); diff_freq];
            wt = diff_freq./freqStuetz;
            wt(wt == Inf) = 0;
            wt = wt ./ max(wt);
    end

    % weighting and frequency range?
    if sArgs.freqRange
        wt(data.freqVector < sArgs.freqRange(1)) = 0;
        wt(data.freqVector > sArgs.freqRange(2)) = 0;
    end
       
    
    freqPi   = freqStuetz / sArgs.sr * 2 * pi;
    token    = data.ch(ch_idx);
    freqVals = token.freq(data.freq2index(freqStuetz));
    maxValue = max(abs(freqVals));
    
    %% don't try this at home... pdi
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
    
    [z,p,k] = tf2zp(bb,aa);
    
    if sArgs.dist
        [z,p,k] = ita_zpk_reduce(z,p,k,'dist',sArgs.dist);
    end
    
%     % limit to pi
%     z(angle(z) == pi) = abs(z(angle(z) == pi));
%     p(angle(p) == pi) = abs(p(angle(p) == pi));
% 
    % delete nyquists   
    
    sum(any(z(angle(z) == pi)))
        sum(any(p(angle(p) == pi)))

%     z(angle(z) == pi) = 0;
%     p(angle(p) == pi) = 0;
%     
    
    %     z = abs(z) .* exp(1i.*angle(z) / 2);
    %     p = abs(p) .* exp(1i.*angle(p) / 2);
    
    %% show?
    if sArgs.zplane
        ita_plot_zplanepz(z,p,k)
    end

    [bb,aa] = zp2tf(z,p,k);
    
    %% reconstruct signal
    recon      = data;
    recon.freq = freqz(bb, aa, recon.freqVector/sArgs.sr*2*pi);
    
    result(ch_idx) = recon; %#ok<AGROW>
end

result = merge(result);
result = ita_metainfo_add_historyline(result,mfilename,varargin);
result.signalType = 'energy';

%% Set Output
varargout{1} = p;
varargout{2} = z;
varargout{3} = k;
if nargout == 4
    varargout{4} = result;
end

%end function
end