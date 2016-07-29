% CHO_PLATE_MOBILITIES calculates the out-of-plane point and transfer
% mobilities of rectangular plates for different boundary conditions by
% using a modal summation approach as described in [1]. In total, nine
% mobilities are calculated:
% 	Y_vz_Fz  Y_vz_Mx  Y_vz_My
% 	Y_Ox_Fz  Y_Ox_Mx  Y_Ox_My
% 	Y_Oy_Fz  Y_Oy_Mx  Y_Oy_My
% Fz and vz are the linear force and velocity in normal direction to the
% plate. Mx, My, Ox, Oy are the out-of-plane moments and angular velocities
% at the points of excitation and response.
% So far, three different boundary conditions are supported:
%	- pinned-pinned (simply supported);
%	- clamped-clamped;
%	- free-free.
% The plate properties (dimensions and material properties) have to be
% specified, as well as the frequency-dependent loss factor of the plate.
% For normal use, it should be sufficient to adjust only the first three
% cells of this m file.

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% AUTHOR:  Christoph Hoeller, christoph.hoeller@liverpool.ac.uk
% REVISED: 19 August 2010

% REFERENCES:
%	[1] Fahy/Walker: Advanced Applications in Acoustics, Noise and
%	Vibration. 2004. Chapter 9.8.4, pages 436-442 by Gardonio/Brennan.



%% Initialization
% clear all;close all
clc;commandwindow

Options.plotOverview	= 1; % plot all nine calculated mobilities in one figure
Options.plotPlate		= 1; % plot a sketch of the plate indicating excitation and response position
Options.plotYinf		= 1; % for point mobilities also plot the infinite plate mobilities


%% Plate Properties
Plate.Lx		= 2.120;	% length of plate [m]
Plate.Ly		= 1.500;	% width of plate [m]
Plate.Lz		= 0.0193;	% thickness of plate (in bending direction) [m]
Plate.x1		= 0.630;	% position of point of excitation in x direction [m]
Plate.y1		= 0.550;	% position of point of excitation in y direction [m]
Plate.x2		= 0.630;	% position of point of response in x direction [m]
Plate.y2		= 0.550;	% position of point of response in y direction [m]
Plate.velocity	= 5100;		% quasi-longitudinal phase velocity [m/s]
Plate.eModul    = 70e9;		% Young's modulus [N/m^2]
Plate.poisson   = 0.33;		% Poisson's ratio [-]
Plate.density   = 2.7e3;	% density of material [kg/m^3]
Plate.indenter	= 0.010;	% radius of indenter [m] (only needed for point moment mobility of infinite plate)
Plate.mPerArea  = Plate.density * Plate.Lz;  % mass per area [kg/m^2]
Plate.bendStiff = (Plate.eModul*Plate.Lz^3)/(12*(1-Plate.poisson^2)); % bending stiffness

% Boundary condition
% Plate.boundary	= 'pinned-pinned';
% Plate.boundary	= 'clamped-clamped';
Plate.boundary	= 'free-free';

if Plate.Lx < Plate.x1 || Plate.Lx < Plate.x2 || Plate.Ly < Plate.y1 || Plate.Ly < Plate.y2
    error([thisFuncStr 'Coordinates of excitation or response are out of range.'])
end


%% Calculation Parameters and Loss Factor
% Frequency vector freq.
% freq = logspace(0, 4.3, 1000); % logarithmic frequency resolution
freq = 1:1:2000; % linear frequency resolution

% Frequency-dependent loss factor. The loss factor of the plate has to be
% specified as a vector of same length as the frequency vector freq. For
% example, for a constant loss factor over frequency use this statement:
Plate.lFactor = 0.01*ones(1,length(freq));

% The maximum frequency fMax determines the number of modes that are
% considered for modal summation. Please note: all modes up to fMax are
% considered for modal summation, but there are also some modes that are
% considered above fMax. This is owed to the use of the eigenfrequency
% matrix fmn (see below).
fMax	= 2000;

% The values below are the initial values for the number of modes in both
% dimensions that are considered for modal summation. The initial values
% are chosen quite high, but are decreased later according to the desired
% maximum frequency.
mModes  = 100;
nModes  = 100;


