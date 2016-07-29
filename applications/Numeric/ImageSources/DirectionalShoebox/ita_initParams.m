function params = ita_initParams(params)
% Noam Shabtai
% Institution of Technical Acoustics
% RWTH Aachen
% nsh@akustik.rwth-aachen.de
% 24.7.2014

if ~strcmp(params.mode.domain.method,'sh_to_sh')
    switch params.mode.microphone_directivity.method
    case 'omni'
        params.stages.directivity_angles = 0;
        params.stages.directivity_spherical_harmonics = 0;
    case 'figure_of_eights';
        params.microphone.directivity.order = 1;
        params.microphone.directivity.anm_NMx1 = [0;0;1;0];
    case 'preset_sh'
        otherwise
        error('No such option for microphone directivity.');
    end
end

L = params.room.dimensions;
params.wall.length.x = L(1);  
params.wall.length.y = L(2);  
params.wall.length.z = L(3);  
V = prod(L);
params.room.volume = V;

Sxy = prod(L([1,2]));
Sxz = prod(L([1,3]));
Syz = prod(L([2,3]));
params.wall.surface.Sxy = Sxy;
params.wall.surface.Sxz = Sxz;
params.wall.surface.Syz = Syz;

S = 2*Sxy + 2*Sxz + 2*Syz;
params.room.surface = S;

switch params.mode.reflection_coefficients.method
case 'from_t60'
    T60 = params.room.reverberation_time;
    A = 0.161*V/T60;

    a = A/S;
    a = repmat(a,1,6);

    R = sqrt(1-a);

    params.wall.reflection_coefficients.Ryz_x_0 = R(1);
    params.wall.reflection_coefficients.Ryz_x_Lx= R(2);
    params.wall.reflection_coefficients.Rxz_y_0 = R(3);
    params.wall.reflection_coefficients.Rxz_y_Ly= R(4);
    params.wall.reflection_coefficients.Rxy_z_0 = R(5); 
    params.wall.reflection_coefficients.Rxy_z_Lz= R(6); 
case 'given'
    R = [params.wall.reflection_coefficients.Rxy_z_0,...
         params.wall.reflection_coefficients.Rxy_z_Lz,...
         params.wall.reflection_coefficients.Rxz_y_0,...
         params.wall.reflection_coefficients.Rxz_y_Ly,...
         params.wall.reflection_coefficients.Ryz_x_0,...
         params.wall.reflection_coefficients.Ryz_x_Lx];
    a = 1 - R.^2;
    A = (a(1)+a(2))*Sxy + (a(3)+a(4))*Sxz + (a(5)+a(6))*Syz;
    T60 = 0.161*V/A;
    params.room.reverberation_time = T60;
otherwise
    error('no such method for calculating the reflection coefficients');
end
params.wall.absorption.ayz_x_0 = a(1);
params.wall.absorption.ayz_x_Lx= a(2);
params.wall.absorption.axz_y_0 = a(3);
params.wall.absorption.axz_y_Ly= a(4);
params.wall.absorption.axy_z_0 = a(5); 
params.wall.absorption.axy_z_Lz= a(6); 

params.microphone.displacement_to_source = params.source.location-params.microphone.location;
params.microphone.distance_to_source = norm(params.microphone.displacement_to_source);
[params.microphone.angle_to_source.phi,params.microphone.angle_to_source.theta] =...
    cart2sph(params.microphone.displacement_to_source(1),...
             params.microphone.displacement_to_source(2),...
             params.microphone.displacement_to_source(3) );

switch params.mode.microphone_directivity.method
case 'figure_of_eights';
    N = params.microphone.directivity.order;
    alpha = params.microphone.angle_to_source.phi+pi/2;
    beta = pi/2;
    gamma = 0;
    switch params.spherical_harmonics.base
    case 'complex'
        D_NMxNM = ita_sph_wignerD(N,alpha,beta,gamma);
    otherwise
        D_NMxNM = ita_sph_wignerD_real(N,alpha,beta,gamma);
    end
    params.microphone.directivity.anm_NMx1 = D_NMxNM * params.microphone.directivity.anm_NMx1;
end
