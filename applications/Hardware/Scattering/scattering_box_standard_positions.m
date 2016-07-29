function positions = scattering_box_standard_positions(idx)
% function to return standard measurement positions
% using idx returns a selection of the positions

% <ITA-Toolbox>
% This file is part of the application Scattering for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

if ~nargin
    idx = 1:10;
end

positions = itaCoordinates(10);
positions.rho = 1;    
    
POSITION_1_HEIGHT = .05; 
POSITION_1_ANGLE = 0;

POSITION_2_HEIGHT = .05; 
POSITION_2_ANGLE = pi/4;

POSITION_3_HEIGHT = .10; 
POSITION_3_ANGLE = pi/2.5;

POSITION_4_HEIGHT = .10; 
POSITION_4_ANGLE = pi/5;

POSITION_5_HEIGHT = .15; 
POSITION_5_ANGLE = pi*3/4;

POSITION_6_HEIGHT = .15; 
POSITION_6_ANGLE = pi/3.5;

POSITION_7_HEIGHT = .20; 
POSITION_7_ANGLE = pi/3;

POSITION_8_HEIGHT = .20; 
POSITION_8_ANGLE = 0;

POSITION_9_HEIGHT = .25; 
POSITION_9_ANGLE = pi*2/3;

POSITION_10_HEIGHT = .25; 
POSITION_10_ANGLE = pi/2;

positions.z = [  POSITION_1_HEIGHT ; 
                 POSITION_2_HEIGHT ;
                 POSITION_3_HEIGHT ;
                 POSITION_4_HEIGHT ;
                 POSITION_5_HEIGHT ;
                 POSITION_6_HEIGHT ;
                 POSITION_7_HEIGHT ;
                 POSITION_8_HEIGHT ;
                 POSITION_9_HEIGHT ;
                 POSITION_10_HEIGHT]';
             
positions.phi = [   POSITION_1_ANGLE; 
                    POSITION_2_ANGLE; 
                    POSITION_3_ANGLE; 
                    POSITION_4_ANGLE; 
                    POSITION_5_ANGLE; 
                    POSITION_6_ANGLE; 
                    POSITION_7_ANGLE; 
                    POSITION_8_ANGLE; 
                    POSITION_9_ANGLE;
                    POSITION_10_ANGLE]';

idx = idx(idx <= 10);
idx = idx(idx >= 1);
positions = positions.n(idx);
ita_verbose_info('Using standard positions.',1);

end