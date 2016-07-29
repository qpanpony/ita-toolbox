function test_ita_analysis()

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%% get two signals and a tp
sr = 44100;
fftdeg = 15;
a       = ita_generate('sine',1,1000,sr,fftdeg);
b       = ita_generate('noise',1,sr,fftdeg);
c       = ita_merge(ita_fft(a),b);
tp      = ita_fft(ita_merge(a,a,a,a));
tp.signalType = 'energy';


%% used to test the transformation at the beginning of functions
timeData = b;
freqData = ita_fft(b);


%% fft transformation test - energy-signal
timeData = ita_generate('impulse', 1, sr, fftdeg);
freqData = ita_fft(timeData);
timeData_b = ita_ifft(freqData);

if sum(find(timeData.timeData-timeData_b.timeData))
   error('FFT or IFFT ERROR with energy-signal'); 
end

%% fft transformation test - power-signal
timeData = ita_generate('sine', 1, 1000, sr,fftdeg);
freqData = ita_fft(timeData);
timeData_b = ita_ifft(freqData);
if 0.0001 < sum(abs(timeData.timeData.^2-timeData_b.timeData.^2))
   error('FFT or IFFT ERROR with power-signal');
end

%% test functions
c = ita_spk2frequencybands(b);


end