function [grad_theta, grad_phi] = ita_sph_gradient(s, f)
%ITA_SPH_GRADIENT - calculates the gradient of a spherical function
% function [grad_theta, grad_phi] = ita_sph_gradient(s, f)
%
%   s: itaSamplingSph (needs to have Y and weights defined)
%   f: spatial function
%   grad_theta, grad_phi: spatial gradient function

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 15.11.2010

% first add one SH-order
s2 = s;
s2.nmax = s.nmax + 1;

grad_theta = zeros(size(s.Y,1),1);
grad_phi = zeros(size(s.Y,1),1);

% TODO: use weights that attenuate the influence of the shadow zones behind
% the musician
% fSH = lscov(s.Y, f, s.weights);

% no weights used
fSH = pinv(s.Y) * f;

for ind = 1:size(s.Y,2) % number of coefficients
    
    if ind > numel(fSH)
        break;
    end
    
    [n,m] = ita_sph_linear2degreeorder(ind);
    
    C_scalingfactor = sqrt( (2*n+1) ./ (2*(n+1)+1) .* ...
        factorial(n-m) ./ factorial(n-m+1) ./ factorial(n+m) .* factorial(n+m+1));

    oneOverTheta = 1./sin(s.theta);
    
    T_theta = oneOverTheta .* ...
        (s2.Y(:,ind+(2*n+2)) .* C_scalingfactor .* (n+1-m) - s.Y(:,ind) .* cos(s.theta) .* (n+1) );    
    T_phi = 1i * m .* oneOverTheta .* s.Y(:,ind);
    
    if any(~isfinite(T_theta)) || any(~isfinite(T_phi))
        error('singularities detected');
    end
    
    grad_theta = grad_theta + fSH(ind) .* T_theta;
    grad_phi = grad_phi + fSH(ind) .* T_phi;
end
