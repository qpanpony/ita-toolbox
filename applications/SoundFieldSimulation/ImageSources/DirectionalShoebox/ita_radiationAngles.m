function state = ita_radiationAngles(params,state,dirs)
% Noam Shabtai
% Institution of Technical Acoustics
% RWTH Aachen
% nsh@akustik.rwth-aachen.de
% 24.7.2014

switch params.stages.radiation_angles
case 0
    return;
case 1
    if params.display.headers disp('Setting image radiation angles...');end
    source_to_receiver_displacements = state.source_to_receiver_displacements;
    left_image_to_receiver_displacements = state.left_image_to_receiver_displacements;
    bottom_image_to_receiver_displacements = state.bottom_image_to_receiver_displacements;
    backward_image_to_receiver_displacements = state.backward_image_to_receiver_displacements;
    left_bottom_image_to_receiver_displacements = state.left_bottom_image_to_receiver_displacements;
    left_backward_image_to_receiver_displacements = state.left_backward_image_to_receiver_displacements;
    bottom_backward_image_to_receiver_displacements = state.bottom_backward_image_to_receiver_displacements;
    left_bottom_backward_image_to_receiver_displacements = state.left_bottom_backward_image_to_receiver_displacements;

    [source_to_receiver_phi, source_to_receiver_theta] = cart2sph(source_to_receiver_displacements(:,1),source_to_receiver_displacements(:,2),source_to_receiver_displacements(:,3));
    [left_image_to_receiver_phi, left_image_to_receiver_theta] = cart2sph(left_image_to_receiver_displacements(:,1),left_image_to_receiver_displacements(:,2),left_image_to_receiver_displacements(:,3));
    [bottom_image_to_receiver_phi, bottom_image_to_receiver_theta] = cart2sph(bottom_image_to_receiver_displacements(:,1),bottom_image_to_receiver_displacements(:,2),bottom_image_to_receiver_displacements(:,3));
    [backward_image_to_receiver_phi, backward_image_to_receiver_theta] = cart2sph(backward_image_to_receiver_displacements(:,1),backward_image_to_receiver_displacements(:,2),backward_image_to_receiver_displacements(:,3));
    [left_bottom_image_to_receiver_phi, left_bottom_image_to_receiver_theta] = cart2sph(left_bottom_image_to_receiver_displacements(:,1),left_bottom_image_to_receiver_displacements(:,2),left_bottom_image_to_receiver_displacements(:,3));
    [left_backward_image_to_receiver_phi, left_backward_image_to_receiver_theta] = cart2sph(left_backward_image_to_receiver_displacements(:,1),left_backward_image_to_receiver_displacements(:,2),left_backward_image_to_receiver_displacements(:,3));
    [bottom_backward_image_to_receiver_phi, bottom_backward_image_to_receiver_theta] = cart2sph(bottom_backward_image_to_receiver_displacements(:,1),bottom_backward_image_to_receiver_displacements(:,2),bottom_backward_image_to_receiver_displacements(:,3));
    [left_bottom_backward_image_to_receiver_phi, left_bottom_backward_image_to_receiver_theta] = cart2sph(left_bottom_backward_image_to_receiver_displacements(:,1),left_bottom_backward_image_to_receiver_displacements(:,2),left_bottom_backward_image_to_receiver_displacements(:,3));

    left_image_to_receiver_phi = pi-left_image_to_receiver_phi;
    bottom_image_to_receiver_theta = pi-bottom_image_to_receiver_theta;
    backward_image_to_receiver_phi = -backward_image_to_receiver_phi;
    left_bottom_image_to_receiver_phi = pi-left_bottom_image_to_receiver_phi;
    left_bottom_image_to_receiver_theta = pi-left_bottom_image_to_receiver_theta;
    left_backward_image_to_receiver_phi = pi+left_backward_image_to_receiver_phi;
    bottom_backward_image_to_receiver_phi = -bottom_backward_image_to_receiver_phi;
    bottom_backward_image_to_receiver_theta = pi-bottom_backward_image_to_receiver_theta;
    left_bottom_backward_image_to_receiver_phi = pi+left_bottom_backward_image_to_receiver_phi;
    left_bottom_backward_image_to_receiver_theta = pi-left_bottom_backward_image_to_receiver_theta;

    radiation_angles.theta_Rx1 = [...
    source_to_receiver_theta;...
    left_image_to_receiver_theta;...
    bottom_image_to_receiver_theta;...
    backward_image_to_receiver_theta;...
    left_bottom_image_to_receiver_theta;...
    left_backward_image_to_receiver_theta;...
    bottom_backward_image_to_receiver_theta;...
    left_bottom_backward_image_to_receiver_theta;...
    ];
    radiation_angles.phi_Rx1 = [...
    source_to_receiver_phi;...
    left_image_to_receiver_phi;...
    bottom_image_to_receiver_phi;...
    backward_image_to_receiver_phi;...
    left_bottom_image_to_receiver_phi;...
    left_backward_image_to_receiver_phi;...
    bottom_backward_image_to_receiver_phi;...
    left_bottom_backward_image_to_receiver_phi;...
    ];
    if params.mode.save_intermediate_results
        save(fullfile(dirs.parent_dir,dirs.mat_dir,...
                      dirs.radiation_angles_filename),...
            'radiation_angles');
    end
case 2
    if params.display.headers disp('Loading image radiation angles...');end
    load(fullfile(dirs.parent_dir,dirs.mat_dir,...
                  dirs.radiation_angles_filename),...
        'radiation_angles');
end

state.radiation_angles = radiation_angles;
