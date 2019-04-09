function varargout =  ita_constants( varargin )
%ITA_CONSTANTS - Calculate acoustic constants
%
%  Syntax: varargout = ita_constants(what, Options)
%       Options (default):
%       medium (air):   medium of interest
%       T (293.16):     temperatur in K or C (Values below 100 will be interpreted as C)
%       f (1000):       Frequency of interrest (only affects m) can be a vector
%       p (101325):     static pressure in Pa
%       phi (0.1):      relative humidity [0 - 1]
%
%       Example:    c      = ita_constants('c');
%                   [c, m] = ita_constants({'c','m'},'medium','air', 'T', 15, 'f',[100 200 400 1000], 'p', 101300);
%
%       Currently supportet constants:
%                   all - returns structure with all constants
%                   c - speed of sound
%                   m - attenuation constant
%                   rho_0 - density
%                   z_0 = rho_0 * c - characteristic impedance
%                   p_b or p_0 - reference pressure for calculation of sound pressure level
%
%       (air atenuation according to ISO 9613-1 and paper by Bass, et al.,
%       "Atmospheric absorption of sound", JASA, January 1995.)
%
%   See also ita_roomacoustics, itaValue
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_sabine">doc ita_sabine</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  02-Feb-2009

%% Get ITA Toolbox preferences and Function String
sArgs = struct('pos1_what','anything','medium','air','T',293.16,'f',1000,'p',101325, 'phi', 0.5);
%                                                  Temperature,
%                                                  Frequency, Static air pressure, Rel. Humidity
thisFuncStr  = [upper(mfilename) ':'];
if nargin > 0
    sArgs = ita_parse_arguments(sArgs,varargin);
else
    sArgs.what = {'all'};
end

if ischar(sArgs.what)
    sArgs.what = {sArgs.what};
end

if sArgs.T < 100
    sArgs.T = 273.15 + sArgs.T; %Celsius to Kelvin
    ita_verbose_info([thisFuncStr 'conversion of Celsius to Kelvin.'],1)
end

if sArgs.phi > 1 || sArgs.phi < 0
    error('Invalid range for relative humidity PHI. It has to be in range 0...1.')
end

sArgs.f   = itaValue(sArgs.f,'Hz');
sArgs.T   = itaValue(sArgs.T,'K');
sArgs.p   = itaValue(sArgs.p,'Pa');
sArgs.phi = itaValue(sArgs.phi,'');

persistent constants

if ~isempty(constants)
    tEqual = false;
    if numel(double(constants.T)) == numel(double(sArgs.T)) && all(double(constants.T) == double(sArgs.T))
        tEqual = true;
    end
    
    phiEqual = false;
    if numel(double(constants.phi)) == numel(double(sArgs.phi)) && all(double(constants.phi) == double(sArgs.phi))
        phiEqual = true;
    end
    
    fEqual = false;
    if numel(double(constants.f)) == numel(double(sArgs.f)) && all(double(constants.f) == double(sArgs.f))
        fEqual = true;
    end
    
    pEqual = false;
    if numel(double(constants.p_stat)) == numel(double(sArgs.p)) && all(double(constants.p_stat) == double(sArgs.p))
        pEqual = true;
    end
    allIsWell = tEqual && phiEqual && fEqual && pEqual;
else
    allIsWell = false;
end

