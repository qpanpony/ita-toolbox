function varargout = ita_sph_surf_SH(SHcoefs, varargin)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% This function plots the vector of spherical harmonic coefficients as a
% spherical function. If no sampling grid is given, loading an
% equiangular sampling grid
%
% Usage:
%       h = ita_sph_surf_SH(SHcoefs, sampling, [opt. props])

ita_verbose_obsolete('Marked as obsolete. Please report to mpo, if you still use this function.');

persistent nmaxOld samplingOld

% first check if there was a sampling given
sampling = [];
if nargin > 1
    if isa(varargin{1},'itaSamplingSph')
        sampling = varargin{1};
        % and delete it from the other properties
        varargin = varargin(2:end);
    end
end
 
% if there was no sampling given, create one
if isempty(sampling)
    % check number of grid points
    nrCoefs = numel(SHcoefs);
    % convert to maximum order
    % if in doubt (strange number of coefs) use more points (ceil)    
    nmax = ceil(sqrt(nrCoefs)-1);
    
    if isequal(nmaxOld,nmax) && ~isempty(samplingOld)
        sampling = samplingOld;
    else        
        sampling = ita_sph_sampling_equiangular(nmax);
        % and set the values to remember
        samplingOld = sampling;
        nmaxOld = nmax;
    end
end

% check if Y is calculated already
if numel(sampling.Y) == 0
    error('Set nmax to evaluate the SH base.');
end

% now transform into a spatial function
spatial = sampling.Y * SHcoefs(:);

% and call surf of itaCoordinates class
hFig = surf(sampling, spatial, varargin{:});

maxVal = max(abs(spatial(:)));
xlim([-maxVal maxVal]);
ylim([-maxVal maxVal]);
zlim([-maxVal maxVal]);

if nargout
    varargout = {hFig};
else
    varargout = {};
end
