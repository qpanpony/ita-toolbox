function s = ita_sph_sampling_equiangular(varargin)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


sArgs.theta_type = '()';
sArgs.phi_type = '[)';
% sArgs.thetaRes = nan(1);
% sArgs.phiRes = nan(1);



if nargin < 2
    nmax = varargin{1};
    v = round((nmax+1).*2);
    h = v;
else
    v = varargin{1};
    h = varargin{2};
    
    sArgs = ita_parse_arguments(sArgs,varargin(3:end));
    nmax = floor(sqrt(v*h/4))-1;
    disp(['I use the maximum SH order of ' num2str(nmax)]);
    if nargin > 2
        theta_type = varargin{3};
        if nargin > 3
           phi_type = varargin{4};
        end            
    end
end

theta_type = sArgs.theta_type;
phi_type = sArgs.phi_type;

disp(['using grid ' num2str(v) ' x ' num2str(h)]);

if isinteger(log2(nmax+1))
    warning('nmax should be (power of 2) - 1 to guarantee exact weights');
elseif ~strcmp(theta_type,'()') || ~strcmp(phi_type,'[)')
    warning(['weights only approximated for theta_type = ' theta_type ' and phi_type = ' phi_type]);
end

switch theta_type
    case '()'
        theta_term = pi/(2*v):pi/v:pi*(1-1/(2*v));
    case '[)'
        theta_term = 0:pi/v:pi*(1-1/v);
    case '[]'
        theta_term = 0:pi/(v-1):pi;
    otherwise
        error('no valid type for theta');
end

switch phi_type
    case '()'
        error('not defining phi = 0 makes no sense');
    case '[)'
        phi_term = 0:(2*pi)/h:2*pi*(1-1/h);
    case '[]'
        phi_term = 0:(2*pi)/(h-1):2*pi;
    otherwise
        error('no valid type for phi');
end

[theta, phi] = ndgrid(theta_term, phi_term);
[v,h] = size(theta);

r = ones(size(theta));

s = itaSamplingSph([r(:) theta(:) phi(:)],'sph');
% s.dim = size(theta);
s.weights = regular_weights(theta(:,1),h,nmax);
s.nmax = nmax;

end

function weights = regular_weights(theta,h,nmax)
% weights for equiangular grid on sphere
%
% determine exact weights (cf. Driscoll/Healy) for a grid of 2^N x 2^N
% points, arranged as created by the function ita_sph_grid_regular with the
% options '()', '[)'
%
% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 03.09.2008

J = theta.';
L = 2 .* (0:nmax) + 1;

v = length(theta);
% h = size(gridData.theta, 2);

phifactor = 2 * pi / h;
thetafactor = 2 / v;
sinfactor = 4/pi * sin(J) .* ((1./L) * sin(L'*J));
a = phifactor .* thetafactor .* pi/2 .*  sinfactor;
% weights = a.';
weights = repmat(a', [1 h]);
weights = weights(:);
end