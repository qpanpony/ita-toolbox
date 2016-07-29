function result = ita_sfm_diffuse_noise(varargin)
%sArgs = struct('hatype','BTE','fs',44100,'fft_degree',16,'noisetype','flatnoise');

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

sArgs = struct('HRTF',[],'direction',itaCoordinates([1 pi/2 0],'sph'),'audio',ita_generate('flatnoise',1,44100,16),'ref_per_s',1000);
sArgs = ita_parse_arguments(sArgs,varargin);

nRefs = ceil(double(sArgs.audio.trackLength) * sArgs.ref_per_s);
c = double(ita_constants('c'));

reflections = random(itaCoordinates,nRefs);
reflections.r = rand(nRefs,1) .* sArgs.audio.trackLength * c;

HRTF = sArgs.HRTF;
sArgs.audio = sArgs.audio.';

result = ita_convolve(sArgs.audio, HRTF.getNearest(itaCoordinates([2 2 2],'cart')));

for idx = 1:reflections.nPoints
    if mod(idx,100) == 0
        disp([int2str(idx/reflections.nPoints*100) '%']);
    end
    if isa(HRTF,'itaAnalyticDirectivity')
        result = result + ita_convolve(sArgs.audio, HRTF.getNearest(reflections.n(idx)));
    else
        thisRef = reflections.n(idx);
        d = thisRef.r;
        thisRef.r = 1;
        result = result + ita_time_shift(ita_convolve(sArgs.audio, HRTF.getNearest(thisRef)),d/c,'time','frequencydomain');
    end
end


%result.channelNames = {[sArgs.hatype ' left front mic'] [sArgs.hatype ' left back mic'] [sArgs.hatype ' right front mic'] [sArgs.hatype ' right back mic']};

result = ita_metainfo_rm_historyline(result,'all');
result = ita_metainfo_add_historyline(result,mfilename,varargin);
result.channelCoordinates = HRTF.channelCoordinates;
result.channelNames = HRTF.channelNames;
result.comment = 'diffuse';

end