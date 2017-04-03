% dirplot_demo.m
% 
% Demonstrates usage of DIRPLOT.M to generate polar
% directivity plots.
%
% Generate a couple of sample curves on -90 to +90
% degrees and plot on the same graph with autoscaling.
clear;
theta = -90:5:90;
rho1 = -20 + 20*(cos(theta*pi/180)).^2;
rho2 = -20 + 18*cos(theta*pi/180);
dirplot(theta,rho1,'b');
hold
dirplot(theta,rho2,'r');
title('Semicircular Plot Example');
legend('rho1','rho2');

% Now plot the difference 
figure;
rho3 = rho1 - rho2;
dirplot(theta,rho3);
title('Difference Plot');

% Now generate a cardiod pattern in a full plot.
% We know what we want to see, so we'll scale manually.
figure;
theta = -180:5:180;
rho = 1 + cos(theta*pi/180);
dirplot(theta,rho,[2 0 5]);
title('Full Polar Plot of Cardiod');