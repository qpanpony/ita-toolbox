function varargout = ita_nonlinear_shift_frequency_vector(varargin)
% ITA_NONLINEAR_SHIFT_FREQUENCY_VECTOR - Shifts a set of harmonics corresponding to their frequency vector
% This function shifts the frequency vector of a harmonic according to the 
% degree of the harmonic to be shifted. If no degree is specified, a
% itaAudio with channels corresponding to the harmonics is assumed,
% i.e. channel 1 is the fundamental ... channel N is the n^th harmonic.
% If a degree is specified all channels will be shifted corresponding to
% this fixed degree.
% 
%  Syntax:
%   audioObjOut = ita_nonlinear_shift_frequency_vector(audioObjIn, options)
%
%   Options (default):
%           'left' (true)       : shift spectrum to the left (lower frequencies)
%           'right' (false)     : shift spectrum to the right (higher frequencies)
%           'degree' ([])       : use a fixed degree of harmonics
%           'array' (false)     : format as an array instead of one
%                                 itaAudio with multiple channels
%
%  Example:
%   audioObjOut = ita_nonlinear_shift_frequency_vector(audioObjIn, 'left')
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_nonlinear_shift_frequency_vector">doc ita_nonlinear_shift_frequency_vector</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Marco Berzborn -- Email: marco.berzborn@akustik.rwth-aachen.de
% Created:  11-Dec-2014 


%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudio', 'left', true, 'right', false, 'degree', [], 'array', false);
[audioObjIn,sArgs] = ita_parse_arguments(sArgs,varargin); 

if sArgs.right
    sArgs.left = false;
elseif sArgs.left
    sArgs.right = false;
end

if numel(audioObjIn) > 1
    audioObjIn =  ita_merge(audioObjIn);
    ita_verbose_info(['Conversion from an Array to an itaAudio with ' num2str(audioObjIn.nChannels) ' channels'], 1);
end

%% do a pre shift that will be compensated at the end
% preShiftSamples = ita_start_IR(audioObjIn);
% audioObjIn = ita_time_shift(audioObjIn,-preShiftSamples,'samples');

%% shift
degree = sArgs.degree;
audioObjInVector(audioObjIn.nChannels) = itaAudio();
audioObjOutVector(audioObjIn.nChannels) = itaAudio();
for idx = 1:audioObjIn.nChannels
    audioObjInVector(idx) = audioObjIn.ch(idx);
    audioObjOutVector(idx) = audioObjIn.ch(idx);
    if isempty(sArgs.degree)
        degree = idx;
    end
    if sArgs.left
        audioObjInVector(idx).samplingRate = audioObjIn.samplingRate/degree;
        % audioObjOutVector(idx) = ita_extract_dat(ita_resample(audioObjInVector(idx), audioObjIn.samplingRate), audioObjIn.fftDegree, 'symmetric');
        % this is quite faster
        audioObjOutVector(idx).freqData = [audioObjInVector(idx).freqData(1:degree:end); zeros(audioObjIn.nBins-numel(audioObjInVector(idx).freqData(1:degree:end)), 1)];
    else
        audioObjInVector(idx).samplingRate = audioObjIn.samplingRate*degree;
%         audioObjOutVector(idx) = ita_extend_dat(ita_resample(audioObjInVector(idx), audioObjIn.samplingRate), audioObjIn.fftDegree, 'symmetric');
        audioObjOutVector(idx).freqData = audioObjInVector(idx).freqData(1:round(end/degree));
        audioObjOutVector(idx) = ita_extend_dat(audioObjOutVector(idx), audioObjIn.fftDegree,'symmetric');
    end
%     audioObjOutVector(idx) = ita_time_shift(audioObjOutVector(idx),preShiftSamples(idx),'samples');
end

if ~sArgs.array
    audioObjIn = ita_merge(audioObjOutVector);
else
    audioObjIn = audioObjOutVector;
end

%% Add history line
audioObjIn = ita_metainfo_add_historyline(audioObjIn,mfilename,varargin);

varargout(1) = {audioObjIn}; 

end