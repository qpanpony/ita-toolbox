function SH = ita_sph_real_valued_basefunctions(sampling, nmax)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% ita_sph_realvalued_basefunctions(sampling, nmax)
% Returnes the amplitudes of the real valued basefunctions at the sampling's
% points up to order nmax
%
% according to Dissertation Zotter, eq. 26 (page 18)
% Martin Kunkemoeller 16.11.2010
%%

ita_verbose_obsolete('Marked as obsolete. Please report to mpo, if you still use this function.');

SH = zeros(sampling.nPoints, (nmax+1)^2);

for n = 0:nmax
    idxLeftSide  = n^2+n  : -1 : n^2+1;
    idxRightSide = n^2+n+1:  1 : (n+1)^2;
    
    
    
    N = normalize_const(n);
    P = legendre(n, cos(sampling.theta)).';
    if size(P,1) ~= sampling.nPoints
        P = P.';
    end
    
    SH(:, idxRightSide) = repmat(N ,[sampling.nPoints 1])        .* P          .* cos(sampling.phi * (0:n));
    SH(:, idxLeftSide)  = repmat(N(2:end) ,[sampling.nPoints 1]) .* P(:,2:end) .* sin(-sampling.phi * (1:n));
end
end

function N = normalize_const(n)
%     function for orthogonality (Dis Zotter, eq.31 (page 19))
N = zeros(1,n+1);
for m = 0:n
    N(m+1) = ((-1)^m) * sqrt((2*n+1)*(2-d(m,0))*factorial(n-m)/(4*pi*factorial(n+m)));
end
end

function out = d(x,m)
% kronecker delta
out = zeros(size(x));
% if sum(x==m), disp('hello'); end
out(x~=m)=0;
out(x==m)=1;

end
