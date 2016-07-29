function varargout = ita_multitone(varargin)
%ITA_MULTITONE - Generates a multitone signal
%  This function generates a multitone signal with the given
%  specifications. This function can create fixed logarithmically spaced
%  multitones, fixed factor spaced multitones, multitones with user
%  defined frequencies and Split-Band signals
%  Syntax: dat = ita_multitone('log', start_freq, end_freq, number_of_tones, amplitude, FFT_degree, sampling_rate)
%  Syntax: dat = ita_multitone('user', frequencies, amplitude, FFT_degree, sampling_rate)
%  Syntax: dat = ita_multitone('factor', factor, start_freq, number_of_tones, amplitude, FFT_degree, sampling_rate)
%  Syntax: dat = ita_multitone('splitband', start_freq1, factor1, number_of_tones1, start_freq2, factor2, number_of_tones_2, amplitude, FFT_degree, sampling_rate)
%
%  Example:
%   x = ita_multitone('user', [1000, 1778.279, 3162.278, 5623.413, 10000], 1, 15, 44100]
%   generates a multitone with the given frequencies.
%
%   See also ita_roomacoustics, ita_sqrt, ita_roomacoustics_reverberation_time, ita_roomacoustics_reverberation_time_hirata, ita_roomacoustics_energy_parameters, test, ita_sum, ita_audio2struct, test, ita_channelnames_to_numbers, ita_test_all, ita_test_rsc, ita_arguments_to_cell, ita_test_isincellstr, ita_empty_header, ita_metainfo_check ita_metainfo_to_filename, ita_filename_to_header, ita_metainfo_coordinates, ita_metainfo_coordinates, ita_metainfo_coordinates, ita_roomacoustics_EDC, test_ita_class, ita_metainfo_find_frequencystring, clear_struct, ita_italian, ita_italian_init, ita_multitone.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_multitone">doc ita_multitone</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: benedikt.bretthauer -- Email: @akustik.rwth-aachen.de
% Created:  27-Jan-2009 

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(1,1);

multitone_type = varargin{1};


