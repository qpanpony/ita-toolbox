function A = steering_matrix(k0,R,phiS,thetaS,phi,theta,method)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%%% steering matrix computation in cartesian and spherical harmonics 
% includes also a trial for plane_wave decomposition, but it doesn't work
% properly



if nargin < 7, method = 'cart'; end


switch method
    case 'sph'              % spherical harmonics
        A=steering_matrix_sph(k0,R,phiS,thetaS,phi,theta); 
    case 'sph_planewave'    % plane wave decomposition
        A=steering_matrix_planewave(k0,R,phiS,thetaS,phi,theta);
    case 'cart'             % cartesian
        A=steering_matrix_cart(k0,R,phiS,thetaS,phi,theta);
    otherwise
        error([mfilename 'non-valid method']);                         
end


end


% steering_matrix_sph: computation of steering matrix in spherical coordinates
function A=steering_matrix_sph(k0,R,phiS,thetaS,phi,theta)

%%%     N is the number of spherical harmonics, in theory it's inf
%           k0*R is a good number, according with Rafaeli
%           I tested in several cases, and errors are about 5%
%           so I added 10 harmonics more
%       If too much harmonics, numerical inconsistency because
%           asymptotic behaviour of hankel or bessel functions
%

% cuidado con n=0, el array es diferente

    nA = length(phi);
    nS = length(phiS);
    A=zeros(nA,nS);  
    
    N=ceil(k0*R)+10;                               
    for n=0:N,
        bn=sph_bn(n,k0*R,'rigid');
        Y=sph_harmonics(n,theta,phi);
        YS=sph_harmonics(n,thetaS,phiS);
        if n==0,
            Y=Y.'; YS=YS.';
        end
        YSS=Y(1,:).'*conj(YS(1,:));
        for m=1:n,
            YSS=YSS+2.*real(Y(m+1,:).'*conj(YS(m+1,:)));  % ab*+ba*=2Re(ab)
        end
        A=A+bn*YSS;
    end
end

function A=steering_matrix_planewave(k0,R,phiS,thetaS,phi,theta)

%%%     N is the number of spherical harmonics, in theory it's inf
%           k0*R is a good number, according with Rafaeli
%           I tested in several cases, and errors are about 5%
%           so I added 10 harmonics more
%       If too much harmonics, numerical inconsistency because
%           asymptotic behaviour of hankel or bessel functions
%

    nA = length(phi);
    nS = length(phiS);
    A=zeros(nA,nS);  
    
    Nmore = 0;
    N=ceil(k0*R)+Nmore;         % lot of careful with Nmore!!      
    N=5;
    for n=0:N,
        bn=sph_bn(n,k0*R,'rigid');
        Y=sph_harmonics(n,theta,phi);
        YS=sph_harmonics(n,thetaS,phiS);
        if n==0,
            Y=Y.'; YS=YS.';
        end
        YSS=Y(1,:).'*conj(YS(1,:));
        for m=1:n,
            YSS=YSS+2.*real(Y(m+1,:).'*conj(YS(m+1,:)));  % ab*+ba*=2Re(ab)
        end
        A=A+YSS./bn;            % plane wave decomposition (compare with 'sph')
    end
end



% steering_matrix_cart: computation of steering matrix in cartesian coordinates
function A=steering_matrix_cart(k0,R,phiS,thetaS,phi,theta)

    nA = length(phi);
    nS = length(phiS);
    A=zeros(nA,nS);     % steering matrix 2 (cartesian coordinates)
    costh = cos(theta);
    sinth = sin(theta);
    cosph = cos(phi);
    sinph = sin(phi);
    costhS = cos(thetaS);
    sinthS = sin(thetaS);
    cosphS = cos(phiS);
    sinphS = sin(phiS);
    kx=(sinth.*cosph)*(sinthS.*cosphS)';
    ky=(sinth.*sinph)*(sinthS.*sinphS)';
    kz=(costh)*(costhS)';
    kr=k0*R*(kx+ky+kz);        % k direction is -k
    A=exp(1*i*kr);  %
end
