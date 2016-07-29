function test_ita_fileIO()

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

warning('test_ita_fileIO: Lots of comments here, please check me!')
sr     = 44100;
fftdeg = 14;
a      = ita_generate_sweep('mode','lin','freqRange',[2 22000],'samplingRate',44100,'fftDegree',15);

%% test dat
nBits = [16 24 32];
for idx = nBits
%    ita_write(a,'test.dat',idx);
%     b = ita_read('test.dat');
%     if  ~ita_issimilar(a,b);
%         fprintf(2,'OH LORD: *** IO ROUTINES ARE BAD ***')
%         disp(['.dat -- nBits: ' num2str(idx)])
%     end
end

%% test spk
% nBits = [16 24 32];
% for idx = nBits
%     ita_write(a,'test.spk',idx);
%     b = ita_read('test.spk');
%     if  ~ita_issimilar(a,b);
%         fprintf(2,'OH LORD: *** IO ROUTINES ARE BAD ***')
%         disp(['.spk -- nBits: ' num2str(idx)])
%     end
% end

%% test ita
warning(['please check the commented functions in ' mfilename])
% ita_write(a,'test.ita')
% b = ita_read('test.ita');
% c = a-b;
% if sum(c.dat.^2) ~= 0
%     fprintf(2,'OH LORD: *** IO ROUTINES ARE BAD ***')
%     disp('.ita')
% end
end

function res = ita_issimilar(a,b)

sArgs   = struct('pos1_a','itaAudioTime','pos2_b','itaAudioTime');

[a,b,sArgs] = ita_parse_arguments(sArgs,{a,b});  %#ok<ASGLU>

c_a = a-b; % %see if everything is okay, check is inside;
c   = a.dat - b.dat; %just do it, without checking
res = sum(c.^2)/c_a.nSamples < 1e-7;
if res == 0
    res = 0;
end

end