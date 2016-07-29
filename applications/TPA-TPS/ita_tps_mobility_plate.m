function varargout = ita_tps_mobility_plate(varargin)
%ita_tps_mobility_plate - After Fahy Book Edition 2. pp 108
%  This function calculates the ideal mobility matrix of an rectangular plate of size
%  (Lx, Ly, h) for source position (rs_x, rs_y, 0) and receiver
%  positions (rr_x, rr_y, 0). Material data required:
%  - Young Modulus [Pa]
%  - Poisson Ratio
%  - Density [kg/m³]
%  - Damping Coefficient
%
%  Syntax:
%   audioObjOut = ita_tps_mobility_plate(geometryCoordinates, sourceCoordinates, receiverCoordinates, Young Modulus, ...
%   Poisson Ratio,  Density, Damping Coefficient, options)
%
%
%   Options (default):
%           'delta' (2) : description
%           'f_max' (10000) : description
%           
%
%  Example:
% 
%  audioObj=ita_tps_mobility_plate(itaCoordinates([.45 .8 1e-3]),itaCoordinates([0.35,0.6,0]), ...
%  ... itaCoordinates([0.3,0.6,0]),.7e11,0.346,2710, 0.005, 'f_max',2000 )
% 
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_roomacoustics_analytic_FRF">doc ita_roomacoustics_analytic_FRF</a>

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Pascal -- Email: pdi@akustik.rwth-aachen.de
%         Lian 
% Created:  10-Fev-2011


%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaCoordinates', 'pos2_data','itaCoordinates','pos3_data','itaCoordinates', 'pos4_data', 'double', ...
    'pos5_data', 'double', 'pos6_data' , 'double','pos7_data', 'double', 'f_max',10000);
[geometry, source_pos, receiver_pos , E, v, rho, eta, sArgs] = ita_parse_arguments(sArgs,varargin);

%% Init and Constants
% v is the Poisson Ratio
% E is the Young (Elastcity) Modulus [Pa]
% rho is the density [kg/m³]
L               = geometry.cart;
lx = L(1); 
lz = L(2); 
h  = L(3);
r_source        = source_pos.cart;
r_receiver      = receiver_pos.cart;
% c               = sqrt(E*(1-v)/rho/(1+v)/(1-2*v)); %sound speed
D               = E*h^3/12/(1-v^2) ; %bending stiffnes per unit length
m               = rho*h;           % mass per unit area
% Mr              = rho * lx * lz * h; %total mass

%% Verifications
if lx<r_source(1) || lz<r_source(2) || lx<r_receiver(1) || lz<r_receiver(2)
    error('Hey! Coordinates of source or receiver are out of range. Try to correct and run again!')
end
if E<1000 || v>1
    ita_verbose_info('Humm... Your material data is very strange. Please check the values and units!',0)
end

%% Checking how many eigenfreqs are there?
warning off
idx = 0;
for nx = 0:floor(sqrt(2*sArgs.f_max*sqrt(m/D)*lx^2/pi)) %pq 12??
    if ~isempty(nx) && isreal(nx)
        idx= idx + floor(real(sqrt( (2*pi*sArgs.f_max*sqrt(m/D) - (nx*pi/lx)^2)  * (lz/pi)^2) ));
    end
end
nModes = idx;
dummy  = zeros(1,nModes);

%% calculating all possible combinations of n-coefficients
n = zeros(2,nModes);
idx = 1;
nx_max =floor(sqrt(2*sArgs.f_max*sqrt(m/D)*lx^2/pi));
for nx = 1:nx_max %change initval 0 by 1
    nz_max = floor(real(sqrt( (2*pi*sArgs.f_max*sqrt(m/D) - (nx*pi/lx)^2)  * (lz/pi)^2) ));
    
    idx_end = idx + nz_max ;
    n(1,idx:idx_end) = nx;
    n(2,idx:idx_end-1) = 1:nz_max;
    
    idx = idx+nz_max + 1;
    
