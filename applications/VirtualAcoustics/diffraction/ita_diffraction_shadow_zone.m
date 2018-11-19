function in_shadow = ita_diffraction_shadow_zone( wedge, source_pos, receiver_pos )
%ITA_DIFFRACTION_SHADOW_ZONE Returns true if receiver is in shadow zone of
%source

%% assertions
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
switch dim_src(1) >= dim_rcv(1)
    case true
        dim_n = dim_src(1);
        S = source_pos;
        R = repmat( receiver_pos, dim_n, 1 );
    case false
        dim_n = dim_rcv(1);
        S = repmat( source_pos, dim_n, 1 );
        R = receiver_pos;
end

%% function begin
in_shadow = false( dim_n, 1 );
Apex_Point = wedge.get_aperture_point( source_pos, receiver_pos );
eps = wedge.set_get_geo_eps;

ref_face = wedge.point_facing_main_side( S );
N1 = zeros( dim_n, 3 );
N2 = zeros( dim_n, 3 );

N1( ref_face, : ) = repmat( wedge.main_face_normal, sum(ref_face), 1 );
N2( ref_face, : ) = repmat( wedge.opposite_face_normal, sum(ref_face), 1 );
Apex_Dir( ref_face, : ) = repmat( wedge.aperture_direction, sum(ref_face), 1 );

N1( ~ref_face, : ) = repmat( wedge.opposite_face_normal, sum(~ref_face), 1 );
N2( ~ref_face, : ) = repmat( wedge.main_face_normal, sum(~ref_face), 1 );
Apex_Dir( ~ref_face, : ) = repmat( -wedge.aperture_direction, sum(~ref_face), 1 );


% Distances of source from wedge faces
dist1_src = dot( S - Apex_Point, N1, 2 );
dist2_src = dot( S - Apex_Point, N2, 2 );

if any( ( dist1_src < -eps ) & ( dist2_src < -eps ) )
    error('Invalid source location!')
end

% Use of a auxiliary shadow plane which describes the border of the
% shadow zone
source_apex_direction = ( Apex_Point - S ) ./ Norm( Apex_Point - S ) ;

% Check right orientation of normal vector of shadow plane by consideration
% of source facing wedge side
shadow_plane_normal = zeros( dim_n, 3 );
mask = dist1_src >= -eps;
shadow_plane_normal(mask, :) = cross( source_apex_direction(mask, :), Apex_Dir(mask, :), 2 ) ./ Norm( cross( source_apex_direction(mask, :), Apex_Dir(mask, :), 2 ) ); % ./ sqrt( sum( (cross( source_apex_direction(mask, :), Apex_Dir(mask, :), 2 )).^2, 2 ) );
shadow_plane_normal(~mask, :) = cross( Apex_Dir(~mask, :), source_apex_direction(~mask, :), 2 ) ./ Norm( cross( Apex_Dir(~mask, :), source_apex_direction(~mask, :), 2 ) ); % ./ sqrt( sum( (cross( Apex_Dir(~mask, :), source_apex_direction(~mask, :), 2 )).^2, 2 ) );

% Distance of receiver from shadow plane
dist_rcv = dot( R - Apex_Point, shadow_plane_normal, 2 );

% Checking for receiver position in shadow zone and considering special
% cases
case1 = ( ( dist1_src >= -eps ) & ( dist2_src >= -eps ) );
case2 = dot( R - Apex_Point, N1, 2 ) >= -eps;
in_shadow( ~(case1 | case2) ) = dist_rcv( ~(case1 | case2) ) < -eps;
end

function res = Norm( A )
    res = sqrt( sum( A.^2, 2 ) );
end