function wN = rafaely_plane(N,k0,R,wS,phiS,thetaS,phi,theta)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%%% plane wave decomposition method. See Rafaely JASA 2004


    nS = length(phiS);
    pnm=zeros(N+1,2*(N+1));  
    
    %% 1. Computation of pnm coefficients of plane waves
    for n=0:N,
        bn=sph_bn(n,k0*R,'rigid');
        YS=sph_harmonics(n,thetaS,phiS);        
        if n==0,
            YS=YS.';
        end
        i=n+1;
        j=0;
        for m=-n:n,
            j=j+1;
            if m>=0,
                Ynm=conj(YS(m+1,:));
            else
                Ynm=(-1)^m*YS(abs(m)+1,:);
            end
            pnmj=Ynm*wS;
            pnm(i,j)=bn*pnmj;
        end
    end
    
    %% 2. Computation of directivity function using pnm values
    
    nV=size(phi(:),1);
    wN=zeros(1,nV);  
    pnmj=0;
    for n=0:N,
        bn=sph_bn(n,k0*R,'rigid');
        Y=sph_harmonics(n,theta,phi); 
        if n==0,
            Y=Y.';
        end
        i=n+1;
        j=0;
        for m=-n:n,
            j=j+1;
            if m>=0,
                Ynm=Y(m+1,:);
            else
                Ynm=(-1)^m*conj(Y(abs(m)+1,:));
            end
            wN=wN+pnm(i,j).*(1./bn)*Ynm;         
        end
    end
    
    
    
end

