function result = ita_fft(varargin)
%ITA_FFT - spectrum calculation (according to MF) 
%   This function calculates the spectrum of a time signal by
%   rescaling/normalizing the results as in Monkey Forest.
%   Negative frequencies are ommited. This is due to reason as
%   we only consider REAL audio time data, therefore the spectrum is always
%   symmetric in a way. See Oppenheim or Ohm/L�ke.
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
%   Syntax: itaAudio = ita_fft(itaAudio)
%   Syntax: itaAudio = ita_fft(itaAudio,'silent') - suppress verbose Info
%
%   See also ita_ifft, ita_plot_spk, ita_plot_dat.
%
%   Reference page in Help browser
%       <a href="matlab:doc ita_fft">doc ita_fft</a>

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



%% Verbose 
% % verboseMode  = ita_preferences('verboseMode');

%% Initialization
narginchk(1,2);
% % if nargin == 2
% %     try  %#ok<TRYNC>
% %         if strcmpi(varargin{2},'silent')
% %             verboseMode = 0;
% %         end
% %     end
% % end

if isa(varargin{1}, 'itaAudio')
    audioObj = varargin{1};
    
    % check if already in target domain and if yes:
    % loop input parameters to output parameter
    if audioObj.isFreq
        result = audioObj;
        return;
    end
else
    error('ITA_FFT:InputArguments','This functions works only with itaAudio objects.')
end

%% Check for empty data
if audioObj.isempty
   audioObj.domain = 'freq';
   result = audioObj;
   return;
end

%% Do the FFT
fftResult = fft(audioObj.timeData);

%% Discard negative frequencies
nSamples = audioObj.nSamples;
if audioObj.isEvenSamples
    fftResult = fftResult(1:(nSamples+2)/2,:);
else
    ita_verbose_info(' Be careful with odd numbers of time samples!',1);
    fftResult = fftResult(1:(nSamples+1)/2,:);
end

%% Normalize spectrum

% Comment from Monkey Forest author Swen Mueller:
% % % FFTnorm = 0 : Power signal: gives invariant spectrum readings regardless of the length of the
% % %               the time record (nSamples) for continuous signals (e.g. sine
% % %               signal for THD analysis or noise for SPL measurements).
% % % FFTnorm = 1 : Energy signal: gives invariant spectrum readings regardless of the length of the
% % %               the time record (nSamples) for impulse responses.
% % % FFTnorm = 2 : calculates the gain of a FIR filter for use in fixed-point DSPs
% % %               (result of binary 1 for the spectral bins means 0 dB of gain).
% % % FFTnorm = 0    --> MulFac = VoltPerLSB / sqrt(2)
% % % FFTnorm = 1    --> MulFac = VoltPerLSB / sqrt(2) / nSamples
% % % FFTnorm = 2    --> MulFac = 1 / (2^quantisation in bits)

switch audioObj.signalType
    case 'power'
        MulFac = 1/nSamples;
        ita_verbose_info([' FFTnorm ' num2str(audioObj.signalType) ' - Power signal'], 2)
    case 'energy'
        MulFac = 1;
        ita_verbose_info([' FFTnorm ' num2str(audioObj.signalType) ' - Energy signal'], 2)
    case 'passband'
        MulFac = 1;
        ita_verbose_info(' FFTnorm: This normalization option is yet not fully supported.',0)
        ita_verbose_info([' FFTnorm ' num2str(audioObj.signalType) ' - Passband signal'],2)
end

% Don't double DC and Nyquist frequency, since they are unique points
% Divide all points but DC by sqrt(2) because fft gives amplitude 
% and we want effective value.
% The multiplication factor corrects the fact the FFT gives the
% amplitude times the length of the input sequence.
% Energy sequences should be left as they are.

if audioObj.isPower
    if audioObj.isEvenSamples
        fftResult(end,:) = fftResult(end,:)/sqrt(2);
        fftResult(2:end-1,:) = fftResult(2:end-1,:)*sqrt(2);
    else
        fftResult(2:end,:) = fftResult(2:end,:)*sqrt(2);
    end
end

%% Store back the frequency vector
audioObj.freqData = MulFac * fftResult;

%% Output
result = audioObj;
end
