function varargout = ita_radiation_impedance(varargin)
%ITA_RADIATION_IMPEDANCE - calculates radiation impedance for given radiator shape
%  This function calculates the acoustical(!) radiation impedance for a
%  given radiator shape (so far sphere and piston).
%  The returned impedance has the unit of p/v; for the mechanical
%  equivalent Zsm, Zs has to be multiplied by the radiator surface area.
%
%  Syntax:
%   audioObjOut = ita_radiation_impedance(string, double, options)
%
%   Options (default):
%           'samplingRate' (ita_preferences('samplingRate')) : sampling rate
%           'fftDegree' (ita_preferences('fftDegree'))       : fft degree
%           'c' (ita_constants('c'))                         : speed of sound
%           'Z_0' (ita_constants('c'))                       : wave impedance
%
%  Example:
%   Zs = ita_radiation_impedance('piston',0.065)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_radiation_impedance">doc ita_radiation_impedance</a>

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  15-Sep-2013 

%% Initialization and Input Parsing
sArgs        = struct('pos1_type','string','pos2_radius','double','samplingRate', ita_preferences('samplingRate'),'fftDegree',ita_preferences('fftDegree'),'c',ita_constants('c'),'Z_0',ita_constants('z_0'));
[type,a,sArgs] = ita_parse_arguments(sArgs,varargin); 

%%
Z_s = itaAudio(nan(2^sArgs.fftDegree,1),sArgs.samplingRate,'time');
freqVec = Z_s.freqVector;
ka = 2.*pi.*freqVec./double(sArgs.c).*a;
Z_0 = sArgs.Z_0;

switch type
    case 'sphere'
        Z_s.freq = 1./(1 + 1./(1i.*ka));
    case 'piston'
        Z_s.freq = 1 - (2.*besselj(1, 2.*ka)./(2.*ka)) + 2.*1i.*ita_struve1(2.*ka)./(2.*ka); % vgl. Mendel: Electroacoustics S. 176 (10.40)
    otherwise
        error('Only (pulsating) sphere and piston implemented so far');
end

Z_s = Z_s*Z_0;
Z_s.signalType = 'energy';
Z_s.comment    = ['Acoustical radiation impedance (' type ' approximation)'];

%% Add history line
Z_s = ita_metainfo_add_historyline(Z_s,mfilename,varargin);

%% Set Output
varargout(1) = {Z_s}; 

%end function
end