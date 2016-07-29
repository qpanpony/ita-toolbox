function varargout = ita_kundt_calc_impedance(audioObj, geometry, temp, humidity,  freqRange)
%ITA_KUNDT_CALC_IMPEDANCE - calculates the impedance of a probe, measured in Kundts Tube
%
%   Call:
%       impedance = ita_kund_calc_impedance(audioObj, geometry)
%
%
% re-implementation as ita_rohrbert didnt work anymore
% if geometry is a numeric array it has to contain the following data:
% [distance sample to mic1, distance mic1 mic2, distance mic1 mic3, distance mic1 mic4 (optional for 4 mic measurement)]
%
% Naming conventions from good old Rohrbert:
%   source               mic3 mic2   mic1      mat_probe       mic4  mic5 mic6             termination
%     |--------------------|---|------|------------|------------|------|---|--------------------|
%
%      <------------------> <-> <----> <----------> <----------> <----> <-> <------------------>
%                            |    d12       s_v         s_h       d45    |
%                         d13-d12                                     d46-d45
%
%
% Default Dimensions of the Kundt's Tubes at ITA
%
% Small Tube
% Rohrdurchmesser: 50.8 mm
%
%
%   source               mic3     mic2 mic1           probenhalter           mic4 mic5     mic6             termination
%     |--------------------|--------|---|------------|------------|------------|---|--------|--------------------|
%
%      <------------------> <------> <-> <----------> <----------> <----------> <-> <------> <------------------>
%             200mm           93mm   17mm    100mm        50mm         100mm    17mm  93mm           200mm
%                            d13-d12  d12      s_v                      s_h     d45  d46-d45
%
% Big Tube
% Querschnitt: 15 x 15 cm^2
%
%
%   source               mic3 mic2   mic1      mat_probe
%     |--------------------|---|------|------------|
%
%      <------------------> <-> <----> <---------->
%             66.5cm        5cm  8cm      20.5cm        (d45,d46,s_h = 0 !!!)

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Martin Pollow, mpo@akustik.rwth-aachen.de, 12.11.09

% ToDo: TRansmission calculation


%% tube specific parameters

if ischar(geometry)
    switch geometry
        case {'smallTubeITA Mics123', 'Small Kundt''s Tube at ITA Mics123'}
            geometry =  [ 100e-3 17e-3 110e-3 ];
            dampingDimension = 0.0508 ; % used to compesate the air damping acc to ISO 10534
             crossingFreq = 1200;
        case {'smallTubeITA Mics1234', 'Small Kundt''s Tube at ITA Mics1234'}
            %geometry =  [100e-3 17e-3 110e-3 400e-3];
            geometry =  [95 17 110.5 510] / 1000; % LAS FOR CALCULATION, FIX
            dampingDimension = 0.0508 ; % used to compesate the air damping acc to ISO 10534
            freqRange_default = [20 14000];
            crossingFreq = [1200 190];
        case {'smallTubeITA Mics1236', 'Small Kundt''s Tube at ITA Mics1236'}
            geometry =  [100 17 110.55 514.05]/ 1000;
            dampingDimension = 0.0508 ; % used to compesate the air damping acc to ISO 10534
            freqRange_default = [20 14000];
            crossingFreq = [1200 190];
        case {'bigTubeITA', 'Big Kundt''s Tube at ITA'}
            dampingDimension = 0.15 ; % used to compesate the air damping acc to ISO 10534
            geometry =  [ 305e-3 80e-3 130e-3 ];
            freqRange_default = [20 2000];
            crossingFreq = 600;
        case {'rohrOhr', 'Rohr mit Ohr'}
            %             warnMsg = 'It could happen that some frequency data will be NaN. This will lead to errors with the interpolation algorithm.';
            %             geometry =  [ 25e-3 07e-3 40e-3 ];
            %             freqRange_default = [20 18000];
            error('erst code überprüfen bevor man das verwendet...')
        otherwise
            error('I dont know this tube!')
    end
else
    freqRange_default = [20 10000];
     dampingDimension = 0.0508;
  crossingFreq = [1200 190];
end

