function [varargout] = ita_read_BK_pulse(varargin)
%ITA_READ_BK_PULSE - Import BK Pulse Data
%  Import raw data exported to MATLAB with BK Pulse measurement system.
%  This function directly converts into ITA representation.
%
%  Call: spk/dat = ita_BK_pulse_read([filename])
%
%   See also ita_read, ita_write.
%
%   Reference page in Help browser
%       <a href="matlab:doc ita_BK_pulse_read">doc ita_BK_pulse_read</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  29-May-2008

%% Init
thisFuncStr  = [upper(mfilename) ':'];

%% Get Filename if missing
if nargin == 0 % No filename specified
    result{1}.extension = '.mat';
    result{1}.comment = 'BK Pulse Matlab Export (*.mat)';
    varargout{1} = result;
    return
else
    filename  = varargin{1};
end

data_set        = load(filename);
if ~isfield(data_set,'File_Header')
    ita_verbose_info([thisFuncStr 'This was not exported by BK Pulse. Returning RAW data instead.'],0)
    varargout{1} = data_set;
    return;
end
number_channels = str2num(data_set.File_Header.NumberOfChannels);
header.FileInfo = data_set.File_Header;
data = itaAudio;
data.timeData   = zeros(number_channels,length(getfield(data_set,['Channel_' num2str(1) '_Data'])))';

%% Get data and additional File Info
for idx = 1:number_channels
    data.timeData(:,idx) = getfield(data_set,['Channel_' num2str(idx) '_Data']);
    header.info(idx).header = getfield(data_set,['Channel_' num2str(idx) '_Header']);
    test = getfield(data_set,['Channel_' num2str(idx) '_Header']);
    ChannelNames{idx} = test.SignalName;
    ChannelUnits{idx} = test.Unit;
end

%% Update header

data.samplingRate    = str2num(data_set.File_Header.SampleFrequency(1:5));
data.dateCreated     = [datevec(datenum(header.FileInfo.Date)) 0];
data.comment         = [data_set.File_Header.Comment ' - ' filename];
data.channelNames    = ChannelNames;
data.channelUnits    = ChannelUnits;

%% New header settings
data.fileName  = (filename);


%% Find output parameter
varargout(1) = {data};

