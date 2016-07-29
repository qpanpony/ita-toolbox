function state = ita_imageReceiverDisplacements(params,state,dirs)
% Noam Shabtai
% Institution of Technical Acoustics
% RWTH Aachen
% nsh@akustik.rwth-aachen.de
% 24.7.2014

switch params.stages.image_receiver_displacements
case 0
    return;
case 1
    if params.display.headers disp('Setting image-receiver displacements...');end
    xs = params.source.location;
    xm = params.microphone.location;

    num_of_rooms = state.num_of_rooms;
    room_displacements = state.room_displacements;

    image_locations_of_source = ones(num_of_rooms,1)*(xs.*[ 1  1  1]) + room_displacements;
    image_locations_of_left_image = ones(num_of_rooms,1)*(xs.*[-1  1  1]) + room_displacements;
    image_locations_of_bottom_image = ones(num_of_rooms,1)*(xs.*[ 1 -1  1]) + room_displacements;
    image_locations_of_backward_image = ones(num_of_rooms,1)*(xs.*[ 1  1 -1]) + room_displacements;
    image_locations_of_left_bottom_image = ones(num_of_rooms,1)*(xs.*[-1 -1  1]) + room_displacements;
    image_locations_of_left_backward_image = ones(num_of_rooms,1)*(xs.*[-1  1 -1]) + room_displacements;
    image_locations_of_bottom_backward_image = ones(num_of_rooms,1)*(xs.*[ 1 -1 -1]) + room_displacements;
    image_locations_of_left_bottom_backward_image = ones(num_of_rooms,1)*(xs.*[-1 -1 -1]) + room_displacements;

    source_to_receiver_displacements = repmat(xm,num_of_rooms,1)-image_locations_of_source;
    left_image_to_receiver_displacements = repmat(xm,num_of_rooms,1)-image_locations_of_left_image;
    bottom_image_to_receiver_displacements = repmat(xm,num_of_rooms,1)-image_locations_of_bottom_image;
    backward_image_to_receiver_displacements = repmat(xm,num_of_rooms,1)-image_locations_of_backward_image;
    left_bottom_image_to_receiver_displacements = repmat(xm,num_of_rooms,1)-image_locations_of_left_bottom_image;
    left_backward_image_to_receiver_displacements = repmat(xm,num_of_rooms,1)-image_locations_of_left_backward_image;
    bottom_backward_image_to_receiver_displacements = repmat(xm,num_of_rooms,1)-image_locations_of_bottom_backward_image;
    left_bottom_backward_image_to_receiver_displacements = repmat(xm,num_of_rooms,1)-image_locations_of_left_bottom_backward_image;

    if params.mode.save_intermediate_results
        save(fullfile(dirs.parent_dir,dirs.mat_dir,...
                      dirs.image_to_receiver_displacements_filename),...
        'source_to_receiver_displacements',...
        'left_image_to_receiver_displacements',...
        'bottom_image_to_receiver_displacements',...
        'backward_image_to_receiver_displacements',...
        'left_bottom_image_to_receiver_displacements',...
        'left_backward_image_to_receiver_displacements',...
        'bottom_backward_image_to_receiver_displacements',...
        'left_bottom_backward_image_to_receiver_displacements');
    end
case 2
    if params.display.headers disp('Loading image-receiver displacements...');end
    load(fullfile(dirs.parent_dir,dirs.mat_dir,...
                  dirs.image_to_receiver_displacements_filename),...
    'source_to_receiver_displacements',...
    'left_image_to_receiver_displacements',...
    'bottom_image_to_receiver_displacements',...
    'backward_image_to_receiver_displacements',...
    'left_bottom_image_to_receiver_displacements',...
    'left_backward_image_to_receiver_displacements',...
    'bottom_backward_image_to_receiver_displacements',...
    'left_bottom_backward_image_to_receiver_displacements');
end

state = rmfield(state, 'room_displacements');

state.source_to_receiver_displacements = source_to_receiver_displacements;
state.left_image_to_receiver_displacements = left_image_to_receiver_displacements;
state.bottom_image_to_receiver_displacements = bottom_image_to_receiver_displacements;
state.backward_image_to_receiver_displacements = backward_image_to_receiver_displacements;
state.left_bottom_image_to_receiver_displacements = left_bottom_image_to_receiver_displacements;
state.left_backward_image_to_receiver_displacements = left_backward_image_to_receiver_displacements;
state.bottom_backward_image_to_receiver_displacements = bottom_backward_image_to_receiver_displacements;
state.left_bottom_backward_image_to_receiver_displacements = left_bottom_backward_image_to_receiver_displacements;
