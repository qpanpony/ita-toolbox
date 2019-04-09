function [ ref_factor, ref_db ] = calibrate( obj, cal_time, channels, method )
    % Default track_id and channel_num is 1, time can be relative
    % seconds of record or absolute date
    % methods: 'rms', 'maximum' or 'wideband' (default)

    if nargin < 4
        method = 'wideband';
    end
    if nargin < 3
        channels = 1;
    end

    % Extract non-calibrated (!) signal
    cal_signal = obj.extract( cal_time, channels, false );

    if strcmp( method, 'maximum' )
        % Variates the sample truncation and uses (jst)
        max_samples = 60;
        for l = 1:max_samples
            calibration_signal_chunk = ita_time_crop( cal_signal, [1 cal_signal.nSamples-l], 'samples' );
            power(l) = max( abs( calibration_signal_chunk.freqData ) );
        end
        ref_db = 20*log10( max( power ) ); % == 94 dB (Sound Calibrator Type 4231)
        ref_factor = max( power );

    elseif strcmp( method, 'wideband' )
        % Include neighbouring frequency bins around target frequency
        % of 1kHz (mgu)
        neighborBins = 20;
        nSamplesMaxCut = 100;
        justMaxVec = zeros(nSamplesMaxCut,1);
        maxAndNeighborVec = zeros(nSamplesMaxCut,1);

        for iSamplesCut = 1:nSamplesMaxCut
            tmpSine = cal_signal; % copy original
            tmpSine.timeData = tmpSine.timeData(1:end-iSamplesCut,1); % truncate signal
            [justMaxVec(iSamplesCut), idxMax] = max(abs(tmpSine.freqData));
            maxAndNeighborVec(iSamplesCut) = sqrt( sum(abs(tmpSine.freqData(idxMax-neighborBins:idxMax+neighborBins)).^2) );
        end

        ref_db = 20*log10( max( maxAndNeighborVec ) );

        ref_factor = max( maxAndNeighborVec );

    else
        % Use root-mean-square (ITA Toolbox RMS)
        rms = cal_signal.rms;
        if rms > 0
            ref_db = 20*log10( rms );
        else
            ref_db = -Inf;
        end
        ref_factor = rms;
    end

    track_ids = obj.get_track_ids( channels );
    for t = 1:numel( track_ids )
        obj.tracks{ track_ids( t ) }.cal_ref_factor = ref_factor;
    end

end
