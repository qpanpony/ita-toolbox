function direction = longer_branch_on_aperture( obj, apex_point )
%Returns the direction vector of the longer one of two sections on the aperture devided
%by the aperture point
%   direction:  vector(normalized) pointing in direction of longer section from given aperture
%               point

d1 = norm( obj.aperture_start_point - apex_point );
d2 = norm( obj.aperture_end_point - apex_point );
if d2 >= d1
    direction = obj.aperture_direction;
else
    direction = -obj.aperture_direction;
end

end

