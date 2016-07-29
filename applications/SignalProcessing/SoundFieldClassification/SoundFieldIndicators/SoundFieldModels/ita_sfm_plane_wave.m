function result = ita_sfm_plane_wave(varargin)
%% Plane wave from theta

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

sArgs = struct('hrtf','','direction',itaCoordinates([1 pi/2 0],'sph'),'audio',ita_generate('flatnoise',1,44100,16));
sArgs = ita_parse_arguments(sArgs,varargin);

fs = sArgs.audio.samplingRate;

HRTF = sArgs.hrtf;

dist = sArgs.direction.r;
sArgs.direction.r = 1;

result = getNearest(HRTF,sArgs.direction);

result = ita_convolve(sArgs.audio, result);
%result = sArgs.audio * ita_interpolate_spk(result,sArgs.audio.nBins);
%result = ita_time_shift(result,dist/340,'time');
result.channelCoordinates = HRTF.channelCoordinates;


result = ita_metainfo_rm_historyline(result,'all');
result = ita_metainfo_add_historyline(result,mfilename,varargin);
result.comment = 'Plane Wave';
end
