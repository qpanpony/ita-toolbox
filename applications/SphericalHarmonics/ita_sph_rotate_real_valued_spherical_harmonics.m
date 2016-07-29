function varargout = ita_sph_rotate_real_valued_spherical_harmonics(input, euler)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% if "value" is a matrix of coefficients (size(value) == [nmax_lin, ~]) , which weights some real valued spherical
% basefunctions, this function returns the coeficients of the rotated
% function.
% if value == nmax, it returns a rotation matrix 
% (newCoef = marix * oldCoef)
%
% rotation is proceeded along euler-angel
%   first: euler(1,1) - rotation arround the z-axis
%   then:  euler(1,2) - rotation arround the y-axis
%   then:  euler(1,3) - rotation arround the z-axis
%   then the function continues with euler(2,1) ...
%
% attention: - there are also other definitions of euler-angles!!
%            - all angles must be [rad]
%
% this implementation has many if-caseses due to awesome speedup
%
% author: martin kunkemoeller, 16.11.2010
% according to Dis Zotter, chapter 3.1.4

ita_verbose_obsolete('Marked as obsolete. Please report to mpo, if you still use this function.');

% initialize
if length(input) == 1
    nmax = input;
    value = [];
elseif ~mod(sqrt(size(input,1))-1, 1)
    nmax = sqrt(size(input,1))-1;
    value = input;
else
    error('can  not handle your input!');
end

if size(euler,2) ~= 3
    error('size(euler,2) must be 3');
end

whos_ = whos('input');
precision = whos_.class;

%% proceed rotation
if sum(abs(euler(:,2)))
    ROT = eye((nmax+1)^2, precision);
    ROT_y = ROT_y_90d(nmax, precision);
    for idxE = 1:size(euler,1)
        ROT = ROT...
            *ROT_z(nmax,euler(idxE,1)+pi/2, precision)...
            *ROT_y...
            *ROT_z(nmax,euler(idxE,2)+pi, precision)...
            *ROT_y...
            *ROT_z(nmax,euler(idxE,3)+pi/2, precision);
    end
    if isempty(value)
        %not the coordnate system is rotation, but the function -> transpose
        varargout{1} = ROT.';
    else
        varargout{1} = ROT.'*value;
    end

elseif isempty(value)
    ROT = ROT_z(nmax,sum(euler(:,1))+sum(euler(:,3)), precision);
    varargout{1} = ROT.';
else
    varargout{1} = ROT_Val_z(value, nmax, sum(euler(:,1))+sum(euler(:,3)), precision);
end
end


function matrix = ROT_z(nmax, phi, precision)
%Idea: Fs,m = [ cos(m phi) sin(m phi)] * [Fs,mo ; Fc,mo]
%      Fc,m = [-sin(m phi) cos(m phi)] * [Fs,mo ; Fc,mo]

matrix = zeros((nmax+1)^2, precision);
for n = 0:nmax
    matrix(nm2N(n,0),nm2N(n,0)) = 1;
    for m = 1:n
        matrix(nm2N(n,-m),nm2N(n,[-m m])) = [cos(m*phi) sin(m*phi)];    
        matrix(nm2N(n, m),nm2N(n,[-m m])) = [-sin(m*phi) cos(m*phi)];
    end
end
end

function rotValue = ROT_Val_z(value, nmax, phi, precision)
%Idea: Fs,m = [ cos(m phi) sin(m phi)] * [Fs,mo ; Fc,mo]
%      Fc,m = [-sin(m phi) cos(m phi)] * [Fs,mo ; Fc,mo]

rotValue = zeros(size(value), precision);
for m = 0:nmax
   for n = m:nmax
    rotValue([nm2N(n,-m);nm2N(n, m)],:) = [cos(m*phi) -sin(m*phi); sin(m*phi) cos(m*phi)] * value(nm2N(n,[-m m]),:);
   end
end
end

function matrix = ROT_y_90d(nmax, precision)
blocks = cell(2*nmax+1, 1);

% step 1
for n = 0:2*nmax
    % mo = 0:n;
    blocks{n+1} = zeros(min(n+1, 2*nmax+1-n), n+1, precision);
    P = cast(legendre(n,0), precision);
    blocks{n+1}(1,:) = sqrt(4*pi/(2*n+1)) * normalize_const(n) .* P.';
end

% step 2
for n = 2*nmax : -1 : 2
    for m = 0:min(n-2, 2*nmax - n)
        for mo = m+1:n-1
        blocks{n}(m+2,mo+1) = sqrt(2-d(m+1,0)) / (2*b(n,m)*sqrt(2-d(m,0))) * ...
           (sqrt(2-d(mo,0)) * ...
                  (b(n,mo-1) /sqrt(2-d(mo-1,0))* blocks{n+1}(m+1,mo)...
                - b(n,-mo-1) /sqrt(2-d(mo+1,0))* blocks{n+1}(m+1,mo+2))...
           + 2*a(n-1,mo) * blocks{n+1}(m+1,mo+1));     
        end
    end
end

% step 3
for n = 0:nmax
    for mo = 0:n
        for m = mo+1:n
            blocks{n+1}(m+1,mo+1) = (-1)^(m+mo)*blocks{n+1}(mo+1, m+1);
        end
    end
end

matrix = zeros(nm2N(nmax,nmax), precision);
for n = 0:nmax
    mo = 0:n;
    for m = 1:n % sinus part
        matrix(nm2N(n,-m),nm2N(n,-mo)) = d(mod(n+m+mo+1,2),0) .* blocks{n+1}(m+1, mo+1);        
    end
    mo = 0:n;
    for m = 0:n % cosinus part
        matrix(nm2N(n,m), nm2N(n,mo))  = d(mod(n+m+mo,2),0) .* blocks{n+1}(m+1, mo+1);
    end
end

end

function N = normalize_const(n)
% function for orthogonality (Dis Zotter, eq.31 (page 19))
N = zeros(1,n);
for m = 0:n
   N(m+1) =  (-1)^m * sqrt((2*n+1)*2*factorial(n-m) / (4*pi*factorial(n+m)));
end
N(1) = N(1)/sqrt(2);
end

function val = a(n,m)
% just a factor see dis Zotter eq 146, (page 45)
if abs(m) > n
    val = 0;
else
    val = sqrt((n-abs(m)+1).*(n+abs(m)+1)/(2*n+1)/(2*n+3));
end
end

function val = b(n,m)
% just a factor see dis Zotter eq 146, (page 45)

val = sign(m) .* sqrt((n-m-1).*(n-m)./(2*n-1)./(2*n+1));
val(m==0 || m>n) = sqrt((n-1)*n/(2*n-1)/(2*n+1));
end

function out = d(x,m)
% kronecker delta
out = zeros(size(x));
out(x~=m)=0;
out(x==m)=1;
end

function lin = nm2N(n,m)
if length(n) > 1, error(' '); end
lin = n^2+n+1+m;
end
