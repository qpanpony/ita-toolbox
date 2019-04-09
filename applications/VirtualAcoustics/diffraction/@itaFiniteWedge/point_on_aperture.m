function b = point_on_aperture( obj, point )
% Returns true if point is on aperture of the wedge and between start and
% end point of the aperture
dim = size( point );
if dim(1) ~= 3 && dim(2) ~= 3
    error( 'Point must be of dimension 3' );
end

b = zeros( numel(point) / 3, 1 );
norms = sqrt( sum( (point - obj.location).^2, 2 ) );
condition1 = norms < obj.set_get_geo_eps;
if any( condition1 )
    b = b | condition1;
end
dir1 = ( point - obj.location ) ./ norms;
dir2 = ( point - obj.aperture_end_point ) ./ sqrt( sum( (point - obj.aperture_end_point).^2, 2 ) );
dir1_norms = sqrt( sum( (dir1 - obj.aperture_direction).^2, 2 ) );
dir2_norms = sqrt( sum( (dir2 + obj.aperture_direction).^2, 2 ) );
condition2 = (dir1_norms < obj.set_get_geo_eps | dir2_norms < obj.set_get_geo_eps) & norms < obj.length;
if any( condition2 )
    b = b | condition2;
end
b = all(b);

end