if ~allIsWell %pdi: performance reasons
    
    %% set some constants
    switch lower(sArgs.medium)
        case {'luft','air'}
            T_0   = itaValue(273.15,'K'); % Zero-Temperature (in K)
            T_r   = itaValue(20,'K') + T_0; % Reference Temperature (equiv. 20 C)
            p_r   = itaValue(101325,'Pa'); % Reference static pressure (in Pa)
            % calculate molar concentration of water (h) in air (in percent)
            % use new version
            V = -6.8346*(T_0/sArgs.T)^1.261+4.6151;
            p_sat = p_r*10^V; % stauration vapor pressure
            h = 100*sArgs.phi*p_sat/sArgs.p; % molar concentration of water vapor in percent
            M_r = itaValue(0.0289644,'kg/mol'); % molar mass of dry air
            R_mol = itaValue(8.31,'N m/(mol*K)'); % molar gas constant for air
            R_l = R_mol/M_r; % [J/(kg*K)] gas constant for dry air
            R_d = itaValue(461,'J/kg*K'); % gas constant of water vapor
            R_f = R_l/(1-(h/100)*(1-R_l/R_d)); % [J/(kg K)] gas constant for air with relative humidity phi
            kappa = 1.4; % heat capacity ratio
            nu = itaValue(0.0261,'W/(m*K)');%#ok<NASGU> % heat conductivity
            C_v = itaValue(718,'J/(kg*K)');%#ok<NASGU> % specific heat capacity
            rho_0 = sArgs.p/(R_f*sArgs.T); % air density
            eta = itaValue(17.1*1e-6,'Pa*s');%#ok<NASGU> % air viscosity (at 273K)
            p_b = itaValue(2*10^(-5),'Pa');% - reference pressure for SPL
            
        otherwise
            error([thisFuncStr ' I dont know that medium yet, please teach me!']);
    end
    
    %% include input parameter T, phi, f and p_stat
    constants.T   = sArgs.T;
    constants.phi = sArgs.phi;
    constants.f = sArgs.f;
    constants.p_stat = sArgs.p;
    
    %% Speed of sound
    constants.c = sqrt(kappa*R_f*sArgs.T);
    c = constants.c;
    
    %% Air attenuation
    % the formulas are according to Bass, the units really do not make sense
    % relaxation frequencies for oxygen and nitrogen (dimensionless ???)
    frO = double((sArgs.p/p_r).*(24 + 4.04e4.*h.*(0.02 + h)./(0.391 + h)));
    frN = double((sArgs.p./p_r).*(sArgs.T./T_r).^(-1/2).*(9 + 280.*h.*exp(-4.17.*((sArgs.T./T_r).^(-1/3) - 1))));
    
    % m (1/m), factor 2 comes from conversion Neper -> dB -> linear
    m = 2.*double(sArgs.f).^2.*(double(1.84e-11.*double(p_r./sArgs.p).*double(sArgs.T/T_r)^(1/2)) + ...
        double(sArgs.T/T_r)^(-5/2).*(0.01275.*exp(-2239.1./double(sArgs.T)).*frO./(frO.^2 + double(sArgs.f).^2) + ...
        0.1068.*exp(-3352./double(sArgs.T)).*frN./(frN.^2+double(sArgs.f).^2)));
    
    % this is a linear factor, to convert to dB/m multiply by 10*log10(e)=4.34
    constants.m = itaValue(m,'1/m');
    
    %% Density
    constants.rho_0 = rho_0;
    
    %% Z_0
    constants.z_0 = rho_0*c;
    
    %% p_b
    constants.p_b = p_b;
    constants.p_0 = p_b;
    
    %% P_0/P_b
    constants.P_b = itaValue(1e-12,'W');
    constants.P_0 = itaValue(1e-12,'W');
    
end

%% set output arguments
if ~nargout
    % plot that thang!
    disp('Your constants are:');
    fields = fieldnames(constants);
    fieldStr = char(fields);
    constantsStr = cell(numel(fields),1);
    for i=1:numel(fields)
        cons = constants.(fields{i});
        if numel(cons.value) > 1
            constantsStr{i} = ['<' num2str(numel(cons.value)) ' values> ' cons.unit];
        else
            constantsStr{i} = num2str(cons);
        end
    end
    disp([fieldStr repmat('  :  ',numel(fields),1) char(constantsStr)]);
end

for idx = 1:numel(sArgs.what)
    if isfield(constants,lower(sArgs.what{idx}))
        varargout{idx} = constants.(sArgs.what{idx}); %#ok<AGROW>
    elseif strcmpi(sArgs.what{idx},'all')
        varargout{idx} = constants; %#ok<AGROW>
    else
        error([thisFuncStr ' I dont know that constant yet, please teach me!']);
    end
    
end