%sArgs        = struct('pos1_data','itaAudio');
%[data,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% +++Body - Your Code here+++ 'result' is an audioObj and is given back 

switch lower(multitone_type)
    case 'log'
        
        if nargin ~= 7
            error('ITA_MULTITONE:Please see syntax.')
        end
            
        start_freq = varargin{2};
        end_freq = varargin{3};
        number_of_tones = varargin{4};
        amplitude = varargin{5};
        FFT_degree = varargin{6};
        sampling_rate = varargin{7};
        
        if end_freq > (sampling_rate/2)
            error('ITA_MULTITONE:Please mind sampling-rate.')   %Abtasttheorem �berpr�fen
        end
        
        freq_vec = 0:(sampling_rate/2)/(2^(FFT_degree-1)):(sampling_rate/2);  %Frequenzvektor f�r angegebenen FFT_degree
        increment = (log10(end_freq/start_freq))/(number_of_tones-1);
        
        for i = 0:number_of_tones-1
            freq_nonbin = 10^((log10(start_freq)) + i*increment);
            
            
            for j = 1:(size(freq_vec,2)-1)

                if abs(freq_nonbin - freq_vec(1,j)) < abs(freq_nonbin - freq_vec(1,j+1))
                    freq = freq_vec(1,j);                                       %Runden der Frequenzen auf die FFT_bins
                    break;
                end
            end
            
            single_tone = ita_generate('sine', amplitude, freq, sampling_rate, FFT_degree);
           
            if i == 0
                tone = single_tone;
            end
            
            if i >= 1
                tone = ita_add(tone, single_tone);
            end
        end
        
        result = tone;
        result.comment = ['Log-Multitone - '  num2str(start_freq) 'Hz - ' num2str(end_freq) 'Hz'];
        result.channelNames{1} = result.comment;
%         result.History = [];
        
    case 'user'
        
        if nargin ~= 5  
            error('ITA_MULTITONE:Please see syntax.')
        end
            
        freq_nonbin = varargin{2};
        amplitude = varargin{3};
        FFT_degree = varargin{4};
        sampling_rate = varargin{5};
        number_of_tones = size(freq_nonbin, 2);
        
        if freq_nonbin(1, number_of_tones) > (sampling_rate/2)
            error('ITA_MULTITONE:Please mind sampling-rate.')
        end
        
        freq_vec = 0:(sampling_rate/2)/(2^(FFT_degree-1)):(sampling_rate/2);
        
        for i = 1:number_of_tones
            
            for j = 1:(size(freq_vec,2)-1)

                if abs(freq_nonbin(1,i) - freq_vec(1,j)) < abs(freq_nonbin(1,i) - freq_vec(1,j+1))
                    freq_bin(1,i) = freq_vec(1,j);
                    break;
                end
            end
            
        end
%         freq_bin-freq_nonbin;
        for i = 1:number_of_tones
            single_tone = ita_generate('sine',amplitude, freq_bin(1, i),sampling_rate,FFT_degree);
           
            if i == 1
                tone = single_tone;
            end
            
            if i >= 2
                tone = ita_add(tone, single_tone);
            end
        end
        
        result = tone;
        result.comment = 'User defined Multitone';
        result.channelNames{1} = result.comment;
%         result.History = [];
        
    case 'factor'

        if nargin ~= 7  
            error('ITA_MULTITONE:Please see syntax.')
        end

        factor = varargin{2};
        start_freq = varargin{3};
        number_of_tones = varargin{4};
        amplitude = varargin{5};
        FFT_degree = varargin{6};
        sampling_rate = varargin{7};
        
        if (start_freq*(factor^number_of_tones-1)) > (sampling_rate/2)
            error('ITA_MULTITONE:Please mind sampling-rate.')
        end
        
        freq_vec = 0:(sampling_rate/2)/(2^(FFT_degree-1)):(sampling_rate/2);
        
        for i = 1:number_of_tones
            freq_nonbin(1,i) = start_freq*(factor^(i-1));
        end
        
        for i = 1:number_of_tones
            
            for j = 1:(size(freq_vec,2)-1)

                if abs(freq_nonbin(1,i) - freq_vec(1,j)) < abs(freq_nonbin(1,i) - freq_vec(1,j+1))
                    freq_bin(1,i) = freq_vec(1,j);
                    break;
                end
            end
            
        end

        for i = 1:number_of_tones
            single_tone = ita_generate('sine', amplitude, freq_bin(1,i), sampling_rate, FFT_degree);

            if i == 1
            tone = single_tone;
            end

            if i >= 2
                tone = ita_add(tone, single_tone);
            end

        end

        result = tone;
        result.comment = ['Fixed Factor Multitone - Start-Frequency: ', num2str(start_freq), ', Factor = ', num2str(factor), ', Number of Tones: ', num2str(number_of_tones)];
        result.channelNames{1} = result.comment;
%         result.History = [];
            
    case 'splitband'
        
        if nargin ~= 10
            error('ITA_MULTITONE:Please see syntax.')
        end
        
        start_freq1 = varargin{2};
        factor1 = varargin{3};
        number_of_tones1 = varargin{4};
        start_freq2 = varargin{5};
        factor2 = varargin{6};
        number_of_tones2 = varargin{7};
        amplitude = varargin{8};
        FFT_degree = varargin{9};
        sampling_rate = varargin{10};
        
        if (start_freq2*(factor2^number_of_tones2-1)) > (sampling_rate/2)
            error('ITA_MULTITONE:Please mind sampling-rate.')
        end
        
        freq_vec = 0:(sampling_rate/2)/(2^(FFT_degree-1)):(sampling_rate/2);
        
        for i = 1:number_of_tones1
            freq_nonbin1(1,i) = start_freq1*(factor1^(i-1));
        end
        
        for i = 1:number_of_tones1
            
            for j = 1:(size(freq_vec,2)-1)

                if abs(freq_nonbin1(1,i) - freq_vec(1,j)) < abs(freq_nonbin1(1,i) - freq_vec(1,j+1))
                    freq_bin1(1,i) = freq_vec(1,j);
                    break;
                end
            end
            
        end
        
        for i = 1:number_of_tones2
            freq_nonbin2(1,i) = start_freq2*(factor2^(i-1));
        end
        
        for i = 1:number_of_tones2
            
            for j = 1:(size(freq_vec,2)-1)

                if abs(freq_nonbin2(1,i) - freq_vec(1,j)) < abs(freq_nonbin2(1,i) - freq_vec(1,j+1))
                    freq_bin2(1,i) = freq_vec(1,j);
                    break;
                end
            end
            
        end
        
        for i = 1:number_of_tones1
            single_tone = ita_generate('sine', amplitude, freq_bin1(1,i), sampling_rate, FFT_degree);

            if i == 1
            tone = single_tone;
            end

            if i >= 2
                tone = ita_add(tone, single_tone);
            end
        end
        
        for i = 1:number_of_tones2

            single_tone = ita_generate('sine', amplitude, freq_bin2(1,i), sampling_rate, FFT_degree);
            tone = ita_add(tone, single_tone);
            
        end
        
        result = tone;
        result.comment = ['Split Band Multitone'];
        result.channelNames{1} = result.comment;
%         result.History = [];
        
    otherwise
        error('ITA_MULTITONE:Please see syntax.')
end

%% Add history line
result = ita_metainfo_add_historyline(result,'ita_multitone',varargin);

%% Check header
%result = ita_metainfo_check(result);

%% Find output parameters
ita_plot_freq(result);
varargout(1) = {result};

%end function
end