%% Calculate Gx, Gy, Hx, Hy, Jx, Jy (Table 9.9)
m	= 1:mModes;
n	= (1:nModes)';
switch Plate.boundary
    case 'pinned-pinned'
        Gx	= m;
        Gy	= n;
        Hx	= m.^2;
        Hy	= n.^2;
        Jx	= m.^2;
        Jy	= n.^2;
    case 'clamped-clamped'
        Gx	= m + 0.5; Gx(1) = 1.506;
        Gy	= n + 0.5; Gy(1) = 1.506;
        Hx	= (m+0.5).^2 .* (1-repmat(4,1,mModes)./((2*m+1)*pi)); Hx(1) = 1.248;
        Hy	= (n+0.5).^2 .* (1-repmat(4,nModes,1)./((2*n+1)*pi)); Hy(1) = 1.248;
        Jx	= (m+0.5).^2 .* (1-repmat(4,1,mModes)./((2*m+1)*pi)); Jx(1) = 1.248;
        Jy	= (n+0.5).^2 .* (1-repmat(4,nModes,1)./((2*n+1)*pi)); Jy(1) = 1.248;
    case 'free-free'
        % Please note: the numbering for free-free plates is different than
        % for the other cases. The numbering of the modes in this file does
        % NOT correspond to the numbering in [1]. Here, the even rigid body
        % mode is indicated by (1,1), the two simple rocking modes are
        % called (2,1) and (1,2). The first "real" mode, which is called
        % (1,1) in [1] is called (3,3) in this file. The factors G, H, J
        % have to be adjusted to fit the different numbering, and so has
        % the gamma function (see below).
        Gx	= (m-2) + 0.5;
        Gy	= (n-2) + 0.5;
        Hx	= (m-2+0.5).^2 .* (1-repmat(4,1,mModes)./((2*(m-2)+1)*pi));
        Hy	= (n-2+0.5).^2 .* (1-repmat(4,nModes,1)./((2*(n-2)+1)*pi));
        Jx	= (m-2+0.5).^2 .* (1+repmat(12,1,mModes)./((2*(m-2)+1)*pi));
        Jy	= (n-2+0.5).^2 .* (1+repmat(12,nModes,1)./((2*(n-2)+1)*pi));
        Gx(1) = 0;		Gx(2) = 0;			Gx(3) = 1.506;
        Gy(1) = 0;		Gy(2) = 0;			Gy(3) = 1.506;
        Hx(1) = 0;		Hx(2) = 0;			Hx(3) = 1.248;
        Hy(1) = 0;		Hy(2) = 0;			Hy(3) = 1.248;
        Jx(1) = 0;		Jx(2) = 12/pi^2;	Jx(3) = 5.017;
        Jy(1) = 0;		Jy(2) = 12/pi^2;	Jy(3) = 5.017;
    case 'clamped-free'
        error([thisFuncStr ': Specified boundary conditions are not in the database.']);
    case 'clamped-pinned'
        error([thisFuncStr ': Specified boundary conditions are not in the database.']);
    case 'free-pinned'
        error([thisFuncStr ': Specified boundary conditions are not in the database.']);
    otherwise
        error([thisFuncStr ': Specified boundary conditions are not in the database.']);
end


%% Calculate qmn function and eigenfrequencies fmn (Equation 9.68)
% This will give a matrix qmn of size (nModes,mModes), indicating the q
% factors for all combinations of modes in x and y direction. Same for fmn.
qmn	= sqrt(repmat(Gx,nModes,1).^4 + (repmat(Gy,1,mModes).*(Plate.Lx/Plate.Ly)).^4 + 2*(Plate.Lx/Plate.Ly).^2 * ...
    (Plate.poisson .* repmat(Hx,nModes,1) .* repmat(Hy,1,mModes) + (1-Plate.poisson) .* repmat(Jx,nModes,1) .* repmat(Jy,1,mModes)));
fmn	= 1/(2*pi) .* sqrt(Plate.bendStiff/Plate.mPerArea) .* (pi/Plate.Lx).^2 .* qmn;


%% Decrease size of eigenfrequency matrix fmn as much as possible
% From the huge matrix fmn, only the elements are needed that are below
% fMax. Since the value of its elements (i.e. the eigenfrequencies)
% increase for increasing row (column), it is sufficient to search for the
% last element smaller than fMax in the first row (column). The elements in
% the second, third... row (column) must be higher. The matrix fmn can
% therefore be made significantly smaller.
mModes	= find(fmn(1,:) < fMax,1,'last');
nModes	= find(fmn(:,1) < fMax,1,'last');
m		= m(1:mModes);
n		= n(1:nModes);
fmn		= fmn(1:nModes,1:mModes);


%% Calculate characteristic beam functions phi (Table 9.10)
% And evaluate beam functions at specified coordinates x1, x2, y1, and y2.
% Naming convention: phi_x1 is the beam function phi evaluated at point x1.
% phi_dv_y2 is the first derivative of the beam function phi evaluated at
% point y2. This is needed for the cross-mobilities.

% Preallocation for speed and verification reasons
phi_x1 = zeros(1,mModes);	phi_dv_x1 = zeros(1,mModes);
phi_x2 = zeros(1,mModes);	phi_dv_x2 = zeros(1,mModes);
phi_y1 = zeros(nModes,1);	phi_dv_y1 = zeros(nModes,1);
phi_y2 = zeros(nModes,1);	phi_dv_y2 = zeros(nModes,1);

