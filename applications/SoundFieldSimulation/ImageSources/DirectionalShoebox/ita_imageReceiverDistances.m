function state = ita_imageReceiverDistances(params,state,dirs)
% Noam Shabtai
% Institution of Technical Acoustics
% RWTH Aachen
% nsh@akustik.rwth-aachen.de
% 24.7.2014

switch params.stages.image_receiver_distances
case 0
    return;
case 1
    if params.display.headers disp('Setting image-receiver distances...');end
    source_to_receiver_displacements = state.source_to_receiver_displacements;
    left_image_to_receiver_displacements = state.left_image_to_receiver_displacements;
    bottom_image_to_receiver_displacements = state.bottom_image_to_receiver_displacements;
    backward_image_to_receiver_displacements = state.backward_image_to_receiver_displacements;
    left_bottom_image_to_receiver_displacements = state.left_bottom_image_to_receiver_displacements;
    left_backward_image_to_receiver_displacements = state.left_backward_image_to_receiver_displacements;
    bottom_backward_image_to_receiver_displacements = state.bottom_backward_image_to_receiver_displacements;
    left_bottom_backward_image_to_receiver_displacements = state.left_bottom_backward_image_to_receiver_displacements;

    source_receiver_distances = sqrt(sum(source_to_receiver_displacements.^2,2));
    left_image_receiver_distances = sqrt(sum(left_image_to_receiver_displacements.^2,2));
    bottom_image_receiver_distances = sqrt(sum(bottom_image_to_receiver_displacements.^2,2));
    backward_image_receiver_distances = sqrt(sum(backward_image_to_receiver_displacements.^2,2));
    left_bottom_image_receiver_distances = sqrt(sum(left_bottom_image_to_receiver_displacements.^2,2));
    left_backward_image_receiver_distances = sqrt(sum(left_backward_image_to_receiver_displacements.^2,2));
    bottom_backward_image_receiver_distances = sqrt(sum(bottom_backward_image_to_receiver_displacements.^2,2));
    left_bottom_backward_image_receiver_distances = sqrt(sum(left_bottom_backward_image_to_receiver_displacements.^2,2));

    sources_receiver_distances = [...
    source_receiver_distances;...
    left_image_receiver_distances;...
    bottom_image_receiver_distances;...
    backward_image_receiver_distances;...
    left_bottom_image_receiver_distances;...
    left_backward_image_receiver_distances;...
    bottom_backward_image_receiver_distances;...
    left_bottom_backward_image_receiver_distances;...
    ];

    if params.mode.save_intermediate_results
        save(fullfile(dirs.parent_dir,dirs.mat_dir,...
                      dirs.image_receiver_distances_filename),...
            'sources_receiver_distances');
    end
case 2
    if params.display.headers disp('Loading image-receiver distances...');end
    load(fullfile(dirs.parent_dir,dirs.mat_dir,...
                  dirs.image_receiver_distances_filename),...
        'sources_receiver_distances');
end

state.sources_receiver_distances = sources_receiver_distances;
