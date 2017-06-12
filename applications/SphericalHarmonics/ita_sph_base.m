function Y = ita_sph_base(varargin)
%ITA_SPH_BASE - creates spherical harmonics (SH) base functions
% function Y = ita_sph_base(sampling, Nmax, options)
% Y is a matrix with dimensions [nr_points x nr_coefs]
% calculates matrix with spherical harmonic basis functions
% for the grid given in theta and phi
%
%
% the definition was taken from:
% E. G. Williams, "Fourier Acoustics",
% Academic Press, San Diego, 1999. p. 190
%
% This definition includes the Condon-Shotley phase term (-1)^m
%
%  Syntax:
%   Y = ita_sph_base(sampling, Nmax, options)
%
%   Options (default):
%           'norm' ('orthonormal')	: Normalization type
%           'real' (false)          : Return real valued SH
%
%  Example:
%   Y = ita_sph_base(sampling, Nmax, 'norm', 'Williams')
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sph_base">doc ita_sph_base</a>
%
% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>
%
%
% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 03.09.2008


sArgs = struct('pos1_sampling', 'itaCoordinates', ...
               'pos2_Nmax', 'int', ...
               'norm', 'orthonormal', ...
               'real', false);
[sampling, Nmax, sArgs] = ita_parse_arguments(sArgs, varargin);

%check for invalid sampling
if sampling.nPoints < 1
    Y = [];
    ita_verbose_info('The sampling needs to consist of at least one point.', 0)
    return
end

% vectorize grid angles
theta = sampling.theta;
phi = sampling.phi;

nm = 1:(Nmax+1)^2;

[~,m] = ita_sph_linear2degreeorder(nm);
exp_term = exp(1i*phi*m);

% calculate a matrix containing the associated legendre functions
% function Pnm = ass_legendre_func
% calculate the matrix of associated Legrendre functions
Pnm = zeros(sampling.nPoints, (Nmax+1)^2);

for ind = 0:Nmax
    % define the linear indices for the i'th degree
    index_m_neg = ita_sph_degreeorder2linear(ind,-1:-1:-ind);  % count in reverse order
    index_m_pos = ita_sph_degreeorder2linear(ind,1:ind);
    index_m_pos0 = ita_sph_degreeorder2linear(ind,0:ind);
    
    % define positive orders with correct normalization
    switch lower(sArgs.norm)
        case {'orthonormal','williams'}
            % the Pnm's used here are the Pnm's from Williams multiplied with the
            % orthonormality factor sqrt((2n+1)./(4*pi).*(n-m)! ./ (n+m)!)
            Pnm(:,index_m_pos0) = ...
                bsxfun(@times,(-1).^(0:ind)/sqrt(2*pi),legendre(ind,cos(theta.'),'norm').');
            
        case {'unit','power','unit-power'}
            Pnm(:,index_m_pos0) = ...
                bsxfun(@times,(-1).^(0:ind)*sqrt(2),legendre(ind,cos(theta.'),'norm').');
            
        case {'schmidt','sch','semi-normalized'}
            Pnm(:,index_m_pos0) = ...
                bsxfun(@times,(-1).^(0:ind),legendre(ind,cos(theta.'),'sch').');
        case {'ambix'}
            Pnm(:,index_m_pos0) = ...
                bsxfun(@times,(-1).^(0:ind)/sqrt(8*pi),legendre(ind,cos(theta.'),'sch').');
            
        otherwise
            error('Wow! I do not know this normalization!')
    end
    
    % copy the Pnm data to the left side of the Toblerone spectrum
    % the phase term over theta is not included up to this point and Pnm is
    % already normalized. We do not need to use the complex conjugate of
    % Pnm or renormalize.
    if ind > 0
        Pnm(:,index_m_neg) = bsxfun(@times,(-1).^(1:ind),Pnm(:,index_m_pos));
    end
end

% compose the spherical harmonic base functions
Y = Pnm .* exp_term;

if strcmp(sArgs.norm, 'ambix')
    % multiply by sqrt(2-delta_m)
    mask = ~(m | zeros(size(m)));
    Y(:,mask) = Y(:,mask) * sqrt(2);
end

if sArgs.real
    Y = ita_sph_complex2real(Y.').';
end