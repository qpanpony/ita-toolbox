%% Config
n1 = [1, 1, 0];
n2 = [-1, 1, 0];
loc = [0, 0, -3];
src = [-4, -2, 0];
rcv = [5, -2, 0];
p = [0, 0, 2];
len = 18;
sampling_rate = 44100;
filter_length = 3534;

infw = itaInfiniteWedge(n1, n2, loc);
finw = itaFiniteWedge(n1, n2, loc, len);

ref = infw.point_facing_main_side( src ); % reference wedge

%% EDB variables
fs = sampling_rate;
closwedang = finw.wedge_angle;
rs = sqrt( src(1)^2 + src(2)^2 );
thetas = infw.get_angle_from_point_to_wedge_face( src, ref ); 
zs = 0;
rr = sqrt( rcv(1)^2 + rcv(2)^2 );
thetar = infw.get_angle_from_point_to_wedge_face( rcv, ref );
zr = rcv(3) - src(3);
zw = [ loc(3) - src(3), len - src(3) ];
Method = 'New';

%% Filter

[ir,initdelay,singularterm] = EDB2wedge1st_int( fs, closwedang, rs, thetas, zs, rr, thetar, zr, zw, Method );
res1 = ir(ir ~= 0);
res2 = ita_diffraction_btm_finite_wedge( finw, src, rcv, fs, filter_length );


% figure();
% plot(res1);
% title( 'EDB2 toolbox' );
% xlim( [0, 1200] );
% grid on;

figure();
plot( [res1, res2.timeData] );
title( 'BTM_{finw}' );
xlim( [0, 1200] );
legend( 'EDB Toolbox', 'own Impl' );
grid on;

res3 = ita_diffraction_btm_infinite_wedge( infw, src, rcv, fs, filter_length );
figure();
plot(res3.timeData);
title( 'BTM_{infw}' );
xlim( [0, 1200] );
grid on;

ratio1 = res1 ./ res2.timeData;
ratio2 = res2.timeData ./ res3.timeData;
figure();
plot([ratio1, ratio2]);
title( 'Ratio between EDB2 toolbox and BTM_{finw}' );
xlim( [0, 1200] );
legend( 'svensson / btm_{finw}', 'btm_{finw} / btm_{infw}' );
grid on;

% Res = [res1, res2.timeData, ratio]';
% 
% figure();
% yyaxis left
% plot( Res(1 : 2, :) );
% ylabel( 'amplitude' );
% legend( 'res1', 'res2' );
% yyaxis right
% plot( Res(3, :) );
% ylabel( 'ratio: res1/res2' );

% A = itaAudio;
% A.timeData = res1(1:1024);
% 
% B = res2;
% 
% A.pt;
% B.pt;
% A.pf;
% B.pf;

