function [varargout] = ita_get_surface_impedance(pMeasRaw, uMeasRaw, dProbeSample, varargin)
% ITA_GET_SURFACE_IMPEDANCE - calculates the surface impedance for given raw Data measured with the ITA Microflown PU-Mini Probe
% This function calculates the surface impedance for given raw Data measured with the ITA Microflown PU-Mini Probe.
% In order to calculate the surface impedance from the raw measurement data (the output of the p and u channel of
% the microflowm signal conditioner) you need to at least specify the distance between the probe and the sample.
% Many additional further parameters can be specified to include for example in-situ calibration data,
% environmental variables like temperature, adiabatic pressure etc. or more complex wavefield models to transform the
% measured field impedance at the probe to the sample surface.
%
% The following list contains all mandatory and optional parameters that can be used in this function,
% default values are marked in brackets []
%
%
%   MANDATORY INPUT PARAMETERS
%      VariableName       	Type        Values	 			Description
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% 	1) pMeasRaw           	itaAudio/itaResult   			Contains the raw data from the p-Channel of the microflown signal conditioner
%                                                           If 'fieldImp' == yes, it contains the field impedance
%
% 	2) uMeasRaw				itaAudio/itaResult  			Contains the raw data from the u-Channel of the microflown signal conditioner
%                                                           If 'fieldImp' == yes, it contains the same field impedance as passed on in input parameter 1
%
%   3) dProbeSample         double                      	Specifies distance between probe and sample surface in [m]
%
%   OPTIONAL PAIRS
%      Identifier			Type		Values				Description
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%      'gain'		     	string		['high'],'low'  	Specifies the Gain Setting on the Microflown signal conditioner
%      'correction'         string      'on',['off']    	Specifies the setting of the hardware correction switch for the velocity
% 															channel on the Microflown signal conditioner
%
%      'method'				int			[1], 2, 3			The 'method' option specifies which wave field assumption is used to transform
%															the specific impedance at the probe to the sample surface. Option numbers are given in
% 															increasing order of complexity of the models.
%															Option '1' assumes plane waves,
%															Option '2' a point source with respective mirror source and
%															Option '3' assumes a point source but accounts for the spherical reflection factor,
%															which means the reflected wavefronts are generally not spherical.
%															!!! If option 2 or 3 is chosen the distance between source and probe has to be specified
%														    	as an additional parameter.
%
%	   'dSourceSample'       double							Specifies distance between source and sample in [m]. Must be specified for 'method' 2 and 3.
%
%      'calibType'			string		'ff',['pu']			There exist two calibration types, the respective calibration data has to be specified as an
%                                                       	additional parameter (see 'calibData'):
%															1) ff:  The calibration data contains the raw p and u channel of a freefield measurement carried out with the
%																	pu-probe. Since a freefield measurement should yield aprroximately an impedance of Z_0 = rho*c = 414 kg/(s m²),
%																	this measurement can be used to correct for the freq. dependent transfer functions of probe
%                                                                   and signal conditioner. By dividing the measurement data obtained in front of a sample by the
%																	freefield measurement data we get the field impedance at the probe relative to Z_0.
% 															2) pu:  The calibration data contains absolute calibration curves for the p and u sensor in [V/Pa]
%                                                               	and [V/(m/s)] respectively. By calibrating the p and u sensor individually, we get the
%																	absolute field impedance at the probe. This is divided by Z_0 to get the relative specific impedance.
%
%	   'calibData'			cell-array	[*]					Cell array has to contain two itaAudio structs, where the first specifies the pressure calibration data and
%															the 2nd the velocity calibration data. The processing of the calibration data depends on 'calibType'
%															[*] as default calibration curves we use the analytic calibration curves specified in the
%																"Microflown Calibration Report" that was supplied by Microflown with the probe and conditioner.
%
%	   'r_ff'       		double		[-1]  				Source receiver distance [m] for the free field shot. Needs to be set, if calibType is set to 'ff'
%
%	   'temperature'		double		[20]				Temperature in [°C]. This value affects the sound speed and the equilibrium density of air, used to calculate
%															the wave number k and Z_0.
%
%	   'pressure' 			double		[101.578]			Adiabatic pressure in [Pa]. This value effects the equilibrium density of air, used to calculate Z_0.
%
%	   'angle'				double		[0]:90				Angle of incidence for the measurement of the acoustic surface impedance in [°deg]. This is needed to calculate the right
%															reflection factor and absorption coefficient from the surface impedance for angle of incidence theta_i.
%															The default value is set to '0', which means normal incidence on the measured absorber sample.
%
%      'fieldImp'           string      'yes',['no']        Set this optional parameter to 'yes' if you wanna process an already readily calculated field impedance value.
%                                                           This can be useful for test purposes.
%                                                           In this special case call:
%                                                           ita_get_surface_impedance(fieldImp, fieldImp, h, 'method', usedMethod, 'fieldImp', 'yes', 'dSourceSample', h_s );
%                                                           Since the function expects two itaAudios as first and second input, you have to pass the same field impedance as
%                                                           first and second input to the function to avoid an error
%
%	OUTPUT PARAMETERS
%		Identifier			Type		Description
%		z_surface		    itaAudio	Acoustic surface impedance relative to Z_0 for angle of incidence theta_i
%		refl				itaAudio	Reflection Factor for angle of incidence theta_i
%		alpha    			itaAudio    Acoustic Absorption coefficient for angle of incidence theta_i
%
% In the following we present different examples for the use of this function:
%
% In its simplest form just call:
%
% 	[z_surface, refl, alpha] = ita_get_surface_impedance(pMeasRaw, uMeasRaw, 2e-3)
% 	In this case we use default pressure and velocity calibration curves to calculate absolute sound pressure and velocity from
% 	the pMeasRaw and uMeasRaw itaAudio-Structs. By division of the calibrated p and u curves we get the specific impedance at the
% 	coordinates of the pu-probe. In this case we assume plane waves to transform the specific impedance to the sample surface
% 	over the distance dProbeSample.
%
% If you want to use more options you can for example call:
%
%	z_surface = ita_get_surface_impedance( ...
%                                               pMeasRaw, uMeasRaw, 2e-3, ...
%                                               'gain', 'high', 'correction', 'on', ...
%                                               'method', 2, 'dSourceSample', 1.5, , ...
%                                               'calibType', 'ff', 'calibData', {pMeas_ff, uMeas_ff})
%	In this case we use the point source - image source assumption (method 2) to transform the field impedance to the sample surface. In order to do so it is neccessary to
%   additionally specify the distance between sound source an absorber sample (dSourceSample). Instead of using the default calibration data from the microflown report, we use the
%   raw measurement data (p- and u-channel) of a freefield shot to calibrate our impedance measurement.
%
% 07.04.2010 Marc Aretz

