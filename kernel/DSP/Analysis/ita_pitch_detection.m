function varargout = ita_pitch_detection(varargin)
%ITA_PITCH_DETECTION - detect pitch in audio signal
%  Cepstrum biased harmonic product spectrum based pitch detection
%  This function will try to determine the pitch of a given audio signal
%  It will return the pitch and a confidence value between 1 and 0 which describes how reliable the pitch determination is
%
%  Syntax: [f_pitch, confidence] = ita_pitch_detection(itaAudio, Options)
%
%       Options (default): f_min (10):                      Minimum frequency to use when searching for pitch. Should be greater than 0
%                          f_max (22100):                   Maximum frequency to use when searching for pitch. Should be less than Nyquist-Frequency
%                          'overtones' (5):                 Iteration used for calculation of harmonic product spectrum. Should be equal to the number of overtones of your source for best results
%                          'max_pitch_no' (1):              If there is more than one source you can search for more than one pitch. Sould be equal to the number of pitches in the audio signal
%                          'min_pitch_distance' (10):       Minimum distance in Hertz between two pitches when 'max_pitch_no' is greater than 1
%                          'min_confidence' (0.1):          Minimum confidence for returned pitches
%                          'rescale_confidence' (true):     Changes scale when searching for more than one pitch, so that pitches with high confidence still have confidence 1 instead of e.g. 0.25 for 4 pitches
%                          'blocksize' ():                  Blocksize for blockwise processing (result will be a time signal)
%                          'overlap' (0):                   Overlap for blockwise processing
%                          'window' ('hanning'):            Window applied to the signal
%
%
%   See also ita_roomacoustics, ita_sqrt, ita_roomacoustics_reverberation_time, ita_roomacoustics_reverberation_time_hirata, ita_roomacoustics_energy_parameters, test, ita_sum, ita_audio2struct, test, ita_channelnames_to_numbers, ita_test_all, ita_test_rsc, ita_arguments_to_cell, ita_test_isincellstr, ita_empty_header, ita_metainfo_check ita_metainfo_to_filename, ita_filename_to_header, ita_metainfo_coordinates, ita_metainfo_coordinates, ita_metainfo_coordinates, ita_roomacoustics_EDC, test_ita_class, ita_metainfo_find_frequencystring, clear_struct, ita_italian, ita_italian_init, ita_make_dimension_vectors, test_ita_multiple_time_windows, ita_dimension2numer, ita_pitch_detection.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_pitch_detection">doc ita_pitch_detection</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  27-Jan-2009

% ToDo: Sort pitches in some intelligent way
%       More tests
%       New options in help

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs = struct( ...
    'pos1_data','itaAudio', ...
    'f_min', 10, ...
    'f_max', 22100, ...
    'blocksize', [], ...
    'overlap', 0, ...
    'window', 'Hanning', ...
    'overtones', 5, ...
    'max_pitch_no', 1, ...
    'min_pitch_distance', 10, ...
    'min_confidence', 0.1, ...
    'rescale_confidence', true, ...
    'replace_unknown_with', nan, ...
    'fftDegree', 16);
[data, sArgs] = ita_parse_arguments(sArgs,varargin); 

if isempty(sArgs.blocksize)
    blocksize = data.nSamples;
    overlap = 0;
else
    blocksize = sArgs.blocksize;
    overlap = sArgs.overlap;
end

%% +++Body - Your Code here+++ 'result' is an audioObj and is given back

ChNo = 0;
Rest = data;

result = itaAudio();

