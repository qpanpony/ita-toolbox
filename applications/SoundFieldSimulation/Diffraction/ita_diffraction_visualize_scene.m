function ita_diffraction_visualize_scene( w, source_pos, target_pos, is_opengl_cs )
%% ita_diffraction_visualize_scene Visualises a source-receiver-wedge scene
%
% Example: ita_diffraction_visualize_scene( wedge, source_pos, target_pos )
%

if nargin < 4
    is_opengl_cs = false;
end

apx = w.approx_aperture_point( source_pos, target_pos );
d1 = norm( source_pos - apx );
d2 = norm( target_pos - apx );
d3 = norm( w.location - source_pos );
d4 = norm( w.location - target_pos );
face_scaling = max( [ d1 d2 d3 d4 ] );

% Edge type decides which direction from aperture the faces are drawn
if strcmpi( w.edge_type, 'inner_edge' )
    edge_type_sign = -1;
elseif strcmpi( w.edge_type, 'outer_edge' )
    edge_type_sign = 1;
else
    error 'Encountered unrecognized edge type, aborting.'
end
    

%% Main wedge face

if isa( w, 'itaFiniteWedge' )
    
    p1 = w.aperture_start_point;
    p2 = w.aperture_end_point;
    
else

    p1 = w.location - face_scaling * w.aperture_direction;
    p2 = w.location + face_scaling * w.aperture_direction;

end

v_aux = edge_type_sign * cross( w.main_face_normal, w.aperture_direction );
p3 = v_aux * face_scaling + p2;
p4 = v_aux * face_scaling + p1;

X = [ p1( 1 ); p2( 1 ); p3( 1 ); p4( 1 ) ];
Y = [ p1( 2 ); p2( 2 ); p3( 2 ); p4( 2 ) ];
Z = [ p1( 3 ); p2( 3 ); p3( 3 ); p4( 3 ) ];


%% Opposite wedge face

v_aux = edge_type_sign * ( -1 ) * cross( w.opposite_face_normal, w.aperture_direction );
p3 = v_aux * face_scaling + p2;
p4 = v_aux * face_scaling + p1;

X2 = [ p1( 1 ); p2( 1 ); p3( 1 ); p4( 1 ) ];
Y2 = [ p1( 2 ); p2( 2 ); p3( 2 ); p4( 2 ) ];
Z2 = [ p1( 3 ); p2( 3 ); p3( 3 ); p4( 3 ) ];


%% Solid-part boundary
    
if strcmpi( w.edge_type, 'outer_edge' )
    
    v_aux = edge_type_sign * cross( w.main_face_normal, w.aperture_direction );
    p3 = v_aux * face_scaling / 2 + p1;
    v_aux = edge_type_sign * ( -1 ) * cross( w.opposite_face_normal, w.aperture_direction );
    p4 = v_aux * face_scaling / 2 + p1;

    X4 = [ p1( 1 ); p3( 1 ); p4( 1 ) ];
    Y4 = [ p1( 2 ); p3( 2 ); p4( 2 ) ];
    Z4 = [ p1( 3 ); p3( 3 ); p4( 3 ) ];

    v_aux = cross( w.main_face_normal, w.aperture_direction );
    p3 = v_aux * face_scaling / 2 + p2;
    v_aux = edge_type_sign * ( -1 ) * cross( w.opposite_face_normal, w.aperture_direction );
    p4 = v_aux * face_scaling / 2 + p2;

    X4 = [ X4, [ p2( 1 ); p3( 1 ); p4( 1 ) ] ];
    Y4 = [ Y4, [ p2( 2 ); p3( 2 ); p4( 2 ) ] ];
    Z4 = [ Z4, [ p2( 3 ); p3( 3 ); p4( 3 ) ] ];

elseif strcmpi( w.edge_type, 'inner_edge' )
    
    v_aux = edge_type_sign * cross( w.main_face_normal, w.aperture_direction );
    p3 = v_aux * face_scaling / 2 + p1;
    v_aux = edge_type_sign * ( -1 ) * cross( w.opposite_face_normal, w.aperture_direction );
    p4 = v_aux * face_scaling / 2 + p1;
    p5 = ( -1 ) * face_scaling / 2 * ( w.main_face_normal + w.opposite_face_normal ) / 2 + p1;

    X4 = [ p1( 1 ); p3( 1 ); p5( 1 ); p4( 1 ) ];
    Y4 = [ p1( 2 ); p3( 2 ); p5( 2 ); p4( 2 ) ];
    Z4 = [ p1( 3 ); p3( 3 ); p5( 3 ); p4( 3 ) ];

    v_aux = edge_type_sign * cross( w.main_face_normal, w.aperture_direction );
    p3 = v_aux * face_scaling / 2 + p2;
    v_aux = edge_type_sign * ( -1 ) * cross( w.opposite_face_normal, w.aperture_direction );
    p4 = v_aux * face_scaling / 2 + p2;
    p5 = ( -1 ) * face_scaling / 2 * ( w.main_face_normal + w.opposite_face_normal ) / 2 + p2;

    X4 = [ X4, [ p2( 1 ); p3( 1 ); p5( 1 ); p4( 1 ) ] ];
    Y4 = [ Y4, [ p2( 2 ); p3( 2 ); p5( 2 ); p4( 2 ) ] ];
    Z4 = [ Z4, [ p2( 3 ); p3( 3 ); p5( 3 ); p4( 3 ) ] ];
    
end

%% Aperture point

X3 = [ source_pos( 1 ); apx( 1 ); target_pos( 1 ) ];
Y3 = [ source_pos( 2 ); apx( 2 ); target_pos( 2 ) ];
Z3 = [ source_pos( 3 ); apx( 3 ); target_pos( 3 ) ];


%% Polygon 3D plot

M1 = [ X, Y, Z ];
M2 = [ X2, Y2, Z2 ];
M3 = [ X3, Y3, Z3 ];
M41 = [ X4(:,1), Y4(:,1), Z4(:,1) ];
M42 = [ X4(:,2), Y4(:,2), Z4(:,2) ];
if is_opengl_cs
    M1 = ita_openGL2Matlab( M1 );
    M2 = ita_openGL2Matlab( M2 );
    M3 = ita_openGL2Matlab( M3 );
    M41 = ita_openGL2Matlab( M41 );
    M42 = ita_openGL2Matlab( M42 );
end

figure
fill3( M1(:,1), M1(:,2), M1(:,3), 'red', ...
       M2(:,1), M2(:,2), M2(:,3), 'yellow', ...
       M3(:,1), M3(:,2), M3(:,3), 'green', ...
       M41(:,1), M41(:,2), M41(:,3), 'blue', ...
       M42(:,1), M42(:,2), M42(:,3), 'blue' )


end
