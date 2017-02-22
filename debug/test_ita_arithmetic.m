function test_ita_arithmetic()

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%% get two signals and a tp
sr = 44100;
fftdeg = 15;
a       = ita_generate('sine',1,1000,sr,fftdeg);
b       = ita_generate('noise',1,sr,fftdeg);
c       = merge(a,b);
tp      = fft(merge(a,a,a));
tp.signalType = 'energy';
imp = ita_generate('impulse',1,sr,fftdeg-5);

%% used to test the transformation at the beginning of functions
a_spk    = fft(a);
timeData = b;
freqData = fft(b);

%% test functions
d = ita_add(timeData,timeData);
d = ita_add(freqData,freqData);
d = ita_add(freqData,timeData);
d = ita_add(timeData,freqData);

d = ita_conj(freqData);

d = ita_divide_spk(a_spk,tp);

d = ita_invert_spk(timeData);
d = ita_invert_spk(freqData);

d = ita_multiply_dat(a,timeData);

d = ita_multiply_spk(a_spk,tp);
if ~(tp == ita_divide_spk(ita_multiply_spk(tp,freqData),freqData)) 
    error('ITA_DIVIDE_SPK/ITA_MULTIPLY_SPK:Oh Lord. Function seems not to work properly.')
end

d = ita_negate(a);
d = ita_negate(a_spk);
if ~(b == ita_negate(ita_negate(b))) 
    error('ITA_NEGATE:Oh Lord. Function seems not to work properly.')
end

d = ita_negTozero(freqData);

d = ita_posTozero(freqData);

d = timeData.^2;
d = freqData^2;

d = timeData.^(0.5);
d = freqData^(0.5);

d = ita_subtract(timeData,timeData);
d = ita_subtract(freqData,freqData);
if ~(timeData == ita_subtract(ita_add(timeData,freqData),freqData)) 
    error('ITA_SUBTRACT/ITA_ADD:Oh Lord. Function seems not to work properly.')
end


d = ita_sum(freqData);
d = ita_sum(timeData);


d = ita_amplify(timeData,2);
d = ita_amplify(timeData,'2');
d = ita_amplify(timeData,'2dB');


%overloaded stuff
d = a .* tp;
d = a * 2;
d = a .* 2;
d = 2 * a;
d = 2 .* a;

d = a ./ b;
d = a / 2;
d = a ./ 2;
d = 2 / a;
d = 2 ./ a;

d = a + a;
d = a - a;
d = 1 + a;
d = 1 - a;
d = a + 1;
d = a - 1;

d = a^2;
d = sqrt(a_spk);

d = abs(freqData);
d = abs(timeData);

d = sum(freqData);
d = sum(timeData);

d = mean(freqData);
d = mean(timeData);

end