while Rest.nChannels > 0
    ChNo = ChNo+1;
    [fulldata,Rest] = ita_split(Rest,1);
    
    segments = ceil(fulldata.nSamples/(blocksize*(1-overlap))); %How many segments wil we have?
    
    f_pitch = zeros(sArgs.max_pitch_no,segments);
    confidence = f_pitch;
    
    for iSegment = 1:segments %Process every segment
        iLow = ceil((iSegment-1)*(1-overlap)*blocksize)+1; %Calc inds
        iHigh = min(iLow+blocksize-1,fulldata.nSamples);
        data = ita_extract_samples(fulldata,iLow:iHigh,sArgs.window);
        if ~isempty(sArgs.fftDegree) && sArgs.fftDegree > data.fftDegree
            data = ita_extend_dat(data,sArgs.fftDegree);
        end
        if iHigh-iLow < blocksize
           data = ita_extend_dat(data,blocksize,'forcesamples'); 
        end
        
        if iSegment == 1
            f_vct = data.freqVector;
            i_min = find(f_vct > sArgs.f_min,1,'first');
            i_max = find(f_vct < sArgs.f_max,1,'last');
            d_i_min = find(f_vct > sArgs.min_pitch_distance,1,'first');
        end
        
        spect = ita_fft(data);
        
        hps = abs(spect.spk); %Harmonic product spectrum
        for a = 1:sArgs.overtones+1
            ds_spect = abs(resample(abs(spect.spk),1,a));
            ds_spect(end+1:length(spect.spk)) = 0;
            hps = hps .* ds_spect;
        end
        
        hps_spect = hps;
        

        cepstrum = ita_cepstrum(data);
        cepstrum = cepstrum.dat;
        cepstrum = abs(cepstrum);
        
        N = length(f_vct)*2;
        k = 1:length(cepstrum);
        
        i_fic = floor(N./k);
        fic = zeros(size(hps_spect));
        %for a = i_min:min([i_max max(i_fic)])
        for a = i_min:min(i_max)
            %fic(a) = max([0 sum(abs(cepstrum(i_fic == a)))]); %Frequency Indexed Cepstrum
            fic(a) = abs(cepstrum(i_fic(a)));
        end
        
        spect = hps_spect .* fic;
        
%         %% Debug
%         idgela = 1:500;
%         hps_spect = hps_spect ./ max(abs(hps_spect(idgela)));
%         fic = fic ./ max(abs(fic(idgela)));
%         spect = spect ./ max(abs(spect(idgela)));
%         
%         figure()
%          plot(cepstrum);
%         
%           figure();
%           plot(hps_spect);
%           hold all;
%           plot(fic);
%           plot(spect);
%           xlim([min(idgela) max(idgela)])
          
          
        
        %% Find peaks in resulting CBHPS
        a = 0;
        last_confidence = 1;
        while a < sArgs.max_pitch_no && last_confidence > sArgs.min_confidence;
            sumsum = sum(hps_spect(i_min:i_max).^2);
            a = a+1;
            [c, i] = max(spect(i_min:i_max));
            
            if i > 1 && i < i_max-i_min
                i = i + i_min;
                
                i1 = floor(max([i_min i-d_i_min/2]));
                i2 = ceil(min([i_max i+d_i_min/2]));
                
                f_pitch(a,iSegment) = f_vct(i-1);
                confidence(a,iSegment) = sum(hps_spect(i1:i2).^2) / sumsum;
                last_confidence = confidence(a,iSegment) * a;
                spect(i1:i2) = 0;
                hps_spect(i1:i2) = 0;
            else
                f_pitch(a,iSegment) = sArgs.replace_unknown_with;
                confidence(a,iSegment) = 0;               
            end
            
        end
        
        pitches = sum(confidence(:,iSegment) > 0);
        if sArgs.rescale_confidence
            confidence(:,iSegment) = min(confidence(:,iSegment).*pitches,1); %Rescale to [0 1]
        end
        
        f_pitch(confidence < sArgs.min_confidence) = sArgs.replace_unknown_with;
        confidence(confidence < sArgs.min_confidence) = 0;
        
    end
    
    %% Sort result
     %[f_pitch sort_i] = sort(f_pitch,1);
     %confidence = confidence(sort_i);
    
    result(ChNo).timeData = [f_pitch; confidence].';
%    result(ChNo).dimensions = {'time','Channels'};
    result(ChNo).samplingRate = data.samplingRate/(blocksize*(1-overlap));
    for idx = 1:size(f_pitch,1)
        result(ChNo).channelNames{idx} = ['Pitch ' int2str(idx) ' of ' data.channelNames{1}];
        result(ChNo).channelUnits{idx} = 'Hz';
        result(ChNo).channelNames{idx+size(f_pitch,1)} = ['Confidence pitch ' int2str(idx) ' of ' data.channelNames{1}];
        result(ChNo).channelUnits{idx+size(f_pitch,1)} = '';
    end
end

result = ita_merge(result);

%% Add history line
result = ita_metainfo_add_historyline(result,'ita_pitch_detection','ARGUMENTS');

%% Check header
%result = ita_metainfo_check(result);

%% Find output parameters
% Write Data
varargout(1) = {result};
%end function
end