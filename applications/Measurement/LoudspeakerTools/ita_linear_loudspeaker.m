function varargout = ita_linear_loudspeaker(varargin)
%ITA_LINEAR_LOUDSPEAKER
% 
%  Generates electrical impedance, displacement TF, sound pressure level
%  and acoustic power of a transducer specified by the input Thiele-Small
%  Parameters.
%
%  Syntax:
%   [Z Hx p Pac] = ita_linear_loudspeaker(TS, options)
%
%   Options (default):
%           'samplingRate' (44100)  : samplingRate
%           'fftDegree' (18)        : fftDegree
%           'Zs'                    : radiation impedance, if none is given
%                                     approximations are used
%           'membraneType'('piston'): membrane shape
%           'd'                     : distance from the LS for SPL estimation
%                                     can also be a itaAudio file
%                                     containing an SPL measurement
%           'c' (ita_constants('c')): speed of sound
%           'Z_0' (ita_constants('z_0')): characteristic impedance of air
%
%  Example:
%   [Z Hx p Pac] = (TS, 'samplingRate', 44100, 'fftDegree', 18);
%
%  See also:
%   ita_thiele_small, ita_thiele_small_fit, ita_radiation_impedance, ita_generate, ita_differentiate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_linear_loudspeaker">doc ita_linear_loudspeaker</a>

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Marco Berzborn -- Email: marco.berzborn@rwth-aachen.de
% Created:  23-Jan-2014 

%% check input
sArgs = struct('pos1_TS', '*', 'samplingRate', ita_preferences('samplingRate'), 'fftDegree', ita_preferences('fftDegree'), 'Zs', [], 'd', itaValue(1, 'm'), 'membraneType', 'piston','c',ita_constants('c'),'Z_0',ita_constants('z_0'));
[TS, sArgs] = ita_parse_arguments(sArgs, varargin);
imp = ita_generate('impulse', 1, sArgs.samplingRate, sArgs.fftDegree);
freqVector = imp.freqVector;
omega = 2.*pi.*freqVector;
s = 1i.*omega;
c = sArgs.c;
Z_0 = sArgs.Z_0;

% check if distance is given via a reference spl measurement
if isa(sArgs.d, 'itaAudio')
    sArgs.d = ita_start_IR(sArgs.d)/sArgs.d.samplingRate*c;
    sArgs.d = itaValue(sArgs.d.value, 'm');
    
elseif ~isa(sArgs.d, 'itaValue')
    sArgs.d = itaValue(sArgs.d, 'm');
end


if isa(TS, 'itaThieleSmall')
    TS = TS.convert2struct('double');
else
    TS = structfun(@double, TS, 'UniformOutput', 0);
end
if ~isfield(TS, 'f_s')
    TS.f_s = 1/(2*pi*sqrt(TS.m*TS.n));
end

Lces = TS.n*TS.M^2;
Res = TS.M^2/TS.w;
Cmes = TS.m/TS.M^2;


%%  equivalent circuit referred to elec side
if isfield(TS, 'lambda')
    Lces = Lces*(1-TS.lambda.*log10(s./(2*pi*TS.f_s))); % Knudsen model
%     Lces = Lces*(1-TS.lambda.*log10(s./(1i*2*pi*TS.f_s))); % Klippel model
    Lces(1) = real(Lces(2));
elseif isfield(TS, 'k') && isfield(TS, 'f_min')
    Lces = Lces.*(1-TS.k.*log10(1i.*(freqVector./TS.f_min).*exp(-1i.*atan(freqVector./TS.f_min))./(sqrt(1+(freqVector./TS.f_min).^2))));
    Lces(1) = real(Lces(2));
end

if isfield(TS, 'n_g') && ~isempty(TS.n_g)
    Lencl = TS.n_g*TS.M^2;
    Lces = Lces.*Lencl ./ (Lces + Lencl);
end

if isfield(TS,'w_g') && ~isempty(TS.w_g)
    Res = TS.M^2/(TS.w + TS.w_g);
end

Zp = Lces.*s./(Lces.*Cmes.*(s.^2) +  Lces./Res.*s + 1);
Ze = TS.L_e.*s + TS.R_e;

if isfield(TS, 'R_f')
    Ze = Ze + TS.R_f.*omega;
    
elseif isfield(TS, 'L_2') && isfield(TS, 'R_2')
    Ze = Ze + TS.R_2*TS.L_2.*s./(TS.R_2 + s.*TS.L_2);
end

Z = Ze + Zp;
Hx = Zp./(TS.M.*s.*Z);
Hx(1) = TS.n*TS.M./TS.R_e;

Z = itaAudio(Z, sArgs.samplingRate, 'freq');
Z.channelUnits = {'Ohm'};
Z.channelNames = {'Calculated Electrical Impedance'};
Z.signalType = 'energy';

Hx = itaAudio(Hx, sArgs.samplingRate, 'freq');
Hx.channelUnits = {'m/V'};
Hx.channelNames = {'Calculated Displacement'};
Hx.signalType = 'energy';

varargout{1} = Z;
varargout{2} = Hx;

%% Radiation impedance - if none is given, use piston radiation impedance
if isfield(TS, 'S_d')
    Hv = ita_differentiate(Hx);

    if isempty(sArgs.Zs)
        sArgs.Zs = TS.S_d*ita_radiation_impedance(sArgs.membraneType, double(sqrt(TS.S_d/pi)), 'samplingRate', sArgs.samplingRate, 'fftDegree', sArgs.fftDegree,'c',c,'Z_0',Z_0);
        
    elseif ~isa(sArgs.Zs, 'itaValue')
        sArgs.Zs = itaValue(sArgs.Zs, 'kg/m^2 s');
        sArgs.Zs = itaAudio(repmat(double(sArgs.Zs(:)),[1+Hv.nBins-numel(double(sArgs.Zs(:))) 1]), Hv.samplingRate, 'freq');
    end
    
    Pac = abs(Hv')^2*ita_real(sArgs.Zs); 
    Pac.signalType = 'energy';
    Pac.channelUnits = {'W/V^2'};
    Pac.channelNames = {'Estimated Acoustic Power'};
    
    p = sqrt(Pac*Z_0/(2*pi*(sArgs.d^2)));
    % also include propagation delay
    p.freq = bsxfun(@times,p.freq,exp(-1i.*2*pi.*p.freqVector./double(c).*double(sArgs.d)));
    p.channelNames = {['Estimated Sound Pressure in ' num2str(sArgs.d) ' distance']};
    varargout{3} = p;
    varargout{4} = Pac;
end

for idx = 1:nargout
    varargout{idx} = ita_metainfo_add_historyline(varargout{idx}, mfilename);
end

end