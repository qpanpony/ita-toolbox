function [hrtf,rep_d] = ita_analytic_directivity_soundfield_mic(r,d,resolution)
%   r: radius of sound field mic
%   d: equivalent distance for point source -> chose large for an classical HRTF
%
% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


a = itaAnalyticDirectivity;
a.freq = zeros(513,1,4); % currently necessary

tet_angle = acos(-1/3);

a.channelCoordinates = itaCoordinates([r 0 0; r tet_angle 0; r tet_angle 1/3*2*pi; r tet_angle 2/3*2*pi] ,'sph');
b = a.channelCoordinates;
dists = [b.n(1) - b.n(2); b.n(1) - b.n(3); b.n(1)-b.n(4); b.n(2) - b.n(3); b.n(2)-b.n(4); b.n(3)-b.n(4) ];
dists.r;



rep_d(1) = b.n(1) + (b.n(2) - b.n(1))./2 ;
rep_d(2) = (b.n(3) + (b.n(4) - b.n(3))./2);

rep_d = rep_d(1) - rep_d(2);

rep_d = rep_d.r;

% rep_d = 2*r/sqrt(3); %rep_d -> Kantelkugelradius *2
% a = 4*r/sqrt(6) -> Kantelänge

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