% <ITA-Toolbox>
% This file is part of the application MicroflownImpedanceProcessor for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% input check
narginchk(3,23);

% check mandatory inputs
valid = 0;
if (isa(pMeasRaw, 'itaAudio') && isa(uMeasRaw, 'itaAudio'))
    if isequal(pMeasRaw.freqVector, uMeasRaw.freqVector)
        valid = 1;
        errormessage = '';
        usedDataType = 'itaAudio';
    else
        errormessage = ['ITA_GET_SURFACE_IMPEDANCE: AttributeList', ...
            'If p and u measurement data are of type itaAudio, they must have the same sampling rate and number of bins.'];
    end
elseif (isa(pMeasRaw, 'itaResult') && isa(uMeasRaw, 'itaResult'))
    if (strcmpi(pMeasRaw.domain, 'freq')) && (strcmpi(uMeasRaw.domain, 'freq')) && (pMeasRaw.nBins == uMeasRaw.nBins)
        valid = 1;
        errormessage = '';
        usedDataType = 'itaResult';
    else
        errormessage = ['ITA_GET_SURFACE_IMPEDANCE: AttributeList', ...
            'If p and u measurement data are of type itaResult, they must be in frequency domain with the same number of bins.'];
        
    end
else
    errormessage = ['ITA_GET_SURFACE_IMPEDANCE: AttributeList: ', ...
        'First two input parameters (for p and u measurement data) must be members of class itaAudio or itaResult.'];
end

if valid == 0
    error(errormessage);
end

if (~isnumeric(dProbeSample)) || (dProbeSample<0)
    error(['ITA_GET_SURFACE_IMPEDANCE: AttributeList: ', ...
        'dProbeSample must be numeric and >= 0.']);
end

% mandatory inputs are ok!
if strcmpi(usedDataType,'itaAudio')
    samplingRate = pMeasRaw.samplingRate;
    fIta = ita_generate('flat',0,pMeasRaw.samplingRate, pMeasRaw.fftDegree);
    fIta.freqData = fIta.freqVector;
else
    samplingRate = -1;
    fIta = itaResult(pMeasRaw.freqVector,pMeasRaw.freqVector,'freq');
