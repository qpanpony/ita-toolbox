function P = sph_DOA(A,p,method,nS)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% A : steering matrix
% p : pressure at array of microphones (sphere)
% method : array processing technique for DOA detection
% nS : number of sources

% Maliutov method use cvx convex optimization package

if nargin < 3, method = 'capon'; end


nA   = size(A,1);        % number of microphones
nang = size(A,2);        % number of angles for array processing
P    = zeros(1,nang);

switch method
    case 'beamforming'   % Beamforming method
        R=(p*p')/nA;
        for ang=1:nang
            a = A(:,ang);
            w=a./sqrt(a'*a);
            P(ang)=a'*R*a/(a'*a);
        end
    case 'sphS'           % Spherical harmmonics plane wave (Rafaely)
        %P=(4*pi/nA)*A*p;   % standard plane wave method
                          % steering matrix A is modified before call
        lambda=0.4;         % L1 parameter 
        [m,n]=size(A);        
        cvx_begin
            variable x1(n) complex;
            minimize (norm(A*x1-p)+lambda*norm(x1,1))
        cvx_end  
        P = x1;  
    case 'sphP'           % Spherical harmmonics plane wave (Rafaely)
        P=(4*pi/nA)*A*p;   % standard plane wave method     
    case 'capon'         % Capon (MVDR)
        R=(p*p')/nA;
        mu=0.000001*(trace(R)/nA);   % matrix regularization parameter (0.1,1,10)
        R=R+mu*eye(nA);
        Rinv=inv(R);
        for ang=1:nang
            a = A(:,ang);
            P(ang)=1./(a'*Rinv*a);
        end
    case 'music'         % MUSIC
        R=(p*p')/nA;
        mu=0.0001*(trace(R)/nA);   % matrix regularization parameter (0.1,1,10)
        R=R+mu*eye(nA);
        [U,D,V]=svd(R);   
        G=U(:,nS+1:nA);
        for ang=1:nang
            a = A(:,ang);
            P(ang)=1./(a'*G*G'*a);
        end
    case 'maliutov'      % Maliutov sparse method
        lambda=0.1;         % L1 parameter 
        [m,n]=size(A);        
        % [At,b,c,K]=rls(A,p,0.20);     % old method, not working At is not
                                        %   properly set
        % [x1,y1]=sedumi(At,b,c,K);
        cvx_begin
            variable x1(n) complex;
            minimize (norm(A*x1-p)+lambda*norm(x1,1))
        cvx_end  
        P = x1;
    otherwise
        error([mfilename 'non-valid method']);                         
end


end
