% Generate HRTFs for ideal sensors

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

ccx;
load('Hoertnix_Grid.mat');
grid = grid.reduce_equiangular_grid(10);
HRTF = itaAnalyticDirectivity;
HRTF.freq = zeros(513,1,8);
HRTF.channelNames = { ...
    'BTE right front' ...
    'BTE right back' ...
    'BTE left front' ...
    'BTE left back' ...
    'ITC right front' ...
    'ITC right back' ...
    'ITC left front' ...
    'ITC left back' ...
    };
HRTF = ita_hearingaids_set_channelCoordinates(HRTF);

HRTF.functionHandle = @ita_analytic_directivity_freefield;

HRTF.directions = grid;


HRTF = HRTF.sample(grid);

[BTE, ITC] = ita_split(HRTF,'BTE','ITC','substring');

ita_write(BTE,'IDEALHA_HRTF_BTE_diffuse_compensated.ita');
ita_write(BTE,'IDEALHA_HRTF_BTE_non_compensated.ita');
ita_write(ITC,'IDEALHA_HRTF_ITC_diffuse_compensated.ita');
ita_write(ITC,'IDEALHA_HRTF_ITC_non_compensated.ita');