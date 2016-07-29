function varargout = ita_impulsiveNoiseDetection(varargin)
%ita_impulsiveNoiseDetection - detects impulsive events in measured impulse responses
%  This function detects impulsive noise events in measurements. Therefor
%  the recoded signal is reconstructed and the estimated signal part is
%  subtrcted. Based on the resulting estimated background noise a threshold
%  method is used to detect implusive events. Therefore the L_max_rms, the
%  ratio of maximum amplitude and the room mean square value in dB, is
%  calculated. For stationary noise L_max_rms is about 12 dB .. 14 db
%  depending on the lenghth of the signal. For L_max_rms values > 20 dB it
%  is likely that an impulsive event occured during the measurement that
%  will have significant effects for further usage (i.e. room acoustic
%  parameter evaluation, auralization ,...). The estimated background noise
%  can also be returend for further analysis (i.e. idetification of the
%  source).
%
%  Syntax:
%    impulsiveNoiseDetected,                             = ita_impulsiveNoiseDetection(impulseResponse, excitationSignal, options)
%   [impulsiveNoiseDetected, L_max_rms]                  = ita_impulsiveNoiseDetection(impulseResponse, excitationSignal, options)
%   [impulsiveNoiseDetected, L_max_rms, backgroundNoise] = ita_impulsiveNoiseDetection(impulseResponse, excitationSignal, options)
%
%   Options (default):
%           'peakRmsThreshold' (20)      : threshold for L_max_rms to  classify results
%           'plot' (false)               : delete input pdfs after output was created
%
%  Example:
%        ita_impulsiveNoiseDetection(impulseResponse, excitationSignal)
%
%
%
%  See also:
%   itaMSTF, ita_generate_sweep, ita_roomacoustics
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_impulsiveNoiseDetection">doc ita_impulsiveNoiseDetection</a>

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  20-Jul-2012

%% input parting

sArgs           = struct('pos1_ir','itaAudioTime','pos2_excitation','itaAudioTime', 'peakRmsThreshold', 20, 'plot', false);
[ir, excitation, sArgs] = ita_parse_arguments(sArgs,varargin);

%% calculation

nChannels = ir.nChannels;

% remove impulse response to obtain background noise
[~, ~,  intersectionTime] = ita_roomacoustics_reverberation_time_lundeby(ir, 'broadbandAnalysis');
if max(intersectionTime.freqData / ir.trackLength) > 0.85
    ita_verbose_info('longer excitation signal needed !?!')
end

% [~, shiftTime] = ita_time_shift(ir, '30db');

irWin = itaAudio(nChannels,1);
for iCh = 1:nChannels
    
    
%     irWin(iCh) = ita_time_window(ir.ch(iCh), -shiftTime(iCh) *[1 0.95 ] , 'time');
    
    if ~isnan(intersectionTime.freqData(iCh))
        irWin(iCh) = ita_time_window(ir.ch(iCh), intersectionTime.freqData(iCh) *[1.05 1 ] , 'time');
    else
        irWin(iCh) = ir.ch(iCh) * nan;
    end

end
    
% irWin = ir -  irWin.merge; % take only the noise part
 irWin = irWin.merge; 

% convolve with excitation to get original disrupter
noiseInExcitation = irWin * excitation;


% first approach: simple threshold for peak to rms ratio
peakRmsRatio = 20*log10(max(noiseInExcitation.timeData) ./ noiseInExcitation.rms);
impulsiveNoiseDetected = peakRmsRatio > sArgs.peakRmsThreshold;


% plot if impulsive noise was found
if sArgs.plot
    idxChImpNoise = find(impulsiveNoiseDetected);
    for iCh = idxChImpNoise
        fgh = figure;
        
        ita_plot_time_dB(ir.ch(iCh),'figure_handle', fgh, 'axes_handle', subplot(221))
        title('Impulse Response time')
        
        ita_plot_spectrogram(ir.ch(iCh),'figure_handle', fgh, 'axes_handle', subplot(222))
        title('Impulse Response spectrogram')
        
        ita_plot_time(noiseInExcitation.ch(iCh), 'figure_handle', fgh, 'axes_handle', subplot(223))
        title('Estimated Backgroundnoise ')
        ita_plot_time_dB(noiseInExcitation.ch(iCh), 'figure_handle', fgh, 'axes_handle', subplot(224))
        
        title(sprintf('noise: peakRmsRatio %2.1f dB', peakRmsRatio(iCh)))
    end
end

varargout{1} = impulsiveNoiseDetected;
if nargout >= 2
    varargout{2} = peakRmsRatio;
end
if nargout >= 3
    varargout{3} = noiseInExcitation;
end

if nargout >= 4
    varargout{4} = irWin;
end

