%% Test transition at shadown zone of UTD diffraction

n1 = [  1  1  0 ] / sqrt( 2 );
n2 = [ -1  1  0 ] / sqrt( 2 );
loc = [ 0 0 0 ];
source_pos = 5 * [ -1  0  0 ];
w = itaInfiniteWedge( n1, n2, loc );

delta = 0.001;
r_shadow = 5 * [ 1 -delta 0 ];
r_illuminated = 5 * [ 1 delta 0 ];

assert( ita_diffraction_shadow_zone( w, source_pos, r_shadow ) )
assert( ~ita_diffraction_shadow_zone( w, source_pos, r_illuminated ) )

utd_tf = itaAudio( 1 );
utd_tf.fftDegree = 11;

f = utd_tf.freqVector( 2:end );
c = 341;

[ H1, D1, A1 ] = ita_diffraction_utd( w, source_pos, r_shadow, f, c );
utd_tf.freqData( :, 1 ) = [ 0 H1 ];

[ H2, D2, A2 ] = ita_diffraction_utd( w, source_pos, r_illuminated, f, c );
utd_tf.freqData( :, 2 ) = [ 0 H2 ];

d = norm( source_pos - r_illuminated );
c = 343;
k = 2 * pi * f / c;
H_direct = 1 ./ d .* exp( -1i .* k .* d );

utd_tf.freqData( :, 3 ) = [ 0 H1 ./ H_direct ];
utd_tf.freqData( :, 4 ) = [ 0 ( H2 + H_direct ) ./ H_direct ];

utd_tf.channelNames = { 'Diffracted field (shadow)', 'Diffracted field (illuminated)', 'Insertion loss (shadowed)', 'Insertion loss (illuminated)' };

%utd_tf.pf


%% Trajectory rotational movement

receiver_start_pos = 5 * [ -1  -1  0 ] / sqrt( 2 );

apex_point = w.get_aperture_point( source_pos, receiver_start_pos );
apex_dir = w.aperture_direction;

freq = [ 20, 50, 100, 200, 400, 800, 1600, 3200, 6400, 12800, 24000 ]';
k = 2 * pi * freq ./ c;

num_angles = 1000;
alpha_d_start = w.opening_angle;
alpha_d_end = 0;
alpha_d = linspace( alpha_d_start, alpha_d_end, num_angles );

% Set different receiver positions rotated around the aperture
recevier_positions = norm( receiver_start_pos ) * [ cos( alpha_d - pi/4 ); sin( alpha_d - pi/4 ); zeros( 1, numel( alpha_d ) ) ]';

H_diffracted_field_log = [];

N = size( recevier_positions, 1 );
for n = 1 : N
    
    receiver_pos = recevier_positions( n, 1:3 );
    
    r_dir = norm( receiver_pos  - source_pos );
    H_direct_field = 1 ./ r_dir .* exp( -1i .* k .* r_dir );

    shadow_zone = ita_diffraction_shadow_zone( w, source_pos, receiver_pos );

    % UTD total wave field
    H_diffracted_field = ita_diffraction_utd( w, source_pos, receiver_pos, freq, c );
    if shadow_zone
        H_total_field = H_diffracted_field;
    else
        H_total_field = H_diffracted_field + H_direct_field;
    end
    
    H_diffracted_field_log = [ H_diffracted_field_log, H_total_field ./ H_direct_field ];
    
end

figure
plot( db( H_diffracted_field_log( :, : )' ) )



%% Trajectory rotational vertical
freq = [ 20, 200, 2000, 20000 ]';
k = 2 * pi * freq ./ c;

w = itaInfiniteWedge( [ 1 0 0 ], [ 0 1 0 ], [ 0 0 0 ] ); % OpenGL coordinates

num_positions = 199;

receiver_pos = [ -3, 3, 0 ];
% Set different receiver positions rotated around the aperture
source_positions = [ 3 * ones( num_positions, 1 ), 3 * linspace( 2, -2, num_positions )', zeros( num_positions, 1 ) ];

H_diffracted_field_log = [];

N = size( source_positions, 1 );
for n = 1 : N
    
    source_pos = source_positions( n, : );
    
    r_dir = norm( receiver_pos  - source_pos );
    H_direct_field = 1 ./ r_dir .* exp( -1i .* k .* r_dir );

    shadow_zone = ita_diffraction_shadow_zone( w, source_pos, receiver_pos );
    reflection_zone_main = ita_diffraction_reflection_zone( w, source_pos, receiver_pos, false );
    
    if n > 1
        if shadow_zone_last ~= shadow_zone
            fprintf( 'Shadow zone transition at frame %i\n', n )
            %ita_diffraction_visualize_scene( w, source_pos, receiver_pos, true )
        end
        if reflection_zone_main_last ~= reflection_zone_main
            fprintf( 'Opposite reflection zone transition at frame %i\n', n )
            %ita_diffraction_visualize_scene( w, source_pos, receiver_pos, true )
        end
    end
	shadow_zone_last = shadow_zone;
    reflection_zone_main_last = reflection_zone_main;

    % UTD total wave field
    H_diffracted_field = ita_diffraction_utd( w, source_pos, receiver_pos, freq, c );
    if shadow_zone
        H_total_field = H_diffracted_field;
    else
        H_total_field = H_diffracted_field + H_direct_field;
    end
    
    H_diffracted_field_log = [ H_diffracted_field_log, H_total_field ./ H_direct_field ];
    
end

figure
plot( db( H_diffracted_field_log( :, : )' ) )

