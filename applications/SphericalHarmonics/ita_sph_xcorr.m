function corr = ita_sph_xcorr(f, g, type)
%ITA_SPH_XCORR - spatial correlation in SH-domain
% corr = ita_sph_xcorr(f, g, type)
% 
% computes the (normalized) spatial correlation of two functions
% on the 2-sphere in the spherical harmonic domain
%
% f and g are SH-Vectors or matrixes of size [freq x SH]
% type is a string which can be 'norm' (default) or 'noNorm'
%   expressing normalized or not normalized correlation
%
% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

% set default
if nargin < 3, type = 'norm'; end

% check if there is a frequency dependence
f_isMatrix = min(size(f)) > 1;
g_isMatrix = min(size(g)) > 1;

% convert any vector to a row vector
if ~f_isMatrix, f = f(:).'; end
if ~g_isMatrix, g = g(:).'; end

% if we have a frequency dependence, use both f and g as matrix
if f_isMatrix || g_isMatrix
    % first dimension is assumed to be frequency
    % enlarge any occuring vector to a matrix
    if ~f_isMatrix, f = repmat(f,size(g,1),1); end
    if ~g_isMatrix, g = repmat(g,size(f,1),1); end
end

% check identical frequency resolution
if size(f,1) ~= size(g,1)
    error([mfilename ': check the frequency resolution'])
else
    nFreq = size(f,1);
end

% number of SHs of f and g
nF = size(f,2);
nG = size(g,2);

% use the maximum size of f and g for both
if nF ~= nG
    f = [f zeros(size(f,2),nG-nF)];
    g = [g zeros(size(g,2),nF-nG)];
end

% initialize without explicit norm
norm = ones(nFreq,1);
switch type
    case 'noNorm'
        % do nothing
    case 'norm'
        % only compares the shape, not the amplitudes
        energyF = sum(abs(f).^2,2);
        energyG = sum(abs(g).^2,2);
        norm = sqrt(energyF .* energyG);
    case 'absNorm'
        % compares the shape and amplitude
        norm = sum(abs(f).^2,2); % energyF
    otherwise
        error([mfilename ': I do not know this normalization']);
end

corr = zeros(nFreq,1);
for ind = 1:nFreq
    corr(ind) = (f(ind,:) * g(ind,:)') ./ norm(ind);
end