function result = ita_sfm_all(varargin)
%sArgs = struct('hatype','BTE','fs',44100,'fft_degree',16,'noisetype','flatnoise');
%sArgs = struct('HRTF','IDEALHA_HRTF_BTE_non_compensated.ita','direction',itaCoordinates([1 pi/2 0],'sph'),'audio',ita_generate('flatnoise',1,44100,16),'ref_per_s',1000);
%sArgs = ita_parse_arguments(sArgs,varargin);

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


result = ita_normalize_dat(ita_sfm_plane_wave(varargin{:}));

result = ita_append(result,  ita_normalize_dat(ita_sfm_diffuse_noise(varargin{:})));

result = ita_append(result,  ita_normalize_dat(ita_sfm_reactive(varargin{:})));

result = ita_append(result,  ita_normalize_dat(ita_sfm_incoherent_noise(varargin{:})));
