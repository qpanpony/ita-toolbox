% ITA_LARGE_SIGNAL_PARAMETERS - determine the large signal parameters variation of a loudspeaker
% 
%% ITA_LARGE_SIGNAL_PARAMETERS
% Method to determine the large signal parameters variation of a loudspeaker. 
% The method can be found in DIN 62458: Dynamic Point-by-Point Method.
% The large signal parameters are determined according to the membrane
% displacement.
%
% See also
%   ita_measurement, ita_modulita_control, ita_time_window, ita_impedance_fit  
%   ita_invert_spk_regularization, ita_amplify, ita_merge

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Alexandre Bleus -- alexandre.bleus@akustik.rwth-aachen.de
% Created: June-2010

%% Initialisation of the delayed sweep for the measurement routine
sine=ita_generate('sine',0.1,60,44100,18);
sweep=ita_generate_sweep('mode','exp','freqRange',[20 20000],'stopMargin',0.1,'samplingRate',44100,'fftDegree',17);
delsweep=itaAudio();
delsweep.timeData=zeros(length(sine.timeData),1);
delay=delsweep.time2index(sine.trackLength.value-sweep.trackLength.value);
delsweep.timeData(delay: delay+length(sweep.timeData)-1)=sweep.timeData;
delsweep.channelNames{1}=['Delayed Sweep'];
delsweep.comment=[];

%% Compensation of the transformator (with only the transformator
%% connected)
MSimp=itaMSImpedance('useMeasurementChain',false,'inputChannels',1,'outputChannels', 1, ...
                    'samplingRate',44100, 'fftDegree', 18, ...
                    'freqRange',[20 20000], 'type', 'exp', ...
                    'stopMargin', 0.1, 'outputamplification', '-20dB');
MSimp.calibrate;
Tr=MSimp.run;
index=Tr.freq2index(1000);
Tr_init=abs(Tr.freqData(index));
Tr_comp=ita_invert_spk_regularization(Tr, [20 20000])*Tr_init;

%% Measurement routine
% First small signal parameters calulus
MS=itaMSTF('useMeasurementChain',false,'inputChannels',[1 2],'outputChannels', 2, ...
                    'samplingRate',44100, 'fftDegree', 18, ...
                    'freqRange',[20 20000], 'type', 'exp', ...
                    'stopMargin', 0.1, 'outputamplification', '-30dB');
disp('Connect LS to amp - without additional mass')
pause
U=MS.run;
U_win=ita_time_window(U,[0.04,0.07],'time','symmetric');
Z_o=U_win.ch(1)/U_win.ch(2)*itaValue(0.1, 'Ohm');
disp('Connect LS to amp - with additional mass')
pause
U=MS.run;
U_comp_first=U*Tr_comp;
U_win=ita_time_window(U_comp_first,[0.01,0 0.04,0.07],'time','symmetric');
Z_m=U_win.ch(1)/U_win.ch(2)*itaValue(0.1, 'Ohm');
disp('delta_m?')
delta_m = input('Please insert the weight of the additional mass in kg and press enter:');
disp('d?')
d = input('Please insert the diameter of the membrane in m and press enter:');
TS=ita_thiele_small(Z_o, Z_m, delta_m, d, 'L_e', true);

% Initialisation of the large signal parameters measurement
MS=itaMSTF('inputChannels',[1 2],'outputChannels',[1 2], ...
                    'samplingRate',44100, 'fftDegree', 18, ...
                    'freqRange',[20 20000], 'type', 'exp', ...
                    'stopMargin', 0.1, 'outputamplification', '-30dB');
MS.calibrate;

