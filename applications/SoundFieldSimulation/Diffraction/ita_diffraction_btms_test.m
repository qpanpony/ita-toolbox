%% Config
% rectangular wedge
n1Wedge = [1  1  0];
n2Wedge = [-1  1  0];
loc = [0 0 -3];
len = 8;
infWedge = itaInfiniteWedge(n1Wedge / norm( n1Wedge ), n2Wedge / norm( n2Wedge ), loc);
finWedge = itaFiniteWedge(n1Wedge / norm( n1Wedge ), n2Wedge / norm( n2Wedge ), loc, len);

% simple Screen
n1Screen = [1, 0, 0];
apexDir = [0, 0, 1];
infScreen = itaSemiInfinitePlane(n1Screen, loc, apexDir);
finScreen = itaFiniteWedge(n1Screen, -n1Screen, loc, len);
finScreen.aperture_direction = apexDir;

% Source and receiver setup
src = 3/sqrt(1) * [-1  0  0];
rcvStartPos = 3/sqrt(2) * [ 1, 1, 0 ];
rcvEndPos = 3/sqrt(2) * [ 1, -1, 0 ];

% Set receiver positions alligned around the aperture
apexPoint = infWedge.get_aperture_point(src, rcvStartPos);
refFace = infWedge.point_facing_main_side( src );
alpha_start = infWedge.get_angle_from_point_to_wedge_face(rcvStartPos, refFace);
alpha_end = infWedge.get_angle_from_point_to_wedge_face(rcvEndPos, refFace);
alpha_res = 200;
alpha_d = linspace( alpha_start, alpha_end, alpha_res );

rcvPositions = ita_align_points_around_aperture( infWedge, rcvStartPos, alpha_d, apexPoint, refFace );
inShadowZone = zeros(size(rcvPositions, 1), 1);
for i = 1:size(rcvPositions, 1)
    inShadowZone(i) = ita_diffraction_shadow_zone( infWedge, src, rcvPositions(i, :) );
end

% Params
c = 344; % Speed of sound
fs = 44100;

resData = itaAudio();
resData.samplingRate = fs;
resData.fftDegree = 12;

% Direct field component for normalization of total field
freq = resData.freqVector;
N = resData.nSamples;
k = 2* pi * freq / c;
R_dir = repmat( sqrt( sum( ( rcvPositions - src ).^2, 2 ) ), 1, numel(freq) );
E_dir = 1 ./ R_dir .* exp( -1i .* k' .* R_dir );

%% Calculations
tempData = resData;
resBTMS = resData;
resMaekawa = resData;

% diffraction with btms model
for i = 1:size(rcvPositions, 1)
    tempData.timeData = ita_diffraction_btms(finWedge, src, rcvPositions(i, :), fs, N, c);
    if ~inShadowZone(i)
        tempData.freqData = tempData.freqData + (E_dir(i, :))';
    end
    tempData.freqData = tempData.freqData ./ (E_dir(i, :))';
    if i == 1
        resBTMS.freqData = tempData.freqData;
    else
        resBTMS = ita_merge(resBTMS, tempData);
    end    
end

% diffraction with maekawa model
for i = 1:size(rcvPositions, 1)
    tempData.freqData = ita_diffraction_maekawa(finWedge, src, rcvPositions(i, :), freq, c);
    if ~inShadowZone(i)
        tempData.freqData = tempData.freqData + (E_dir(i, :))';
    end
    tempData.freqData = tempData.freqData ./ (E_dir(i, :))';
    if i == 1
        resMaekawa.freqData = tempData.freqData;
    else
        resMaekawa = ita_merge(resMaekawa, tempData);
    end    
end


%% Plot
str_freqs = repmat( ' Hz', numel( freq ), 1 );
resPlotBTMS = resBTMS.freqData_dB;
resPlotMaekawa = resMaekawa.freqData_dB;

figure( 'units', 'normalized', 'outerposition', [0 0 1 1] );
subplot( 2, 2, 1 );
plot( rad2deg(alpha_d), ( resPlotBTMS( 6:50:end, : ) )' );
title( 'BTMS diffraction for various receiver positions' );
% legend( [num2str( round( freq' ) ), str_freqs], 'Location', 'southwest' );
xlabel( 'theta_R [°]' );
ylabel( 'p_{total} [dB]' );
ylim( [-35, 10] );
xlim( [rad2deg(alpha_d(1)), rad2deg(alpha_d(end))] );
grid on
ylim auto

subplot( 2, 2, 2 );
plot( rad2deg(alpha_d), ( resPlotMaekawa( 6 : 50 : end, : ) )' );
title( 'Maekawa diffraction for various receiver positions' );
% legend( [num2str( round( freq' ) ), str_freqs], 'Location', 'southwest' );
xlabel( 'theta_R [°]' );
ylabel( 'p_{total} [dB]' );
ylim( [-35, 10] );
xlim( [rad2deg(alpha_d(1)), rad2deg(alpha_d(end))] );
grid on