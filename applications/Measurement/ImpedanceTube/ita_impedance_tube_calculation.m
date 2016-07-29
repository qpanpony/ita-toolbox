function varargout = ita_impedance_tube_calculation(rawMeasurements, c0, rho0, micDistances,  freqRange, dampingDimension, crossingFreq,  windowTime, useTimeShift,options)
%ITA_IMPEDANCE_TUBE_CALCULATION - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   rawMeasurementsOut = ita_impedance_tube_calculation(rawMeasurementsIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   rawMeasurementsOut = ita_impedance_tube_calculation(rawMeasurementsIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_impedance_tube_calculation">doc ita_impedance_tube_calculation</a>

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  22-Nov-2014 

%%
% xFading between microphone combinations starts at  fc / fadingFactor and ends at  fc * fadingFactor
fadingFactor = 2^(1/2/3);

%%

freqVector = rawMeasurements.freqVector;
omega = 2*pi*freqVector;

% account for air attenuation in propagation constant, formula taken from Kundt's Tube ISO norm
k = omega/c0- 1i*1.94e-2*sqrt(freqVector) ./ (c0*dampingDimension);

%% window impulse response
if useTimeShift
    rawMeasurements = ita_time_shift(rawMeasurements);
end
if ~isempty(windowTime) 
    rawMeasurements = ita_time_window(rawMeasurements, windowTime, 'time', 'symmetric');
end

%% calc R for every mic combination
dist_probe_mic1 = micDistances(1);

dist_mic1_mic2 = micDistances(2) - micDistances(1);
invNenner = ita_invert_freq(itaAudio((rawMeasurements.freqData(:,2) - exp(-1i*k*dist_mic1_mic2) .* rawMeasurements.freqData(:,1)), rawMeasurements.samplingRate, 'freq'), freqRange);
Refl_12 = itaAudio(exp(2*1i*k*dist_probe_mic1) .* (exp(+1i*k*dist_mic1_mic2) .* rawMeasurements.freqData(:,1) - rawMeasurements.freqData(:,2)), rawMeasurements.samplingRate, 'freq') * invNenner;

dist_mic1_mic3 = micDistances(3) - micDistances(1);
invNenner = ita_invert_freq(itaAudio(( rawMeasurements.freqData(:,3) - exp(-1i*k*dist_mic1_mic3) .* rawMeasurements.freqData(:,1) ), rawMeasurements.samplingRate, 'freq'), freqRange);
Refl_13 = itaAudio(exp(2*1i*k*dist_probe_mic1) .* (exp(+1i*k*dist_mic1_mic3) .* rawMeasurements.freqData(:,1) - rawMeasurements.freqData(:,3)), rawMeasurements.samplingRate, 'freq') * invNenner;

if rawMeasurements.nChannels == 4
    dist_mic1_mic4 = micDistances(4) - micDistances(1);
    invNenner = ita_invert_freq(itaAudio(( rawMeasurements.freqData(:,4) - exp(-1i*k*dist_mic1_mic4) .* rawMeasurements.freqData(:,1) ), rawMeasurements.samplingRate, 'freq'), freqRange);
    Refl_14 = itaAudio(exp(2*1i*k*dist_probe_mic1) .* (exp(+1i*k*dist_mic1_mic4) .* rawMeasurements.freqData(:,1) - rawMeasurements.freqData(:,4)), rawMeasurements.samplingRate, 'freq') * invNenner;
end

%% cross fading
if options.doSineMerge == 1
   sinS1 = sin(k*dist_mic1_mic2).^2;
   sinS2 = sin(k*dist_mic1_mic3).^2;
   Refl = Refl_12;

   Refl.freqData = (Refl_12.freqData.*sinS1 + Refl_13.freqData.*sinS2)./(sinS2 + sinS1);
else
    Refl = ita_xfade_spk(Refl_13, Refl_12, crossingFreq(1)* [1/fadingFactor fadingFactor]);
end

if rawMeasurements.nChannels == 4
    Refl = ita_xfade_spk(Refl_14, Refl, crossingFreq(2)* [1/fadingFactor fadingFactor]);
end

%% R => Z

Z = rho0 * c0 * (1+Refl)/(1-Refl);

%% plot
plotVar = merge(Refl, Refl_12, Refl_13); % Refl_14.
plotVar  = 1-abs(plotVar )^2;
plotVar.channelNames = {'combined' 'mic12' 'mic13' 'mic14'}
plotVar.comment = rawMeasurements.comment;
plotVar.plotLineProperties = {'Linewidth', 3, 'color', [1 1 1] * 0.5}
plotVar.allowDBPlot = false;
plotVar.ch(1).pf
plotVar.plotLineProperties = {};
ita_plot_freq(plotVar.ch(2:plotVar.nChannels), 'hold', 'on', 'figure_handle', gcf, 'axes_handle', gca);
ylim([-0.1 1.1])
xlim(freqRange)
hold off

%% output parameter
varargout(1) = {Z};
if nargout >= 2
    varargout(2) = { Refl};
end
if nargout >= 3
    plotVar = merge(Refl, Refl_12, Refl_13, Refl_14);
    plotVar  = 1-abs(plotVar )^2;
    plotVar.channelNames = {'combined' 'mic12' 'mic13' 'mic14'};
    plotVar.comment = rawMeasurements.comment;
    plotVar.allowDBPlot = false;
    varargout(3) = { plotVar};
end


%end function
end