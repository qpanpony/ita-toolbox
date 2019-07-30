function aperture_point = get_aperture_point( obj, source_pos, receiver_pos )
% get_aperture_point Returns aperture point on wedge (closest point on wedge
% between source and receiver)
    
assert( numel( source_pos ) == 3 )
assert( numel( receiver_pos ) == 3 )


%% Calculations

source_receiver_vec = receiver_pos - source_pos;
source_receiver_dir = source_receiver_vec / norm( source_receiver_vec );
aperture_dir = obj.aperture_direction / norm( obj.aperture_direction );

if norm( source_receiver_vec ) == 0
    warning( '@todo auxiliar plane must be created differently if source and receiver positions are equal. Trying to continue.' )
end

% Auxilary plane spanned by source_receiver_dir and aux_plane_dir (closest
% line between aperture vector and source-receiver-vector
aux_plane_vec = cross( source_receiver_dir, aperture_dir );
aux_plane_dir = aux_plane_vec / norm( aux_plane_vec );
aux_plane_normal = cross( source_receiver_dir, aux_plane_dir );


% Determine intersection of line (aperture) and auxiliary plane

lambda_divisor = ( -1 ) * dot( aux_plane_normal, aperture_dir );
assert( lambda_divisor ~= 0 )

lambda = dot( aux_plane_normal, obj.location ) / lambda_divisor;
aperture_point = obj.location + lambda * aperture_dir;

end