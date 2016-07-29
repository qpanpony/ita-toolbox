function [hrtf,rep_d] = ita_analytic_directivity_soundfield_mic(r,d,resolution)
%   r: radius of sound field mic
%   d: equivalent distance for point source -> chose large for an classical HRTF
%
% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


a = itaAnalyticDirectivity;
a.freq = zeros(513,1,2); % currently necessary


a.channelCoordinates = itaCoordinates([r/2 pi/2 0; r/2 pi/2 pi; ] ,'sph');

b = a.channelCoordinates;
dists = [b.n(1) - b.n(2)];
rep_d = dists.r;

a.functionHandle = @ita_analytic_directivity_sample_function;

bla = a.getNearestFreq(itaCoordinates([2 pi/2 pi/2],'sph'));

sgrid = itaCoordinates;
for idx = 1:numel(d)
    grid = itaCoordinates;
    grid = grid.equally_angled_sphere('phi_step', resolution/180*pi,'theta_step',resolution/180*pi);
    grid.r = d(idx);
    sgrid = merge(sgrid,grid);
end


hrtf = sample(a,sgrid);

hrtf.comment = num2str(rep_d);

%ita_write(hrtf,'SoundFieldMic_HRTF_d_sf_mic_0.01.ita');