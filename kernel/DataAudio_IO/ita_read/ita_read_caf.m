function result = ita_read_caf(filename,varargin)
%ITA_READ_FLAC - Read Core Audio Format Files
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
    result{1}.extension = '.caf';
    result{1}.comment = 'Core Audio Format Files (*.caf)';
    return
end

    
if ~exist(filename,'file')
    error('ITA_READ_CAF: File does not exist');
end

try
    [data,fs] = audioread(filename);
    result = itaAudio;
    result.samplingRate = fs;
    result.timeData = data;
catch
    error('ITA_READ_CAF: Something went wrong');
end
    
end

