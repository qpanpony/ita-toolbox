function [ opt_coord_LS, opt_val ] = ita_HRTFarc_optimize_coord_arcLS( toa, phi, r_z, SR,coordLS_ideal)
%TEST_ZILLEKENS_OPTIMIZE_COORD_ARCLS returns the optimized arc LS
%coordinates of the arc and some optimized values
% 
% [opt_coord_LS, opt_val] = TEST_ZILLEKENS_OPTIMIZE_COORD_ARCLS(toa, phi, r_z)
% 
% INPUT: 
%   toa          -   time of arrival samples in a vector
%   phi          -   vector of measured phi angles in radiant
%   r_z          -   distances between the mics on the flute
%   SR           -   sampling rate
%
% OUTPUT:
%   opt_coord_LS -   itaCoordinates with LS positions
%   opt_val      -   struct with following values:
%        a       -   distance to boom arm
%        d       -   length of boom arm
%        c       -   Speed of Sound
%        alpha   -   offset angle of turntable
%        beta    -   angle beetween mic stand and mic boom arm
%        gamma   -   angle between mic holder and mic boom arm
%        latency -   latency samples between the 5 DA converters 
% 
% Origin of the coordinate system is considered in the center of the 
% turntable (rotary axis) on top of the mic stands joint.
% 
% See also TEST_ZILLEKENS_ERROR_DISTANCE_LS TEST_ZILLEKENS_COORD_HRTFARC
% TEST_ZILLEKENS_COORD2VEC

% Author: Stefan Zillekens
% Created: 2013-09-09

% Jan Richter - 27.05.2015
% renamed and changed to work with new arc setup

if nargin < 4
    SR = 44100;
end


%% init
npos = numel(phi);
nmic = numel(r_z);

%% optimize those parameters  [ start value, lower limit, upper limit ]
a_opt   = [ 0.04         0.03           0.05        ];% distance from joint to boom arm          ~4cm
d_opt   = [ 0.4          0.3            0.5         ];% length of boom arm
% h_opt = [-0.005   0   0.005]; % height offset from the arm
c_opt   = [ 345          320            350         ];% Speed of Sound
al_opt  = [ 0           -pi/2           pi/2        ];% angle offset of reference point of TT    ~0
be_opt  = [ 0           -pi/2           pi/2        ]; % angle between mic stand and mic boom     ~pi/2
ga_opt  = [ 0           -pi/6           pi/6        ];% angle between mic holder and flute       ~0
x_opt   = [ 0.01          -0.05            0.05         ];% x offset of the drehteller
y_opt   = [ 0.01          -0.05            0.05         ];% y offset of the drehteller

opt_val = struct(   'a',        a_opt(1),   ...
                    'd',        d_opt(1),   ...
                    'c',        c_opt(1),   ...
                    'alpha',    al_opt(1),  ...
                    'beta',     be_opt(1),  ...
                    'gamma',    ga_opt(1),  ...
                    'x',        x_opt(1),   ...
                    'y',        y_opt(1));

% create ideal arc coordinates
nLS = coordLS_ideal.nPoints;                

                
v_coordLS_init  = reshape(coordLS_ideal.cart',1,[]);       % to row vector
v_coordLS_min   = min(coordLS_ideal.cart)-[0.3, 0.3, 0.8]; % Lower limit
v_coordLS_max   = max(coordLS_ideal.cart)+[0.3, 0.3, 0.8]; % Upper limit

opt  = optimset(    'TolFun',   1e-8,   ...
                    'TolX',     1e-4,   ...
                    'Display',  'iter', ...
                    'MaxIter',  40      ... 
                 ...   'FinDiffRelStep', [repmat(1e-3, 1, nLS*3), 1e-3, 1e-3, 1, 1e-4, 1e-4, 1e-4, ones(1,5)] ...
                    );
                
%% little warning                
nvar = numel(fieldnames(opt_val));    % +4 caused by latency
if ( nvar+3*nLS > nLS*npos*nmic)
    warning('There are more unknowns than equations.');
end

%% optimize
disp(['Starting optimizer at ',datestr(now,'HH:MM:SS')]);
% tic;
[x, ~]  =   lsqnonlin(@(x) ita_HRTFarc_error_distance_LS(x, toa, phi, r_z, SR ), ...
    [v_coordLS_init                a_opt(1) d_opt(1)  c_opt(1) al_opt(1) be_opt(1) ga_opt(1) x_opt(1) y_opt(1)], ... % Startvalue
    [repmat(v_coordLS_min, 1, nLS) a_opt(2) d_opt(2)  c_opt(2) al_opt(2) be_opt(2) ga_opt(2) x_opt(2) y_opt(2)], ... % Lower limit
    [repmat(v_coordLS_max, 1, nLS) a_opt(3) d_opt(3)  c_opt(3) al_opt(3) be_opt(3) ga_opt(3) x_opt(3) y_opt(3)], ... % Upper limit
    opt);  
% toc;
disp(['Ended    optimizer at ',datestr(now,'HH:MM:SS')]);


%% multi start optimization
% opts = optimoptions(@lsqnonlin,'Display','iter');
% problem = createOptimProblem('lsqnonlin','objective',...
%  @(x) test_zillekens_error_distance_LS(x, toa, phi, r_z, SR ) ...
%  ,'x0',[v_coordLS_init                a_opt(1) d_opt(1)  c_opt(1) al_opt(1) be_opt(1) ga_opt(1) x_opt(1) y_opt(1)], ...
%  'lb',[repmat(v_coordLS_min, 1, nLS) a_opt(2) d_opt(2)  c_opt(2) al_opt(2) be_opt(2) ga_opt(2) x_opt(2) y_opt(2)], ... 
%  'ub',[repmat(v_coordLS_max, 1, nLS) a_opt(3) d_opt(3)  c_opt(3) al_opt(3) be_opt(3) ga_opt(3) x_opt(3) y_opt(3)], ... 
%  'options',opts);
% ms = MultiStart('UseParallel',true);
% [x,f] = run(ms,problem,20)


opt_val.err = ita_HRTFarc_error_distance_LS(x, toa, phi, r_z, SR );
%% Solved
opt_val.a         =   x(end-7);
opt_val.d         =   x(end-6);
% opt_val.h         =   x(end-4);
opt_val.c         =   x(end-5);
opt_val.alpha     =   x(end-4);
opt_val.beta      =   x(end-3);
opt_val.gamma     =   x(end-2);
opt_val.x         =   x(end-1);
opt_val.y         =   x(end);

% Assign LS positions to itaCoordinates
v_posLS_opt     = x(1:3*nLS);
m_posLS_opt     = reshape(v_posLS_opt, 3,[])';      % row vector to matrix
opt_coord_LS    = itaCoordinates(m_posLS_opt);

end