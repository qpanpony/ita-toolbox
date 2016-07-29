function state = ita_directivitySphericalHarmonics(params,state,dirs)
% Noam Shabtai
% Institution of Technical Acoustics
% RWTH Aachen
% nsh@akustik.rwth-aachen.de
% 24.7.2014

switch params.stages.directivity_spherical_harmonics
case 0
    return;
case 1
    if params.display.headers disp('Calculating directivity spherical harmonics...');end
    N = params.microphone.directivity.order;
    base = params.spherical_harmonics.base;
    theta_Rx1 = state.directivity_angles.theta_Rx1;
    phi_Rx1 = state.directivity_angles.phi_Rx1;

    directivity_Ynm_RxNM = ita_sphericalHarmonics(base,N,theta_Rx1,phi_Rx1).';

    if params.mode.save_intermediate_results
        save(fullfile(dirs.parent_dir,dirs.mat_dir,...
                      dirs.directivity_spherical_harmonics_filename),...
        'directivity_Ynm_RxNM');
    end
case 2
    if params.display.headers disp('Loading image spherical harmonics...');end
    load(fullfile(dirs.parent_dir,dirs.mat_dir,...
                  dirs.directivity_spherical_harmonics_filename),...
    'directivity_Ynm_RxNM');
end

state.directivity_Ynm_RxNM = directivity_Ynm_RxNM;
