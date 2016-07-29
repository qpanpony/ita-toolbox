function varargout = ita_sph_sampling_slayer(varargin)
% ITA_SPH_SAMPLING_SLAYER - Generate sampling of Slayer loudspeaker
%
% s = ita_sph_sampling_slayer('order',0,'trans', [1 2 3]);
%
% order =  0: Sampling of physical array
% order = 11: Sampling of all transducer positions for measurement order 11
% order = 23: Sampling of all transducer positions for measurement order 23
%
% trans =  1: Only 5 inch transducers
% trans =  2: Only 3 inch transducers
% trans =  3: Only 2 inch transducers
%
% Johannes Klein (johannes.klein@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 23.05.2012

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>



sArgs = struct('order',0,'trans',[1 2 3]);
sArgs = ita_parse_arguments(sArgs, varargin);

array_radius = 0.2;

if sArgs.order == 0
    ele = 0;
    rot = 0;
elseif sArgs.order == 11
    ele = 0;
    rot = [0:15:359.9]./360.*2.*pi;
elseif sArgs.order == 23
    ele = [0 3.7]./360.*2.*pi;
    rot = [0:15/2:359.9]./360.*2.*pi;
end


%% Generate basic samplings
% Gaussian sampling order 3
gauss_3_theta = acos(lgwt(3+1,-1,1));
% Gaussian sampling order 11
gauss_11_theta = acos(lgwt(11+1,-1,1));

%% Modify basic samplings
if ~isempty(find(sArgs.trans == 1, 1))
    % 5 inch - base
    membranes_1_unique_theta = gauss_3_theta;
    % 5 inch - phi - front
    membranes_1_1_phi = (75)/360*2*pi;
    membranes_1_2_phi = (310)/360*2*pi;
    % 5 inch - phi - back
    membranes_1_3_phi = (235)/360*2*pi;
    membranes_1_4_phi = (105)/360*2*pi;
    % 5 inch - merge
    membranes_1_pos = zeros(size(membranes_1_unique_theta,1),2);
    membranes_1_pos(1,:) = [membranes_1_unique_theta(1,1), membranes_1_1_phi];
    membranes_1_pos(2,:) = [membranes_1_unique_theta(2,1), membranes_1_2_phi];
    membranes_1_pos(3,:) = [membranes_1_unique_theta(3,1), membranes_1_3_phi];
    membranes_1_pos(4,:) = [membranes_1_unique_theta(4,1), membranes_1_4_phi];
    % 5 inch -
    membranes_1_pos(1,1) = membranes_1_pos(1,1) + (18)/360*2*pi;
    membranes_1_pos(4,1) = membranes_1_pos(4,1) - (18)/360*2*pi;
    
    membranes_size_1 = repmat(0.05250,size(membranes_1_pos,1),1);
    membranes_displacement_1 = repmat(0.00500,size(membranes_1_pos,1),1);
else
    membranes_1_pos             = [];
    membranes_size_1            = [];
    membranes_displacement_1    = [];
end

if ~isempty(find(sArgs.trans == 2, 1))
    % 3 inch
    membranes_2_unique_theta = gauss_11_theta;
    % 3 inch - front
    membranes_2_1_phi  = 15/360*2*pi;
    membranes_2_3_phi  = 345/360*2*pi;
    membranes_2_5_phi  = 15/360*2*pi;
    membranes_2_7_phi  = 0/360*2*pi;
    membranes_2_9_phi  = 17/360*2*pi;
    membranes_2_11_phi = 330/360*2*pi;
    % 3 inch - back
    membranes_2_2_phi  = 180/360*2*pi;
    membranes_2_4_phi  = 160/360*2*pi;
    membranes_2_6_phi  = 180/360*2*pi;
    membranes_2_8_phi  = 165/360*2*pi;
    membranes_2_10_phi = 195/360*2*pi;
    membranes_2_12_phi = 120/360*2*pi;
    % 3 inch - merge
    membranes_2_pos = zeros(size(membranes_2_unique_theta,1),2);
    membranes_2_pos(1,:)  = [membranes_2_unique_theta(1,1),  membranes_2_1_phi];
    membranes_2_pos(2,:)  = [membranes_2_unique_theta(2,1),  membranes_2_2_phi];
    membranes_2_pos(3,:)  = [membranes_2_unique_theta(3,1),  membranes_2_3_phi];
    membranes_2_pos(4,:)  = [membranes_2_unique_theta(4,1),  membranes_2_4_phi];
    membranes_2_pos(5,:)  = [membranes_2_unique_theta(5,1),  membranes_2_5_phi];
    membranes_2_pos(6,:)  = [membranes_2_unique_theta(6,1),  membranes_2_6_phi];
    membranes_2_pos(7,:)  = [membranes_2_unique_theta(7,1),  membranes_2_7_phi];
    membranes_2_pos(8,:)  = [membranes_2_unique_theta(8,1),  membranes_2_8_phi];
    membranes_2_pos(9,:)  = [membranes_2_unique_theta(9,1),  membranes_2_9_phi];
    membranes_2_pos(10,:) = [membranes_2_unique_theta(10,1), membranes_2_10_phi];
    membranes_2_pos(11,:) = [membranes_2_unique_theta(11,1), membranes_2_11_phi];
    membranes_2_pos(12,:) = [membranes_2_unique_theta(12,1), membranes_2_12_phi];
    
    membranes_size_2 = repmat(0.032,size(membranes_2_pos,1),1);
    membranes_displacement_2 = repmat(0.00100,size(membranes_2_pos,1),1);
else
    membranes_2_pos             = [];
    membranes_size_2            = [];
    membranes_displacement_2    = [];
end

if ~isempty(find(sArgs.trans == 3, 1))
    % 2 inch
    membranes_3_unique_theta = gauss_11_theta;
    % 2 inch - front
    membranes_3_1_phi  = 252/360*2*pi;
    membranes_3_3_phi  = 30/360*2*pi;
    membranes_3_5_phi  = 345/360*2*pi;
    membranes_3_7_phi  = 30/360*2*pi;
    membranes_3_9_phi  = 345/360*2*pi;
    membranes_3_11_phi = 33/360*2*pi;
    % 2 inch - back
    membranes_3_2_phi  = 110/360*2*pi;
    membranes_3_4_phi  = 195/360*2*pi;
    membranes_3_6_phi  = 150/360*2*pi;
    membranes_3_8_phi  = 195/360*2*pi;
    membranes_3_10_phi = 150/360*2*pi;
    membranes_3_12_phi = 255/360*2*pi;
    % 2 inch - merge
    membranes_3_pos = zeros(size(membranes_3_unique_theta,1),2);
    membranes_3_pos(1,:)  = [membranes_3_unique_theta(1,1),  membranes_3_1_phi];
    membranes_3_pos(2,:)  = [membranes_3_unique_theta(2,1),  membranes_3_2_phi];
    membranes_3_pos(3,:)  = [membranes_3_unique_theta(3,1),  membranes_3_3_phi];
    membranes_3_pos(4,:)  = [membranes_3_unique_theta(4,1),  membranes_3_4_phi];
    membranes_3_pos(5,:)  = [membranes_3_unique_theta(5,1),  membranes_3_5_phi];
    membranes_3_pos(6,:)  = [membranes_3_unique_theta(6,1),  membranes_3_6_phi];
    membranes_3_pos(7,:)  = [membranes_3_unique_theta(7,1),  membranes_3_7_phi];
    membranes_3_pos(8,:)  = [membranes_3_unique_theta(8,1),  membranes_3_8_phi];
    membranes_3_pos(9,:)  = [membranes_3_unique_theta(9,1),  membranes_3_9_phi];
    membranes_3_pos(10,:) = [membranes_3_unique_theta(10,1), membranes_3_10_phi];
    membranes_3_pos(11,:) = [membranes_3_unique_theta(11,1), membranes_3_11_phi];
    membranes_3_pos(12,:) = [membranes_3_unique_theta(12,1), membranes_3_12_phi];
    % 2 inch -
    membranes_3_pos(1,1)  = membranes_3_pos(1,1)  + (10)/360*2*pi;
    membranes_3_pos(12,1) = membranes_3_pos(12,1) - (8)/360*2*pi;
    
    membranes_size_3 = repmat(0.022,size(membranes_3_pos,1),1);
    membranes_displacement_3 = repmat(0.00085,size(membranes_3_pos,1),1);
else
    membranes_3_pos             = [];
    membranes_size_3            = [];
    membranes_displacement_3    = [];
end

%% Merge samplings
membranes_pos(:,2:3)    = [membranes_1_pos; membranes_2_pos; membranes_3_pos];
membranes_pos(:,1)      = array_radius;

membranes_pos_coord     = itaCoordinates(membranes_pos,'sph');
membranes_pos_cart      = membranes_pos_coord.cart';

membranes_size          = [membranes_size_1; membranes_size_2; membranes_size_3];
membranes_displacement  = [membranes_displacement_1; membranes_displacement_2; membranes_displacement_3];

%% Elevate and rotate
block = size(membranes_pos,1);
yblock = numel(rot)*block;
membranes_pos_final = zeros(numel(ele)*numel(rot)*block,3);
membranes_size_final = zeros(1,numel(ele)*numel(rot)*block);
membranes_displacement_final = zeros(1,numel(ele)*numel(rot)*block);
for idx = 1:(numel(ele))
    r       = membranes_pos(:,1);    
    rot_p = [   cos(ele(idx))    0   sin(ele(idx));
                0                         1   0;
                -sin(ele(idx))   0   cos(ele(idx));];    
    membranes_pos_coord = itaCoordinates((rot_p*membranes_pos_cart)','cart');
    theta = membranes_pos_coord.theta;       
    for idy = 1:(numel(rot))
        phi = membranes_pos(:,3) + rot(idy);
        membranes_pos_final((idx-1)*yblock+(idy-1)*block+1:(idx-1)*yblock+idy*block,:) = [r, theta, phi];
        membranes_size_final(1,(idx-1)*yblock+(idy-1)*block+1:(idx-1)*yblock+idy*block) = membranes_size;
        membranes_displacement_final(1,(idx-1)*yblock+(idy-1)*block+1:(idx-1)*yblock+idy*block) = membranes_displacement;
    end
end

%% Generate sampling
s = itaSamplingSph(membranes_pos_final,'sph');
s.weights = 1;

%% Output
varargout{1} = s;
varargout{2} = membranes_size_final;
varargout{3} = membranes_displacement_final;
end

function x = lgwt(n,a,b)
% Taken from: ita_sph_sampling_gaussian
% Originally: Gauss-Legendre interpolatory quadrature rule.
% Copyright 2006-2007 Jens Keiner
n = n-1; n1= n + 1; n2 = n + 2;
xu = linspace(-1,1,n1)';
y=cos((2*(0:n)'+1)*pi/(2*n+2))+(0.27/n1)*sin(pi*xu*n/n2);
L=zeros(n1,n2);
Lp=zeros(n1,n2);
y0=2;
while (max(abs(y - y0)) > eps)
    L(:,1) = 1;
    Lp(:,1) = 0;
    L(:,2) = y;
    Lp(:,2) = 1;
    for k = 2:n1
        L(:,k+1) = ((2*k-1)*y.*L(:,k)-(k-1)*L(:,k-1))/k;
    end
    Lp = n2 * (L(:,n1) - y.*L(:,n2))./(1-y.^2);
    y0 = y;
    y = y0 - L(:,n2)./Lp;
end

x = (a*(1-y)+b*(1+y))/2;
end