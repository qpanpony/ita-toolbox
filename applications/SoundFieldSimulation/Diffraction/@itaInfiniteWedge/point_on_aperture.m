function b = point_on_aperture( obj, point )
% Returns true if point is on aperture of the wedge

if numel( point ) ~= 3
    error( 'Point must be of dimension 3' );
end

b = false;

d = point - obj.location;
if norm( d ) < obj.set_get_geo_eps
    b = true; % Point is indescriminably close to wedge location
else
    
    dir1 = d / norm( d );
    
    d2 = obj.aperture_direction;
    dir2 = d2 / norm( d2 );
    
    % Point should have same (or opposite) direction as aperture
    if 1 - abs( dot( dir1, dir2 ) ) < obj.set_get_geo_eps 
        b = true;
    end
    
end
