function [V,Vsph,D] = sphere_design(method, R, print);
%

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% spherical t-designs (optimal) (some cases only)
% 
% Usage: [V,Vsph]=sphere_design(design,R,print)
%   design : type of design -> one of {24p-3d, 25p-5d, 32p-7d}
%   R      : radius of the sphere
%   print  : 1 gives a figure with the result
%            0 no printout
%
% Output
%   V      : cartesian coordinates of the sphere array
%   Vsph   : spherical coordinates of the sphere array (optional)
%
%   example: V=sphere_design('32p-7d',2,0);
%               
%
% Reference: R.H. Hardin and N.J.A. Sloane: 'McLaren's Improved Snub Cube 
%   and Other New Spherical Designs in Three Dimensions', Discrete and 
%   Computational Geometry, 14(1996),pp.429-441. Also see the web page
%   /http://www2.research.att.com/~njas/sphdesigns/ for other designs


if nargin < 3, print = 0; end


% normalized designs for R=1 
switch lower(method)
    case '24p-3d'    % 24 points 3-design
        A = 0.8503;
        B = 0.4623;
        C = 0.2514;

        V = [A B C; A -B -C; -A B -C; -A -B C; A C -B; A -C B; -A C B; -A -C -B; ...
             B C A; B -C -A; -B C -A; -B -C A; B A -C; B -A C; -B A C; -B -A -C; ...
             C A B; C -A -B; -C A -B; -C -A B; C B -A; C -B A; -C B A; -C -B -A];
    case '25p-5d'    % 25 points 5-design
        g1=(1/(2*sqrt(3)))*sqrt(7-sqrt(11));
        g2=(1/(2*sqrt(3)))*sqrt(7+sqrt(11));
        h1=sqrt(1-g1^2);
        h2=sqrt(1-g2^2);
        p2=acos(-0.4670);
        th=2*pi/5;
        for k=0:4,
            V(5*k+1,:)=[  0     cos(k*th)        sin(k*th)];
            V(5*k+2,:)=[ h1 -g1*cos(k*th)    -g1*sin(k*th)];
            V(5*k+3,:)=[-h1 -g1*cos(k*th)     g1*sin(k*th)];
            V(5*k+4,:)=[ h2  g2*cos(k*th+p2)  g2*sin(k*th+p2)];
            V(5*k+5,:)=[-h2  g2*cos(k*th+p2) -g2*sin(k*th+p2)];
        end
    case '32p-7d'    % 32 points 7-design
        A = 0.8989;
        B = 0.4355;
        C = 0.0480;

        V = [A B C; A -B -C; -A B -C; -A -B C; A C -B; A -C B; -A C B; -A -C -B; ...
             B C A; B -C -A; -B C -A; -B -C A; B A -C; B -A C; -B A C; -B -A -C; ...
             C A B; C -A -B; -C A -B; -C -A B; C B -A; C -B A; -C B A; -C -B -A];
        D = 1/sqrt(3);
        V2 = [D D D; D D -D; D -D D; D -D -D; -D D D; -D D -D; -D -D D; -D -D -D];
        V=[V;V2];
    case '60p-10d'   % 60 points 10-design
        V=   sym_12points(0.71315107, 0.03408955, 0.70018102);
        V=[V;sym_12points(0.75382867, 0.54595191,-0.36562119)];
        V=[V;sym_12points(0.78335594,-0.42686412,-0.45181910)];
        V=[V;sym_12points(0.93321004, 0.12033145,-0.33858436)];
        V=[V;sym_12points(0.95799794, 0.27623022, 0.07705072)];
    case '96p-13d'   % 96 points 13-design
        V=   sym_12points(0.69989534, 0.59974524,-0.38788163);
        V=[V;sym_12points(0.73338128,-0.54971991,-0.39994990)];
        V=[V;sym_12points(0.78556905, 0.09585688,-0.61130412)];
        V=[V;sym_12points(0.82321276, 0.56450535, 0.06045217)];
        V=[V;sym_12points(0.83255539,-0.25643858,-0.49100996)];
        V=[V;sym_12points(0.88122889, 0.33818291,-0.33025441)];
        V=[V;sym_12points(0.96391874,-0.26382492,-0.03545521)];
        V=[V;sym_12points(0.96783463,-0.01683358,-0.25102343)];
end

% denormalization for R /neq 1
x = R.*V(:,1);
y = R.*V(:,2);
z = R.*V(:,3);
[phi,theta,r]=cart2sph(x,y,z);      % Matlab uses different spherical axes
%r = sqrt(x.^2+y.^2+z.^2);          % same r
%phi = atan2(y,x);                  % same phi
%theta = atan2(z,sqrt(x.^2+y.^2));  % different theta (this is ours)
phi = mod(phi, 2*pi);               % [-pi,pi] -> [0,2*pi]
theta = pi/2 - theta;               % [-pi/2,pi/2] -> [0,pi]
V    = [x y z];
Vsph = [phi theta r];

% computation of max(min(distance between two points))
N = size(V,1);
Dm = zeros(N,N);
for i=1:N
    Di=repmat(V(i,:),N,1)-V;
    Dm(i,:)=sum((Di.^2)');
end
Dm=Dm+2*R*eye(N);
D=max(min(Dm));

if print
    % print geometry of the sphere array
    F = convhulln(V,{'Qt'});    % only triangular mesh (Delaunay)
    figure
    p.Vertices = V;
    p.Faces = F;
    p.FaceColor = 'b';
    p.EdgeColor = 'k';
    p.Marker = 'o';
    p.MarkerFaceColor = 'g';
    patch(p)
end

end

% sym_12points : 12 point group with symmetries (for 12m-point t-designs)
function V=sym_12points(A,B,C)
    V = [A B C; A -B -C; -A B -C; -A -B C; ...
         B C A; B -C -A; -B C -A; -B -C A; ...
         C A B; C -A -B; -C A -B; -C -A B];
end
