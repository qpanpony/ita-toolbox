function varargout = ita_kundt_calc_impedance_transmission(p_mic, p_trans,  geometry, temp, humidity)
%ITA_KUNDT_CALC_IMPEDANCE - calculates the impedance of a probe, measured in Kundts Tube
% 
%   Call:
%       impedance = ita_kund_calc_impedance(p_mic,p_trans, geometry)
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

% RSC:turn divide by zero warning off, as we handle it ourself
warn_state = warning('off','MATLAB:divideByZero');

freqVector = p_mic.freqVector;

% material constants (default)
if nargin < 4
    rho0 = double(ita_constants('rho_0'));
    c0 = double(ita_constants('c'));
else
    rho0    = double(ita_constants('rho_0', 'T', temp, 'phi', humidity));
    c0      = double(ita_constants('c',     'T', temp, 'phi', humidity));
end


omega = 2*pi*freqVector;
% k = omega/c0;
% account for air attenuation in propagation constant, formula taken from Kundt's Tube ISO norm
k = omega/c0- 1i*1.94e-2*sqrt(freqVector) ./ (c0*0.0508);

if p_mic.nChannels == 3
    if ischar(geometry)
        switch geometry
            case {'smallTubeITA Mics123', 'Small Kundt''s Tube at ITA Mics123'}
                geometry =  [ 100e-3 17e-3 110e-3 ];
            case {'bigTubeITA', 'Big Kundt''s Tube at ITA'}
                geometry =  [ 205e-3 80e-3 130e-3 ];
            case {'rohrOhr', 'Rohr mit Ohr'}
                geometry =  [ 25e-3 07e-3 40e-3 ];
            otherwise
                error('I dont know this tube.')
        end
    end
    if ~( isnumeric(geometry) && ...
            ( isequal(size(geometry), [3,1]) || isequal(size(geometry), [1,3]) ) )
        error('ITA_KUNDT_CALC_IMPEDANCE: Invalid input parameter geometry. Has to be valid string or valid numeric array.');
    end
    
    % microphone distances 
    s_v = geometry(1);
    d12 = geometry(2);
    d13 = geometry(3);
    
    nInputMics = 3;

elseif p_mic.nChannels == 4
    if ischar(geometry)
        switch geometry
            case {'smallTubeITA Mics1234', 'Small Kundt''s Tube at ITA Mics1234'}
                geometry =  [100e-3 17e-3 110e-3 400e-3];
            otherwise
                error('I dont know this tube.')
        end
    end
    
    if ~( isnumeric(geometry) && ...
            ( isequal(size(geometry), [4,1]) || isequal(size(geometry), [1,4]) ) )
        error('ITA_KUNDT_CALC_IMPEDANCE: Invalid input parameter geometry. Has to be valid string or valid numeric array.');
    end
    
    % microphone distances (default = distances of the small Kundt's tube at ITA)
    s_v = geometry(1);
    d12 = geometry(2);
    d13 = geometry(3);
    d14 = geometry(4);

    nInputMics = 4;
    
else
    error('ITA_KUNDT_CALC_IMPEDANCE: Invalid numer of channels in p_mic, p_mic has to have 3 or 4 channels.');
end

p_mic_freqData = p_mic.freqData; %pdi: save time

Refl_12 = exp(2*j*k*s_v) .* (exp(+j*k*d12) .* p_mic_freqData(:,1) - p_mic_freqData(:,2)) ...
    ./ (p_mic_freqData(:,2) - exp(-j*k*d12) .* p_mic_freqData(:,1)); %#ok<*IJCL>

Refl_13 = exp(2*j*k*s_v) .* (exp(+j*k*d13) .* p_mic_freqData(:,1) - p_mic_freqData(:,3)) ...
    ./ ( p_mic_freqData(:,3) - exp(-j*k*d13) .* p_mic_freqData(:,1) );

if nInputMics == 4
    Refl_14 = exp(2*j*k*s_v) .* (exp(+j*k*d14) .* p_mic_freqData(:,1) - p_mic_freqData(:,4)) ...
        ./ ( p_mic_freqData(:,4) - exp(-j*k*d14) .* p_mic_freqData(:,1) );
end

% That is the old function to blend between the results from MicPair 12
% and MicPair 13, this blending function was found to be not optimal by
% MAR, MGU. Therefore alternative weighting functions are applied.
% For more information see documentation.
% Refl = ( ( (sin(k*d12)).^2 .* Refl_12 ) + ( (sin(k*d13)).^2 .* Refl_13 ) ) ...
%     ./ ( (sin(k*d12)).^2 + (sin(k*d13)).^2 );

%%% Calculate now blending functions, that also support 4 microphone technique

% window for Mic Pair 12
binAtLE = p_mic.freq2index(1000); % Lower End
binAtUE = p_mic.freq2index(1100); % Upper End
smoothwidth = binAtUE - binAtLE;       % Smoothing Width
weighting12 = zeros(size(Refl_12));
weighting12(1:binAtLE) = 0;
weighting12(binAtLE:binAtUE) = ( (binAtLE:binAtUE) - binAtLE )/(binAtUE - binAtLE);
weighting12(binAtUE:end) = 1;
weighting12 = smooth(weighting12, smoothwidth);

if nInputMics == 4
    % window for Mic Pair 14
    binAtLE = p_mic.freq2index(320); % Lower End
    binAtUE = p_mic.freq2index(380); % Upper End
    smoothwidth = binAtUE - binAtLE;      % Smoothing Width
    weighting14 = zeros(size(Refl_14));
    weighting14(1:binAtLE) = 1;
    weighting14(binAtLE:binAtUE) = ( binAtUE - (binAtLE:binAtUE))/(binAtUE - binAtLE);
    weighting14(binAtUE:end) = 0;
    weighting14 = smooth(weighting14, smoothwidth);
    
    weighting13 = 1 - (weighting12 + weighting14);
    Refl = (weighting14 .* Refl_14) + (weighting13 .* Refl_13) + (weighting12 .* Refl_12);
else
    weighting13 = 1 - (weighting12);
    Refl = (weighting13 .* Refl_13) + (weighting12 .* Refl_12);
end

Z = itaAudio(p_mic);
Z.freqData = rho0 * c0 * (1+Refl)./(1-Refl);
Z.channelUnits = {'kg/s*m^2'};

ita_verbose_info('transmission has been measured.')
% calculate incident wave
p_i_12 = exp(2*j*k*s_v) .* (p_mic_freqData(:,2) - exp(-j*k*d12) .* p_mic_freqData(:,1))...
    ./( exp(j*k*d12) - exp(-j*k*d12) );
p_i_13 = exp(2*j*k*s_v) .* (p_mic_freqData(:,3) - exp(-j*k*d13) .* p_mic_freqData(:,1))...
    ./( exp(j*k*d13) - exp(-j*k*d13) );
p_i = Z;
p_i.freq =  (weighting13 .* p_i_13) + (weighting12 .* p_i_12);


T = ita_divide_spk( p_trans,p_i,'regularization',[50 9000]);
T.allowDBPlot = false;

% replace infs and NaNs with 0
Z.freqData(~isfinite(Z.freqData)) = 0;

% Turn warning back on
warning(warn_state);


if nargout == 1
    varargout = {T};
elseif nargout == 2
    varargout = {Z,T};
else
    Refl = itaAudio(Refl, p_mic.samplingRate, 'freq');
    Refl.allowDBPlot = false;
    varargout = {Z, T, Refl};
end