end
f = pMeasRaw.freqVector;

% set and check optional inputs
[method, dSourceSample, calibType, pCalib, uCalib, r_ff, T, pressure, angle, fieldImp] = ...
    parseoptionalinput(varargin, samplingRate, f, usedDataType);

% Calculate Z0, c and rho_0
[Z0, c, rho0] = get_Z0_c_rho0(T, pressure);

if strcmpi(fieldImp, 'no')
    % get field impedance Z at measurement point relative to Z0
    if strcmpi(calibType,'pu')
        % calculate absolute pressure and velocity with calibration curves
        % then divide pressure and velocity to get the field impedance
        % then divide by Z0 to get the relative impedance
        z_field = ( (pMeasRaw/pCalib) / (uMeasRaw/uCalib) ) / Z0;
    elseif strcmpi(calibType, 'ff')
        % Calculate the uncalibrated field impedance and the uncalibrated
        % freefield impedance.
        % The division of the two directly yields the relative field impedance,
        % the influence of the measurement chain is eliminated, if it was the
        % same for both measurements
        % Attention: the free field shot method has the inherent assumption
        % that the freefield shot is proportional to Z0. This is however
        % not the case, if the source receiver distance is small, due to
        % effects of the then spherical wave fronts. We therefore apply a
        % correction term (see diploma thesis of Jan Van Gemmeren p.32 for more details.)
        if r_ff>0
            ZsphWave   = (pCalib/uCalib);
            ZplaneWave = ZsphWave * ( 1 + 1/(1i*r_ff*2*pi*fIta/c) );
            z_field = (pMeasRaw/uMeasRaw) / ZplaneWave;
        else
            error(['ITA_GET_SURFACE_IMPEDANCE: If you use a free field shot calibration'...
                ' you have to specify the according source receiver distance from the freefield shot!']);
        end
    end
elseif strcmpi(fieldImp, 'yes')
    z_field = pMeasRaw;   % first input argument is already field impedance
end

% if z_field.timeData(1) < 0
%     ita_verbose_info('be careful phase is 180 degree, turning for you...',0)
%     z_field = -z_field;
% end

% Transform the relative field impedance to the sample surface
z_surface = impedance_transformation(z_field, method, dProbeSample, dSourceSample, c);

% Calculate reflection factor and absorption coefficient depending on angle
% of incidence