switch Plate.boundary
    case 'pinned-pinned'
        phi_x1		= sqrt(2) * sin(m*pi*Plate.x1/Plate.Lx); %pdi. m and n are differently in fahy
        phi_x2		= sqrt(2) * sin(m*pi*Plate.x2/Plate.Lx);
        phi_y1		= sqrt(2) * sin(n*pi*Plate.y1/Plate.Ly);
        phi_y2		= sqrt(2) * sin(n*pi*Plate.y2/Plate.Ly);
        phi_dv_x1	= sqrt(2) .* m .* pi ./ Plate.Lx .* cos(m.*pi.*Plate.x1/Plate.Lx);
        phi_dv_x2	= sqrt(2) .* m .* pi ./ Plate.Lx .* cos(m.*pi.*Plate.x2/Plate.Lx);
        phi_dv_y1	= sqrt(2) .* n .* pi ./ Plate.Ly .* cos(n.*pi.*Plate.y1/Plate.Ly);
        phi_dv_y2	= sqrt(2) .* n .* pi ./ Plate.Ly .* cos(n.*pi.*Plate.y2/Plate.Ly);
        
    case 'clamped-clamped'
        % Calculate values of the gamma functions (Table 9.11)
        % Gamma functions are used for the calculation of the characteristic beam
        % functions. Please note: the indices in Table 9.10 and Table 9.11 DO NOT
        % CORRESPOND! Variable gamma_i in Table 9.10 is called gamma_j in Table
        % 9.11, and vice versa. That is why they are called gamma_minus and
        % gamma_plus in this m file.
        maxModes		= max(mModes,nModes);
        gamma_idx		= 1:ceil(maxModes/2);
        
        % gamma_minus are solutions of tan(0.5*gamma_minus)-tanh(0.5*gamma_minus)=0
        gamma_minus		= (4*gamma_idx+1)*pi/2;
        gamma_minus(1)	= 7.853200;
        gamma_minus(2)	= 14.13716;
        gamma_minus(3)	= 20.42040;
        gamma_minus(4)	= 26.70360;
        gamma_minus(5)	= 32.98680;
        
        % gamma_plus are solutions of tan(0.5*gamma_plus)+tanh(0.5*gamma_plus)=0
        gamma_plus		= (4*gamma_idx-1)*pi/2;
        gamma_plus(1)	= 4.730040;
        gamma_plus(2)	= 10.99560;
        gamma_plus(3)	= 17.27876;
        gamma_plus(4)	= 23.56200;
        gamma_plus(5)	= 29.84520;
        
        % Arguments of the trigonometric functions: gamma*(x/Lx-0.5)
        triArg_x1_odd	= gamma_plus*(Plate.x1/Plate.Lx-0.5);
        triArg_x2_odd	= gamma_plus*(Plate.x2/Plate.Lx-0.5);
        triArg_y1_odd	= gamma_plus*(Plate.y1/Plate.Ly-0.5);
        triArg_y2_odd	= gamma_plus*(Plate.y2/Plate.Ly-0.5);
        triArg_x1_even	= gamma_minus*(Plate.x1/Plate.Lx-0.5);
        triArg_x2_even	= gamma_minus*(Plate.x2/Plate.Lx-0.5);
        triArg_y1_even	= gamma_minus*(Plate.y1/Plate.Ly-0.5);
        triArg_y2_even	= gamma_minus*(Plate.y2/Plate.Ly-0.5);
        
        % Distinguish between even and odd numbers of m or n.
        phi_x1_odd		= sqrt(2) * (cos(triArg_x1_odd) + (sin(0.5*gamma_plus)./sinh(0.5*gamma_plus)) .* cosh(triArg_x1_odd));
        phi_x2_odd		= sqrt(2) * (cos(triArg_x2_odd) + (sin(0.5*gamma_plus)./sinh(0.5*gamma_plus)) .* cosh(triArg_x2_odd));
        phi_y1_odd		= sqrt(2) * (cos(triArg_y1_odd) + (sin(0.5*gamma_plus)./sinh(0.5*gamma_plus)) .* cosh(triArg_y1_odd));
        phi_y2_odd		= sqrt(2) * (cos(triArg_y2_odd) + (sin(0.5*gamma_plus)./sinh(0.5*gamma_plus)) .* cosh(triArg_y2_odd));
        phi_x1_even		= sqrt(2) * (sin(triArg_x1_even) - (sin(0.5*gamma_minus)./sinh(0.5*gamma_minus)) .* sinh(triArg_x1_even));
        phi_x2_even		= sqrt(2) * (sin(triArg_x2_even) - (sin(0.5*gamma_minus)./sinh(0.5*gamma_minus)) .* sinh(triArg_x2_even));
        phi_y1_even		= sqrt(2) * (sin(triArg_y1_even) - (sin(0.5*gamma_minus)./sinh(0.5*gamma_minus)) .* sinh(triArg_y1_even));
        phi_y2_even		= sqrt(2) * (sin(triArg_y2_even) - (sin(0.5*gamma_minus)./sinh(0.5*gamma_minus)) .* sinh(triArg_y2_even));
        phi_dv_x1_odd	= sqrt(2) * (gamma_plus/Plate.Lx) .* (-sin(triArg_x1_odd) + (sin(0.5*gamma_plus)./sinh(0.5*gamma_plus)) .* sinh(triArg_x1_odd));
        phi_dv_x2_odd	= sqrt(2) * (gamma_plus/Plate.Lx) .* (-sin(triArg_x2_odd) + (sin(0.5*gamma_plus)./sinh(0.5*gamma_plus)) .* sinh(triArg_x2_odd));
        phi_dv_y1_odd	= sqrt(2) * (gamma_plus/Plate.Ly) .* (-sin(triArg_y1_odd) + (sin(0.5*gamma_plus)./sinh(0.5*gamma_plus)) .* sinh(triArg_y1_odd));
        phi_dv_y2_odd	= sqrt(2) * (gamma_plus/Plate.Ly) .* (-sin(triArg_y2_odd) + (sin(0.5*gamma_plus)./sinh(0.5*gamma_plus)) .* sinh(triArg_y2_odd));
        phi_dv_x1_even	= sqrt(2) * (gamma_minus/Plate.Lx) .* (cos(triArg_x1_even) - (sin(0.5*gamma_minus)./sinh(0.5*gamma_minus)) .* cosh(triArg_x1_even));
        phi_dv_x2_even	= sqrt(2) * (gamma_minus/Plate.Lx) .* (cos(triArg_x2_even) - (sin(0.5*gamma_minus)./sinh(0.5*gamma_minus)) .* cosh(triArg_x2_even));
        phi_dv_y1_even	= sqrt(2) * (gamma_minus/Plate.Ly) .* (cos(triArg_y1_even) - (sin(0.5*gamma_minus)./sinh(0.5*gamma_minus)) .* cosh(triArg_y1_even));
        phi_dv_y2_even	= sqrt(2) * (gamma_minus/Plate.Ly) .* (cos(triArg_y2_even) - (sin(0.5*gamma_minus)./sinh(0.5*gamma_minus)) .* cosh(triArg_y2_even));
        
        % In order to get the vectors phi and phi_dv, the elements of the
        % vectors phi_even and phi_odd must be alternated:
        % phi = [phi_odd(1), phi_even(1), phi_odd(2), phi_even(2)...]
        % Attention must be paid if the vectors phi_odd and phi_even have
        % an odd length!
        phi_x1(1:2:end)		= phi_x1_odd(1:ceil(mModes/2));
        phi_x1(2:2:end)		= phi_x1_even(1:floor(mModes/2));
        phi_x2(1:2:end)		= phi_x2_odd(1:ceil(mModes/2));
        phi_x2(2:2:end)		= phi_x2_even(1:floor(mModes/2));
        phi_y1(1:2:end)		= phi_y1_odd(1:ceil(nModes/2)).';
        phi_y1(2:2:end)		= phi_y1_even(1:floor(nModes/2)).';
        phi_y2(1:2:end)		= phi_y2_odd(1:ceil(nModes/2)).';
        phi_y2(2:2:end)		= phi_y2_even(1:floor(nModes/2)).';
        phi_dv_x1(1:2:end)	= phi_dv_x1_odd(1:ceil(mModes/2));
        phi_dv_x1(2:2:end)	= phi_dv_x1_even(1:floor(mModes/2));
        phi_dv_x2(1:2:end)	= phi_dv_x2_odd(1:ceil(mModes/2));
        phi_dv_x2(2:2:end)	= phi_dv_x2_even(1:floor(mModes/2));
        phi_dv_y1(1:2:end)	= phi_dv_y1_odd(1:ceil(nModes/2)).';
        phi_dv_y1(2:2:end)	= phi_dv_y1_even(1:floor(nModes/2)).';
        phi_dv_y2(1:2:end)	= phi_dv_y2_odd(1:ceil(nModes/2)).';
        phi_dv_y2(2:2:end)	= phi_dv_y2_even(1:floor(nModes/2)).';
        
    case 'free-free'
        % Calculate values of the gamma functions (Table 9.11)
        % Gamma functions are used for the calculation of the characteristic beam
        % functions. Please note: the indices in Table 9.10 and Table 9.11 DO NOT
        % CORRESPOND! Variable gamma_i in Table 9.10 is called gamma_j in Table
        % 9.11, and vice versa. That is why they are called gamma_minus and
        % gamma_plus in this m file. Also, as the numbering is different
        % for the free-free plate, the indeces of the gamma functions also
        % change.
        maxModes		= max(mModes,nModes);
        gamma_idx		= [0 1:ceil(maxModes/2)-1];
        
        % gamma_minus are solutions of tan(0.5*gamma_minus)-tanh(0.5*gamma_minus)=0
        gamma_minus		= (4*gamma_idx+1)*pi/2;
        gamma_minus(1)	= 0;
        gamma_minus(2)	= 7.853200;
        gamma_minus(3)	= 14.13716;
        gamma_minus(4)	= 20.42040;
        gamma_minus(5)	= 26.70360;
        gamma_minus(6)	= 32.98680;
        
        % gamma_plus are solutions of tan(0.5*gamma_plus)+tanh(0.5*gamma_plus)=0
        gamma_plus		= (4*gamma_idx-1)*pi/2;
        gamma_plus(1)	= 0;
        gamma_plus(2)	= 4.730040;
        gamma_plus(3)	= 10.99560;
        gamma_plus(4)	= 17.27876;
        gamma_plus(5)	= 23.56200;
        gamma_plus(6)	= 29.84520;
        
        % Contributions of even and rocking mode.
        phi_x1_m0		= 1;
        phi_x2_m0		= 1;
        phi_y1_n0		= 1;
        phi_y2_n0		= 1;
        phi_x1_m1		= sqrt(3) * (1-2*Plate.x1/Plate.Lx);
        phi_x2_m1		= sqrt(3) * (1-2*Plate.x2/Plate.Lx);
        phi_y1_n1		= sqrt(3) * (1-2*Plate.y1/Plate.Ly);
        phi_y2_n1		= sqrt(3) * (1-2*Plate.y2/Plate.Ly);
        phi_dv_x1_m0	= 0;
        phi_dv_x2_m0	= 0;
        phi_dv_y1_n0	= 0;
        phi_dv_y2_n0	= 0;
        phi_dv_x1_m1	= -2 * sqrt(3) / Plate.Lx;
        phi_dv_x2_m1	= -2 * sqrt(3) / Plate.Lx;
        phi_dv_y1_n1	= -2 * sqrt(3) / Plate.Ly;
        phi_dv_y2_n1	= -2 * sqrt(3) / Plate.Ly;
        
        % Arguments of the trigonometric functions: gamma*(x/Lx-0.5)
        triArg_x1_odd	= gamma_plus*(Plate.x1/Plate.Lx-0.5);
        triArg_x2_odd	= gamma_plus*(Plate.x2/Plate.Lx-0.5);
        triArg_y1_odd	= gamma_plus*(Plate.y1/Plate.Ly-0.5);
        triArg_y2_odd	= gamma_plus*(Plate.y2/Plate.Ly-0.5);
        triArg_x1_even	= gamma_minus*(Plate.x1/Plate.Lx-0.5);
        triArg_x2_even	= gamma_minus*(Plate.x2/Plate.Lx-0.5);
        triArg_y1_even	= gamma_minus*(Plate.y1/Plate.Ly-0.5);
        triArg_y2_even	= gamma_minus*(Plate.y2/Plate.Ly-0.5);
        
        % Distinguish between even and odd numbers of m or n.
        phi_x1_odd		= sqrt(2) * (cos(triArg_x1_odd) - (sin(0.5*gamma_plus)./sinh(0.5*gamma_plus)) .* cosh(triArg_x1_odd));
        phi_x2_odd		= sqrt(2) * (cos(triArg_x2_odd) - (sin(0.5*gamma_plus)./sinh(0.5*gamma_plus)) .* cosh(triArg_x2_odd));
        phi_y1_odd		= sqrt(2) * (cos(triArg_y1_odd) - (sin(0.5*gamma_plus)./sinh(0.5*gamma_plus)) .* cosh(triArg_y1_odd));
        phi_y2_odd		= sqrt(2) * (cos(triArg_y2_odd) - (sin(0.5*gamma_plus)./sinh(0.5*gamma_plus)) .* cosh(triArg_y2_odd));
        phi_x1_even		= sqrt(2) * (sin(triArg_x1_even) + (sin(0.5*gamma_minus)./sinh(0.5*gamma_minus)) .* sinh(triArg_x1_even));
        phi_x2_even		= sqrt(2) * (sin(triArg_x2_even) + (sin(0.5*gamma_minus)./sinh(0.5*gamma_minus)) .* sinh(triArg_x2_even));
        phi_y1_even		= sqrt(2) * (sin(triArg_y1_even) + (sin(0.5*gamma_minus)./sinh(0.5*gamma_minus)) .* sinh(triArg_y1_even));
        phi_y2_even		= sqrt(2) * (sin(triArg_y2_even) + (sin(0.5*gamma_minus)./sinh(0.5*gamma_minus)) .* sinh(triArg_y2_even));
        phi_dv_x1_odd	= sqrt(2) * (gamma_plus/Plate.Lx) .* (-sin(triArg_x1_odd) - (sin(0.5*gamma_plus)./sinh(0.5*gamma_plus)) .* sinh(triArg_x1_odd));
        phi_dv_x2_odd	= sqrt(2) * (gamma_plus/Plate.Lx) .* (-sin(triArg_x2_odd) - (sin(0.5*gamma_plus)./sinh(0.5*gamma_plus)) .* sinh(triArg_x2_odd));
        phi_dv_y1_odd	= sqrt(2) * (gamma_plus/Plate.Ly) .* (-sin(triArg_y1_odd) - (sin(0.5*gamma_plus)./sinh(0.5*gamma_plus)) .* sinh(triArg_y1_odd));
        phi_dv_y2_odd	= sqrt(2) * (gamma_plus/Plate.Ly) .* (-sin(triArg_y2_odd) - (sin(0.5*gamma_plus)./sinh(0.5*gamma_plus)) .* sinh(triArg_y2_odd));
        phi_dv_x1_even	= sqrt(2) * (gamma_minus/Plate.Lx) .* (cos(triArg_x1_even) + (sin(0.5*gamma_minus)./sinh(0.5*gamma_minus)) .* cosh(triArg_x1_even));
        phi_dv_x2_even	= sqrt(2) * (gamma_minus/Plate.Lx) .* (cos(triArg_x2_even) + (sin(0.5*gamma_minus)./sinh(0.5*gamma_minus)) .* cosh(triArg_x2_even));
        phi_dv_y1_even	= sqrt(2) * (gamma_minus/Plate.Ly) .* (cos(triArg_y1_even) + (sin(0.5*gamma_minus)./sinh(0.5*gamma_minus)) .* cosh(triArg_y1_even));
        phi_dv_y2_even	= sqrt(2) * (gamma_minus/Plate.Ly) .* (cos(triArg_y2_even) + (sin(0.5*gamma_minus)./sinh(0.5*gamma_minus)) .* cosh(triArg_y2_even));
        
        % Assemble the beam functions evaluated at the different points
        % from the different cases (rigid body motion, even and odd modes).
        % In order to get the vectors phi and phi_dv, the elements of the
        % vectors phi_even and phi_odd must be alternated:
        % phi = [phi_rigidMotion phi_rockingMotion phi_odd(1), phi_even(1), phi_odd(2), phi_even(2)...]
        % Attention must be paid if the vectors phi_odd and phi_even have
        % an odd length!
        phi_x1(1)		= phi_x1_m0;
        phi_x1(2)		= phi_x1_m1;
        phi_x1(3:2:end)	= phi_x1_odd(2:ceil(mModes/2));
        phi_x1(4:2:end)	= phi_x1_even(2:floor(mModes/2));
        phi_x2(1)		= phi_x2_m0;
        phi_x2(2)		= phi_x2_m1;
        phi_x2(3:2:end)	= phi_x2_odd(2:ceil(mModes/2));
        phi_x2(4:2:end)	= phi_x2_even(2:floor(mModes/2));
        phi_y1(1)		= phi_y1_n0;
        phi_y1(2)		= phi_y1_n1;
        phi_y1(3:2:end)	= phi_y1_odd(2:ceil(nModes/2)).';
        phi_y1(4:2:end)	= phi_y1_even(2:floor(nModes/2)).';
        phi_y2(1)		= phi_y2_n0;
        phi_y2(2)		= phi_y2_n1;
        phi_y2(3:2:end)	= phi_y2_odd(2:ceil(nModes/2)).';
        phi_y2(4:2:end)	= phi_y2_even(2:floor(nModes/2)).';
        phi_dv_x1(1)		= phi_dv_x1_m0;
        phi_dv_x1(2)		= phi_dv_x1_m1;
        phi_dv_x1(3:2:end)	= phi_dv_x1_odd(2:ceil(mModes/2));
        phi_dv_x1(4:2:end)	= phi_dv_x1_even(2:floor(mModes/2));
        phi_dv_x2(1)		= phi_dv_x2_m0;
        phi_dv_x2(2)		= phi_dv_x2_m1;
        phi_dv_x2(3:2:end)	= phi_dv_x2_odd(2:ceil(mModes/2));
        phi_dv_x2(4:2:end)	= phi_dv_x2_even(2:floor(mModes/2));
        phi_dv_y1(1)		= phi_dv_y1_n0;
        phi_dv_y1(2)		= phi_dv_y1_n1;
        phi_dv_y1(3:2:end)	= phi_dv_y1_odd(2:ceil(nModes/2)).';
        phi_dv_y1(4:2:end)	= phi_dv_y1_even(2:floor(nModes/2)).';
        phi_dv_y2(1)		= phi_dv_y2_n0;
        phi_dv_y2(2)		= phi_dv_y2_n1;
        phi_dv_y2(3:2:end)	= phi_dv_y2_odd(2:ceil(nModes/2)).';
        phi_dv_y2(4:2:end)	= phi_dv_y2_even(2:floor(nModes/2)).';
        
    case 'clamped-free'
        error([thisFuncStr ': Specified boundary conditions are not in the database.']);
    case 'clamped-pinned'
        error([thisFuncStr ': Specified boundary conditions are not in the database.']);
    case 'free-pinned'
        error([thisFuncStr ': Specified boundary conditions are not in the database.']);
    otherwise
        error([thisFuncStr ': Specified boundary conditions are not in the database.']);
