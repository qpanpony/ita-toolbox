% function varargout = plane_wave_decomposition(varargin)
%

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% This function perform the wavefield decomposition of a plane wave
% impinging on a spherical sphere of radius R, using a spherical harmonics
% expansion or cartesian one, and compute DOA diagrams for a different set
% of techniques, with polot support. 

%% Get function string
thisFuncStr = [upper(mfilename) ':'];   % warning advise

%% Input parsing

%% Input parameteres
f = 1350;           % f (Hz)
c = 343.7;          % speed of sound (m/s)
k0 = 2*pi.*f/c;     % wavenumber 
R = 0.2;            % radius of sphere (m)

%% Calculate coordinates of microphone array
[V,Vsph,D]=sphere_design('96p-13d',R);   % position of microphones in the R-radius
%[V,Vsph,D]=sphere_design('24p-3d',R);   % position of microphones in the R-radius
% D is the minimun distance


% similar computation with Martin ITA toolbox
array=ita_sph_sampling_hyperinterpolation(5);
array.nmax=10;

beta=array;
phiA=array.phi;
thetaA=array.theta;

% phiA=Vsph(:,1);
% thetaA=Vsph(:,2);

nA = length(phiA);

%% Simulate sources

% definition of source parameters
w      = [1.0 1.0 1.0]';                  % amplitudes
phiS   = [1 1 1.2]';
thetaS = [0.6 0.8 0.8]';

% Rafaely example sources
wphase = [0 20 80 180 270]';
wmag   = [1.0 1.0 1.0 1.0 1.0]';                  % amplitudes
w      = wmag.*exp(j.*wphase);
phiS   = (pi/180)*[200 270 270 210 250]';
thetaS = (pi/180)*[20 45 60 120 120]';
    % phiS=phiS(1); thetaS=thetaS(1);       % testing
nS     = length(phiS);


% w      = [1.0 1.0]';                  % amplitudes
% phiS   = [1 1]';
% thetaS = [0.6 1.2]';


nSnap = 100;        % #time snapshots, for experimental simil

% computation of the A matrix for the simulation of generated field
A=steering_matrix(k0,R,phiS,thetaS,phiA,thetaA,'cart');

wp=repmat(w,1,nSnap);


% noise simultation
noise = randn(nA,nSnap) + 1*i*randn(nA,nSnap);
sigma = 0.01;     % noise variance
noise = sqrt(sigma/2)*noise;
p=A*wp+noise;      %% add noise (complex)



%% Array processing technique

% 1. Define coordinates for computation and visualization

dd=5;       % delta (degrees)
dr=dd*(2*pi)/360;

[phi,theta]=meshgrid(dr:dr:2*pi,dr:dr:pi);
phiv=phi(:); thetav=theta(:);

% 2. Compute steering matrix and apply array processing (in step 3)

A=steering_matrix(k0,R,phiv,thetav,phiA,thetaA,'cart');

% 3. Plot results for different techniques

P_bf = sph_DOA(A,p,'beamforming');
P_bf=reshape(P_bf,size(phi));

figure(1)
pcolor(phi,theta,abs(P_bf))
shading interp;
%contourf(phi,theta,abs(P_bf),5)
colorbar
xlabel('\phi')
ylabel('\theta')
title('beamforming');
hold on
plot(phiS,thetaS,'ko','MarkerSize',6,'MarkerFaceColor','w');
plot(phiA,thetaA,'kx');
hold off


P_cap = sph_DOA(A,p,'capon');
P_cap=reshape(P_cap,size(phi));

figure(2)
pcolor(phi,theta,abs(P_cap))
shading interp;
%contourf(phi,theta,abs(P_cap),5)
colorbar
xlabel('\phi')
ylabel('\theta')
title('Capon')
hold on
plot(phiS,thetaS,'ko','MarkerSize',6,'MarkerFaceColor','w');
plot(phiA,thetaA,'kx');
hold off


P_mus = sph_DOA(A,p,'music',nS);
P_mus=reshape(P_mus,size(phi));

figure(3)
pcolor(phi,theta,abs(P_mus))
shading interp;
%contourf(phi,theta,abs(P_cap),5)
colorbar
xlabel('\phi')
ylabel('\theta')
title('MUSIC')
hold on
plot(phiS,thetaS,'ko','MarkerSize',6,'MarkerFaceColor','w');
plot(phiA,thetaA,'kx');
hold off

p1=p(:,1);
P_mal = sph_DOA(A,p1,'maliutov');
P_mal=reshape(P_mal,size(phi));

figure(33)
pcolor(phi,theta,abs(P_mal))
shading interp;
colorbar
xlabel('\phi')
ylabel('\theta')
title('Maliutov')
hold on
plot(phiS,thetaS,'ko','MarkerSize',6,'MarkerFaceColor','w');
plot(phiA,thetaA,'kx');
hold off

% spherical Rafaely
% 
% R=0.2;

N=10;
wN=rafaely_plane(N,k0,R,w,phiS,thetaS,phiv,thetav);
P_plw=reshape(wN,size(phi));

figure(34)
pcolor(phi,theta,abs(P_plw))
shading interp;
colorbar
xlabel('\phi')
ylabel('\theta')
title('Spherical')
hold on
plot(phiS,thetaS,'ko','MarkerSize',6,'MarkerFaceColor','w');
plot(phiA,thetaA,'kx');
hold off

N=10;
A=steering_matrix(k0,R,phiA,thetaA,phiv,thetav,'sph_planewave');
p1=p(:,1);
P_sph = sph_DOA(A,p1,'sphP');
P_sph=reshape(P_sph,size(phi));

figure(35)
pcolor(phi,theta,abs(P_sph))
shading interp;
colorbar
xlabel('\phi')
ylabel('\theta')
title('Spherical2')
hold on
plot(phiS,thetaS,'ko','MarkerSize',6,'MarkerFaceColor','w');
plot(phiA,thetaA,'kx');
hold off



return
P_sph2 = sph_DOA(A',p1,'sphS');
P_sph2=reshape(P_sph2,size(phi));

figure(341)
pcolor(phi,theta,abs(P_sph2))
shading interp;
colorbar
xlabel('\phi')
ylabel('\theta')
title('Spherical L1')
hold on
plot(phiS,thetaS,'ko','MarkerSize',6,'MarkerFaceColor','w');
plot(phiA,thetaA,'kx');
hold off


%% Pressure in the sphere
% nSnap = 100;
% A=steering_matrix(k0,R,phiS,thetaS,phiv,thetav,'sph');
% nv = size(phiv,1);
% noise = randn(nv,1) + 1*i*randn(nv,1);
% sigma = 0.01;     % noise variance
% noise = sqrt(sigma/2)*noise;
% p=A*w+noise;      %% add noise (complex)
% figure(35)
% p=reshape(p,size(phi));
% f1=pcolor(phi,theta,abs(p));
% % pf2=griddata(phiA,thetaA,abs(pf),phi,theta);
% % pcolor(phi,theta,pf2)
% % 
% shading interp;
% colorbar
% xlabel('\phi')
% ylabel('\theta')
% title('p(\theta,\phi)')
% set(gca,'FontSize',9);
% hold on
% plot(phiS,thetaS,'ko','MarkerSize',6,'MarkerFaceColor','w');
% %plot(phiA,thetaA,'kx');
% hold off



return

