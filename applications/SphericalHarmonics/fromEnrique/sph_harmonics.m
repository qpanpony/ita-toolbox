function Y = sph_harmonics(n,theta,phi)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% compute spherical harmonics for a vector of coordinates until order n

    
    t1=(2*n+1)/(4*pi);
    %
    np=length(theta);       % number of points with coordinates
    Y = zeros(n+1,np);
    costh = cos(theta);
    Pnm = legendre(n,costh);
    if n==0,
        Pnm=sqrt(t1).*Pnm;
    else
    for m=0:n,
        t2=factorial(n-m)/factorial(n+m);
        K=sqrt(t1*t2);          % K is normalization constant
        Pnm(m+1,:)=K.*Pnm(m+1,:).*exp(1i*m*phi.');
    end
    end
    Y=Pnm;
end
