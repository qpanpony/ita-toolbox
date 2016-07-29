function result = ita_ifft(varargin)
%ITA_IFFT - MF iFFT
%   This function calculates the time signal to a spectrum as in MF with
%   proper scaling and normalization. Negative frequencies are added as the
%   conjugate complex of the positive frequencies. This is due to reason as
%   we only consider REAL audio time data, therefore the spectrum has this
%   characteristic. See Oppenheim or Ohm/Lueke.
%
%   It is distinguished between power and energy signals
%   by means of the FFTnorm flag. A value of 0 stands for a power signal,
%   i.e. noise, speech, music. A value of 1 stands for an energy signal,
%   i.e. impulse responses. If a power signal is filled up with zeros the
%   level in frequency goes down as we have a look at the power (energy per
%   time). We still observe the same energy but have a longer period of
%   time. Impulse responses have a characteristic energy, regardless of the
%   signal length in time domain. Therefore, when adding zeros in the end
%   the energy remains still the same and we have a look at the energy in
%   frequency domain. A value of 2 stands for Bandpass characteristic used
%   for HUGO settings. This information was kindly provided by Swen M�ller,
%   author of Monkey Forest.
%
%   Call: itaAudio = ita_ifft(itaAudio)
%   Call: itaAudio = ita_ifft(itaAudio,'silent') - suppress verbose Info
%
%   CAUTION: This fft is based on the assumption of real time signals.
%   Therfore the zero frequency element AND the Nyquist frequency element
%   have to be real!
%
%   See also ita_plot_dat, ita_plot_dat_dB, ita_plot_spk, ita_read, ita_write, ita_fft.%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_ifft">doc ita_ifft</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  29 May 2008


%**************************************************************************
%**************************************************************************
%  PLEASE DO NOT APPLY CHANGES TO THIS FUNCTION WITHOUT ASKING
%**************************************************************************
%**************************************************************************


%% Initialization
narginchk(1,2);

if isa(varargin{1},'itaAudio')
    audioObj = varargin{1};
    if audioObj.isTime
        result = audioObj;
        return;
    end
end

%% Check for empty data
if audioObj.isempty
   audioObj.domain = 'time';
   result = audioObj;
   return;
end

%% Check for NaN at DC
audioObj.freqData(1,~isfinite(audioObj.freqData(1,:))) = 0;

%% Normalize

% Comment from MF autor Swen Mueller:
% % % FFTnorm = 0 : Power signal: gives invariant spectrum readings regardless of the length of the
% % %               the time record (NoOfSamples) for continuous signals (e.g. sine
% % %               signal for THD analysis or noise for SPL measurements).
% % % FFTnorm = 1 : Energy signal: gives invariant spectrum readings regardless of the length of the
% % %               the time record (NoOfSamples) for impulse responses.
% % % FFTnorm = 2 : calculates the gain of a FIR filter for use in fixed-point DSPs
% % %               (result of binary 1 for the spectral bins means 0 dB of gain).
% % % FFTnorm = 0    --> MulFac = VoltPerLSB / sqrt(2)
% % % FFTnorm = 1    --> MulFac = VoltPerLSB / sqrt(2) / NoOfSamples
% % % FFTnorm = 2    --> MulFac = 1 / (2^quantisation in bits)

switch audioObj.signalType
    case 'power'
        MulFac = 1/audioObj.nSamples;
        ita_verbose_info(['FFTnorm ' num2str(audioObj.signalType) ' - Power signal'],2)
    case 'energy'
        MulFac = 1;
        ita_verbose_info(['signalType ' num2str(audioObj.signalType) ' - Energy signal'],2)
    case 'passband'
        MulFac = 1;
        ita_verbose_info('signalType: This normalization option is yet not fully supported.',0)
        ita_verbose_info(['signalType ' num2str(audioObj.signalType) ' - Passband signal'],2)
    otherwise
        error(['ITA_IFFT:signalType is broken: ' audioObj.signalType])
end

fftResult = audioObj.freqData ./ MulFac; %correct here, as less data.

if audioObj.isPower
    if audioObj.isEvenSamples
        fftResult(end,:) = fftResult(end,:)*sqrt(2);
        fftResult(2:end-1,:) = fftResult(2:end-1,:)/sqrt(2);
    else
        fftResult(2:end,:) = fftResult(2:end,:)/sqrt(2);
    end
end

%% Warn if DC or Nyquist is not real
if any(~isreal(fftResult(1,:)))
    ita_verbose_info('Using the real part only of the complex data at DC for the FFT',1)
end
if any(~isreal(fftResult(end,:)))
    ita_verbose_info('Using the real part only of the complex data at the Nyquist frequency for the FFT',1)
end

%% Reconstruction of full spectrum
if audioObj.isEvenSamples
    fftResult = [real(fftResult(1,:));...
                 fftResult(2:(end-1),:);...
                 real(fftResult(end,:));...
                 conj(fftResult((end-1):-1:2,:))];
else
    ita_verbose_info(' Be careful with odd numbers of time samples!',0)
    fftResult = [real(fftResult(1,:));...
                 fftResult(2:end,:);...
                 conj(fftResult(end:-1:2,:))];
end

%% Do the IFFT
audioObj.timeData = ifft(fftResult,'symmetric');

%% Output
result = audioObj;
end
