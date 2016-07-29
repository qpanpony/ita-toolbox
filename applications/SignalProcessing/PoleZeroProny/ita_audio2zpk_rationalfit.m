function varargout = ita_audio2zpk_rationalfit(varargin)
%ITA_AUDIO2ZPK - Pole-Zero-Analysis
%  This function returns the poles and zeros of a transfer-function
%
%  Syntax:
%   [z,p,k,(itaAudio)] = ita_audio2zpk(audioObjIn, options)
%
%   Options (default):
%           'degree' (50)        : Number of resonance frequencies
%           'mode' ('log')       : lin or log over frequency
%           'freqRange' ([])     : range used for analysis e.g. [500 10000] Hz
%           'tolerance' (-50)    : tolerance in dB, how good should the result be
%           'tendstozero' (true) : does the result tend to zero for high and low frequencies
%           'delayfactor' ([])   : use this delay for impulse response
%           'finddelay' (false)  : first find delay in impulse response (maximum peak in time domain)
%
%  See also:
%   ita_zpk2audio
%
% TODO: update help
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_audio2zpk">doc ita_audio2zpk</a>

% <ITA-Toolbox>
% This file is part of the application PoleZeroProny for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Pascal -- Email: pdi@akustik.rwth-aachen.de
% Created:  30-Aug-2010



sArgs        = struct('pos1_data','itaSuper','degree',50,'mode','log','freqRange',[],'tolerance',-50,'tendstozero',true,'delayfactor',0,'finddelay',false,'iterationlimit',20);
[data,sArgs] = ita_parse_arguments(sArgs,varargin);

%% tf (pole-zero) polynom with invfreqz
for ch_idx = 1:data.nChannels

    switch lower(sArgs.mode)
        case 'lin'
            freqStuetz   = data.freqVector;
            wt = 1./freqStuetz;
            wt(wt == Inf) = 0;
            wt = wt ./ max(wt);
            
        case 'log'
            freqStuetz = data.freqVector;
            diff_freq = diff(freqStuetz);
            diff_freq = [diff_freq(1); diff_freq]; %#ok<AGROW>
            wt = diff_freq./freqStuetz;
            wt(wt == Inf) = 0;
            wt = wt ./ max(wt);
    end
    
    % weighting and frequency range?
    if sArgs.freqRange
        wt(data.freqVector < sArgs.freqRange(1)) = 0;
        wt(data.freqVector > sArgs.freqRange(2)) = 0;
    end
    
    idx = [1:length(data.freqVector)]' .* (wt > 0);
    idx = idx (idx ~= 0);
    
    token   = data.ch(ch_idx);
    
    if sArgs.finddelay %only works for itaAudios
        [token, delayfactor] = ita_time_shift(token,'0dB');
    end
    
    freqVec = token.freqVector(idx);
    dataVec = token.freq(idx);
    wt      = wt(idx);
    
    %% check for NaNs and zeros
    dataVec(isnan(dataVec)) = eps;
    %     dataVec(abs(dataVec) < eps)  = eps;
    
    %% rational fit
    %     profile on
    %     freq,data,tol,weight,delayfactor,tendstozero,npoles,iterationlimit,showbar
    %pdi: delay to zero seems to give better results with artificial rir.
    %low frequencies have influence on high frequencies in terms of phase.
    %fit with high freq range gives also very accurate results below the
    %lowest frequency under consideration
    %     if verLessThan('matlab','7.11')
    %         fit_data(ch_idx) = rationalfit(freqVec,dataVec,sArgs.tolerance,wt,sArgs.delayfactor,sArgs.tendstozero,[sArgs.degree * 2]);
    %     else
    if numel(sArgs.degree) == 1
        sArgs.degree = [sArgs.degree * 2, sArgs.degree * 2];
    end
    iterationlimit   = sArgs.iterationlimit;
    fit_data(ch_idx) = ita_rationalfit(freqVec,dataVec,sArgs.tolerance,wt,sArgs.delayfactor,sArgs.tendstozero,sArgs.degree,iterationlimit,false); %#ok<AGROW>
    
    if numel(sArgs.degree) == 2
        ita_verbose_info(['Best Fit found with ' num2str(numel(fit_data(ch_idx).f)) ' poles'],1)
    end
    
    if sArgs.finddelay
        fit_data(ch_idx).delay = fit_data(ch_idx).delay - delayfactor;
    end
    
    %     end
    %     profile viewer
    
    %     fit_data(ch_idx).C(logical(abs(real(fit_data(ch_idx).A)) > sArgs.freqRange(2))) = 0;
    
    %     [resp]    = freqresp(fit_data(ch_idx),token.freqVector);
    %     result(ch_idx)  = token;
    %     result(ch_idx) = resp;
    %         ita_plot_spkphase(merge(token,result(ch_idx)))
    
end

res = itaAudioAnalyticRational;
res.analyticData = fit_data;



res.channelCoordinates = data.channelCoordinates;
res.channelNames = data.channelNames;
res.channelUnits = data.channelUnits;
if ~isa(data,'itaResult')
    res.samplingRate = data.samplingRate;
    res.fftDegree = data.fftDegree;
end

%% Set Output
varargout{1} = res;
if nargout == 2
    varargout{2} = fit_data;
end

%end function
end