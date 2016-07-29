function result = ita_sfm_incoherent_noise(varargin)

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

sArgs = struct('audio',ita_generate('flatnoise',1,44100,16),'noisetype','noise','hrtf',[]);
sArgs = ita_parse_arguments(sArgs,varargin);

for idx = 1:sArgs.hrtf.nChannels;
    result(idx) = ita_generate(sArgs.noisetype,1,sArgs.audio.samplingRate,sArgs.audio.fftDegree); %#ok<AGROW>
end

result = ita_merge(result);

result = ita_metainfo_rm_historyline(result,'all');
result = ita_metainfo_add_historyline(result,mfilename,varargin);
result.channelCoordinates = sArgs.hrtf.channelCoordinates;
result.channelNames = sArgs.hrtf.channelNames;
result.comment = 'Incoherent noise';
end