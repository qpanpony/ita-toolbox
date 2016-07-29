function [varargout] = ita_read_artemis(varargin)
%ITA_ARTEMIS_READ - Import ArtemiS Data
% Import data exported to MATLAB with HeadAcoustics Artemis system.
% This function directly converts into ITA representation.
% It bases its functionality on ita_bk_pulse_read.
% It is nice for PsychParameter vs Time calculations, but it also can read
% some other paramters as Specific Loudness. It reads the header from the
% Artemis Matlab file and puts a lot of info into the ITA structure.
%
% Call: dat/spk = ita_read_artemis([filename]) 
%
%   See also ita_read, ita_write, ita_bk_pulse_read.
%
%   Reference page in Help browser 
%       <a href="matlab:doc ita_read_artemis">doc ita_read_artemis</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Sebastian Fingerhuth -- Email: sfi@akustik.rwth-aachen.de
% Created:  17-Feb-2009


if nargin == 0 % No filename specified
    result{1}.extension = '.mat';
    result{2}.extension = '.MAT';
    result{1}.comment = 'ArtemiS Matlab Export (*.mat)';
    varargout{1} = result;
    return
else
    filename  = varargin{1};
end

load(filename,'-mat');

number_channels = shdf.nNbrOfChn;

%% New header settings
[tmp.Filepath tmp.Filename tmp.FileExt]   = fileparts(filename);

data = itaAudio;

%% Get data and additional File Info
for idx = 1:number_channels
    switch shdf.Absc.szAbbrev
        case 't'
            data.dat(idx,:) = shdf.Data(idx,:);
%             data.nSamples = shdf.Absc.nNbrOfSamples;
%             data.nBins    = 'NN';
        case 'f'
            data.spk(idx,:) = shdf.Data(idx,:);
%             data.nBins = shdf.Absc.nNbrOfSamples;
%             data.nSamples    = 'NN';
            switch shdf.Absc.szUnit
                case 'Hz' 
                    data.UserData.PlotOptions.xlim = [10 shdf.Absc1Data(end) ]; % Hz
                    data.UserData.PlotOptions.ylim = [ ];
                    data.UserData.PlotOptions.xscale = 'lin';
                    data.UserData.PlotOptions.yscale = 'lin';
                case 'Bark'
                    data.UserData.PlotOptions.xlim = [1 24]; % bark
                    data.UserData.PlotOptions.ylim = [0  max(max(data.spk))];
                    data.UserData.PlotOptions.xscale = 'lin';
                    data.UserData.PlotOptions.yscale = 'lin';
                    if strcmpi(shdf.Chn.szUnit, 'soneGF/Bark')
                        data.fcentre = [1:240]/10;
                    else 
                        data.fcentre = [1:24];
                    end
            end
        otherwise
            data.data(idx,:) = shdf.Data(idx,:);
    end
    ChannelNames{idx} = [shdf.Chn(idx).szName];
    ChannelUnits{idx} = shdf.Chn(idx).szUnit;
end


%% Update header
if isfield( shdf.Chn,'dSamplingrate') %If Exist: Take Sampling-Rate from first Channel
    data.samplingRate    = shdf.Chn(1,1).dSamplingrate;     
else
    if verboseMode; 
        disp('ITA_READ_ARTEMIS: Guessing Sampling Rate. (It is not on channel 1.)');  % works for Roughness vs Time
        disp('                  Please Check it with an ArtemiS plot'); 
    end
    data.samplingRate = shdf.Absc.nNbrOfSamples/shdf.Absc.dStop;
end
% data.nChannels       = number_channels;
% data.DateVector      = [datevec(datenum(shdf.szDateOfRecording))  0];
data.comment         = [ shdf.szTitle ' ' shdf.szMoniker  ': ArtemiS Import'];
data.channelNames    = ChannelNames;
data.channelUnits    = ChannelUnits;
% data.signalType         = '-';
% data.UserData.ArtemiSHeader_Chn = shdf.Chn;
% data.UserData.ArtemiSHeader_Absc = shdf.Absc;
% data.UserData.ArtemiSHeader_UserDefinedInfos = shdf.UserDefinedInfos;


%% New header settings
% [data.Filepath data.Filename data.FileExt]   = fileparts(filename);

%% Find output parameter
varargout(1) = {data};