end
n     = n(:,1:idx - nz_max - 1); %Fixed Lian - The number of modes estimation is not always correct
% dummy = dummy(:,1:idx - nz_max - 1); %Same thing of n
dummy  = zeros(1,size(n,2));

disp([num2str(idx - nz_max - 1) ' modes have been calculated...'])

%% Eigen-Frequencies
f_n = sqrt( D/m ) / (2 * pi) * sum( bsxfun( @rdivide,pi*n,[lx lz]' ).^2,1 ) ;

% % % % % %% coefficient receiver and source / phi/psi function in Fahy's Book
% % % % % r_norm      = r_receiver ./ L; %relative position
% % % % % r_norm_n    = bsxfun(@times,n,r_norm(1:2)');
% % % % % 
% % % % % coeff_r     = 2 * prod(sin(pi*r_norm_n),1); %phi in Fahy's book
% % % % % d_coeff_r_x	= 2*pi*r_norm_n(1,:).*cos(pi*r_norm_n(1,:)).*sin(pi*r_norm_n(2,:));
% % % % % d_coeff_r_z	= 2*pi*r_norm_n(2,:).*sin(pi*r_norm_n(1,:)).*cos(pi*r_norm_n(2,:));
% % % % % %d_coeff_r = cos(d_coeff_r_z)-sin(d_coeff_r_x); %psi in Fahy's book
% % % % % 
% % % % % s_norm      = r_source ./ L; %relative position
% % % % % s_norm_n    = bsxfun(@times,n,s_norm(1:2)');
% % % % % 
% % % % % coeff_s     = 2 * prod(sin(pi * s_norm_n),1);
% % % % % % d_coeff_s_x	= 2*pi*s_norm_n(1,:)*r_norm(1).*cos(pi*s_norm_n(1,:)).*sin(pi*s_norm_n(2,:));
% % % % % % d_coeff_s_z	= 2*pi*s_norm_n(2,:)*r_norm(2).*sin(pi*s_norm_n(1,:)).*cos(pi*s_norm_n(2,:));
% % % % % d_coeff_s_x	= 2*pi*s_norm_n(1,:).*cos(pi*s_norm_n(1,:)).*sin(pi*s_norm_n(2,:)); %pdi s_ to r_
% % % % % d_coeff_s_z	= 2*pi*s_norm_n(2,:).*sin(pi*s_norm_n(1,:)).*cos(pi*s_norm_n(2,:));
% % % % % %d_coeff_s = cos(d_coeff_s_z)-sin(d_coeff_s_x);

%% coefficient receiver and source / phi/psi function in Fahy's Book
% the PSI-function in FAHYs book seems strange, a derivation is totally
% resonable but this sin(cos + sin) is odd!

% source
s_norm      = r_source ./ L; %relative position
s_norm_n    = bsxfun(@times,n,s_norm(1:2)'); %including mode number index

coeff_s     = 2 * prod(sin(pi * s_norm_n),1);
d_coeff_s_x	= 2 * pi / L(1) * n(1,:).* cos(pi*s_norm_n(1,:)) .* sin(pi*s_norm_n(2,:)); %pdi s_ to r_
d_coeff_s_z	= 2 * pi / L(2) * n(2,:).* sin(pi*s_norm_n(1,:)) .* cos(pi*s_norm_n(2,:));

% receiver
r_norm      = r_receiver ./ L; %relative position
r_norm_n    = bsxfun(@times,n,r_norm(1:2)');

coeff_r     = 2 * prod(sin(pi*r_norm_n),1); %phi in Fahy's book
d_coeff_r_x	= 2 * pi / L(1) * n(1,:).* cos(pi*r_norm_n(1,:)) .* sin(pi*r_norm_n(2,:));
d_coeff_r_z	= 2 * pi / L(2) * n(2,:).* sin(pi*r_norm_n(1,:)) .* cos(pi*r_norm_n(2,:));


%% final coeffs
% Changing Y and Z coordinates: According to Ansys simulations, and most
% useful coordinates system. Fahy X = Our X and Fahy Y = Our Z
Yvzfz = coeff_s     .* coeff_r;
Yvzmx = d_coeff_s_x .* coeff_r;
Yvzmy = d_coeff_s_z .* coeff_r;

Yoxfz = coeff_s     .* d_coeff_r_x;
Yoxmx = d_coeff_s_x .* d_coeff_r_x;
Yoxmy = d_coeff_s_z .* d_coeff_r_x;

Yoyfz = coeff_s     .* d_coeff_r_z;
Yoymx = d_coeff_s_x .* d_coeff_r_z;
Yoymy = d_coeff_s_z .* d_coeff_r_z;

Ycomp = zeros(1,length(Yvzfz));
% pdi: line checked!
Y     = [ repmat(Ycomp', 1, 14)                                                                                                          Yvzfz'   Yvzmx'   Yvzmy'   repmat(Ycomp', 1, 3)       Yoxfz'   Yoxmx'   Yoxmy'   repmat(Ycomp', 1, 3)       Yoyfz'   Yoymx'   Yoymy'   repmat(Ycomp', 1, 7)];
Ystr  = ['Yvxfx'; 'Yvxfy'; 'Yvxfz'; 'Yvxmx'; 'Yvxmy'; 'Yvxmz';  'Yvyfx'; 'Yvyfy'; 'Yvyfz'; 'Yvymx'; 'Yvymy'; 'Yvymz'; 'Yvzfx'; 'Yvzfy'; 'Yvzfz'; 'Yvzmx'; 'Yvzmy'; 'Yvymz'; 'Yoxfx'; 'Yoxfy'; 'Yoxfz'; 'Yoxmx'; 'Yoxmy'; 'Yoxmz'; 'Yoyfx'; 'Yoyfy'; 'Yoyfz'; 'Yoymx'; 'Yoymy'; 'Yoymz'; 'Yozfx'; 'Yozfy'; 'Yozfz'; 'Yozmx'; 'Yozmy'; 'Yozmz'];

%% delta or eta in Fahy's book
delta_n_raw = eta;
if isa(delta_n_raw,'itaSuper')
    delta = delta_n_raw.freq2value(f_n).';
else
    delta = dummy + delta_n_raw;
end

%% Units
mulfac  = 3;
v_units = [repmat(itaValue(1,'m/s'),1,mulfac) repmat(itaValue(1,'1/s'),1,mulfac)];
F_units = [repmat(itaValue(1,'N'),1,mulfac)   repmat(itaValue(1,'N m'),1,mulfac)];
units   = repmat(itaValue,2*mulfac,2*mulfac); % just init

for idx = 1:numel(v_units)
    for jdx = 1:numel(F_units)
        aux = itaValue(v_units(idx)) / itaValue(F_units(jdx));
        units(jdx,idx) = aux;
    end
end
units_lin = [];
for idx = 1:size(units,1)
    units_lin = [units_lin units(idx,:)]; %#ok<AGROW>
end

%% Set Output
if nargout == 3
    varargout(1) = {f_n};
    varargout(2) = {Y'};
    varargout(3) = {delta};
  
else
    for idx=1:36
        pz = itaPZ;
        pz.f = f_n; pz.C = Y(:,idx).'; pz.sigma = -delta;
        respt(idx) = itaAudioAnalyticRational(pz);
        respt(idx).channelNames{1} = Ystr(idx,:);
        respt(idx).channelUnits{1} = units_lin(idx).unit;

    end

    kdx = 1;
    for idx = 1:6
        for jdx = 1:6
            aMatrix(idx,jdx) = respt(kdx);
            kdx = kdx+1;
        end
    end
    
    varargout{1} = aMatrix;
end

%end function
end
