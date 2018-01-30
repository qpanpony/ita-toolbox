function lspSignals = filterCTC_LS2or4(binauralInput, ctcFilter, crossoverFreq)
% filterCTC_LS2or4 - Filter binaural signal with CTC filter network
%  This function receives a binaural singal as a two channel itaAudio
%  object and a CTC filter as a multi channel itaAudio object (depending on
%  the loudspeaker count). This version supports two or four CTC
%  loudspeakers.
%  Alternative version to general filterCTC method which also allows to
%  pass a crossover frequency 

% Authors: Florian Pausch, Lukas Aspöck -- Email: {fpa, las}@akustik.rwth-aachen.de
% 2014

warning('this function is obsolete and will vanish in future realeases. Use ita_ctc_loudspeaker_signals.'); %MKO

    ctcDelay=ctcFilter(1,1).nSamples/2;

    % Frequency vectors for the binaural input
    if binauralInput.nChannels ~= 2
        error('The binaural signal must contain two channels.')
    else
        inL = binauralInput.ch(1);
        inR = binauralInput.ch(2);
    end

    % Frequency vectors for the CTC filters.
    % e.g.: CTC_LR -> transfer function for the filter from the left signal to
    % the right loudspeaker.
    if ctcFilter.nChannels == 4
        
        if (crossoverFreq > 0)
             % signal above crossover frequency without ctc filter, just binaural
                CTC_HF = itaAudio;
                CTC_HF.samplingRate = ctcFilter(1,1).samplingRate;
                CTC_HF.timeData = zeros(ctcFilter.nSamples, 4);
                CTC_HF.timeData(ctcDelay, 1) = sum(ctcFilter.ch(1).time.^2);
                CTC_HF.timeData(ctcDelay, 4) = sum(ctcFilter.ch(4).time.^2);
                CTC_HF.signalType = 'energy';       

                ctc_low  = ita_mpb_filter(ctcFilter, [0 crossoverFreq]);
                ctc_high = ita_mpb_filter(CTC_HF, [crossoverFreq 0]);

                ctcFilter = ctc_low + ctc_high;
        end
        % Lentz-Notation: [LL RL; LR RR] // Bruno-Notation [1L 1R;2L 2R]
        % ita_merge merged spaltenweise
        CTC_1L = ctcFilter.ch(1); % from first speaker to left ear
        CTC_1R = ctcFilter.ch(3);
        CTC_2L = ctcFilter.ch(2);
        CTC_2R = ctcFilter.ch(4);
        
        outL = ita_convolve(inL,CTC_1L) + ita_convolve(inR,CTC_1R);
        outR = ita_convolve(inL,CTC_2L) + ita_convolve(inR,CTC_2R);
        
        % Output
        lspSignals = itaAudio;
        lspSignals.samplingRate = CTC_1L.samplingRate;
        lspSignals.timeData = zeros(outL.nSamples, 2);
        lspSignals.timeData(:, 1) = outL.time;
        lspSignals.timeData(:, 2) = outR.time;
        
        % compensate CTC filter latency
        lspSignals = ita_time_shift(lspSignals, -ctcDelay, 'samples');
    elseif  ctcFilter.nChannels == 8
        
       if (crossoverFreq > 0)
             % signal above crossover frequency without ctc filter, just binaural
                CTC_HF = itaAudio;
                CTC_HF.samplingRate = ctcFilter(1,1).samplingRate;
                CTC_HF.timeData = zeros(ctcFilter.nSamples, 8);
                CTC_HF.timeData(ctcDelay, 1) = sum(ctcFilter.ch(1).time.^2);
                CTC_HF.timeData(ctcDelay, 7) = sum(ctcFilter.ch(7).time.^2);
                CTC_HF.signalType = 'energy';       

                ctc_low  = ita_mpb_filter(ctcFilter, [0 crossoverFreq]);
                ctc_high = ita_mpb_filter(CTC_HF, [crossoverFreq 0]);

                ctcFilter = ctc_low + ctc_high;
        end
        
                
        % LAS NEW
        CTC_1L = ctcFilter.ch(1); % from first speaker to left ear
        CTC_1R = ctcFilter.ch(5);
        CTC_2L = ctcFilter.ch(2);
        CTC_2R = ctcFilter.ch(6);
        CTC_3L = ctcFilter.ch(3);
        CTC_3R = ctcFilter.ch(7);
        CTC_4L = ctcFilter.ch(4);
        CTC_4R = ctcFilter.ch(8);
        
        out1 = ita_convolve(inL,CTC_1L) + ita_convolve(inR,CTC_1R);
        out2 = ita_convolve(inL,CTC_2L) + ita_convolve(inR,CTC_2R);
        out3 = ita_convolve(inL,CTC_3L) + ita_convolve(inR,CTC_3R);
        out4 = ita_convolve(inL,CTC_4L) + ita_convolve(inR,CTC_4R);
        
       
        
        % Output
        lspSignals = itaAudio;
        lspSignals.samplingRate = CTC_1L.samplingRate;
        lspSignals.timeData = zeros(out1.nSamples, 4);
        lspSignals.timeData(:, 1) = out1.time;
        lspSignals.timeData(:, 2) = out2.time;
        lspSignals.timeData(:, 3) = out3.time;
        lspSignals.timeData(:, 4) = out4.time;
        
        % compensate CTC filter latency
        lspSignals = ita_time_shift(lspSignals, -ctcDelay, 'samples');
    else
        error('The CTC filter must contain two or four channels.')
    end

end

