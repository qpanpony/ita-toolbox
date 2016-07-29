function s = ita_sph_sampling_HRTFarc( varargin )
%ITA_SPH_SAMPLING angles of HRTFarc's loudspeakers
%  
% USAGE:
%   s = ita_sph_sampling_HRTFarc
%   s = ita_sph_sampling_HRTFarc(nphi)
%   s = ita_sph_sampling_HRTFarc(phi)
%   s = ita_sph_sampling_HRTFarc(coord)
%   s = ita_sph_sampling_HRTFarc(nphi, coord)
%   s = ita_sph_sampling_HRTFarc(phi, coord)
% 
%       nphi    -   number of azimuth angles (scalar)
%       phi     -   vector of azimuth angles in radiant
%       coord   -   itaCoordinates of arc's LS positions
% 
% default:
%       nphi    =   96
%       coord   -   ideal gaussian sampling of 40 arc's LS

% See also 

% Author: Stefan Zillekens
% Created: 2013-12-02

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
%% input cases
if nargin == 0
    coord = coord_HRTF_arc_gaussian;
    nphi  = 96;
    phi   = [];
    
elseif nargin == 1
    if isa(varargin{1}, 'itaCoordinates')
        coord = varargin{1};
        nphi  = 96;
        phi   = []; 
        
    elseif  isscalar(varargin{1})
        nphi  = varargin{1};
        phi   = []; 
        coord = coord_HRTF_arc_gaussian;    
        
    elseif isvector(varargin{1})
        phi   = varargin{1};
        coord = coord_HRTF_arc_gaussian;
        nphi  = 96;

    end

elseif nargin == 2
    if  isscalar(varargin{1})
        nphi = varargin{1};
        phi   = [];
    
    elseif isvector(varargin{1})
        phi = varargin{1};
        
    end
    
    if isa(varargin{2}, 'itaCoordinates')
        coord = varargin{2};
    end
end

%% init
nLS = coord.nPoints;

if numel(phi);
    nphi = numel(phi);
else
    phi = linspace(0,2*pi,nphi+1);
    phi = phi(1:end-1);
end
        
%% arc to sphere    
phi = repmat(phi,nLS,1);
phi = phi(:);

coord = coord.repmat(nphi);
coord.phi = wrapTo2Pi(coord.phi + phi);

s = itaSamplingSph(coord);
end



function coord = coord_HRTF_arc_gaussian
% itaCoordinates with the ideal arc's LS positions (gaussian)

nLS                 =   40;
p                   =   ita_sph_sampling_gaussian(47);     %this slows it down
p                   =   unique(p.theta);
p(p>150/180*pi)     =   [];
p                   =   [p(nLS:-2:2); p(1:2:nLS)];

coord = itaCoordinates(nLS);
coord.theta = p;
coord.r = 1;
coord.phi = pi*[zeros(nLS/2,1);ones(nLS/2,1)];
end