function [ corr, delta, orient ] = correctCubic( measured, delta_even, orient_even, qx, qy, qz )
%CORRECTCUBIC correct values using a triscattered interpolation for
%interpolating the measured values...
%measured: the measured values.
%delta_even: the evenly distributed difference array between needed for
%correcting the measured values.

% <ITA-Toolbox>
% This file is part of the application Tracking for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Create the appropriate meshgrid, this needs to be the same one as the
% one used creating delta_even (the evenly distributed points)
%[qx, qy, qz] = meshgrid(-1.5:.1:1.5, 0.8:0.1:2, -1.5:.1:1.5);


%Now use interpolation between the even grid of deltas. Here we can use
%cubic interpolation.
corr_delta_x = interp3(qx, qy, qz, delta_even(:,:,:,1), measured(1), measured(2), measured(3), 'cubic');
corr_delta_y = interp3(qx, qy, qz, delta_even(:,:,:,2), measured(1), measured(2), measured(3), 'cubic');
corr_delta_z = interp3(qx, qy, qz, delta_even(:,:,:,3), measured(1), measured(2), measured(3), 'cubic');
orient = zeros(3);
for k=1:3
    for l=1:3
        orient(k,l) = interp3(qx, qy, qz, orient_even(:,:,:,k,l), measured(1), measured(2), measured(3), 'cubic');
    end
end
orient = inv([-orient(:,3), orient(:,1), -orient(:,2)]);

%Subtract the found difference from our measured value.
delta = [corr_delta_x; corr_delta_y; corr_delta_z];
corr = measured - delta;
end