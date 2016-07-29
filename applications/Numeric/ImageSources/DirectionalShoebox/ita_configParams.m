function params = ita_configParams
% Noam Shabtai
% Institution of Technical Acoustics
% RWTH Aachen
% nsh@akustik.rwth-aachen.de
% 24.7.2014

params.mode.reflection_coefficients.options = {'from_t60','given'};
params.mode.reflection_coefficients.method = 'given';
params.mode.domain.options = {'sh_to_rir','sh_to_sh'};
params.mode.domain.method = 'sh_to_sh';
params.mode.microphone_directivity.options = {'preset_sh','figure_of_eights','omni'};
params.mode.microphone_directivity.method = 'omni';
params.mode.save_intermediate_results = 0;

params.stages.reflection_coefficient_power_vector = 1;
params.stages.reflection_coefficients_and_room_displacements = 1;
params.stages.image_receiver_displacements = 1;
params.stages.image_receiver_distances = 1;
params.stages.radiation_angles = 1;
params.stages.radiation_spherical_harmonics = 1;
params.stages.directivity_angles = 1;
params.stages.directivity_spherical_harmonics = 1;
params.stages.reflection_gains = 1;
params.stages.reflection_times = 1;
params.stages.order_reflections_into_rir = 1;
params.stages.rir.filter = 0;
params.stages.schroeder_decay = 0;

params.display.headers = 1;
params.display.rir = 1;
params.display.schroeder_decay = 1;

params.room.dimensions = [10 10 5];
params.room.reverberation_time = 0.5;

params.spherical_harmonics.base = 'complex';

params.wall.reflection_coefficients.Rxy_z_0 = 0.001;
params.wall.reflection_coefficients.Rxy_z_Lz = 0.001;
params.wall.reflection_coefficients.Rxz_y_0 = 0.001;
params.wall.reflection_coefficients.Rxz_y_Ly = 0.001;
params.wall.reflection_coefficients.Ryz_x_0 = 0.8;
params.wall.reflection_coefficients.Ryz_x_Lx = 0.001;

params.source.location = [2 5 0.5];
params.source.radiation.order = 11;

params.microphone.location = [8 5.2 2.5];
params.microphone.directivity.order = 7;

params.rir.maximum_time = 0.3;
params.rir.sampling_frequency = 44.1e3;

params.filter.normalized_band = [0.025 0.9];
params.filter.order = 4;

params.speed_of_sound = 343.1;

params.schroeder_decay.options = {'3T20','iso','edt'};
params.schroeder_decay.method = 'iso';
params.schroeder_decay.frequency_index = 1;
