function center = ita_hearingaids_calculate_acoustic_center(this, varargin)

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


sArgs = struct('freqRange',[100 500]);
sArgs = ita_parse_arguments(sArgs,varargin);

x = (ita_groupdelay(this.getNearestFreq(itaCoordinates([1 pi/2 0],'sph')))-ita_groupdelay(this.getNearestFreq(itaCoordinates([1 pi/2 pi],'sph'))))*double(ita_constants('c'))/2;
y = (ita_groupdelay(this.getNearestFreq(itaCoordinates([1 pi/2 pi/2],'sph')))-ita_groupdelay(this.getNearestFreq(itaCoordinates([1 pi/2 3*pi/2],'sph'))))*double(ita_constants('c'))/2;
z = (ita_groupdelay(this.getNearestFreq(itaCoordinates([1 0 0],'sph')))-ita_groupdelay(this.getNearestFreq(itaCoordinates([1 pi 0],'sph'))))*double(ita_constants('c'))/2;

i_min = this.freq2index(min(sArgs.freqRange));
i_max = this.freq2index(max(sArgs.freqRange));

center = itaCoordinates([mean(x(:,i_min:i_max),2) mean(y(:,i_min:i_max),2) mean(z(:,i_min:i_max),2)],'cart');





end