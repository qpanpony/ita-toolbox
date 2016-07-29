mode = '3d'; 

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


n_d = 5;
 resolution = 3;
 d = 3;
 d(d>5) = [];
switch mode
    case '1d'
        [hrtf, d_rep] = ita_analytic_directivity_hearing_aid(d_sf_mic,d,resolution);
    case '3d'
        [hrtf, d_rep] = ita_analytic_directivity_soundfield_mic(d_sf_mic,d,resolution);
end
hrtf.directions = build_search_database(hrtf.directions);

bsfs = ita_sfm_all('HRTF',hrtf,'audio',ita_generate('noise',1,44100,17));

