function varargout = ita_distortions(varargin)
% ITA_DISTORTIONS - Calculate the THD, THDN, HD's with noise and/or max SPL 
% of a distorted signal. The proposed methods are the Stepped Sine Method
% and the Exponential Sweep Method.
%
% Syntax: vector = ita_distortions('measurementType',options)
%
% The measurementType can be a stepped sine ('steppedsine') method (as in MF)
% or an exponential sweep ('expsweep') method.
%
% Stepped Sine method: returns a vector with maximal SPL, n first HD's with
% noise and THD corresponding to the maximal SPL (over the frequency:'third' or 'octave').
% Exponential Sweep method: returns a vector with the SPL corresponding
% to the first outburst of THD and the THD/HD's for a certain SPL over the frequency.
% The THD and HD will be express in dB.
%
% Examples:
%   [Max_spl THD THDN HD]=ita_distortions('steppedsine',[100 3 20000],[0.02 2 5], 10, 4,13,8)
%   use the stepped-sine method from 100 to 20000 with a frequency increment of a third
%   octave, a power from 0.02 to 5W with an increment of 2dB, a THD of 10%,
%   until the fourth harmonic, with an FFT degree of 13 and a nominal loudspeaker impedance of 8 Ohm.
%
%   [Max_spl THD THDN HD]=ita_distortions('expsweep',[100 20000],[0.02 2 5], 10, 4,19,8)
%   use the exponential sweep method with a sweep from 100 to 20000 Hz,
%   a power from 0.02 to 5W with an increment of 2dB, a THD of 10%,
%   until the fourth harmonic, with an FFT degree of 19 and a nominal loudspeaker impedance of
%   8 Ohm.
%
% NOTE: for the calcul of the THD for a specific amplitude, just give the
% same begin and end amplitude.
%
%   See also
%      ita_portaudio, ita_measurement, ita_time_shift, ita_time_window, 
%      ita_generate, ita_invert_spk_regularization, ita_amplify, itaResult

% <ITA-Toolbox>
% This file is part of the application Nonlinear for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Alexandre Bleus -- alexandre.bleus@akustik.rwth-aachen.de
% Created: March-2010

%% Get ITA Toolbox preferences
thisFuncStr  = [upper(mfilename) ':'];
verboseMode  = ita_preferences('verboseMode');

%% Initialisation
if nargin==0
    error([thisFuncStr 'Oh Lord! You must give input arguments: please see the help.'])
end

%% Defining the measurement type

% "Global variables"
meas_type  = varargin{1};
sr = 44100;

