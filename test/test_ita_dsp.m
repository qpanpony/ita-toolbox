function test_ita_dsp()
%get two signals and a tp

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

sr = 44100;
fftdeg = 10;
a       = ita_generate('flatnoise',1,sr,fftdeg);
a       = ita_merge(a,a,a);

b = ita_mpb_filter(a,[20,7000]);
b = ita_mpb_filter(a,[20,30000]);
b = ita_mpb_filter(a,[0,7000]);
b = ita_mpb_filter(a,[20 0]);
a = ita_time_shift(a,20,'samples');
a = ita_time_window(a,[0.001 0.002],'time');
a = ita_minimumphase(a);
a = ita_zerophase(a);
a = ita_integrate(a);
% a = ita_apparentmass2impedance(a);

%test stfft and inverse
% if ~(ita_ifft(a) == ita_istfft(ita_stfft(a,'blocksize',256)))
%     disp(['Difference is ' num2str(max(max(res.dat)))]);
%     error(['ita_stfft or ita_istfft are not working']);
%     
% end
end