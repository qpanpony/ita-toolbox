function varargout = ita_impedance_tube_transmission(raw_measurements, temp, humidity)
%ITA_KUNDT_CALC_TRANSMISSION
% Calculates the Transmission of a specimen
% Input: 
%   raw_measurements - Containing data from mic1 mic2 mic3 in
%       channels 1 to 3, ch(4) contains the data measured with the downstream
%       microphone (mic4 or mic5 or mic6)
%  temp and humidity are optional
%
% 
%   Call:
%      transmission = ita_kund_calc_transmission(raw_measurements, geometry)
%  
%     could also be used to give transmission and impedance and reflection
%     (depending on nargout)
%
% Small Tube
% Rohrdurchmesser: 50.8 mm
%
%   source               mic3     mic2 mic1           probenhalter           mic4 mic5     mic6             termination
%     |--------------------|--------|---|------------|------------|------------|---|--------|--------------------|
% 
%      <------------------> <------> <-> <----------> <----------> <----------> <-> <------> <------------------>
%             200mm           93mm   17mm    100mm        50mm         100mm    17mm  93mm           200mm
%                            d13-d12  d12      s_v                      s_h     d45  d46-d45                                    
%
%
% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Felix Werwer, 05.08.2015, Based on ita_kundt_calc_impedance_transmission.m
%% Initialization
freqVector = raw_measurements.freqVector;

% material constants (default)
if nargin < 2
    rho0 = double(ita_constants('rho_0'));
    c0 = double(ita_constants('c'));
else
    rho0    = double(ita_constants('rho_0', 'T', temp, 'phi', humidity));
    c0      = double(ita_constants('c',     'T', temp, 'phi', humidity));
end


omega = 2*pi*freqVector;

% account for air attenuation in propagation constant, formula taken from Kundt's Tube ISO norm
k = omega/c0- 1i*1.94e-2*sqrt(freqVector) ./ (c0*0.0508);


geometry =  [ 100e-3 17e-3 110e-3 ];

    
    % microphone distances 
    s_v = geometry(1);
    d12 = geometry(2);
    d13 = geometry(3);
    
    fadingFactor = 2^(1/2/3);
    crossingFreq = 1200;


p_mic_freqData = raw_measurements.freqData;



%% Calculate Reflection Factor
Refl_12 = itaAudio(exp(2*j*k*s_v) .* (exp(+j*k*d12) .* p_mic_freqData(:,1) - p_mic_freqData(:,2)) ...
    ./ (p_mic_freqData(:,2) - exp(-j*k*d12) .* p_mic_freqData(:,1)), raw_measurements.samplingRate, 'freq');

Refl_13 = itaAudio(exp(2*j*k*s_v) .* (exp(+j*k*d13) .* p_mic_freqData(:,1) - p_mic_freqData(:,3)) ...
    ./ ( p_mic_freqData(:,3) - exp(-j*k*d13) .* p_mic_freqData(:,1) ), raw_measurements.samplingRate, 'freq');

% Fade Reflection Factors of different positions
    Refl = ita_xfade_spk(Refl_13, Refl_12, crossingFreq* [1/fadingFactor fadingFactor]);
    Refl.allowDBPlot = false;
%% Calculate Z 
Z = itaAudio(raw_measurements);
Z.freqData = rho0 * c0 * (1+Refl)./(1-Refl);
Z.channelUnits = {'kg/s*m^2'};

%% Calculate Transmission Factor
% calculate incident wave
p_i_12 = itaAudio(exp(2*j*k*s_v) .* (p_mic_freqData(:,2) - exp(-j*k*d12) .* p_mic_freqData(:,1))...
    ./( exp(j*k*d12) - exp(-j*k*d12) ), raw_measurements.samplingRate, 'freq');
p_i_13 = itaAudio(exp(2*j*k*s_v) .* (p_mic_freqData(:,3) - exp(-j*k*d13) .* p_mic_freqData(:,1))...
    ./( exp(j*k*d13) - exp(-j*k*d13) ), raw_measurements.samplingRate, 'freq');
p_i = Z; %to get right length 
p_i =  ita_xfade_spk(p_i_13, p_i_12, crossingFreq* [1/fadingFactor fadingFactor]);



% Calculate Transmission
T = ita_divide_spk(raw_measurements.ch(4),p_i);
T.allowDBPlot = false;

T.comment = 'Transmission with one Microphon Downstream';

%% plot transmission and returns
ita_plot_freq_phase(T,'xlim',[20 9000],'ylim',[-0.1 2.1],'nodB')

if nargout == 1
    varargout = {T};
elseif nargout == 2
    varargout = {T,Z};
else
    varargout = {T, Z, Refl};
end
end