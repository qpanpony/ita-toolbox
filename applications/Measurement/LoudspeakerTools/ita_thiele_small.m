function varargout = ita_thiele_small(varargin)
%ITA_THIELE_SMALL - Calculation of Thiele-Small Paramters
%  This function calculates the Thiele-Small Parameters
%
%  Syntax:
%   audioObjOut = ita_thiele_small(Z,Z_mass,m,d)
%
%   Options:
%          Z: impedance without enclosure and without extra mass
%          Z_m: impedance with extra mass m
%          m: extra mass m in [kg]
%          d: effective membrane diameter in [m]
%          'frequency_limits' [20 7000]
%  Example:
%   audioObjOut = ita_thiele_small(audioObjIn)
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_thiele_small">doc ita_thiele_small</a>
%
% %   See also: ita_show_struct
%
% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  14-Jan-2010
% MMT: Rewrite for new TS class 16-Jan-2015

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing

if nargin == 0;
    MS = itaMSImpedance;
    MS.edit;
    MS.calibrate;
    disp('Connect LS to amp - without additional mass')
    pause
    Z = MS.run;
    disp('Connect LS to amp - with additional mass')
    pause
    Z_m = MS.run;
    disp('delta_m?')
    delta_m = input('Please insert the weight of the additional mass in kg and press enter:');
    disp('d?')
    d = input('Please insert the diameter of the membrane in m and press enter:');
    sArgs = struct('pos1_Z','itaAudioFrequency','pos2_Zm','itaAudioFrequency', 'pos3_m','itaValue','pos4_d','itaValue','frequency_limits',[20 7000],'L_e', true);
    [Z, Z_m, delta_m, d, sArgs] = ita_parse_arguments(sArgs,{Z, Z_m, delta_m, d});
else
    sArgs = struct('pos1_Z','itaAudioFrequency','pos2_Zm','itaAudioFrequency', 'pos3_m','itaValue','pos4_d','itaValue','frequency_limits',[20 7000],'L_e', false);
    [Z, Z_m, delta_m, d, sArgs] = ita_parse_arguments(sArgs,varargin);
end

if ~isa(delta_m,'itaValue') || isempty(delta_m.unit)
    delta_m = itaValue(double(delta_m),'kg');
elseif ~strcmp(delta_m.unit,'kg')
    error([thisFuncStr 'added mass has wrong unit']);
end

if ~isa(d,'itaValue') || isempty(d.unit)
    d = itaValue(double(d),'m');
elseif ~strcmp(d.unit,'m')
    error([thisFuncStr 'membrane diameter has wrong unit']);
end

%% Calculation of Thiele-Small
low_bin  = Z.freq2index(sArgs.frequency_limits(1));
high_bin = Z.freq2index(sArgs.frequency_limits(2));

freqVec = Z.freqVector(low_bin:high_bin);
Z_o = Z.freqData(low_bin:high_bin);
Z_m = Z_m.freqData(low_bin:high_bin);

%DC resistance
R_e = itaValue(real(Z_o(1)),'Ohm');

phi1 = angle(Z_o);
phi2 = angle(Z_m);

% brute force maximum search
% [Z_max1,index1] = max(abs(Z));
% [dummy,index2] = max(abs(Z_m));

% search resonance through change of phase sign from + to -
index1 = find(gradient(sign(phi1)) < 0,1,'first');
index2 = find(gradient(sign(phi2)) < 0,1,'first');

Z_max1 = abs(Z_o(index1));

%parallel resistance
R_p = itaValue(Z_max1,'Ohm') - R_e;

%resonance frequencies
f_0 = itaValue(freqVec(index1),'Hz');
f_0m = itaValue(freqVec(index2),'Hz');

%membrane mass
m = delta_m / ((f_0/f_0m)^2-1);
n = 1/(m*(2*pi*f_0)^2);

Zstrich = Z_o - double(R_e);

index_df_low = find(abs(Zstrich(1:index1))>double(R_p)/sqrt(2),1,'first');
index_df_high = round(index1 + 1.2*(index1 - index_df_low));
index_df_high = find(abs(Zstrich(1:index_df_high))>double(R_p)/sqrt(2),1,'last');

index_df_low  = index_df_low + low_bin-1;
index_df_high = index_df_high + low_bin-1;
df_low  = freqVec(index_df_low);
df_high = freqVec(index_df_high);

delta_f = itaValue((df_high-df_low)/2,'Hz');

Q_m = f_0 / (2 * delta_f);
w = f_0 * 2 * pi * m/ Q_m;

TS = itaThieleSmall();

S_d = pi*d^2/4;
M = sqrt(R_p * w);
TS.R_e  = R_e;
TS.w    = w;
TS.n    = n;
TS.m    = m;
TS.M    = M;
TS.S_d  = S_d; % effective piston area

if(TS.Q_tot.value < 0)
    ita_verbose_info('Q_tot<0: Frequency Range too small. Increase to include more low Frequencies.',0);
end

%% L_e calculation with curve fitting
if sArgs.L_e
    TS = ita_inductance_fit(Z,TS,'L2','fmin',sArgs.frequency_limits(1),'fmax',sArgs.frequency_limits(2));
end

%% Set Output
% TS.show;
varargout(1) = {TS};
%end function
end