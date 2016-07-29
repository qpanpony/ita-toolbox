function varargout = ita_generate(varargin)
%ITA_GENERATE - Generate some deterministic signals
%  This function generates frequently used signals with the given specification
%  below. Use this function to generate a sweep, sine, cosine, impulse,
%  noise, or special modulated tones.
%
%  Syntax: spk/dat = ita_generate('type', amplitude,(freq),SamplingRate,fft_degree)
%  Syntax: dat     = ita_generate('emptydat',44100,15)
%  Syntax: dat     = ita_generate('impulse',1,44100,15)
%  Syntax: dat     = ita_generate('impulsetrain',1,44100,15,number of impulses in signal)
%  Syntax: dat     = ita_generate('diffimp',1,44100,15) - derivative of impulse
%  Syntax: dat     = ita_generate('sine',Amplitude,Frequency,44100,15,['fullperiod'])
%  Syntax: dat     = ita_generate('cosine',Amplitude,Frequency,44100,15)
%  Syntax: dat     = ita_generate('ComplexTone',[AmplVector], [FreqVector],44100,15,[OptionalPhaseInRad])
%  Syntax: dat     = ita_generate('AMtone',Amplitude,frequency,ModDegree,ModFrequency,44100,15)
%  Syntax: dat     = ita_generate('FMtone',Amplitude,CenterFreq,ModFreq,ModIndex,44100,15)
%  Syntax: dat     = ita_generate('noise',1,44100,15)
%  Syntax: dat     = ita_generate('pinknoise',1,44100,15)
%  Syntax: dat     = ita_generate('flatnoise',1,44100,15)
%  Syntax: spk     = ita_generate('flat',1,44100,15) returns a flat spectrum with ones
%  Syntax: dat     = ita_generate('ComplexExp',a,tau,f0,phi,sr,fft_deg)
%                    f = a*exp(-t/tau) * exp(j2pi t) * e(j phi)
%
%  Sweeps: are handled by ita_generate_sweep
%
%
%   See also ita_generate_sweep, ita_time_shift.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_generate">doc ita_generate</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  30-Jun-2008

% TODO: use ita_parse_arguments and allow also nSamples instead of fftDeg
% (without parser this is a very repetitive task)

%% Initialization
%Inarg checking
narginchk(0,7);
thisFuncStr  = [upper(mfilename) ':'];

%% Check if Toolbox Setup is up-to-date
ita_check4toolboxsetup();

% if there is no input parameter --> GUI
if nargin == 0
    audioObj = ita_generate_gui();
