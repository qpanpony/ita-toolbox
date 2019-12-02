function b = point_on_aperture( obj, point )
% Returns true if point is on aperture of the wedge and between start and
% end point of the aperture

if numel( point ) ~= 3
    error( 'Point must be of dimension 3' );
end


segment_1 = ( point - obj.aperture_start_point );
segment_2 = ( obj.aperture_end_point - point );

diff_norm = obj.length - norm( segment_1 ) - norm( segment_2 );
if abs( diff_norm ) > obj.set_get_geo_eps %changed frm < to >, as if point is on aperture, diff_norm should == 0
    b = false;
else
    b = true;
end

end
