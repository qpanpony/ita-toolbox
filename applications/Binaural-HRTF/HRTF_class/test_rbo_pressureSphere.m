function pTot = test_rbo_pressureSphere(varargin)

% <ITA-Toolbox>
% This file is part of the application HRTF_class for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

sArgs           = struct('sph',[],'fftDeg',8, 'flatSpec_druck',[],'flatSpec_admittanz',[],'radius',1);
sArgs           = ita_parse_arguments(sArgs,varargin);

coord = sArgs.sph;
fftDeg   = sArgs.fftDeg;
rKugel  = mean(sArgs.sph.r);

c0      = ita_constants('c','T',20);
if length(fftDeg) == 1 && isempty(sArgs.flatSpec_druck) && isempty(sArgs.flatSpec_admittanz)         %Geniert ein Spektrum, falls der Eingabeparameter fftDeg eine Zahl ist;
    flatSpec_druck      = ita_generate('flat',1,44100,fftDeg);
    flatSpec_admittanz  = ita_generate('flat',0,44100,fftDeg);
    
elseif length(fftDeg) ~= 1 && isempty(sArgs.flatSpec_druck) && isempty(sArgs.flatSpec_admittanz)
    
    freqVec = fftDeg;                              %Nutzt den eingegebenen Vektor als Frequenzen, falls fftDeg ein Vektor ist
    flatSpec_druck = itaAudio(ones(size(freqVec)), freqVec(end)*2, 'freq');
    flatSpec_admittanz = itaAudio(zeros(size(freqVec)), freqVec(end)*2, 'freq');
    
else
    flatSpec_druck      = sArgs.flatSpec_druck;
    flatSpec_admittanz  = sArgs.flatSpec_admittanz;    
end

maxOrder = 60;% war mal 80

%% Coordinate Transformation
coord_ear_left  = itaCoordinates;
coord_ear_right = itaCoordinates;

coord_ear_left.cart  = [0 rKugel 0];
coord_ear_right.cart = [0 -rKugel 0];

coord_mech = itaCoordinates;

for iCoord = 1: coord.nPoints
    currentTheta = coord.theta_deg(iCoord);
    currentPhi = coord.phi_deg(iCoord);
   
    phi_Y = 180 -  currentTheta;
    phi_Z = 360 - currentPhi;
    
    rot_y = [cosd(phi_Y) 0 sind(phi_Y); 0 1 0; -sind(phi_Y) 0 cosd(phi_Y)]; % MMI-Skript S. 31
    rot_z = [cosd(phi_Z) -sind(phi_Z) 0; sind(phi_Z) cosd(phi_Z) 0; 0 0 1];
    
    tmp_links = rot_y*rot_z*coord_ear_left.cart';
    coord_mech.cart(2*iCoord-1,:) = tmp_links';
    
    tmp_rechts = rot_y*rot_z*coord_ear_right.cart'; % Rotation erst um z dann um y
    coord_mech.cart(2*iCoord,:) = tmp_rechts';
end

coord_mech.r  = rKugel;

%% Pressure
[pScat, pInc] = ita_analytic_plane_wave_on_sphere(flatSpec_druck, flatSpec_admittanz, coord_mech, rKugel, 'c', c0.value, 'maxOrder', maxOrder);
pTot  = pScat + pInc;
pTot.freqData(1,:) = pInc.freqData(1,:); % first column is alway Nan replace this with pInc

pTot.channelCoordinates.sph(1:2:coord.nPoints*2,:) =  coord.sph;
pTot.channelCoordinates.sph(2:2:coord.nPoints*2,:) =  coord.sph;

