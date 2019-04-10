function state = ita_radiationSphericalHarmonics(params,state,dirs)
% Noam Shabtai
% Institution of Technical Acoustics
% RWTH Aachen
% nsh@akustik.rwth-aachen.de
% 24.7.2014

switch params.stages.radiation_spherical_harmonics
case 0
    return;
case 1
    if params.display.headers disp('Calculating image radiation spherical harmonics...');end
    N = params.source.radiation.order;
    base = params.spherical_harmonics.base;
    theta_Rx1 = state.radiation_angles.theta_Rx1;
    phi_Rx1 = state.radiation_angles.phi_Rx1;
    radiation_Ynm_RxNM = ita_sphericalHarmonics(base,N,theta_Rx1,phi_Rx1).';

    if params.mode.save_intermediate_results
        save(fullfile(dirs.parent_dir,dirs.mat_dir,...
                      dirs.radiation_spherical_harmonics_filename),...
        'radiation_Ynm_RxNM');
    end
case 2
    if params.display.headers disp('Loading image radiation spherical harmonics...');end
    load(fullfile(dirs.parent_dir,dirs.mat_dir,...
                  dirs.radiation_spherical_harmonics_filename),...
    'radiation_Ynm_RxNM');
end

state.radiation_Ynm_RxNM = radiation_Ynm_RxNM;