end


%% Calculate plate natural modes psi, psi_x and psi_y (Equ. 9.74)
% These are the plate natural modes evaluated at the points of excitation
% (psi___1, psi_x_1, psi_y_1) and response (psi___2, psi_x_2, psi_y_2).
psi___1	= phi_y1 * phi_x1;
psi___2	= phi_y2 * phi_x2;
psi_x_1 = phi_dv_y1 * phi_x1;
psi_x_2 = phi_dv_y2 * phi_x2;
psi_y_1 = -(phi_y1 * phi_dv_x1);
psi_y_2 = -(phi_y2 * phi_dv_x2);


%% Calculate mobilities according to Equations (9.73a-i)
% Preallocation for better performance
Y_vz_Fz = zeros(1,length(freq));	Y_vz_Mx = zeros(1,length(freq));	Y_vz_My = zeros(1,length(freq));
Y_Ox_Fz = zeros(1,length(freq));	Y_Ox_Mx = zeros(1,length(freq));	Y_Ox_My = zeros(1,length(freq));
Y_Oy_Fz = zeros(1,length(freq));	Y_Oy_Mx = zeros(1,length(freq));	Y_Oy_My = zeros(1,length(freq));

% Generate waitbar to show how much longer the calculation will need
h_fig_wait = waitbar(0,'Calculation in progress...',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
setappdata(h_fig_wait,'canceling',0)

% Calculate mobilities for each frequency bin at a time.
for idx = 1:length(freq)
    
    % Check if user has pressed the "Cancel" button and show progress.
    if getappdata(h_fig_wait,'canceling'), delete(h_fig_wait); return; end
    waitbar(idx/length(freq))
    
    % These terms are included in each of the nine mobility calculations
    % and it is therefore faster to calculate them only once.
    constFactor		= 1i * 2*pi*freq(idx) / (Plate.mPerArea*Plate.Lx*Plate.Ly);
    constDivisor	= ((2*pi*fmn).^2 .* (1+1i*Plate.lFactor(idx)) - (2*pi*repmat(freq(idx),size(fmn,1),size(fmn,2))).^2);
    
    % Equations (9.73a-i): summing up the contributions of all eigenmodes
    Y_vz_Fz(idx) = constFactor .* sum(sum((psi___1 .* psi___2) ./ constDivisor));
    Y_vz_Mx(idx) = constFactor .* sum(sum((psi_x_1 .* psi___2) ./ constDivisor));
    Y_vz_My(idx) = constFactor .* sum(sum((psi_y_1 .* psi___2) ./ constDivisor));
    Y_Ox_Fz(idx) = constFactor .* sum(sum((psi___1 .* psi_x_2) ./ constDivisor));
    Y_Ox_Mx(idx) = constFactor .* sum(sum((psi_x_1 .* psi_x_2) ./ constDivisor));
    Y_Ox_My(idx) = constFactor .* sum(sum((psi_y_1 .* psi_x_2) ./ constDivisor));
    Y_Oy_Fz(idx) = constFactor .* sum(sum((psi___1 .* psi_y_2) ./ constDivisor));
    Y_Oy_Mx(idx) = constFactor .* sum(sum((psi_x_1 .* psi_y_2) ./ constDivisor));
    Y_Oy_My(idx) = constFactor .* sum(sum((psi_y_1 .* psi_y_2) ./ constDivisor));
    
end

% Only for point mobilities, also calculate the point mobilities of an
% infinite plate (Equations 9.58a-c).
if (Plate.x1 == Plate.x2) && (Plate.y1 == Plate.y2) && Options.plotYinf == 1
    Y_vz_Fz_inf	= 1./(8*sqrt(Plate.bendStiff*Plate.mPerArea))*ones(1,length(freq));
    Y_Ox_Mx_inf = (2*pi*freq)./(16*Plate.bendStiff).*(1-(4i/pi)*log((Plate.mPerArea/Plate.bendStiff)^(0.25)*sqrt(2*pi*freq)*Plate.indenter/2));
    Y_Oy_My_inf = Y_Ox_Mx_inf;
end
delete(h_fig_wait) % use delete instead of close (see Matlab help for details)
clear h_fig_wait


%% Cleanup
clear triArg_x1_even triArg_x1_odd triArg_x2_even triArg_x2_odd triArg_y1_even triArg_y1_odd triArg_y2_even triArg_y2_odd
clear thisFuncStr maxModes idx m n qmn mModes nModes
clear phi_dv_x1 phi_dv_x1_even phi_dv_x1_odd phi_dv_x2 phi_dv_x2_even phi_dv_x2_odd
clear phi_dv_y1 phi_dv_y1_even phi_dv_y1_odd phi_dv_y2 phi_dv_y2_even phi_dv_y2_odd
clear phi_x1 phi_x1_even phi_x1_odd phi_x2 phi_x2_even phi_x2_odd
clear phi_y1 phi_y1_even phi_y1_odd phi_y2 phi_y2_even phi_y2_odd
clear phi_x1_m0 phi_x1_m1 phi_x2_m0 phi_x2_m1 phi_y1_n0 phi_y1_n1 phi_y2_n0 phi_y2_n1
clear phi_dv_x1_m0 phi_dv_x1_m1 phi_dv_x2_m0 phi_dv_x2_m1 phi_dv_y1_n0 phi_dv_y1_n1 phi_dv_y2_n0 phi_dv_y2_n1
clear psi___1 psi___2 psi_x_1 psi_x_2 psi_y_1 psi_y_2
clear Gx Gy Hx Hy Jx Jy gamma_idx gamma_minus gamma_plus
clear constFactor constDivisor


%% Plot overview of all nine mobilities
if Options.plotOverview == 1
    if exist('figure_sub2fig.m','file')
        % When using sub2fig(), subplots can be enlarged by clicking.
        h_fig_overview = figure_sub2fig();
    else
        h_fig_overview = figure();
    end
    
    % Order as in matrix notation.
    subplot(3,3,1); plot(freq,abs(Y_vz_Fz)); legend('YvzFz','Location','SouthEast')
    % 	if (Plate.x1 == Plate.x2) && (Plate.y1 == Plate.y2) && Options.plotYinf, hold all; plot(freq,abs(Y_vz_Fz_inf),'color','black'); hold off; end
    subplot(3,3,2); plot(freq,abs(Y_vz_Mx)); legend('YvzMx','Location','SouthEast')
    subplot(3,3,3); plot(freq,abs(Y_vz_My)); legend('YvzMy','Location','SouthEast')
    subplot(3,3,4); plot(freq,abs(Y_Ox_Fz)); legend('YOxFz','Location','SouthEast')
    subplot(3,3,5); plot(freq,abs(Y_Ox_Mx)); legend('YOxMx','Location','SouthEast')
    % 	if (Plate.x1 == Plate.x2) && (Plate.y1 == Plate.y2) && Options.plotYinf, hold all; plot(freq,abs(Y_Ox_Mx_inf),'color','black'); hold off; end
    subplot(3,3,6); plot(freq,abs(Y_Ox_My)); legend('YOxMy','Location','SouthEast')
    subplot(3,3,7); plot(freq,abs(Y_Oy_Fz)); legend('YOyFz','Location','SouthEast')
    subplot(3,3,8); plot(freq,abs(Y_Oy_Mx)); legend('YOyMx','Location','SouthEast')
    subplot(3,3,9); plot(freq,abs(Y_Oy_My)); legend('YOyMy','Location','SouthEast')
    % 	if (Plate.x1 == Plate.x2) && (Plate.y1 == Plate.y2) && Options.plotYinf, hold all; plot(freq,abs(Y_Oy_My_inf),'color','black'); hold off; end
    
    % Set all subplots to these limits.
    xlimits		= [10 6000];
    ylimits		= [1e-6 1e-1];
    h_axes		= findobj(h_fig_overview,'Type','axes','-not','Tag','legend');
    set(h_axes,'Xscale','log','YScale','log','xlim',xlimits,'ylim',ylimits)
    
    % Indicate eigenfrequencies by small triangles at the top of the plots.
    % Indicate fMax by black vertical line.
    % 	fmnMarkers	= sort(reshape(fmn,1,size(fmn,1)*size(fmn,2)));
    % 	for idx = 1:length(h_axes)
    % 		set(h_fig_overview,'CurrentAxes',h_axes(idx))
    % 		line(fmnMarkers,repmat(ylimits(2),1,size(fmn,1)*size(fmn,2)),'linestyle','none','marker','^')
    % 		line([fMax fMax],ylimits,'color','black','linewidth',1)
    % 	end
    % 	clear idx xlimits ylimits
end


%% Plot plate with positions of excitation and response
if Options.plotPlate == 1
    h_fig_plate = figure();
    line(Plate.x1,Plate.y1,'color','blue','linewidth',1,'linestyle','none','marker','.');
    line(Plate.x2,Plate.y2,'color','red','linewidth',1,'linestyle','none','marker','.');
    legend({'Excitation' 'Response'})
    set(gca,'xlim',[0 Plate.Lx],'ylim',[0 Plate.Ly],'PlotBoxAspectRatio',[Plate.Lx Plate.Ly 1],'xticklabel','','yticklabel','','ticklength',[0 0]);
    xlabel('Lx')
    ylabel('Ly')
    box on
end

