function ap = get_aperture_point( obj, source_pos, receiver_pos )
    % Returns aperture point on wedge (closest point on wedge
    % between source and receiver)
    
    %% Verification
    dim_src = size( source_pos );
    dim_rcv = size( receiver_pos );
    if dim_src(2) ~= 3
        if dim_src(1) ~= 3
            error( 'Source point(s) must be of dimension 3')
        end
        source_pos = source_pos';
        dim_src = size( source_pos );
    end
    if dim_rcv(2) ~= 3
        if dim_rcv(1) ~= 3
            error( 'Receiver point(s) must be of dimension 3')
        end
        receiver_pos = receiver_pos';
        dim_rcv = size( receiver_pos );
    end
    if dim_src(1) ~= 1 && dim_rcv(1) ~= 1 && dim_src(1) ~= dim_rcv(1)
        error( 'Number of receiver and source positions do not match' )
    end
    if dim_src(1) > dim_rcv(1)
        dim_n = dim_src(1);
        S = source_pos;
        R = repmat( receiver_pos, dim_n, 1 );
    elseif dim_src(1) < dim_rcv(1)
        dim_n = dim_rcv(1);
        S = repmat( source_pos, dim_n, 1 );
        R = receiver_pos;
    else
        dim_n = dim_src(1);
        S = source_pos;
        R = receiver_pos;
    end
    
    if( size( S, 2 ) ~= 3 )
        S = S';
    end
    if( size( R, 2 ) ~= 3 )
        R = R';
    end
    
    assert( size( S, 2 ) == 3 )
    assert( size( R, 2 ) == 3 )

    %% Variables
    L = obj.location;
    Apex_Dir = obj.aperture_direction;
    assert( numel( Apex_Dir ) == 3 )
    assert( numel( L ) == 3 )
    
    %% Calculations
    SR = R - S;
    SR_dir = SR ./ norm( SR );
    
    assert( norm( SR ) > 0 ); % @todo Auxiliar plane must be created differently if S and R are equal
    
    % Auxilary plane spanned by SR and aux_plane_dir
    aux_plane_dir = cross( SR_dir, Apex_Dir ) ./ norm( cross( SR_dir, Apex_Dir ) );
    aux_plane_normal = cross( SR_dir, aux_plane_dir ) ./ norm( cross( SR_dir, aux_plane_dir ) );

    % Distance of intersection of auxiliary plane and aperture direction
    % from aperture location
    % aux plane: dot( (x - source_point), aux_plane_normal) = 0
    % aperture line: x = location + dist * aperture_direction
    dist = dot( S - L, aux_plane_normal ) ./ dot( Apex_Dir, aux_plane_normal );
    ap = L + dist .* Apex_Dir;

end
