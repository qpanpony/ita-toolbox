function result = ita_sfm_reactive(varargin)
%% Standing plane wave

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

sArgs = struct('hrtf',[],'direction',itaCoordinates([1 pi/2 0],'sph'),'audio',ita_generate('flatnoise',1,44100,16),'R',ita_generate('impulse',1,44100,16),'wall_distance',0);
sArgs = ita_parse_arguments(sArgs,varargin);


fs = sArgs.audio.samplingRate;

HRTF = sArgs.hrtf;

direction_reflection = sArgs.direction;

direction_reflection = itaCoordinates([0 0 0],'cart') - direction_reflection;
direction_reflection.r = 1;%sArgs.wall_distance;

result = getNearestFreq(HRTF,sArgs.direction);
result = ita_convolve(sArgs.audio,  result);
result.timeData(:,2) = 1*result.timeData(:,1);
result.timeData(:,3) = 1.5*result.timeData(:,1);
result.timeData(:,4) = 2*result.timeData(:,1);

result.channelCoordinates = HRTF.channelCoordinates;

result = ita_metainfo_rm_historyline(result,'all');
result = ita_metainfo_add_historyline(result,mfilename,varargin);

result.comment = 'Reactive';
end
