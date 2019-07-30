function ap = get_aperture_point2( obj, source_pos, receiver_pos )
    start = obj.aperture_start_point;
    dir = obj.aperture_direction;
    
    S_on_ap = orthogonal_projection( start, dir, source_pos ); %project the source to the aperture
    S_t = (S_on_ap - start) / dir; S_t = S_t(1,1); %find the parametric distance along the aperture
    R_on_ap = orthogonal_projection( start, dir, receiver_pos ); %same as above but for receiver
    R_t = (R_on_ap - start) / dir; R_t = R_t(1,1);
    
    start_t = min( S_t, R_t ); %start the optimisation at whichever of the projected source/ receiver comes first on the aperture
    end_t = max( S_t, R_t ); %finish at the other
    t = fminbnd(@(t)total_path_distance(t, source_pos, receiver_pos, start, dir), start_t, end_t );
   
    ap = start + t*dir; %using the optimised parameter, find the aperture position
end


function dist = total_path_distance(t, source_pos, receiver_pos, start, dir)
    P = start + (t*dir); %P = point on the aperture
    dist = norm(P - source_pos) + norm(receiver_pos - P); %given point on aperture, source and receiver positions, calculate the distance traveled
end

function point_on_line = orthogonal_projection(line_point,line_dir,point)
    point_on_line = line_point + dot(point-line_point,line_dir) / dot(line_dir,line_dir) * line_dir;
end