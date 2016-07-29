function comp = ita_hearingaids_calculate_diffuse_compensation(this)

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


this = ita_hearingaids_set_channelCoordinates(this);

this = ita_hearingaids_compensate_displacement(this);
abscomp = mean(abs(this'),'equiang');
complcomp = mean(this','equiang');

complcomp.freq = complcomp.freq ./ abs(complcomp.freq);

comp = abscomp * complcomp;
comp = ita_invert_spk_regularization(comp,[1 20000]);

%% Quick and dirty!!!
comp = (ita_time_window(comp,[0.002 0.004],'symmetric'));
ita_verbose_info('ITA_HEARINGSAIDS_CALCULATE_DIFFUSE_COMPENSATION: This may need to be changed!!!',0);
