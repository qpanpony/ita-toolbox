function [D, d] = ita_sph_wignerD(nmax, alpha, beta, gamma)
%ITA_SPH_WIGNERD - Wigner-D matrix
% function [D, d] = ita_sph_wignerD(nmax, alpha, beta, gamma)
%
% creates the Wigner-D matrix to rotate a spherical function
%
% The used convention rotates mathematically positive around the axes,
% namely around the Z-Y-Z-axes. The reduced Wigner-d matrix (d) can be
% helpful to precompute to implement faster rotations.
% 
% application: F_rot(n,m) = D * F(n,m)
%
% algorythm from "FFTs on the Rotation Group", Kostelec a.o., 2003
%
% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 03.09.2008

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

if nargin < 3
    beta = alpha(2);
    gamma = alpha(3);
    alpha = alpha(1);
end

% bring the rotations to the given convention (math.pos)
alpha = -alpha; beta = -beta; gamma = -gamma;

% number of coefficients
lengthSH = (nmax+1)^2;

if beta == 0
    d = eye(lengthSH);
else
    d = wigner_smallD(nmax, beta);
end

% initialize
% D = zeros(lengthSH);
exp_alpha = zeros(lengthSH);
exp_gamma = zeros(lengthSH);

% make exeption for l=0:
% D(1,1) = 1;


% D(n,interv(J+l+1)) = exp(-j * J * alpha) .* exp(-j * M * gamma) .* d(n,interv(J+l+1));


for n = 1:lengthSH
    lm = n2lm(n);
    m = lm(2);
    
    exp_alpha(:,n) = exp(j * m * alpha);
    exp_gamma(n,:) = exp(j * m * gamma);
end 

D = exp_alpha .* d .* exp_gamma;

% -------------------------------------------------------------
function d = wigner_smallD(nmax, beta)

% function d = wigner_smallD(beta)
% 
% rotates a set of SH-coefficients
% using the Wigner-D matrix
%
% algorythm: "FFTs on the Rotation Group", Kostelec a.o., 2003

% if nargin < 3
%     beta = alpha(2);
% end


cosb = cos(beta/2);
sinb = sin(beta/2);

% highest degree
maxl = nmax; %sqrt(lengthSH)-1;
%maxl = 2;
linsize = (maxl+1).^2;

% initialize
d = zeros(linsize);

% define square root of (26)
wterm = wurzelterm(linsize);

% make exeption for l=0:
d(1,1) = 1;

% loop each row of matrix
for n = 2:lm2n(maxl)
    
    lm = n2lm(n);
    l = lm(1);
    M = lm(2);

    interv = ((l^2)+1):((l+1)^2);
    
    for J = -l:l
        
        % d^l_{J,M}
  
        % (26) 1st eq.
        if (J == l)
            d(n,interv(J+l+1)) = wterm(lm2n(l,M)) .* cosb^(l+M) .* (-sinb)^(l-M);
            
        % (26) 2nd eq.    
        elseif (J == -l)
            d(n,interv(J+l+1)) = wterm(lm2n(l,M)) .* cosb^(l-M) .* sinb^(l+M);
            
        % (26) 3rd eq.    
        elseif (M == l)
            d(n,interv(J+l+1)) = wterm(lm2n(l,J)) .* cosb^(l+J) .* sinb^(l-J);
            
        % (26) 4th eq.    
        elseif (M == -l)
            d(n,interv(J+l+1)) = wterm(lm2n(l,J)) .* cosb^(l-J) .* (-sinb)^(l+J);
                
                
                            
        else    % copy old square out of recurrence (25)    
            
            M2 = J;
            Ms2 = M;
            J2 = l-1;
            
            term_pos = plusterm(J2,M2,Ms2);    
            term_neu = neutralterm(J2,M2,Ms2,beta);
            term_neg = negativterm(J2,M2,Ms2);
            
            if l-1 >= max(abs([J M]))
                dneu = d(lm2n_fast(J2,M),lm2n_fast(J2,J));
            else dneu = 0;
            end;
                
            if l-2 >= max(abs([J M]))
               dneg = d(lm2n_fast(J2-1,M),lm2n_fast(J2-1,J));
            else dneg = 0;
            end;
                
                
            d(n,interv(J+l+1)) = - term_neu ./ term_pos .* dneu - term_neg ./ term_pos .* dneg;
        end

    end
end


% -------------------------------------------------------------
function erg = wurzelterm(linsize)
% using the same indexing as with the spherical harmonics
%   n = 
erg = zeros(1,linsize);
for n=1:linsize
    JM = n2lm(n);
    J = JM(1);
    M = JM(2);
    erg(n) = sqrt(factorial(2*J) ./ (factorial(J+M).*factorial(J-M)));
end

% -------------------------------------------------------------
function erg = plusterm(J,M,Ms)
if J + 1 < max(abs(M), abs(Ms));
    error('erg = 0');
end
erg = sqrt(((J+1)^2 - M^2) * (((J+1)^2) - Ms^2)) ./ ((J+1) * (2*J+1));
                % (25) root.... FFTs on rot groups

% -------------------------------------------------------------
function erg = neutralterm(J,M,Ms,beta)
if J < max(abs(M), abs(Ms));
    error('erg = 0');
end

% exception J=0
if J == 0 && ((M == 0) || (Ms == 0))
    erg = M + Ms - cos(beta);
else
    erg = (((M*Ms) / (J*(J+1))) - cos(beta));
                % (25) root.... FFTs on rot groups
end

% -------------------------------------------------------------
function erg = negativterm(J,M,Ms)
if J - 1 < max(abs(M), abs(Ms));
    erg = 0;
else
    erg = sqrt((J^2 - M^2) * ((J^2) - Ms^2)) ./ (J * (2*J+1));               
    % (25) root.... FFTs on rot groups
end

% -------------------------------------------------------------
function lm = n2lm(n)

% converts the linear 1D-index (n) of the spherical harmonics
% to the 2D-index (l,m)

if n < 1
    error('n has to be positive');
end

l = ceil(sqrt(n)) - 1;
m = n - l.^2 - l -1;

lm = [l; m];

% -------------------------------------------------------------
function n = lm2n(l,m)

% function n = lm2n(l,m)
%
% converts the 2D-index (l,m) of the spherical harmonics
% to the linear 1D-index (n)

if l < 0
    n = -1;
    return;
end

if nargin < 2
    m = l;
end

% if abs(m) > l
%     error('order m has to be between -l and l (degree l)');
% end

n = l.^2 + l + m + 1;

% -------------------------------------------------------------
function n = lm2n_fast(l,m)

% function n = lm2n(l,m)
%
% converts the 2D-index (l,m) of the spherical harmonics
% to the linear 1D-index (n)

% pdi: only used if l and m are correct numbers
n = l.^2 + l + m + 1;


