

% <ITA-Toolbox>
% This file is part of the application Microflown for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% free field reference shot
res_ff = ms_microflown.run;

% windowing
ffwin = [0.005 0.010];
cutting_fftdegree = 9; % fftdegree 10 -> 23ms
p_ff = ita_time_window(res_ff.ch(1)*itaValue(1,'Pa'), ffwin);
v_ff = ita_time_window(res_ff.ch(2)*itaValue(1,'m/s'), ffwin);
p_ff = ita_extract_dat(p_ff, cutting_fftdegree);
v_ff = ita_extract_dat(v_ff, cutting_fftdegree);


% calc free field impedance
Z_ff = p_ff/v_ff;
d_ff = double( ita_start_IR(p_ff)/p_ff.samplingRate * c );

f = Z_ff.freqVector;
sphereFactor = itaAudio(1./(1 + 1./(1i.*2*pi*f./double(c).*d_ff)),Z_ff.samplingRate,'freq');


ita_write(p_ff, 'p_ff_meas.ita', 'overwrite');
ita_write(v_ff, 'v_ff_meas.ita', 'overwrite');
ita_write(Z_ff, 'Z_ff_meas.ita', 'overwrite');


