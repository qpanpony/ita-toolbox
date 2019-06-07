function state = ita_reflectionCoefficientPowerVector(params,state,dirs)
% Noam Shabtai
% Institution of Technical Acoustics
% RWTH Aachen
% nsh@akustik.rwth-aachen.de
% 24.7.2014

switch params.stages.reflection_coefficient_power_vector
case 0
    return;
case 1
    if params.display.headers disp('Setting reflection coefficient power vector...');end
    c    = params.speed_of_sound; 
    L    = params.wall.length;
    R    = params.wall.reflection_coefficients;
    Tmax = params.rir.maximum_time;

    num_of_x_images = ceil(Tmax*c/(2*L.x));
    num_of_y_images = ceil(Tmax*c/(2*L.y));
    num_of_z_images = ceil(Tmax*c/(2*L.z));
    num_of_images = (2*num_of_x_images-1) * (2*num_of_z_images-1) * (2*num_of_y_images-1);

    x_index     = -num_of_x_images+1 : num_of_x_images-1;
    num_of_x_indices   = length(x_index);
    y_index     = -num_of_y_images+1 : num_of_y_images-1; 
    num_of_y_indices   = length(y_index);
    z_index     = -num_of_z_images+1 : num_of_z_images-1; 
    num_of_z_indices   = length(z_index);

    reflection_coefficient_power_vector_yz_x_0 = (R.Ryz_x_0 .^(0:num_of_x_images)).';   
    reflection_coefficient_power_vector_yz_x_Lx= (R.Ryz_x_Lx.^(0:num_of_x_images)).';   
    reflection_coefficient_power_vector_xz_y_0 = (R.Rxz_y_0 .^(0:num_of_y_images)).';   
    reflection_coefficient_power_vector_xz_y_Ly= (R.Rxz_y_Ly.^(0:num_of_y_images)).';   
    reflection_coefficient_power_vector_xy_z_0 = (R.Rxy_z_0 .^(0:num_of_z_images)).';   
    reflection_coefficient_power_vector_xy_z_Lz= (R.Rxy_z_Lz.^(0:num_of_z_images)).';   

    if params.mode.save_intermediate_results
        save(fullfile(dirs.parent_dir,dirs.mat_dir,...
                      dirs.reflection_coefficient_power_vector_filename),...
        'num_of_images',...
        'num_of_x_images',...
        'num_of_y_images',...
        'num_of_z_images',...
        'num_of_x_indices',...
        'num_of_y_indices',...
        'num_of_z_indices',...
        'reflection_coefficient_power_vector_yz_x_0',...
        'reflection_coefficient_power_vector_yz_x_Lx',...
        'reflection_coefficient_power_vector_xz_y_0',...
        'reflection_coefficient_power_vector_xz_y_Ly',...
        'reflection_coefficient_power_vector_xy_z_0',...
        'reflection_coefficient_power_vector_xy_z_Lz');
    end
case 2
    if params.display.headers disp('Loading reflection coefficient power vector...');end
    load(fullfile(dirs.parent_dir,dirs.mat_dir,...
                  dirs.reflection_coefficient_power_vector_filename),...
    'num_of_images',...
    'num_of_x_images',...
    'num_of_y_images',...
    'num_of_z_images',...
    'num_of_x_indices',...
    'num_of_y_indices',...
    'num_of_z_indices',...
    'reflection_coefficient_power_vector_yz_x_0',...
    'reflection_coefficient_power_vector_yz_x_Lx',...
    'reflection_coefficient_power_vector_xz_y_0',...
    'reflection_coefficient_power_vector_xz_y_Ly',...
    'reflection_coefficient_power_vector_xy_z_0',...
    'reflection_coefficient_power_vector_xy_z_Lz');
end

state.num_of_images = num_of_images;
state.num_of_x_images = num_of_x_images;
state.num_of_y_images = num_of_y_images;
state.num_of_z_images = num_of_z_images;
state.num_of_x_indices = num_of_x_indices;
state.num_of_y_indices = num_of_y_indices;
state.num_of_z_indices = num_of_z_indices;
state.reflection_coefficient_power_vector_yz_x_0  = reflection_coefficient_power_vector_yz_x_0;
state.reflection_coefficient_power_vector_yz_x_Lx = reflection_coefficient_power_vector_yz_x_Lx;
state.reflection_coefficient_power_vector_xz_y_0  = reflection_coefficient_power_vector_xz_y_0;
state.reflection_coefficient_power_vector_xz_y_Ly = reflection_coefficient_power_vector_xz_y_Ly;
state.reflection_coefficient_power_vector_xy_z_0  = reflection_coefficient_power_vector_xy_z_0;
state.reflection_coefficient_power_vector_xy_z_Lz = reflection_coefficient_power_vector_xy_z_Lz;