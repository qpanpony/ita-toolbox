function test_ita_Value()

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

a = itaValue('-0.20 kg');
b = itaValue(2);
c = itaValue(21,'N');
d = itaValue();
s = ita_generate('noise',1,44100,14);

%% stupid arithmetic
disp('aritmetic test')
x = a + b;
x = 2 + b;
x = b + 2;

x = a - b;
x = 2 - b;
x = b - 2;

x = a * b;
x = 2 * b;
x = b * 2;

x = a .* b;
x = 2 .* b;
x = b .* 2;

x = a / b;
x = 2 / b;
x = b / 2;

x = a ./ b;
x = 2 ./ b;
x = b ./ 2;

x = sqrt(b);
x = power(b,2);
x = power(2,b);

x = log(c);
x = log10(c);
x = exp(c);

%% test with itaAudio object
disp('test with audio objects')
res = a * s;
res = a .* s;
res = a / s;
res = a ./ s;
