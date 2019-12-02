%
% Test some source and receiver positions to varify:
%
%  -> scaling does not affect aperture point
%  -> movements along source-receiver-direction does not affect aperture point
%  -> same movements along source/receiver-aperture-direction does not affect aperture point
%  -> different movements along source/receiver-aperture-direction results in diverging aperture point
%

% Wedge
n_main = [ 3, 1, 1 ];
n_opposite = [ -3, 2, 1 ];
loc = [ 0 3 -3 ];
w = itaInfiniteWedge( n_main / norm( n_main ), n_opposite / norm( n_opposite ), loc );

% Initial setup
source_pos = [ 1 -1 1 ];
receiver_pos = [ 1 1 -1 ];
apx = w.get_aperture_point_far_field( source_pos, receiver_pos );

% Plain scaling is valid
lambda = 10;
w_scaled = w;
w_scaled.location = w_scaled.location .* lambda;
assert( all( apx == w.get_aperture_point_far_field( source_pos * lambda, receiver_pos * lambda ) ) )

% Same movement along source-receiver-direction is valid
source_receiver_vec = receiver_pos - source_pos;
assert( all( apx == w.get_aperture_point_far_field( source_pos - lambda * source_receiver_vec, receiver_pos + lambda * source_receiver_vec ) ) )

% Arbitrary uneven movement along source-receiver-direction is valid
lambda_1 = 5;
lambda_2 = 13;
assert( all( apx == w.get_aperture_point_far_field( source_pos - lambda_1 * source_receiver_vec, receiver_pos + lambda_2 * source_receiver_vec ) ) )

% Same movement along source-apex-direction and receiver-apex-direction is valid
source_pos_scaled = source_pos - lambda * ( apx - source_pos );
receiver_pos_scaled = receiver_pos - lambda * ( apx - receiver_pos );
apx_scaled = w.get_aperture_point_far_field( source_pos_scaled, receiver_pos_scaled );
assert( all( apx == apx_scaled ) )

% Aribtrary uneven movement along source-apex-direction and receiver-apex-direction is NOT valid
source_pos_tilted = source_pos - lambda_1 * ( apx - source_pos );
receiver_pos_tilted = receiver_pos - lambda_2 * ( apx - receiver_pos );
apx_tilted = w.get_aperture_point_far_field( source_pos_tilted, receiver_pos_tilted );
assert( all( apx ~= apx_tilted ) && all( apx_scaled ~= apx_tilted ) )

disp( 'all good' )
