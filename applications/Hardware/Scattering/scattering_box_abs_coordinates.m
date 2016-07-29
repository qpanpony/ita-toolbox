function [mic1,mic2] = scattering_box_abs_coordinates(position,radius_1,radius_2)

% <ITA-Toolbox>
% This file is part of the application Scattering for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% This function uses an ita_coordinate object as input to create two 
% itaCoordinates corresponding to the absolute position of each micrphone. 
%
% It also takes in a 1x2 matrix with radius values [radius_1,radius_2]
%
% The user will be required to input the radius of each microphone from the
% center pole of the robot. 
%
% This function makes many assumptions about the orientation of the robot.
% 
% First: the origin or reference point is in the back right corner.
%
% Second: The robot's default position has the microphones paralell to the
% back wall. this means that the head of mic 1 points orthogonal to the
% left wall and the head of mic 2 would point orthogonal to the right wall
% at zero degrees. 
% 
if(nargout ~= 2),error('Function requires two output variables. Example [a,b] = scattering_box_abs_coordinates(position,radius_1,radius_2)');end
    

center_pole_x = .75 ; %(cm) Distance the center pole is from origin in x-direction
center_pole_y = .605; %(cm) Distance the center pole is from the origin in y-direction
ceiling_reference_point = .95 - .147; % 95 Centimeter high box and microphones start 14.7 cm down 

mic1 = itaCoordinates(position.nPoints);
mic2 = itaCoordinates(position.nPoints);

mic1_radius = radius_1; % takes first radius input
mic2_radius = radius_2; % takes second radius input

mic1.rho = mic1_radius;
mic2.rho = mic2_radius;
mic1.phi = position.phi;
mic2.phi = position.phi + pi;
mic1.z = ceiling_reference_point - position.z;
mic2.z = ceiling_reference_point - position.z;
mic1.x = mic1.x + center_pole_x;
mic2.x = mic2.x + center_pole_x;
mic1.y = -1*mic1.y + center_pole_y; % -1 is because of opposite pointing y axises
mic2.y = -1*mic2.y + center_pole_y; % -1 is because of opposite pointing y axises

end