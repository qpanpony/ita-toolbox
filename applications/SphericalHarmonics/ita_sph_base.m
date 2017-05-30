function Y = ita_sph_base(s, nmax, type, complex)
%ITA_SPH_BASE - creates spherical harmonics (SH) base functions
% function Y = ita_sph_base(s, nmax, type)
% Y is a matrix with dimensions [nr_points x nr_coefs]
% calculates matrix with spherical harmonic base functions
% for the grid given in theta and phi
% give type of normalization
%
%
% the definition was taken from:
% E. G. Williams, "Fourier Acoustics",
% Academic Press, San Diego, 1999. p. 190
%
% This definition includes the Condon-Shotley phase term (-1)^m
%
% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 03.09.2008
%
% Deleted and new implementation
% (careful, history seems to be lost, but checkout of old version is possible):
% Bruno Masiero (bma@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 12.04.2011

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% check input
if nargin < 4
    % Use complex version of the spherical harmonics
    complex = true;
end

if nargin < 3
    type = 'Williams';
    % disp(['using default normalization: ' type]);
end

%check for invalid sampling
if s.nPoints < 1
    Y = [];
    return
end

% vectorize grid angles
theta = s.theta;
phi = s.phi;

nr_points = numel(theta);
if nr_points ~= numel(phi)
    error('theta and phi must have same number of points');
end

nr_coefs = (nmax+1)^2;
nm = 1:nr_coefs;

[~,m] = ita_sph_linear2degreeorder(nm);
exp_term = exp(1i*phi*m);

% calculate a matrix containing the associated legendre functions
% function Pnm = ass_legendre_func
% calculate the matrix of associated Legrendre functions
Pnm = zeros(nr_points, nr_coefs);

for ind = 0:nmax
    % define the linear indices for the i'th degree
    index_m_neg = ita_sph_degreeorder2linear(ind,-1:-1:-ind);  % count in reverse order
    index_m_pos = ita_sph_degreeorder2linear(ind,1:ind);
    index_m_pos0 = ita_sph_degreeorder2linear(ind,0:ind);
    
    % define positive orders with correct normalization
    switch lower(type)
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
                bsxfun(@times,(-1).^(0:ind)*sqrt(2),legendre(ind,cos(theta.'),'sch').');
            
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

if ~complex
    % now the conversion is done outside of this function
    Y = ita_sph_complex2real(Y')';    
    
     % below the old code:
%     for ind = 1:nmax
%         % define the linear indices for the i'th degree
%         index_m_neg = ita_sph_degreeorder2linear(ind,-1:-1:-ind);  % count in reverse order
%         index_m_pos = ita_sph_degreeorder2linear(ind,1:ind);
%         
%         for m = 1:length(index_m_neg)
%             C = ((-1)^m*Y(:,index_m_pos(m)) + Y(:,index_m_neg(m)))/sqrt(2);
%             S = ((-1)^m*Y(:,index_m_neg(m)) - Y(:,index_m_pos(m)))/sqrt(2)/1i;
%             
%             Y(:,ita_sph_degreeorder2linear(ind,m)) = C;
%             Y(:,ita_sph_degreeorder2linear(ind,-m)) = S;
%         end
%     end
end