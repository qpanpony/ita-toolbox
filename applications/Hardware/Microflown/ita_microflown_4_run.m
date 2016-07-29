

% <ITA-Toolbox>
% This file is part of the application Microflown for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% make real measurement
res = ms_microflown.run;

% windowing
p_mess = ita_time_window(res.ch(1)*itaValue(1,'Pa'),  ffwin);
v_mess = ita_time_window(res.ch(2)*itaValue(1,'m/s'), ffwin);
p_mess = ita_extract_dat(p_mess, cutting_fftdegree);
v_mess = ita_extract_dat(v_mess, cutting_fftdegree);


Z_mess = p_mess/v_mess;


%% calculate field impedance
Z_field_norm = Z_mess/Z_ff*sphereFactor;
Z_field = Z_field_norm*c*rho0;
% ita_write(Z_field,'Z_field_meas.ita');
% ita_plot_freq_phase(Z_field,'xlim',[100 8000],'ylim',[10 80]);


%% calculate absorption
h = 0.01; % change according to setup
h_s = 0.32 + h; % change according to setup
[z_surface_meas, R_meas, alpha_meas] = ita_get_surface_impedance( ...
                                                 p_mess, v_mess, h, ...
                                                 'method', 3, ...
                                                 'calibType', 'ff', ...
                                                 'calibData', {p_ff, v_ff}, ...
                                                 'r_ff',d_ff, ...
                                                 'dSourceSample', h_s, ...
                                                 'temperature', temp, ...
                                                 'pressure', 101.3 ...
                                                 );
alpha_meas.channelNames = {'Absorption gemessen'};
% ita_write(alpha_meas,'alpha_meas.ita');
% ita_plot_freq(alpha_meas,'xlim',[90 6900],'ylim',[-0.4 1],'nodb');
