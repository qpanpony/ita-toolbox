%% Shadow zone test

n1 = [  1, 1, 0 ] / sqrt( 2 );
n2 = [ -1, 1, 0 ] / sqrt( 2 );
loc = [ 0 0 0 ];
wedge = itaInfiniteWedge( n1, n2, loc, 'outer_edge' );
screen = itaSemiInfinitePlane( [ 1 0 0 ], loc, [ 0 0 1 ] );

source = [  1 -0.001 0 ];
receiver = [ -1 -0.001 0 ];

assert( ita_diffraction_shadow_zone( wedge, source, receiver ) )
assert( ita_diffraction_shadow_zone( wedge, receiver, source ) )
assert( ita_diffraction_shadow_zone( screen, source, receiver ) )
assert( ita_diffraction_shadow_zone( screen, receiver, source ) )

assert( ~ita_diffraction_shadow_zone( wedge, source, source ) )
assert( ~ita_diffraction_shadow_zone( wedge, receiver, receiver ) )
assert( ~ita_diffraction_shadow_zone( screen, source, source ) )
assert( ~ita_diffraction_shadow_zone( screen, receiver, receiver ) )

source = [  1 +0.001 0 ];
receiver = [ -1 +0.001 0 ];

assert( ~ita_diffraction_shadow_zone( wedge, source, receiver ) )
assert( ~ita_diffraction_shadow_zone( wedge, receiver, source ) )
assert( ~ita_diffraction_shadow_zone( screen, receiver, source ) )
assert( ~ita_diffraction_shadow_zone( screen, source, receiver ) )

assert( ~ita_diffraction_shadow_zone( wedge, source, source ) )
assert( ~ita_diffraction_shadow_zone( wedge, receiver, receiver ) )
assert( ~ita_diffraction_shadow_zone( screen, source, source ) )
assert( ~ita_diffraction_shadow_zone( screen, receiver, receiver ) )

disp 'Shadow zone test successfull'


%% Reflection zone test

source = [  1 0 0 ];
receiver = [ +0.001 1 0 ];

%ita_diffraction_visualize_scene( wedge, source, receiver );

assert( ita_diffraction_reflection_zone_main( wedge, source, receiver ) )
assert( ~ita_diffraction_reflection_zone_main( wedge, receiver, source ) )

source = [  1 0 0 ];
receiver = [ -0.001 1 0 ];

assert( ~ita_diffraction_reflection_zone_main( wedge, source, receiver ) )
assert( ita_diffraction_reflection_zone_main( wedge, receiver, source ) )

%assert( ita_diffraction_reflection_zone_opposite( wedge, source, source ) )
%assert( ~ita_diffraction_reflection_zone_opposite( wedge, receiver, receiver ) )

disp 'Main reflection zone test successfull'
