function varargout = ita_analytic_plane_wave_on_sphere(varargin)
%ITA_ANALYTIC_PLANE_WAVE_ON_SPHERE - sound pressure for a plane wave incident on a sphere with given surface admittance
%  This function calculates the scattered part of the sound field that results from an incoming
%  plane wave hitting a sphere with given (normalized) surface admittance.
%
%  The propagation vector of the plane wave is in z-direction [0 0 1]
%  and the origin of the plane wave is [0 0 0]
%
%  Formulas taken from Mechel: Formulas of Acoustics, page 134
%
%  Mandatory Input parameters are 
%  1) The pressure spectrum of the plane wave as itaAudio or itaResult
%  2) normalized surface admittance of the sphere as itaAudio or itaResult 
%     (has to match dataType and frequency representation of pressure spectrum of plane wave)
%  3) the fieldpoints where the resulting pressure shall be calculated as a set of itaCoordinates
%  4) the sphere radius as a numeric value.
%
%  If two output arguments are specified, the incident sound pressure is
%  also computed and returned as second output argument.
%  The total sound field (incident + scattered) can then be calculated by
%  simple addition of both outputs
% 
%  The output parameters are given as a multichannel instance of the same dataType as the input plane wave spectrum
%  The position of each channel is stored in the channelCoordinates.
%
%  Syntax:
%   audioObjOut = ita_analytic_plane_wave_on_sphere(audioObjIn,itaCoordinates,double,options)
%   [audioObjScat, audioObjInc] = ita_analytic_plane_wave_on_sphere(audioObjIn,audioObjIn,itaCoordinates,double,options)
%
%  Options (default):
%  'c' (ita_constants('c')):        speed of sound in air
%  'maxOrder' (80):                 maximum iteration index for order of Bessel, Hankel and Legendre functions
%
%  Call for example:
%   [p_scat, p_inc] = ita_analytic_plane_wave_on_sphere( ita_generate('flat',1,44100,12), ...     % pressure spectrum with ones
%                                                        ita_generate('flat',0,44100,12), ...     % admittance spectrum with zeros
%                                                        Coords, ...
%                                                        SphereRadius, ...
%                                                        'c', 343.7, ...
%                                                        'maxOrder', 80 )
%
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_analytic_plane_wave_on_sphere">doc ita_analytic_plane_wave_on_sphere</a>

% <ITA-Toolbox>
% This file is part of the application Analytic for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Marc Aretz and Markus Mueller Trapet
% Email: mar/mmt@akustik.rwth-aachen.de
% Created:  20-Feb-2011 


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% please see the documentation for more details
sArgs        = struct('pos1_p', 'itaSuper', 'pos2_normalizedSphereAdmittance', 'itaSuper', 'pos3_fieldpoints', 'itaCoordinates', 'pos4_sphereRadius', 'double', 'c', double(ita_constants('c')), 'maxOrder',80, 'direction',[0 0 1],'origin', [0 0 0]);
[input,normalizedSphereAdmittance,fieldpoints,sphereRadius,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Check for plane wave direction and turn in case it is not 0 0 1
if numel(sArgs.direction) ~= 3
    error([thisFuncStr 'plane wave direction must be a 3-element vector']);
end

if numel(sArgs.origin) ~= 3
    error([thisFuncStr 'plane wave origin must be a 3-element vector']);
end

if any(sArgs.direction(1:2) ~= 0)
    inDirection = itaCoordinates(sArgs.direction);
    delta_phi   = - inDirection.phi;
    delta_theta = - inDirection.theta;
    
    rotTheta = [cos(delta_theta)  0 sin(delta_theta); 0 1 0; -sin(delta_theta) 0 cos(delta_theta)];
    rotPhi   = [cos(delta_phi) -sin(delta_phi) 0; sin(delta_phi) cos(delta_phi) 0; 0 0 1];
    
    fieldpoints.cart = (rotTheta*rotPhi*fieldpoints.cart.').';
end

%% Check if input pressure and surface admittance have the same data representation
if ~isequal(input.freqVector, normalizedSphereAdmittance.freqVector) 
    error([thisFuncStr 'surface admittance must have the same number of frequency bins as the input object!']);
end

if numel(input) > 1 || input.nChannels > 1
    error([thisFuncStr 'one instance and channel at a time, please!']);
end
if numel(normalizedSphereAdmittance) > 1 || normalizedSphereAdmittance.nChannels > 1
    error([thisFuncStr 'one instance and channel at a time, please!']);
end

%% Other Input parameters                                    
f       = input.freqVector;                    % Frequency in Hz (column vector)
m       = 0:1:sArgs.maxOrder;                  % iteration index for order of Bessel, Hankel and Legendre functions (row vector)
c       = sArgs.c;                             % speed of sound in m/s
g       = normalizedSphereAdmittance.freq; % normalized surface admittance of sphere

%% Initialization
p_0_obj = input;
p_0     = p_0_obj.freq;
k0      = 2*pi.*f./c;
m_max   = m(end);
r       = fieldpoints.r;
theta   = fieldpoints.theta;
p_scat  = nan(numel(k0), fieldpoints.nPoints);

%% calculate p_scat for all frequencies and fixed position r,theta_rad
dFactor = DFactor(m, g, k0.*sphereRadius);

for idx = 1:fieldpoints.nPoints
    % sum all rows (m-dimension) to get column vector for all considered frequencies
    % p_inc(idxR,idxTheta,:)    = sum( repmat(                         deltaFactor(m) .* (-1i).^m .* legendrePoly( m_max, cos(theta_rad(idxR, idxTheta)) ), numel(f), 1 ) .* sph_bessel1(m, k0.*r(idxR, idxTheta)) , 2);
    if r(idx) >= sphereRadius
        % sum all rows (m-dimension) to get column vector for all considered frequencies
        p_scat(:,idx)   = sum( bsxfun(@times,bsxfun(@times,dFactor,2.*m+1),(-1i).^m .* legendrePoly( m_max, cos(theta(idx)))) .* ita_sph_besselh(m,2,k0.*r(idx)),2);
    end
end

input.freq = bsxfun(@times,p_0,p_scat);
input.channelCoordinates = fieldpoints;

%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {input}; 

if nargout > 1 % also return incident pressure
    varargout{2} = ita_analytic_plane_wave(p_0_obj,fieldpoints,'origin',sArgs.origin,'direction',sArgs.direction,'c',c);
end
%end function
end

%% Subfunctions
% Legendre Polynomial with argument cos(theta_rad): P_m(cos(theta_rad))
function y = legendrePoly(m_max,z)
m_max = round(m_max);
y = zeros(1,m_max+1);
y(1) = 1;
if m_max > 0
    y(2) = z;
    if m_max > 1
        for n=1:m_max-1 % n is the mathematical order which starts at 0
            y(n+2) = (((2*n)+1).* z .* y(n+1) - n .* y(n)) ./ (n+1);     % P(n+1) = (((2*n)+1).* z .* P(n) - n .* P(n-1))./(n+1); ACHTUNG: Indizierung in Matlab ab 1 -> deshalb y(1) = P(0)
        end
    end
end
end %function

% D Factor for scattered wave
function y = DFactor(m,g,z)
    tmp = bsxfun(@plus,-1i.*g,bsxfun(@times,1./z,m));
    y = - (tmp .* ita_sph_besselj(m,z) - ita_sph_besselj(m+1,z)) ./ (tmp .* ita_sph_besselh(m,2,z) - ita_sph_besselh(m+1,2,z));
end %function