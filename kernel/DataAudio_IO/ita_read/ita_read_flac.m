function result = ita_read_flac(filename,varargin)
%ITA_READ_FLAC - Read Free Lossless Audio Codec Files
%   This function is completely based on the MATLAB audioread.
%
%   It returns a itaAudio object containing the files data and metadata.
%
%   See also ita_read, ita_write, audioread.

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


%% Return type of data this function can read
if nargin == 0
    result{1}.extension = '.flac';
    result{1}.comment = 'FLAC Files (*.flac)';
    return
end

    
if ~exist(filename,'file')
    error('ITA_READ_FLAC: File does not exist');
end

try
    [data,fs] = audioread(filename);
    result = itaAudio;
    result.samplingRate = fs;
    result.timeData = data;
catch
    error('ITA_READ_FLAC: Something went wrong');
end
    
end

