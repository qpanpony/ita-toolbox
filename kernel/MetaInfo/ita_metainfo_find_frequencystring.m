function varargout = ita_metainfo_find_frequencystring(varargin)
%ITA_HEADER_FIND_FREQUENCYSTRING - Find Frequency in ChannelNames
%  This function
%
%  Syntax: itaAudio = ita_header_find_frequencystring(itaAudio)
%  RETURN HEADER
%   See also ita_roomacoustics, ita_sqrt, ita_roomacoustics_reverberation_time, ita_roomacoustics_reverberation_time_hirata, ita_roomacoustics_energy_parameters, test, ita_sum, ita_audio2struct, test, ita_channelnames_to_numbers, ita_test_all, ita_test_rsc, ita_arguments_to_cell, ita_test_isincellstr, ita_empty_header, ita_header_check ita_header_to_filename, ita_filename_to_header, ita_header_coordinates, ita_header_coordinates, ita_header_coordinates, ita_roomacoustics_EDC, test_ita_class.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_header_find_frequencystring">doc ita_header_find_frequencystring</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  20-Jan-2009


%% Initialization and Input Parsing
narginchk(1,1);
if isa(varargin{1},'itaSuper')
    data = varargin{1};
else
    error('what is this? it should be itaAudio')
end

%% Go through all channels and find frequencies
ChannelNames = data.channelNames;
for idx = 1:length(ChannelNames)
    if isstrprop(ChannelNames{idx}(1),'alphanum')
        num_end = findstr(ChannelNames{idx},'Hz')-1;
        frequency(idx) = str2double(ChannelNames{idx}(1:num_end));
        newChannelNames{idx} = ChannelNames{idx}(num_end+6:end);%without freq prefix
    else
        disp('This is not a frequency. Doing Nothing');
        newChannelNames{idx} = ChannelNames{idx};
        frequency(idx) = 1;
    end
end
data.channelNames = newChannelNames;

%% Check if more channels with same frequencies
idx = find(frequency == frequency(1));
if length(idx) > 1 %several same frequencies
    if idx(2) == 2
        frequency = reshape(frequency,length(idx),length(frequency)/length(idx));
    else

    end
else

end

%% Find output parameters

varargout(1) = {frequency};
%end function
end