if ~exist('freqRange', 'var')
    freqRange = [20 12000];
end

nInputMics = audioObj.nChannels;

if ~( isnumeric(geometry) &&   numel(geometry) == nInputMics  )
    error('ITA_KUNDT_CALC_IMPEDANCE: Invalid input parameter geometry. Has to be valid string or valid numeric array.');
end



%%
% xFading between microphone combinations starts at  fc / fadingFactor and ends at  fc * fadingFactor
fadingFactor = 2^(1/2/3);

%%

% material constants (default)
if nargin < 3
    rho0 = double(ita_constants('rho_0'));
    c0 = double(ita_constants('c'));
else
    rho0    = double(ita_constants('rho_0', 'T', temp, 'phi', humidity));
    c0      = double(ita_constants('c',     'T', temp, 'phi', humidity));
end

freqVector = audioObj.freqVector;
omega = 2*pi*freqVector;

% account for air attenuation in propagation constant, formula taken from Kundt's Tube ISO norm
k = omega/c0- 1i*1.94e-2*sqrt(freqVector) ./ (c0*dampingDimension);





%% calc R for every mic combination
dist_probe_mic1 = geometry(1);

dist_mic1_mic2 = geometry(2);
invNenner = ita_invert_freq(itaAudio((audioObj.freqData(:,2) - exp(-1i*k*dist_mic1_mic2) .* audioObj.freqData(:,1)), audioObj.samplingRate, 'freq'), freqRange);
Refl_12 = itaAudio(exp(2*1i*k*dist_probe_mic1) .* (exp(+1i*k*dist_mic1_mic2) .* audioObj.freqData(:,1) - audioObj.freqData(:,2)), audioObj.samplingRate, 'freq') * invNenner;

dist_mic1_mic3 = geometry(3);
invNenner = ita_invert_freq(itaAudio(( audioObj.freqData(:,3) - exp(-1i*k*dist_mic1_mic3) .* audioObj.freqData(:,1) ), audioObj.samplingRate, 'freq'), freqRange);
Refl_13 = itaAudio(exp(2*1i*k*dist_probe_mic1) .* (exp(+1i*k*dist_mic1_mic3) .* audioObj.freqData(:,1) - audioObj.freqData(:,3)), audioObj.samplingRate, 'freq') * invNenner;

if nInputMics == 4
    dist_mic1_mic4 = geometry(4);
    invNenner = ita_invert_freq(itaAudio(( audioObj.freqData(:,4) - exp(-1i*k*dist_mic1_mic4) .* audioObj.freqData(:,1) ), audioObj.samplingRate, 'freq'), freqRange);
    Refl_14 = itaAudio(exp(2*1i*k*dist_probe_mic1) .* (exp(+1i*k*dist_mic1_mic4) .* audioObj.freqData(:,1) - audioObj.freqData(:,4)), audioObj.samplingRate, 'freq') * invNenner;
end

%% cross fading

Refl = ita_xfade_spk(Refl_13, Refl_12, crossingFreq(1)* [1/fadingFactor fadingFactor]);

if nInputMics == 4
    Refl = ita_xfade_spk(Refl_14, Refl, crossingFreq(2)* [1/fadingFactor fadingFactor]);
end

%% R => Z

Z = rho0 * c0 * (1+Refl)/(1-Refl);
% 
% % plot
% plotVar = merge(Refl, Refl_12, Refl_13, Refl_14);
% plotVar  = 1-abs(plotVar )^2;
% plotVar.channelNames = {'combined' 'mic12' 'mic13' 'mic14'}
% plotVar.comment = audioObj.comment;
% plotVar.plotLineProperties = {'Linewidth', 3, 'color', [1 1 1] * 0.5}
% plotVar.allowDBPlot = false;
% plotVar.ch(1).pf
% plotVar.plotLineProperties = {};
% ita_plot_freq(plotVar.ch(2:4), 'hold', 'on', 'figure_handle', gcf, 'axes_handle', gca);
% ylim([0 1])
% xlim([20 10000])

%% output parameter

if nargout == 1
    varargout = {Z};
else
    varargout = {Z, Refl};
end