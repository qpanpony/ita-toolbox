function capSH = ita_sph_northpolecapSH(nmax, theta0)
%ITA_SPH_NORTHPOLECAPSH - SH-coefficients for vibrating cap on north pole
% function capSH = ita_sph_northpolecapSH(nmax, theta0)
%
% Creates the aperture function of a spherical cap on the north pole
% with a elevational opening angle of theta0 (phi is constant).
% 
% The output capSH is given in spherical harmonic coefficients up to the
% maximum degree nmax.
%
% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 03.09.2008
%
% Johannes Klein (johannes.klein@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 05.12.2011

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% General formula:
% capSH = sqrt(pi*(2*n+1)) * kroneckerdelta(m,0) * int_cos(theta)^1 Pn0(x) dx
% Pollow, M. , 'Variable Directivity for Platonic Sound Sources Based on 
% Spherical Harmonics Optimization', 2009, Acta Acustica united with Acustica

if isempty(nmax)
    error('Please give a maximum order nmax');
end

% Only the cosine of theta0 needed, calculate it upfront.
x = cos(theta0);

% The equation will be split up in two parts. The pre term and the integral
% term. Compute the pre term first.
pre = sqrt(pi*(2*(0:nmax)+1));

% Initialize the integral term vector and calucalte the first entry.
leg_int = zeros(1,nmax+1);
leg_int(1) = 1-x;

% In general, the integral int_cos(theta)^1 Pn0(x) dx can be written as:
% (P(n-1)0(x)-P(n+1)0(x))/(2*n+1).
% This will be done in the follwing, for every l=1:nmax.
for n=1:nmax
    % Compute the first term P(n-1)0(x).
    minus = legendre(n-1,x);
    minus = minus(1);
    
    % Compute the second term P(n+1)0(x).
    plus = legendre(n+1,x);
    plus = plus(1);
    
    % Compute the whole integral term for current n.
    leg_int(n+1)= (minus - plus)/(2*n+1);
end

% Reshape the vector of entries for every order n and degree m=0 into the
% usual SH coefficient vector for every n,m.
row = (0:nmax).^2+ (1:nmax+1);
col = ones(1,nmax+1);
capSH = [accumarray([row(:) col(:)], pre .* leg_int ); zeros(nmax,1)];
end