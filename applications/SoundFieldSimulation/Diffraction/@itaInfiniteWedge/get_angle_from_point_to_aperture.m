function alpha = get_angle_from_point_to_aperture( obj, field_point, point_on_aperture )
%Returns angle (radiant) between the ray from field point to aperture point and the
%aperture of the wedge.
%   output angle alpha: 0 <= alpha <= pi/2

%% assertions
dim_fp = size(field_point);
dim_pa = size(point_on_aperture);
if dim_fp(2) ~= 3
    if dim_fp(1) ~= 3
        error( 'Field point must be a row vector of dimension 3' );
    end
    %field_point = field_point';
    dim_fp = size(field_point);
end
if dim_pa(2) ~= 3
    if dim_pa(1) ~= 3
        error( 'Point on Aperture must be a row vector of dimension 3.' );
    end
    %point_on_aperture = point_on_aperture';
    dim_pa = size(point_on_aperture);
end
if dim_fp(1) ~= 1 && dim_pa(1) ~= 1
    if dim_fp(1) ~= dim_pa(1)
        error( 'Use same number of field points and points on aperture' );
    end
end
if ~obj.point_outside_wedge( field_point )
    error( 'Field point must be outside wedge' );
end
if ~obj.point_on_aperture( point_on_aperture )
    error( 'No point on aperture found' )
end

%% begin
norms = sqrt( sum( (point_on_aperture - field_point).^2, 2 ) );
dir_vec = ( point_on_aperture - field_point ) ./ norms;
alpha = acos( sum( dir_vec .* obj.aperture_direction, 2 ) );
mask = alpha > pi/2;
if any(mask)
    alpha(mask) = pi - alpha(mask);
end

end

