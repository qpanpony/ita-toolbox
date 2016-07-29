function varargout = ita_tubeimpedance_transformation(varargin)
%ITA_TUBEIMPEDANCE_TRANSFORMATION - Transmission line impedance transformation for tubes
%  This function transforms the input impedance of a tube into the load impedance,
%  resp. the load impedance of a tube into the input impedance, according to the
%  transmission line theory. For small tubes (diameter 20mm and smaller), 
%  a lossy transformation will be executed.
%
%  There are two cases:
%   1.  The (load) impedance Z(0) is known, so the (input) impedance Z(l) 
%       one would see at x=l has to be computed.
%   2.  The (input) impedance Z(l) is known, so the (load) impedance Z(0) 
%       at x=0 (which would cause Z(l) )has to be computed.
%
%  Instructions for the two cases:
%   Case 1:
%       Specify the length with a positive sign.
%   Case 2:
%       Specify the length with a negative sign.
%
%  Sketch (One is looking from the l plane into the transmission line):
%
%           | x=l (l plane)                     | x=0 (0 plane)
%           |___________________________________|
%           |                                   |
%   Input imp       >>> negative l >>>          Load imp
%   Z(l)    |       <<< positive l <<<          Z(0)
%           |___________________________________|
%           |                                   |
%
%
%  Call: Z_trans = ita_tubeimpedance_transformation(Z_known, diameter, length, temp, [option])
%     Z_known  : itaAudio
%     diameter : numeric in [m]
%     length   : numeric in [m]
%     temp     : numeric in [�C]
%     option   : optional string ('lossless' for transformation type override)
%
%  Example:
%      Z_0 = ita_make_impedance('Z_0',100,44100,16);            % Load impedance
%      Z_L = ita_tubeimpedance_transformation(Z_0,0.03,0.01,30);% Get input impedance
%
%
%   Note: Keep in mind that due to the numerical computation, slight 
%   errors occur, which grow with the value of the transformed impedance. 
%   Try for instance:
%
%   Z_0     = ita_make_impedance('Z_0',inf,44100,16);
%   Z_L     = ita_tubeimpedance_transformation(Z_0,0.03,0.01,30);
%   Z_0_new = ita_tubeimpedance_transformation(Z_L,0.03,-0.01,30);
%   ita_plot_spk(Z_0_new);
%
%   You will will see spots where Z_0_new is not exactly inf (but in the
%   range of 400dB, which is probably almost inf...). This is worse for the
%   lossy transformation.
%
%   The formulas for the lossy transformation for small tubes were taken
%   from 'Mathematical predictions of electroacoustic frequency response of
%   in situ hearing aids' by David P. Egolf (J. Acoust. Soc. Am. 63, 264-271, (1978)).
%
%
%   See also ita_impedance_parallel, ita_make_impedance.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_impedance_transformation">doc ita_impedance_transformation</a>

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Johannes Klein -- Email: johannes.klein@akustik.rwth-aachen.de
% Created:  04-Mar-2009
% Modified: 10-Mar-2009 - klein - Vast performance improvement
% Modified: 21-Jun-2009 - klein - Introducing lossy transmission, work in progress
% Modified: 26-Jun-2009 - klein - Lossy transmission, work pretty much done

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(4,5);
sArgs        = struct('pos1_Z_known','itaAudio','pos2_diameter','integer','pos3_length','integer','pos4_temp','integer','pos5_option','anything');
[Z_known,diameter,length,temp,option,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

if ~ischar(option)
    clear option;
    option  =   'none';
end

%% Paramters - TODO: Outsource computing of std. parameters (see also "medium constants" for lossy transformation below)- klein
% Probe constants
radius  =   diameter/2;

%
density     =   1.1769*(1-0.00335*(temp-26.85));
velocity    =   347.23*(1+0.00166*(temp-26.85));
f           =   Z_known.freqVector;
f(1,1)      =   1;                                  % Brute force fix to prevent division by zero later on.
                                                    % This does not matter, because the first bin will be set to zero at the end.
omega       =   2*pi*f;

%% Preparations for resulting itaAudio
original_name                   =   Z_known.comment;
Z_trans                         =   ita_generate('flat',1,Z_known.samplingRate,Z_known.fftDegree);
Z_trans.channelUnits{1}  =   'kg/s m^2';
Z_trans.comment          =   [original_name '(trans)'];
Z_trans.channelNames{1}  =   Z_trans.comment;

nBins                           =   Z_known.nBins;

if diameter > 2e-2 || strcmp(option, 'lossless')
    %% Transformation for big tubes
    % Abbreviations
    k       =   omega./velocity;
    sine    =   sin(k.*length);
    cosine  =   cos(k.*length);
    
    % Characteristic impedance of the tube  
    Z_c     =   ones(1,nBins).*density.*velocity;
    
    % Transformation components
    b2 = 1i;
    a2 = 1i;
    
else
    %% Transformation for small tubes
    
    % Medium constants
    sigma   =   (0.8410*(1-0.0002*(temp-26.85)))^2;                                         % Prandtl number of fluid medium
    mu      =   ((temp+273.15)/273.15)^1.5*(273.15+110.4)/(temp + 273.15 + 110.4)*1.71e-5;  % Dynamic (absolute) viscosity
    ratio   =   1.4017*(1-0.00002*(temp-26.85));                                            % Ratio of specific heats of the fluid medium (c_p/c_v)
    
    % Propagation constants
    alpha   =   sqrt(-1i.*omega.*density.*sigma./mu);   % Attenuation part of propagation operator
    beta    =   sqrt(-1i.*omega.*density./mu);          % Phase part of propagation operator
    
    % Abbreviations
    ar  =   alpha.*radius;
    br  =   beta.*radius;
    
    % Propagation operator    
    gamma_pre   =   1i.*omega./velocity;                                    % Prefactor of gamma equation
    gamma_num   =   1+2.*(ratio-1).*((bessel(1,ar))./(ar.*bessel(0,ar)));   % Inner numerator of gamma equation
    gamma_den   =   1-(2.*bessel(1,br))./(br.*bessel(0,br));                % Inner denominator of gamma equation
    gamma       =   gamma_pre.*sqrt(gamma_num./gamma_den);                  % Complete gamma
    
    % Characteristic impedance of the tube    
    Z_c_pre     =   (density.*velocity);                                % Prefactor of Z_c equation
    Z_c_first   =   1-(2.*bessel(1,br))./(br.*bessel(0,br));            % First inner factor if Z_c equation
    Z_c_second  =   1+(2.*(ratio-1).*bessel(1,ar))./(ar.*bessel(0,ar)); % Secondinner factor if Z_c equation
    Z_c         =   Z_c_pre./sqrt(Z_c_first.*Z_c_second);               % Complete gamma

    % Further abbreviations
    sine    = sinh(gamma.*length);
    cosine  = cosh(gamma.*length);
    
    % Transformation components
    b2 = 1; % Contrary to lossless no factor "1i"
    a2 = 1; % Contrary to lossless no factor "1i"

end


%% Computation of Z_trans   
% In case of Z_known=inf, Z_known is not needed for the computation of the
% resulting element. A simplified equation is used:
% (Z_trans.spk=dens*vel*cos_kl/sin_kl) or
% (Z_trans.spk=dens*vel*cosh_gl/sinh_gl), respectively .

fin_vec                 =   ~isinf(Z_known.spk);    % Vector with "1" at finite positons of Z_known
Z_known.spk(~fin_vec)   =   1;                      % Set inf Z_known elements to 1 (see explanation above)

b0 = Z_c;
b1 = Z_known.spk;
b2 = b2.*Z_c;
a1 = Z_c;
a2 = a2.*Z_known.spk; 
    
b2          =   b2.*fin_vec;    % Set elements at Z_known=inf positions to 0 (simplification, see explanation above)
a1          =   a1.*fin_vec;    % Set elements at Z_known=inf positions to 0 (simplification, see explanation above)
    
Z_trans.spk = b0.*(b1.*cosine+b2.*sine)./(a1.*cosine+a2.*sine); % The final formula
    
%% Check for zero frequency
Z_trans.spk(:,1) = 0;

%% Check for Nyquist
Z_trans.spk(:,end) = real(Z_trans.spk(:,end));

%% Add history line
Z_trans.header = ita_metainfo_add_historyline(Z_trans.header,mfilename,varargin);

%% Check header
Z_trans = ita_metainfo_check(Z_trans);

%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
    Z_medium    =   ita_generate('flat',(density*velocity),44100,Z_trans.fftDegree);
    Z_medium.comment           =   'Z(medium)';
    Z_medium.channelNames{1}   =   Z_medium.comment;
    ita_plot_freq_phase(Z_trans/Z_medium);
else
    % Write Data
    varargout(1) = {Z_trans}; 
end

%end function
end