%% Determination of the method
switch lower(meas_type)    
%% Stepped Sine Method
    case 'steppedsine'
        
        % Parameter definition
        if nargin ~= 7
            error([thisFuncStr 'Oh Lord! You must give 7 input arguments for this type of measurement: see the help please.'])
        else
            % Determination of the parameters
            f0 = varargin{2}(1); f1 = varargin{2}(3); freq_type = varargin{2}(2);
            power_low = varargin{3}(1); delta_amp = varargin{3}(2); power_high = varargin{3}(3);
            stop_criteria = varargin{4}; n = varargin{5}; fft_degree = varargin{6};
        end

        % Calibration process
        if verboseMode, disp([thisFuncStr 'Calibration process on channel 1']), end
        MS = ita_measurement_setup_transferfunction([1], [1], sr, 17,[f0 f1], 'excitation', 'exp', 'stopmargin', 0.1, 'outputamplification', '-30dB', 'comment', 'Calibration process', 'pause', 0, 'averages', 1);%         MS.calibrate;
        MS.calibrate;
        HP_sens = MS.outputMeasurementChain.sensitivity;
        HP_imp = varargin{7};
        Mic_sens = MS.inputMeasurementChain.sensitivity;
        disp('Calibration finished, press enter to continue')
        pause()
        
        % Find the frequency type
        idx = 1;
        frequency(1) = f0;
        while  frequency(idx)<f1
            frequency(idx+1) = frequency(idx)*2^(1/freq_type);
            idx = idx+1;
        end
        
        % Preparing the loop
        amp_begin = 20*log10(sqrt((power_low*HP_imp)/0.775)/HP_sens.value);
        amp_end = 20*log10(sqrt((power_high*HP_imp)/0.775)/HP_sens.value);
        amplitude = zeros(1,length(frequency));
        
        % Big loop: first the frequency is determined and second the volume
        % is getting higher
        if verboseMode, disp([thisFuncStr 'Measurement process']), end
        for fr = 1:length(frequency)
            amp=1;
            if fr > 1
                amplitude(fr) = max(amplitude(fr-1)-10, amp_begin);
            else
                amplitude(fr) = amp_begin;
            end
            dontstop=1;
            %           pause(delay);
            sine_raw = ita_generate('sine',1 , frequency(fr), sr, fft_degree,['fullperiod']);                     % Generating the sine wave
            sine_raw = ita_time_window(sine_raw,[10,1, sine_raw.nSamples-10,sine_raw.nSamples],@hann,'samples');  % To avoid "clac" in the LS
            
            % Amplification and measurement
            while dontstop
                sine = ita_amplify(sine_raw,amplitude(fr),'dB');
                hpidx = sine.freq2index(frequency(fr));
                hp_amp(fr) = abs(sine.freqData(hpidx))*HP_sens;
                if verboseMode, disp([thisFuncStr 'Play and record a sine with a frequency of ' num2str(frequency(fr)) ' Hz, a voltage of ' num2str(hp_amp(fr).value) 'V and a power of ' num2str(hp_amp(fr).value^2/HP_imp) 'W.']), end
                ir = ita_portaudio(sine,'InputChannels',[1],'OutputChannels',[1],'samplingRate',sr,'reset',false);      % Play and record
                
                % Calculation of the Harmonic Distortions
                for nthharm = 1:n
                    if (nthharm*frequency(fr)) > ir.freqVector(end)  % No need to calculate an harmonic distortion out of the frequency range
                        HD(amp,fr,nthharm) = 0;
                        harm(nthharm) = 0;
                    else
                        harm(nthharm) = ir.freq2value(nthharm*frequency(fr));
                        HD(amp,fr,nthharm) = (sqrt(abs(harm(nthharm)).^2)/sqrt(sum(abs(ir.freqData').^2)));   % The division by the number of sample is already simplified in the fraction.
                    end
                end
                
                % Calculation of the Total Harmonic Distortion with and
                % without noise.
                THDN(amp,fr) = (sqrt((sum(abs(harm(2:end)').^2)))/sqrt(sum(abs(ir.freqData').^2)));
                THD(amp,fr) = (sqrt((sum(abs(harm(2:end)').^2)))/sqrt(sum(abs(harm(1:end)').^2)));  
                
                % Do we have reached one of the limit?
                if THD(amp,fr) >= stop_criteria/100 || amplitude(fr) >= amp_end   % Stop criteria = specified percentage for the THD or maximal power
                    dontstop = 0;
                    micidx = ir.freq2index(frequency(fr));
                    mic_amp(fr) = abs(ir.freqData(micidx))/Mic_sens;
                    if amp_begin < amp_end
                        pause(0.5)
                    end
                else
                    dontstop = 1;
                    amplitude(fr) = amplitude(fr)+delta_amp;  % Increase the amplitude (addition in dB)
                    amp = amp+1;
                    %Waiting
                    time = hp_amp(fr).value/5;          % Time in seconds
                    pause(time);                        % Waiting for a cooling of the LS
                end
            end
        end  
        
        % Post-processing and Results
        % Max SPL
        amp_ao = itaResult;
        amp_ao.freqData = [mic_amp.value]';
        amp_ao = itaValue(1, 'Pa')*amp_ao;
        amp_ao.freqVector = frequency';
        varargout(1) = {amp_ao};
        
        % THD for each amplitude
        for ampl = 1:length(THD(:,end))
            THD_ao(ampl) = itaResult;
            THD_ao(ampl).freqData = THD(ampl,:)';
            THD_ao(ampl).freqVector = frequency';
        end
        varargout(2) = {THD_ao};
        
        % THDN for each amplitude
        for ampl = 1:length(THDN(:,end))
            THDN_ao(ampl) = itaResult;
            THDN_ao(ampl).freqData = THDN(ampl,:)';
            THDN_ao(ampl).freqVector = frequency';
        end
        varargout(3) = {THDN_ao};
        
        % HD for each harmonic and each amplitude
        for h = 1:n
            for ampl = 1:length(HD(:,end,end))
                HD_ao(ampl,h) = itaResult;
                HD_ao(ampl,h).freqData = HD(ampl,:,h)';
                HD_ao(ampl,h).freqVector = frequency';
            end
        end
        varargout(4) = {HD_ao};
        
%% Exponential Sweep Method
    case 'expsweep'
        if nargin ~= 7
            error([thisFuncStr 'Oh Lord! You must give 7 input arguments for this type of measurement: see the help please.'])
        else
            % Determination of the parameters
            freq_vec = varargin{2}; power_low = varargin{3}(1); delta_amp = varargin{3}(2);
            power_high = varargin{3}(3); stop_criteria = varargin{4}; n = varargin{5};
            fft_degree = varargin{6};
        end
        
          % Calibration process
        if verboseMode, disp([thisFuncStr 'Calibration process on channel 1']), end
        MS = ita_measurement_setup_transferfunction([1], [1], sr, 17,freq_vec, 'excitation', 'exp', 'stopmargin', 0.1, 'outputamplification', '-30dB', 'comment', 'Calibration process', 'pause', 0, 'averages', 1);
        MS.calibrate;
        HP_sens = MS.outputMeasurementChain.sensitivity;
        HP_imp = varargin{7};
        Mic_sens = MS.inputMeasurementChain.sensitivity;
        del = MS.latencysamples;   
        disp('Calibration finished, press enter to continue')
        pause()
        
        % Preparing the loop
        amp_begin = 20*log10(sqrt((power_low*HP_imp)/0.775)/HP_sens.value);
        amp_end = 20*log10(sqrt((power_high*HP_imp)/0.775)/HP_sens.value);
        amp = 1;
        amplitude = amp_begin;
        win_vec = [0.02 0.04];
        dontstop = 1;
        stop_margin = 0.1;

        % Big loop : production of a sweep and then loop with an
        % increase in the level.
        if verboseMode, disp([thisFuncStr 'Measurement process']), end
        while dontstop
            
            % Producing and measuring an impulse response with a sweep technique
            sweep = ita_generate('expsweep*',freq_vec,stop_margin,sr,fft_degree);
            sweep = ita_amplify(sweep, amplitude, 'dB');
            comp = ita_invert_spk_regularization(sweep,[freq_vec(1) freq_vec(2)]);
            hp_amp = max(abs(sweep.freqData))*HP_sens;
            if verboseMode, disp([thisFuncStr 'Play and record a sweep with a frequency range of ' num2str(freq_vec) ' Hz and a maximal amplitude of ' num2str(hp_amp)]), end
            dist = ita_portaudio(sweep,'InputChannels',[1],'OutputChannels',[1],'samplingRate',sr);
            ir = dist*comp;
            ir = ita_time_shift(ir,-del, 'samples');
            
            % Distance between each harmonic and the fundamental
            T_sweep = double(sweep.trackLength);
            sweep_rate = test_abl_sweeprate(sweep,freq_vec);
            idx = 1:n;
            delta_t = log(idx) / log(2) / sweep_rate;
            delta_t(1) = 0;
            T_harm = T_sweep - delta_t;
            
            % Windowing each harmonic
            for idx = 1:n
                harmonic(idx) = ita_time_shift(ita_time_window(ita_time_shift(ir,-T_harm(idx),'time'),[win_vec]/max(log(idx)*log(2)*sweep_rate,1),'time','symmetric'),T_harm(idx),'time');
            end
            harmonic = ita_merge(harmonic);
            
            % Distortions evaluation
            % Slow Computation
            idx=1;
            freq(1)=freq_vec(1);
            while  freq(idx)<freq_vec(2)
                freq(idx+1)=freq(idx)*2^(1/12);
                idx=idx+1;
            end
            for fr=1:length(freq)
                harm_shift=zeros(1,length(harmonic.nChannels));
                for nthharm=1:harmonic.nChannels
                    if freq(fr)*nthharm > ir.freqVector(end)  
                        harm_shift(nthharm)=0;
                    else
                        harm_shift(nthharm)=harmonic.ch(nthharm).freq2value(freq(fr)*nthharm);
                    end
                    HD(fr,nthharm)= sqrt((sum(abs(harm_shift(nthharm)').^2)))/sqrt(sum(abs(ir.freq2value(freq(fr))').^2)); % To be verified again
                end
                THD(fr)=sqrt((sum(abs(harm_shift(2:end)').^2)))/sqrt(sum(abs(harm_shift').^2));
                THDN(fr)=sqrt((sum(abs(harm_shift(2:end)').^2)))/sqrt(sum(abs(ir.freq2value(freq(fr))').^2));
            end

%             % Fast Computation: need to be tested on a real loudspeaker.
%             nChannels    = harmonic.nChannels;
%             harmonic     = harmonic';
%             emptyResult  = itaResult(0*harmonic.ch(1));
%             sr           = harmonic.samplingRate;
%             for idx = 1:nChannels
%                 harmonixx(idx) = emptyResult; 
%                 token = harmonic.ch(idx);
%                 freqIndexOrig   = 1:harmonic.nBins;
%                 freqIndexScaled = freqIndexOrig(1:floor(end/idx)) * idx;
%                 harmonixx(idx).freqData(1:length(freqIndexScaled)) = token.freqData(freqIndexScaled);
%             end
%             
%             harmonixx = merge(harmonixx);
%             
%             THD = sqrt(ita_sum(abs(harmonixx.ch(2:nChannels)')^2)) / sqrt(ita_sum(abs(harmonixx')^2));
%             THD.channelNames{1} = 'Total Harmonic Distortion';            

            % Do we have reached one of the limit?
            if max(THD) >= stop_criteria/100 || amplitude >= amp_end  % Stop criteria= specified percentage for the THD or maximal power
                dontstop = 0;
                mic_amp = mean(abs(ir.freqData))/Mic_sens;                
            else
                dontstop = 1;
                amplitude = amplitude+delta_amp;    % increase the amplitude (>>addition in dB)
                amp = amp+1;
                pause(1);           % Waiting for a cooling of the LS
                
            end
        end

        % Post-processing and Results (to be adapted once the fast
        % computation tested)
        
        % Max SPL
        varargout(1)={mic_amp};
        
        % THD for the last amplitude
        THD_ao = itaResult;
        THD_ao.freqData = THD';
        THD_ao.freqVector = freq';
        varargout(2) = {THD_ao};
        
        % THD for the last amplitude
        THDN_ao = itaResult;
        THDN_ao.freqData = THDN';
        THDN_ao.freqVector = freq';
        varargout(3) = {THDN_ao};
        
        % HD with noise for the last amplitude
        for h=1:n
                HD_ao(h) = itaResult;
                HD_ao(h).freqData = HD(:,h)';
                HD_ao(h).freqVector = freq';
        end
        varargout(4) = {HD_ao};
end
