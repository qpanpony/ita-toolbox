function dirs = ita_initDirs(params)
% Noam Shabtai
% Institution of Technical Acoustics
% RWTH Aachen
% nsh@akustik.rwth-aachen.de
% 24.7.2014

parent_dir = fileparts(pwd);
dirs.parent_dir = parent_dir;

mat_dir = 'mat';
dirs.mat_dir = mat_dir;

warning off MATLAB:MKDIR:DirectoryExists
mkdir(parent_dir, mat_dir);

reflection_coefficient_power_vector_filename = 'reflection_coefficient_power_vector';
dirs.reflection_coefficient_power_vector_filename = reflection_coefficient_power_vector_filename;

reflection_coefficients_filename = 'reflection_coefficients';
dirs.reflection_coefficients_filename = reflection_coefficients_filename;

room_displacements_filename = 'room_displacements';
dirs.room_displacements_filename = room_displacements_filename;

image_to_receiver_displacements_filename = 'image_to_receiver_displacements';
dirs.image_to_receiver_displacements_filename = image_to_receiver_displacements_filename;

image_receiver_distances_filename = 'image_receiver_distances';
dirs.image_receiver_distances_filename = image_receiver_distances_filename;

radiation_angles_filename = 'radiation_angles';
dirs.radiation_angles_filename = radiation_angles_filename;

radiation_spherical_harmonics_filename = 'radiation_spherical_harmonics';
radiation_spherical_harmonics_filename = sprintf('%s_N_%d',...
                                     radiation_spherical_harmonics_filename,...
                                     params.source.radiation.order);
dirs.radiation_spherical_harmonics_filename = radiation_spherical_harmonics_filename;

directivity_angles_filename = 'directivity_angles';
dirs.directivity_angles_filename = directivity_angles_filename;

directivity_spherical_harmonics_filename = 'directivity_spherical_harmonics';
directivity_spherical_harmonics_filename = sprintf('%s_N_%d',...
                                     directivity_spherical_harmonics_filename,...
                                     params.source.radiation.order);
dirs.directivity_spherical_harmonics_filename = directivity_spherical_harmonics_filename;

reflections_filename = 'reflections';
reflections_filename = sprintf('%s_N_%d',...
                                     reflections_filename,...
                                     params.source.radiation.order);
if strcmp(params.mode.domain.method,'sh_to_sh')
    reflections_filename = sprintf('%s_%d',...
                                    reflections_filename,...
                                    params.microphone.directivity.order);
end
dirs.reflections_filename = reflections_filename;


rir_signal_filename = 'rir_signal';
dirs.rir_signal_filename = rir_signal_filename;
