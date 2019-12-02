%% Init
% infite wedge
inf_wdg = ita_diffraction_create_standard_rectangular_wedge();

% Point
point_start_pos = [ 1, 0, 0];
point_end_pos = [-1, 0, 0];
num_of_positions = 100;

%% Align points around aperture
apex_point = [0, 0, 0];

point_pos_start_angle = inf_wdg.get_angle_from_point_to_wedge_face(point_start_pos, false);
point_pos_end_angle = inf_wdg.get_angle_from_point_to_wedge_face(point_end_pos, false);
point_angles = linspace( point_pos_start_angle, point_pos_end_angle, num_of_positions );

%% Set different receiver positions rotated around the aperture
aligned_positions = ita_diffraction_align_points_around_aperture( inf_wdg, point_start_pos, point_angles, apex_point, false );

orig_dist = norm(point_start_pos);
for i = 1 : size(aligned_positions, 1)
    diff = norm( aligned_positions(i, :) ) - orig_dist;
    assert( abs( diff ) < inf_wdg.set_get_geo_eps * 10 )
end

disp( 'Test passed' )
