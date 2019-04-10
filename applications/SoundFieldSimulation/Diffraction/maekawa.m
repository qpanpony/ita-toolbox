% Test Maekawa diffraction algorithm

%% Config
S = [ 0 -12 0.5 ];
R = [ 0  2 0.5 ];

mainNormal = [0 -1 1];
oppositeNormal = [0 1 1];
pos = [4 0 1];
c = 344;
A = [mainNormal; oppositeNormal; pos]';
freq = ita_ANSI_center_frequencies;
w = itaInfiniteWedge(mainNormal, oppositeNormal, pos);

%% Test operation for itaWedge

% Wedge rotation around z axis
% rotAngle = pi/5;
% rotMatrix = [ cos(rotAngle), sin(rotAngle), 0; ...
%              -sin(rotAngle), cos(rotAngle), 0; ...
%                           0,             0, 1 ];
% B = rotMatrix * A;

% % Wedge rotation around aperture axis
% A(:, 3) = [0; 0; 0];
% rotAngle = -pi/6;
% rotMatrix = [ 1,              0,             0; ...
%               0,  cos(rotAngle), sin(rotAngle); ...
%               0, -sin(rotAngle), cos(rotAngle) ];
% B = rotMatrix * A;
% B(:, 3) = B(:, 3) + pos';
% 
% itaWedge.set_get_geo_eps( 1e-6 ); % Micro meter precision for geo calcs
% 
% w = itaInfiniteWedge( B(:, 1)', B(:, 2)', B(:, 3)' );
% 
% assert( w.point_outside_wedge( S ) )
% assert( w.point_outside_wedge( R ) )
% 
% apex_point = w.get_aperture_point( S, R )
% 
% %% Maekawa Diffraction
% att = ita_diffraction_maekawa( w, S, R, ita_ANSI_center_frequencies );

% N = 0 : 0.5 : 100;
% att = zeros(2, numel(N));
% att(1, :) = - ( 5 + 20 * log10( sqrt( 2*pi.*N ) ./ tanh( sqrt( 2*pi.*N ) ) ) );  % ( 10^(5/20) * sqrt(2*pi*N) ./ tanh( sqrt( 2*pi*N ) ) );
% att(2, :) = - (10 * log10(3 + 20.*N) );
% 
% figure;
% semilogx( N, att );
% % ylim( [0 , 33] );
% grid on;

att2 = itaResult;
att2.freqVector = freq;
att2.freqData = ita_diffraction_maekawa(w, S, R, freq, c);

att2.pf
ylim([-40, 0])


%% maekawa curve against fresnel number N
n1 = [1, 1, 0];
n2 = [-1, 1, 0];
loc = [0, 2, 0];
src = [-4, 0, 0];
rcv = [4, 0, 0];
w = itaInfiniteWedge(n1, n2, loc);
ap = w.get_aperture_point(src, rcv);

N = 0 : 0.001 : 100;
d = norm(ap - src) + norm(rcv - ap) - norm(rcv - src);
c = 344;
f = c * N / (2 * d);

att = itaResult;
att.freqVector = freq;
att.freqData = ita_diffraction_maekawa(w, src, rcv, f, c);
res = -att.freqData_dB;
att_res = res(2:end);

figure();
semilogx(N(2:end), att_res);
xlabel('Fresnel number N');
ylabel('Attenuation [dB]');
ylim([0; 35]);
grid on;