% Negative dsiplacements
for idx=1:8
    % Rectangular signal from a sine
    sine=ita_generate('sine',0.1*idx,60,44100,18);
    amp=max(sine.timeData);
    sine.timeData=amp.*sign(sine.timeData);
    sine=ita_time_window(sine,[2000,1, sine.nSamples-300,sine.nSamples],@hann,'samples');
    sine.channelNames{1}=['Square Signal'];
    sine.comment=[];
    sine=ita_amplify(sine, ['-' MS.outputamplification ]);
    % Prepare the measurement
    MS.excitation=ita_merge(sine, delsweep);
    delcomp=ita_invert_spk_regularization(delsweep,[20 20000]);
    MS.compensation=delcomp;
    Voltage_neg(idx)= - MS.outputMeasurementChain.sensitivity*0.1*idx;
    U=MS.run;
    U_comp_first=U*Tr_comp;
    U_win=ita_time_window(U_comp,[0.01,0 0.04,0.07],'time','symmetric');
    Z_neg(idx)=U_win.ch(1)/U_win.ch(2)*itaValue(0.1, 'Ohm');
    Z_neg(idx).channelNames{1}=['Signal amplitude of "-"' num2str(0.1*idx)];
    % Calculate the parameters
    TS_new_neg(idx)=ita_impedance_fit(TS, Z_neg(idx));
    Bl_neg(idx)=TS_new_neg(idx).M.value;
    L_e_neg(idx)=TS_new_neg(idx).L_e.value;
    L_2_neg(idx)=TS_new_neg(idx).L_2.value;
    R_2_neg(idx)=TS_new_neg(idx).R_2.value;
    n_inc(idx)=TS_new_neg(idx).n.value;
    K=1./n_inc;
    K_ms=(1/idx)*sum(K(1:idx));
    n_neg(idx)=1/K_ms;
end

% Positive displacements
disp('Invert the voltage at the AC to DC Bridge Terminals and press enter')
pause
for idx=1:8
    % Rectangular signal from a sine
    sine=ita_generate('sine',0.1*idx,60,44100,18);
    amp=max(sine.timeData);
    sine.timeData=amp.*sign(sine.timeData);
    sine=ita_time_window(sine,[2000,1, sine.nSamples-300,sine.nSamples],@hann,'samples');
    sine.channelNames{1}=['Square Signal'];
    sine.comment=[];
    sine=ita_amplify(sine, ['-' MS.outputamplification ]);
    % Prepare the measurement
    MS.excitation=ita_merge(sine, delsweep);
    delcomp=ita_invert_spk_regularization(delsweep,[20 20000]);
    MS.compensation=delcomp;
    Voltage(idx)= MS.outputMeasurementChain.sensitivity*0.1*idx;
    U=MS.run;
    U_comp_first=U*Tr_comp;
    U_win=ita_time_window(U_comp_first,[0.01,0 0.04,0.07],'time','symmetric');
    Z(idx)=U_win.ch(1)/U_win.ch(2)*itaValue(0.1, 'Ohm');
    Z(idx).channelNames{1}=['Signal amplitude of ' num2str(0.1*idx)];
    % Calculate the parameters
    TS_new(idx)=ita_impedance_fit(TS, Z(idx));
    Bl(idx)=TS_new(idx).M.value;
    L_e(idx)=TS_new(idx).L_e.value;
    L_2(idx)=TS_new(idx).L_2.value;
    R_2(idx)=TS_new(idx).R_2.value;
    n_inc(idx)=TS_new(idx).n.value;
    K=1./n_inc;
    K_ms=(1/idx)*sum(K(1:idx));
    n(idx)=1/K_ms;
end

%% Results
Z_global=[Z_neg(end:-1:1) Z(1:1:end)];
U_global=[Voltage_neg(end:-1:1) Voltage(1:1:end)];
TS_new_global=[TS_new_neg(end:-1:1) TS_new(1:1:end)];
Bl_global=[Bl_neg(end:-1:1) Bl(1:1:end)];
L_e_global=[L_e_neg(end:-1:1) L_e(1:1:end)];
L_2_global=[L_2_neg(end:-1:1) L_2(1:1:end)];
R_2_global=[R_2_neg(end:-1:1) R_2(1:1:end)];
n_global=[n_neg(end:-1:1) n(1:1:end)];

