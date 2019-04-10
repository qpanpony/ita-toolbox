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

    %% Variables
    L = repmat( obj.location, dim_n, 1 );
    Apex_Dir = repmat( obj.aperture_direction, dim_n, 1 );
    
    %% Calculations
    SR = R - S;
    norm_of_SR = Norm( SR );
    mask = norm_of_SR ~= 0;
    SR_dir = SR(mask, :) ./ norm_of_SR(mask);
    
    % initialize result vector
    ap = zeros( dim_n, 3 );
    
    % Auxilary plane spanned by SR and aux_plane_dir
    aux_plane_dir = cross( SR_dir, Apex_Dir(mask, :), 2 ) ./ Norm( cross( SR_dir, Apex_Dir(mask, :), 2 ) );
    aux_plane_normal = cross( SR_dir, aux_plane_dir, 2 ) ./ Norm( cross( SR_dir, aux_plane_dir, 2 ) );

    % Distance of intersection of auxiliary plane and aperture direction
    % from aperture location
    % aux plane: dot( (x - source_point), aux_plane_normal) = 0
    % aperture line: x = location + dist * aperture_direction
    dist = dot( S(mask, :) - L(mask, :), aux_plane_normal, 2 ) ./ dot( Apex_Dir(mask, :), aux_plane_normal, 2 );
    ap(mask, :) = L(mask, :) + dist .* Apex_Dir(mask, :);

    % In case receiver and source have same position
    if any( norm_of_SR == 0 )
        dist = dot( R(~mask, :) - L(~mask, :), Apex_Dir(~mask, :), 2 );
        ap(~mask, :) = L(~mask, :) + dist * Apex_Dir(~mask, :);
    end
end

function res = Norm( A )
    res = sqrt( sum( A.^2, 2 ) );
end