refl  = (z_surface'*cos(angle/180*pi) - 1) / (z_surface'*cos(angle/180*pi) + 1);
alpha = 1 - (abs(refl'))^2;

%% find output
if nargout == 1
    varargout = {z_surface};
elseif nargout == 2
    varargout = {z_surface, refl};
elseif nargout == 3
    varargout = {z_surface, refl, alpha};
else
    error(['ITA_GET_SURFACE_IMPEDANCE: OutputArgs: ', ...
        'Invalid numer of output arguments. Must be 1, 2 or 3']);
end

end %function ita_get_surface_impedance

function [method, dSourceSample, calibType, pCalib, uCalib, r_ff, T, pressure, angle, fieldImp] = ...
    parseoptionalinput(varargin, samplingRate, f, usedDataType)

% Set default values
gain          = 'high';
correction    = 'off';
method        =  1;
dSourceSample  = -1;
calibType     = 'pu';
r_ff          = -1;
T             = 20; % °C
pressure      = 101.578; % Pa
angle         = 0; % °deg
fieldImp      = 'no';
externalCalib = 0; % boolean

% varargin=varargin{:};

attributes    = {'method', 'dsourcesample', 'calibtype', 'calibdata', 'r_ff', 'temperature', 'pressure', 'angle', 'fieldimp','gain','correction'};

stringoptions = lower(varargin(cellfun('isclass',varargin,'char')));
attributeindexesinoptionlist = ismember(stringoptions,attributes);
newinputform = any(attributeindexesinoptionlist);
if newinputform
    i=1;
    while i<length(varargin)
        if  (~ismember(lower(varargin{i}),attributes))
            error(['ITA_GET_SURFACE_IMPEDANCE: AttributeList: ', ...
                'Invalid attribute %s in parameter list'], varargin{i})
        end
        if strcmpi(varargin{i},'gain')
            if ismember(lower(varargin{i+1}),{'high','low'})
                gain = lower(varargin{i+1});
            else
                error('ITA_GET_SURFACE_IMPEDANCE: AttributeList: Invalid entry for gain setting.')
            end
        elseif strcmpi(varargin{i},'correction')
            if ismember(lower(varargin{i+1}),{'on','off'})
                correction = lower(varargin{i+1});
            else
                error('ITA_GET_SURFACE_IMPEDANCE: AttributeList: Invalid entry for correction setting.')
            end
        elseif strcmpi(varargin{i},'method')
            if isnumeric(varargin{i+1}) && (ismember(varargin{i+1}, [1,2,3]))
                method = varargin{i+1};
            else
                error('ITA_GET_SURFACE_IMPEDANCE: AttributeList: Invalid method. Must be 1,2 or 3.')
            end
        elseif strcmpi(varargin{i},'dsourcesample')
            if (isnumeric(varargin{i+1})) && (varargin{i+1}>0)
                dSourceSample = varargin{i+1};
            else
                error('ITA_GET_SURFACE_IMPEDANCE: AttributeList: Invalid entry for dSourceSample.')
            end
        elseif strcmpi(varargin{i},'calibtype')
            if ismember(lower(varargin{i+1}),{'ff','pu'})
                calibType = lower(varargin{i+1});
            else
                error('ITA_GET_SURFACE_IMPEDANCE: AttributeList: Invalid entry for calibType.')
            end
        elseif strcmpi(varargin{i},'calibdata')
            if iscell(varargin{i+1}) && numel(varargin{i+1})==2 && ...
                    isa(varargin{i+1}{1}, usedDataType) && isa(varargin{i+1}{2}, usedDataType)
                pCalib = varargin{i+1}{1};
                uCalib = varargin{i+1}{2};
                externalCalib = 1;
                if ~( isequal(pCalib.freqVector,f) && isequal(uCalib.freqVector, f))
                    error(['ITA_GET_SURFACE_IMPEDANCE:AttributeList: ', ...
                        'Calibration data must have the same data type and frequency vector ', ...
                        'as the measurement data.'])
                end
            else
                error('ITA_GET_SURFACE_IMPEDANCE: AttributeList: Calibration data must have the same data type as the measurement data.')
            end
        elseif strcmpi(varargin{i},'r_ff')
            if (isnumeric(varargin{i+1}))
                r_ff = varargin{i+1};
            else
                error('ITA_GET_SURFACE_IMPEDANCE: AttributeList: Invalid entry for r_ff.')
            end
        elseif strcmpi(varargin{i},'temperature')
            if (isnumeric(varargin{i+1}))
                T = varargin{i+1};
            else
                error('ITA_GET_SURFACE_IMPEDANCE: AttributeList: Invalid entry for temperature.')
            end
        elseif strcmpi(varargin{i},'pressure')
            if (isnumeric(varargin{i+1}))
                pressure = varargin{i+1};
            else
                error('ITA_GET_SURFACE_IMPEDANCE: AttributeList: Invalid entry for adiabatic pressure.')
            end
        elseif strcmpi(varargin{i},'angle')
            if (isnumeric(varargin{i+1})) && varargin{i+1}>=0 && varargin{i+1}<90
                angle = varargin{i+1};
            else
                error('ITA_GET_SURFACE_IMPEDANCE: AttributeList: Invalid entry for angle of incidence.')
            end
        elseif strcmpi(varargin{i},'fieldimp')
            if ismember(lower(varargin{i+1}),{'yes','no'})
                fieldImp = lower(varargin{i+1});
            else
                error('ITA_GET_SURFACE_IMPEDANCE: AttributeList: Invalid entry for fieldImp option.')
            end
            
        end
        i=i+2;
    end
end

if ~externalCalib
    % Calculate default sensitivity curves (as given in microflown calibration report)
    
    if strcmpi(usedDataType, 'itaAudio')
        pCalib = itaAudio();
        pCalib.samplingRate = samplingRate;
        uCalib = itaAudio();
        uCalib.samplingRate = samplingRate;
    elseif strcmpi(usedDataType, 'itaResult')
        pCalib = itaResult(zeros(length(f),1), f, 'freq');
        uCalib = itaResult(zeros(length(f),1), f, 'freq');
    end
    % Pressure Sensor calibration
    % ---------------------------------------------------------------------
    Sp_1kHz = 60.6e-3; % [V/Pa]
    f_c1p   = 27;      % [Hz]
    f_c2p   = 10;      % [Hz]
    f_c3p   = 5945;    % [Hz]
    C_1p    = 24;      % [Hz]
    C_2p    = 15;      % [Hz]
    C_3p    = 21826;   % [Hz]
    
    
    S_p   = Sp_1kHz .* ( sqrt(1 + (f.^2./f_c3p.^2)) ) ./ ...
        ( sqrt(1 + (f_c1p.^2./f.^2)) .* sqrt(1 + (f_c2p.^2./f.^2)) );
    
    phi_p = atan(C_1p./f) + atan(C_2p./f) + atan(f./C_3p);
    
    % pressure sensitivity curve
    pCalib.freqData = S_p .* exp(1i.*phi_p);
    
    % Velocity Sensor calibration
    % ---------------------------------------------------------------------
    if strcmpi(gain, 'high')
        Su_250Hz = 65.15;  % [V/(m/s)]
    elseif strcmpi(gain, 'low')
        Su_250Hz = 0.5175; % [V/(m/s)]
    end
    
    f_c1u   = 6;       % [Hz]
    f_c2u   = 891;     % [Hz]
    f_c3u   = 9979;    % [Hz]
    f_c4u   = 25;      % [Hz]
    C_1u    = 1;       % [Hz]
    C_2u    = 820;     % [Hz]
    C_3u    = 14430;   % [Hz]
    C_4u    = 25;      % [Hz]
    
    if strcmpi(correction, 'off')
        S_u   = Su_250Hz ./ ( sqrt(1 + (f_c1u.^2./f.^2)) .* sqrt(1 + (f.^2./f_c2u.^2)) .* ...
            sqrt(1 + (f.^2./f_c3u.^2)) .* sqrt(1 + (f_c4u.^2./f.^2)) );
        phi_u = atan(C_1u./f) - atan(f./C_2u) - atan(f./C_3u) + atan(C_4u./f);
    elseif strcmpi(correction, 'on')
        S_u   = Su_250Hz ./ ( sqrt(1 + (f_c1u.^2./f.^2)) .* sqrt(1 + (f_c4u.^2./f.^2)) );
        phi_u = atan(C_1u./f) + atan(C_4u./f);
    end
    
    % velocity sensitivity curve
    uCalib.freqData = S_u .* exp(1i.*phi_u);
end

end %function parseoptionalinput

function [Z0, c, rho0] = get_Z0_c_rho0(T, p)
% Calculate Z0 as a function of temperature T [°C] and adiabatic
% pressure p [Pa] and return it as itaValue Z0

% Calculate speed of sound and equilibrium density
c = 331.4 + 0.6*T;
specific_gas_constant = 287.05; % for dry air in [J/(kg*K)]
absolute_temperature = 273.16 + T; % in Kelvin
rho0 = p * 1e3/(specific_gas_constant * absolute_temperature); % rho= = 1.205 kg/m^3 for T=20°C
Z0 = itaValue( rho0 * c, 'kg/(s m^2)' );

end %function get_Z0_c_rho0

function z_surface = impedance_transformation(z_field, method, dProbeSample, dSourceSample, c)
% Calculate surface impedance at sample surface from field impedance at
% measurement point. Three different methods exist which make different
% assumptions on the sound field. See docu of main function for more
% details on the three methods

% initialization
z_surface = z_field;
z_surface.freqData = zeros(z_surface.nBins, z_surface.nChannels);

f   = z_field.freqVector;
k   = 2*pi*f./c;            %wave number
h   = dProbeSample;
h_s = dSourceSample;

% All formulas are taken from the paper:
% Alvarez, J.D. and Jacobsen, F.:
% An Iterative Method for Determining the Surface Impedance of Acoustic Materials In Situ
% Internoise 2008
% The numbers of the formulas in the paper are given as comments behind the
% formulas in the code

if method == 1
    % plane wave assumption, only phase correction neccessary
    refl               = (z_field.freqData - 1)./(z_field.freqData + 1) .* exp(2.*1i.*k.*h); % (2)
    z_surface.freqData = (1 + refl)./(1 - refl);                          % (3)
    
elseif method == 2
    % Image Source Model with Plane Wave Reflection Factor
    a1                 = z_field.freqData .* (1./(1i.*k.*(h_s - h)) + 1);                    %
    a2                 = z_field.freqData .* (1./(1i.*k.*(h_s + h)) + 1);                    %
    refl               = (a1 - 1)./(a2 + 1) .* (h_s + h)./(h_s - h) .* exp(2.*1i.*k.*h);     % (5)
    z_surface.freqData = (1i.*k.*h_s)./(1i.*k.*h_s + 1) .* ...
        (1 + refl)./(1 - refl);                % (6)
    
elseif method == 3
    % Image Source Model with Spherical Reflection Factor, iterative
    
    % Start value for surface impedance iteration calculated with method 2
    a1                 = z_field.freqData .* (1./(1i.*k.*(h_s - h)) + 1);                    %
    a2                 = z_field.freqData .* (1./(1i.*k.*(h_s + h)) + 1);                    %
    refl               = (a1 - 1)./(a2 + 1) .* (h_s + h)./(h_s - h) .* exp(2.*1i.*k.*h);     % (5)
    z_init             = (1i.*k.*h_s)./(1i.*k.*h_s + 1) .* ...
        (1 + refl)./(1 - refl);                                  % (6)
    
    % tolerance values
    delta   =  1e-12; % tolerance for change in x-value
    epsilon =  1e-12; % tolerance for error function f11
    disper  =  1e-9; % x-value variation for approximation of inverse of derivative of f11
    maxIt   =  20;    % max. Anzahl der Iterationen
    zMmat   = z_field.freqData; % pdi: pre-calc,speed reason
    z_surface_freqData = zMmat;
    for x = 1:length(f)
        
        % initialization for secant method (initial vlaues for surf. imp. and equation (11))
        zM        = zMmat(x);
        zK        = z_init(x);
        kx        = k(x);
        
        if ~any( isnan([zM, zK]) | isinf([zM,zK]) )
            f_zK      = f11(zK, zM, kx, h_s, h);  % Evaluate formula (11) from Jacobsen paper
            secCoeff = get_sec_coeff(zK, zM, kx, h_s, h, disper);
            
            curIt     = 1;
            
            while ( ( abs(f_zK)     > epsilon ) || ...
                    ( abs(secCoeff.*f_zK) > delta ) )   && ...
                    ( curIt <= maxIt )
                
                zKplus1 = zK - secCoeff.*f_zK;                      % (12)
                
                % update zK for next iteration step
                zK      = zKplus1;
                % update values for secant method
                f_zK      = f11(zK, zM, kx, h_s, h);  % Evaluate formula (11) from Jacobsen paper
                secCoeff  = get_sec_coeff(zK, zM, kx, h_s, h, disper);
                
                % increment iterationStep
                curIt = curIt+1;
            end
            
            if curIt == maxIt
                disp(['ITA_GET_SURFACE_IMPEDANCE: Iteration stopped, because max iteration step reached.', ...
                    'Unreliable results for f = ' num2str(f(x)) ' Hz.']);
            end
            
            z_surface_freqData(x,1) = zKplus1;
        else
            z_surface_freqData(x,1) = NaN;
            disp(['ITA_GET_SURFACE_IMPEDANCE: Cannot perform iteration for f = ' num2str(f(x)) ' Hz.', ...
                ' NaN or Inf values occured in calculation']);
        end
        
    end %for-loop
    z_surface.freqData = z_surface_freqData;
    
end

end %function impedance_transformation

function f_z = f11(z, z_m, k, h_s, h)
% calculates formula (11) of Jacobsen paper

z = double(z);
z_m = double(z_m);

% precalculations for formula (11)
d =  exp(-1i.*k.*(h_s-h))./(h_s-h);
a = ( (1 ./ ( 1i.*k.*(h_s-h) ) ) + 1 );
e =  exp(-1i.*k.*(h_s+h))./(h_s+h);
b = ( (1 ./ ( 1i.*k.*(h_s+h) ) ) + 1 );
expint_pre = expint( 1i.*k .* (h_s+h) .* (z+1)./z );

% antiderivatives for the integrals in equations 11a (int1) and 11b (int2)
% derivations of this formula: siehe Unterlagen
int1 = 1i*exp( 1i.*k.*(h_s+h)./z ) .* ...
    expint_pre;
int2 = exp( 1i.*k.*(h_s+h)./z ) .* ...
    ( -1i./z .* expint_pre + ...
    1./k .* exp(-1i.*k .* (h_s+h) .* (z+1)./z) ./ (h_s+h) ...
    );

f_z = z_m - ( d + e  - 2.*k./z .* int1 ) ./ ...
    ( d.*a - e.*b + 2.*k./z .* int2 );

end %function f11

function secCoeff = get_sec_coeff(z, z_m, k, h_s, h, disper)
% calculate coefficient for secant method,
% this coefficient is an approximation of the inverse of the
% derivative of the function f11 at z = zK

z = double(z);
z_m = double(z_m);

secCoeff = (2.*disper) ./ ...
    ( f11(z+disper, z_m, k, h_s, h) - f11(z-disper, z_m, k, h_s, h) );

end %function get_sec_coeff