else
    signal_type  = varargin{1};
    
    %% Generation of different types
    audioObj = itaAudio;
    switch lower(signal_type)
        case 'complexexp' %'ComplexExp',a,tau,f0,phi,sr,fft_deg
            if nargin == 7
                a = varargin{2};
                tau = varargin{3};
                f0 = varargin{4};
                phi = varargin{5};
                sr = varargin{6};
                [nSamples,fftDegree] = ita_nSamples(varargin{7});
            elseif nargin == 4
                aux = varargin{2};
                a = aux(1);
                tau = aux(2);
                f0 = aux(3);
                phi = aux(4);
                sr = varargin{3};
                [nSamples,fftDegree] = ita_nSamples(varargin{4});
            else
                error('see syntax')
            end
            
            if isnan(phi)
                phi = 0;
            end
            
            audioObj.samplingRate = sr;
            t = linspace(0,nSamples./sr,nSamples);
            audioObj.timeData = real(a .* exp(-t./tau) .* exp(1i*2*pi*f0.*t) .* exp(1i*phi)).';
            audioObj.signalType = 'energy';
            
        case 'halfsineshock'
            if nargin ~= 4
                error('ITA_GENERATE:Please see syntax.')
            end
            a   = varargin{2};
            D   = varargin{3};
            sr  = varargin{4};
            nSamples = 2 * round(D * sr); %is always even
            audioObj.timeData = [(0:(nSamples/2-1))./(nSamples/2) zeros(1,nSamples/2)].';
            audioObj.timeData = a * sin(audioObj.timeData * pi);
            audioObj.timeData = circshift(audioObj.timeData,[floor(nSamples/4),1]);
            audioObj.samplingRate = sr;
            audioObj.comment = ['Half Sine Shock - (' num2str(D) ' sec)'];
            %             audioObj.channelNames{1} = audioObj.comment;
            audioObj.signalType = 'energy';
            
        case 'egyptiannoise'
            audioObj_raw = ita_generate('noise',varargin{2:4});
            audioObj = ita_mpb_filter(audioObj_raw,[3000 16000]);
            
        case 'emptydat'
            if nargin ~= 3
                error('ITA_GENERATE:Please see syntax.')
            end
            SamplingRate = varargin{2};
            [nSamples,fftDegree] = ita_nSamples(varargin{3});
            audioObj.timeData   = zeros(nSamples,1);
            audioObj.samplingRate = SamplingRate;
            audioObj.comment = 'Empty Signal';
            audioObj.channelNames{1} = audioObj.comment;
            audioObj.channelUnits{1} = '';
            audioObj.signalType = 'energy';
            
        case {'impulse','diffimp'}
            if nargin ~= 4
                error('ITA_GENERATE:Please see syntax.')
            end
            Amplitude    = varargin{2};
            SamplingRate = varargin{3};
            [nSamples,fftDegree] = ita_nSamples(varargin{4});
            audioObj.timeData   = zeros(nSamples,1);
            
            audioObj.timeData(1,:) = Amplitude;
            audioObj.samplingRate = SamplingRate;
            audioObj.comment = 'Impulse';
            audioObj.channelNames{1} = audioObj.comment;
            %             audioObj.channelUnits{1} = '';
            audioObj.signalType = 'energy'; %energy signal
            if strcmpi(signal_type,'diffimp')
                audioObj.timeData(2,:) = -Amplitude;
            end
            
        case {'impulsetrain'}
            if nargin ~= 5
                error('ITA_GENERATE:Please see syntax.')
            end
            Amplitude    = varargin{2};
            SamplingRate = varargin{3};
            [nSamples,fftDegree] = ita_nSamples(varargin{4});
            repetition   = varargin{5};
            Interval = round(nSamples/repetition);
            audioObj.timeData   = zeros(nSamples,1);
            audioObj.timeData(1:Interval:nSamples,:) = Amplitude;
            audioObj.samplingRate = SamplingRate;
            audioObj.comment = 'Impulse';
            audioObj.channelNames{1} = audioObj.comment;
            audioObj.channelUnits{1} = '';
            audioObj.signalType = 'energy'; %energy signal
            
        case {'sine','sin'}
            if all(nargin ~= [5 6])
                error('ITA_GENERATE:Please see syntax.')
            end
            Amplitude    = varargin{2};
            Frequency    = varargin{3};
            SamplingRate = varargin{4};
            [nSamples,fftDegree] = ita_nSamples(varargin{5});
            if nargin > 5
                if strcmpi(varargin{6},'fullperiod') %RSC - I think this is useful, MLI
                    periods = floor(nSamples / SamplingRate * Frequency); %Full periods in time frame
                    Frequency = periods * SamplingRate/nSamples; %change the variable Frequency to the nearest frequency line
                end
            end
            audioObj.timeData = Amplitude.*sin((0:nSamples-1)./ SamplingRate * 2.* pi * Frequency).';
            audioObj.samplingRate = SamplingRate;
            audioObj.comment = ['Sine - '  num2str(Frequency) 'Hz' ];
            audioObj.channelNames{1} = audioObj.comment;
            audioObj.channelUnits{1} = '';
            audioObj.signalType = 'power';
            
        case 'amtone'
            if nargin ~= 7
                error('ITA_GENERATE:Please see syntax.')
            end
            Amplitude    = varargin{2};
            Frequency    = varargin{3};
            ModDegree    = varargin{4};
            ModFreq      = varargin{5};
            SamplingRate = varargin{6};
            [nSamples,fftDegree] = ita_nSamples(varargin{7});
            audioObj.timeData = Amplitude.*sin((1:nSamples)'./ SamplingRate * 2.* pi * Frequency);
            onesVec         = ones(nSamples,1);
            testVec   = onesVec + ModDegree .*cos((1:nSamples)./ SamplingRate * 2.* pi * ModFreq).';
            audioObj.timeData      = audioObj.time .* testVec;
            audioObj.samplingRate = SamplingRate;
            audioObj.comment = ['AM Tone - '  num2str(Frequency) 'Hz - ' num2str(ModFreq) 'Hz - ' num2str(ModDegree) ];
            audioObj.channelNames{1} = audioObj.comment;
            audioObj.channelUnits{1} = '';
            audioObj.signalType = 'energy';
            
        case 'fmtone'
            if nargin ~= 7
                error('ITA_GENERATE:Please see syntax.')
            end
            Amplitude       = varargin{2};
            CenterFreq      = varargin{3};
            ModFreq         = varargin{4};
            ModIndex        = varargin{5};
            SamplingRate    = varargin{6};
            [nSamples,fftDegree] = ita_nSamples(varargin{7});
            
            %%%According to Hartmann: Signals, Sound, and Sensation; Springer 1998
            audioObj.timeData = Amplitude .* sin(CenterFreq.*(1:nSamples)./ SamplingRate * 2.* pi + ModIndex .*sin(ModFreq .* (1:nSamples)./ SamplingRate * 2.* pi)  ).';
            audioObj.samplingRate = SamplingRate;
            audioObj.comment = ['FM Tone - '  num2str(CenterFreq) 'Hz - ' num2str(ModFreq) 'Hz,' num2str(ModIndex)  ];
            audioObj.channelNames{1} = audioObj.comment;
            audioObj.channelUnits{1} = '';
            audioObj.signalType = 'energy';
            
        case {'cosine','cos'}
            if nargin ~= 5
                error('ITA_GENERATE:Please see syntax.')
            end
            Amplitude    = varargin{2};
            Frequency    = varargin{3};
            SamplingRate = varargin{4};
            [nSamples,fftDegree] = ita_nSamples(varargin{5});
            audioObj.timeData = Amplitude.*cos((1:nSamples)./ SamplingRate * 2.* pi * Frequency).';
            audioObj.samplingRate = SamplingRate;
            audioObj.comment = ['Cosine - '  num2str(Frequency) 'Hz' ];
            audioObj.channelNames{1} = audioObj.comment;
            audioObj.channelUnits{1} = '';
            audioObj.signalType = 'power';
            
        case {'noise','whitenoise'}
            if nargin ~= 4
                error('ITA_GENERATE:Please see syntax.')
            end
            Amplitude    = varargin{2};
            SamplingRate = varargin{3};
            [nSamples,fftDegree] = ita_nSamples(varargin{4});
            audioObj.timeData   = randn(nSamples,1).*Amplitude;
            audioObj.samplingRate = SamplingRate;
            audioObj.comment = 'White Noise';
            audioObj.channelNames{1} = audioObj.comment;
            audioObj.channelUnits{1} = '';
            audioObj.signalType = 'power';
            
        case 'pinknoise'
            if nargin ~= 4
                error('ITA_GENERATE:Please see syntax.')
            end
            Amplitude    = varargin{2};
            SamplingRate = varargin{3};
            [nSamples,fftDegree] = ita_nSamples(varargin{4});
            audioObj.timeData   = randn(nSamples,1).*Amplitude;
            audioObj.samplingRate = SamplingRate;
            audioObj.comment = 'Pink Noise';
            audioObj.channelNames{1} = audioObj.comment;
            audioObj.channelUnits{1} = '';
            bin_dist    =   audioObj.samplingRate ./ (2 .* (audioObj.nBins - 1));
            bin_vector  =   (0:audioObj.nBins-1).' .* bin_dist;
            bin_vector  =   repmat(bin_vector,audioObj.nChannels,1);
            audioObj.freqData  =   audioObj.freqData ./  sqrt(bin_vector .* 2 .* pi .* 1i);
            audioObj.signalType = 'power';
            audioObj    =   ita_ifft(audioObj);
            
        case 'flatnoise'
            if nargin ~= 4
                error('ITA_GENERATE:Please see syntax.')
            end
            Amplitude    = varargin{2};
            SamplingRate = varargin{3};
            [nSamples,fftDegree] = ita_nSamples(varargin{4});
            temp = itaAudio;
            temp.freqData     = Amplitude.*ones(nSamples/2+1,1);
            % MMT: bugfix for wrong phase distribution (should be rand not randn)
            temp.freqData     = temp.freqData .* exp(1i.*rand(nSamples/2+1,1).*2*pi);
            temp.freqData(1)  = real(temp.freqData(1));
            temp.freqData(end)  = real(temp.freqData(end)); %these must me real!
            temp.samplingRate = SamplingRate;
            temp.signalType = 'power';
            audioObj       = ita_ifft(temp);
            audioObj.comment = 'Flat Noise';
            audioObj.channelNames{1} = audioObj.comment;
            audioObj.channelUnits{1} = '';
            
        case 'flat'
            if nargin ~= 4
                error('ITA_GENERATE:Please see syntax.')
            end
            Amplitude     = varargin{2};
            SamplingRate  = varargin{3};
            [nSamples,fftDegree] = ita_nSamples(varargin{4});
            nBins         = nSamples/2 + 1;
            audioObj.freqData    = Amplitude.*ones(nBins,1);
            audioObj.samplingRate = SamplingRate;
            audioObj.comment = 'Flat Spectrum';
            audioObj.channelNames{1} = audioObj.comment;
            audioObj.channelUnits{1} = '';
            audioObj.signalType = 'energy'; %pdi: seems to be most suitable
            
        case {'ccxsweep','ccxsweep*'}
            %pdi: generation of sweeps according to Mueller/Massarani AES
            %2001
            if nargin == 4 % no stop margin and freqency vector
                f0 = varargin{2}(1);
                f1 = varargin{2}(2);
                samplingRate = varargin{3};
                [nSamples,fftDegree] = ita_nSamples(varargin{4});
                stopMargin = 0.2 * nSamples/samplingRate;
                ita_verbose_info([thisFuncStr 'Automatic Stop Margin ' num2str(stopMargin) ' seconds'],1);
            elseif nargin == 5
                f0 = varargin{2}(1);
                f1 = varargin{2}(2);
                stopMargin = varargin{3};
                samplingRate = varargin{4};
                [nSamples,fftDegree] = ita_nSamples(varargin{5});
            else
                error('see syntax')
            end
            if samplingRate < fftDegree
                [samplingRate, fftDegree] = deal(fftDegree, samplingRate); %Switch vars
            end
            audioObj   = ita_generate('flat',1,samplingRate,fftDegree+1); %do one more in here
            freq_vec = audioObj.freqVector;
            audioObj.freqData = audioObj.freqData ./ sqrt(freq_vec);
            
            tg_start = 1./samplingRate;
            tg_end   = nSamples / samplingRate - stopMargin;
            bin_dist = samplingRate ./ audioObj.nSamples;
            
            f_low    = f0;
            %f_high   = f1;
            f_start  = f0 / sqrt(2);
            f_end    = f1 * sqrt(2);
            
            filt_vec = [f_start f_end];
            
            B = (tg_end-tg_start) / log2(f_end/f_start);
            a = tg_start - B * log2(f_start);
            group_delay = a + B * log2(freq_vec);
            
            %% filtertype            
            %hard limiting
            first_gd = 0.75*audioObj.nSamples/samplingRate;%*tg_start;
            last_gd  = first_gd;%tg_end;
            
            % put together again
            group_delay(group_delay < tg_start) = first_gd;
            group_delay(group_delay > tg_end)   = last_gd;
            
            phase = -(mod(cumsum([0; group_delay(2:end)]) * (bin_dist * 2*pi) + pi,2*pi) - pi);
            
            %correcting the phase according to swen mueller
            phase = phase - freq_vec / (audioObj.samplingRate / 2) * phase(end);
            
            f_low_bin = round(f_low * 0.5 / bin_dist)+1; %pdi
            audioObj.freqData(audioObj.freqData > audioObj.freqData(f_low_bin)) = audioObj.freqData(f_low_bin);
            
            %Finally obtain the SWEEP
            audioObj.freqData = audioObj.freqData .* exp(1i * phase);
            
            fade_samples = round(min(max(1/f_low*samplingRate,600),0.1*nSamples));
            audioObj = ita_mpb_filter(audioObj,filt_vec,'zerophase','order',2);
            audioObj = ita_time_window(audioObj,[fade_samples, 1]);
            audioObj = ita_time_window(audioObj,round([(tg_end)*samplingRate min(tg_end*1.02*samplingRate, nSamples)]),'samples');
            %audioObj = ita_extend_dat(audioObj);
            
            audioObj = ita_extract_dat(audioObj);
            audioObj = ita_normalize_dat(audioObj);
            audioObj.channelNames{1} = ['ccxsweep ' num2str(f0) ' to ' num2str(f1)];
            audioObj.signalType = 'power';
            
        case {'swenlinsweep'}
            if ~isempty(varargin{5})
                fftDegree = varargin{5};
            else
                fftDegree = 18;
            end
            if ~isempty(varargin{4})
                fs = varargin{4};
            else
                fs = 48000;
            end
            if ~isempty(varargin{3})
                stopMargin = varargin{3};
            else
                stopMargin = 0.5;
                % length in seconds of silence in end of sweep
            end
            
            a = ita_generate('flat',1,fs,fftDegree);
            
            gd_0 = .03;         % time in seconds when sweep starts
            gd_end = a.trackLength - stopMargin;
            if gd_end < gd_0
                error('Stop margin is too big');
            end
            
            a = ita_generate('flat',1,fs,fftDegree+1);
            
            k = (gd_end - gd_0)/a.nBins;
            gd = (gd_0 + k*(0:a.nBins-1));
            
            binDist = a.samplingRate/a.nSamples;
            pha = cumsum(-gd)*binDist*2*pi;
            pha = pha - (0:a.nBins-1)/(a.nBins-1)*rem(pha(end),pi);
            a.freqData = exp(1i*pha(:));
            
            win_lim = [gd_0 0 min(gd_end,a.trackLength/2-gd_0)+[0 gd_0]];
            a = ita_time_window(a,win_lim,'time');
            
            for idx = 1:50
                pha = angle(a.freqData);
                a.freqData = exp(1i*pha(:));
                a = ita_time_window(a,win_lim,'time');
            end
            
            a = ita_extract_dat(a);
            a = ita_normalize_dat(a);
            audioObj = ita_metainfo_rm_historyline(a,'all');
            audioObj.signalType = 'power';    
           
        case{'complextone'}
            if nargin > 6
                error('ITA_GENERATE:Please see syntax.')
            end
            Amplitude    = varargin{2};
            Frequency    = varargin{3};
            SamplingRate = varargin{4};
            [nSamples,fftDegree] = ita_nSamples(varargin{5});
            if nargin == 6  % Optional Phase info
                phase = varargin{6};
            else
                phase = zeros(1,numel(Frequency));
            end
            
            if numel(Frequency)>1 % giving more than one tone
                SamplingPointMatrix = repmat((1:nSamples),numel(Frequency),1)./ SamplingRate;
                FrequencyMatrix =repmat(Frequency.',1,nSamples);
                PhaseMatrix = repmat(phase.',1,nSamples);
                if numel(Frequency) ~= numel(Amplitude) % Usea same Amplitude for all tones
                    AmplitudeVector = repmat(Amplitude,numel(Frequency),nSamples);
                else
                    AmplitudeVector = repmat(Amplitude.',1,nSamples);
                end
                audioObj.timeData(:,1) = sum((AmplitudeVector.*sin(SamplingPointMatrix .* 2.* pi .* FrequencyMatrix + PhaseMatrix )),1);
            else
                audioObj.timeData(:,1) = Amplitude.*sin((1:2^(fftDegree))./ SamplingRate * 2.* pi .* Frequency);
            end
            
            audioObj.comment = ['ComplexTone - '  num2str(Frequency) 'Hz' ];
            audioObj.channelNames{1} = audioObj.comment;
            audioObj.channelUnits{1} = '';
            audioObj.signalType = 'power';
            
        otherwise
            error('ITA_GENERATE:I do not know to create such a signal.')
    end
    
    %% Add history line
    audioObj = ita_metainfo_rm_historyline(audioObj,'all');
    audioObj = ita_metainfo_add_historyline(audioObj,'ita_generate',varargin);
end

varargout(1) = {audioObj};

%end function
end
