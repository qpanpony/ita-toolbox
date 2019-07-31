%% Test visualization of source-receiver-wedge scene

n1 = [ 1, 0, 1 ];
n2 = [ -1, 0, 1 ];
loc = [ 0 0 0 ];
w = itaInfiniteWedge( n1 / norm( n1 ), n2 / norm( n2 ), loc );

s = [  3.1 0 0 ];
r = [ -3.1 0 -0.1 ];

ita_diffraction_visualize_scene( w, s, r )

w_inner = itaInfiniteWedge( n1 / norm( n1 ), n2 / norm( n2 ), loc, 'inner_edge' );

ita_diffraction_visualize_scene( w_inner, s, r )
