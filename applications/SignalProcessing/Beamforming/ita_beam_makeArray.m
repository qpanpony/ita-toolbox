function varargout = ita_beam_makeArray(varargin)
%ITA_BEAM_MAKEARRAY - create array geometries
%  This function creates an array with specified parameters or adds the
%  weightings for a given array.
%
%  Syntax: Array = ita_beam_makeArray(arrayType,options)
%  Call: Array = ita_beam_makeArray(Array,weightType)
%
%  Possible array types are:
%   linear, cross, grid, hexa, quincunx, spiral, logspiral, circular,
%   spherical, randomplanar, randomspherical
%
%  Options are defined according to the array type.
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_beam_makeArray">doc ita_beam_makeArray</a>

% <ITA-Toolbox>
% This file is part of the application Beamforming for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  23-Jan-2009

%% Get Function String
thisFuncStr  = [upper(mfilename) ':']; %#ok<NASGU>

%% Initialization and Input Parsing
narginchk(1,30);

%% Body
% if it's already an array just calculate the weights
if isa(varargin{1},'itaMicArray') || isa(varargin{1},'itaMeshNodes')
    % array coordinates
    sArgs = struct('pos1_array','itaMeshNodes','weightType','uniform');
    [array,sArgs] = ita_parse_arguments(sArgs,varargin);
    a = array.cart.';
    % if not, create the array first
else
    % create the parser struct for all possible types, the correct options
    % will be picked by the subfunctions
    if ischar(varargin{1}) && ~isempty(varargin{1})
        arrayType = varargin{1};
    end
    inputStr = '''pos1_arrayType'',''string''';
    generalOptions = ',''Dmax'',[],''weightType'',''uniform''';
    linearOptions = ',''Nx'',10,''dx'',0.1';
    crossOptions = ',''N'',20,''d'',0.1';
    gridOptions = [linearOptions ',''Ny'',10,''dy'',0.1']; % additional to linearOptions
    hexagonalOptions = [crossOptions ',''alpha'',0*pi/180']; % additional to crossOptions
    quincunxOptions = crossOptions; % same as crossOptions
    logspiralOptions = [crossOptions ',''delta'',10,''th_max'',5*360']; % additional to crossOptions
    spiralOptions = [crossOptions ',''delta'',20,''th_max'',4*360']; % additional to crossOptions
    circularOptions = crossOptions;
    sphericalOptions = ',''R'',1,''delta'',5';
    randomplanarOptions = crossOptions;
    randomsphericalOptions = crossOptions;
    
    switch lower(arrayType)
        case 'linear'
            options = linearOptions;
            sArgs = eval(['struct(' inputStr generalOptions options ');']);
            sArgs = ita_parse_arguments(sArgs,varargin);
            a = makeLinear(sArgs);
        case 'cross'
            options = crossOptions;
            sArgs = eval(['struct(' inputStr generalOptions options ');']);
            sArgs = ita_parse_arguments(sArgs,varargin);
            a = makeCross(sArgs);
        case 'grid'
            options = gridOptions;
            sArgs = eval(['struct(' inputStr generalOptions options ');']);
            sArgs = ita_parse_arguments(sArgs,varargin);
            a = makeGrid(sArgs);
        case 'hexagonal'
            options = hexagonalOptions;
            sArgs = eval(['struct(' inputStr generalOptions options ');']);
            sArgs = ita_parse_arguments(sArgs,varargin);
            a = makeHexagonal(sArgs);
        case 'quincunx'
            options = quincunxOptions;
            sArgs = eval(['struct(' inputStr generalOptions options ');']);
            sArgs = ita_parse_arguments(sArgs,varargin);
            a = makeQuincunx(sArgs);
        case 'logspiral'
            options = logspiralOptions;
            sArgs = eval(['struct(' inputStr generalOptions options ');']);
            sArgs = ita_parse_arguments(sArgs,varargin);
            a = makeLogSpiral(sArgs);
        case 'spiral'
            options = spiralOptions;
            sArgs = eval(['struct(' inputStr generalOptions options ');']);
            sArgs = ita_parse_arguments(sArgs,varargin);
            a = makeSpiral(sArgs);
        case 'circular'
            options = circularOptions;
            sArgs = eval(['struct(' inputStr generalOptions options ');']);
            sArgs = ita_parse_arguments(sArgs,varargin);
            a = makeCircular(sArgs);
        case 'spherical'
            options = sphericalOptions;
            sArgs = eval(['struct(' inputStr generalOptions options ');']);
            sArgs = ita_parse_arguments(sArgs,varargin);
            a = makeSpherical(sArgs);
        case 'randomplanar'
            options = randomplanarOptions;
            sArgs = eval(['struct(' inputStr generalOptions options ');']);
            sArgs = ita_parse_arguments(sArgs,varargin);
            a = makeRandomPlanar(sArgs);
        case 'randomspherical'
            options = randomsphericalOptions;
            sArgs = eval(['struct(' inputStr generalOptions options ');']);
            sArgs = ita_parse_arguments(sArgs,varargin);
            a = makeRandomSpherical(sArgs);
        otherwise
            a = -1;
    end
    
    if ~isempty(sArgs.Dmax)
        D = 2*sqrt((max(abs(a(1,:)))^2)+(max(abs(a(2,:)))^2)+(max(abs(a(3,:)))^2));
        a = a.*sArgs.Dmax./D;
    end
end

%% create the weights
% build a basic window
switch(lower(sArgs.weightType))
    case 'triang'
        w = window(@triang,61).';
    case 'hamming'
        w = window(@hamming,61).';
    case 'packman'
        w = window(@blackmanharris,61).';
    case 'chebby'
        w = window(@chebwin,61,40).';
    case 'taylor'
        w = window(@taylorwin,61).';
    otherwise
        w = ones(1,61);
end

% now create a radial window
w = w./max(w);
n = numel(w);
if mod(n,2)
    w = w(ceil(n/2):end);
else
    w = [1,w(n/2:end)];
end
x = linspace(0,1,numel(w));
r_n = sqrt(sum(a.^2));
R = max(r_n);
w = interp1(x,w,r_n./R);
w = w/sum(abs(w));

Array = itaMicArray(a.','cart');
Array.w  = w;

%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
    plot(Array,'Line','none');
else
    % Write Data
    varargout(1) = {Array};
end

%end function
end

%% subfunctions
function cart = makeLinear(sArgs)
cart = [-(sArgs.Nx-1)*sArgs.dx/2:sArgs.dx:(sArgs.Nx-1)*sArgs.dx/2;zeros(2,sArgs.Nx)];
end

function cart = makeCross(sArgs)
% change from the linear distance to cross distance
sArgs.d = sArgs.d/sqrt(2);
if mod(sArgs.N,2)
    cart = [-(sArgs.N-1)*sArgs.d/4:sArgs.d:(sArgs.N-1)*sArgs.d/4, ...
        -(sArgs.N-1)*sArgs.d/4:sArgs.d:(sArgs.N-1)*sArgs.d/4; ...
        -(sArgs.N-1)*sArgs.d/4:sArgs.d:(sArgs.N-1)*sArgs.d/4, ...
        fliplr(-(sArgs.N-1)*sArgs.d/4:sArgs.d:(sArgs.N-1)*sArgs.d/4); ...
        zeros(1,sArgs.N+1)];
    
    index = intersect(finsArgs.d(cart(1,:)==0),finsArgs.d(cart(3,:)==0));
    cart = [cart(:,1:index(2)-1),cart(:,index(2)+1:ensArgs.d)];
else
    cart = [-(sArgs.N-2)*sArgs.d/4:sArgs.d:(sArgs.N-2)*sArgs.d/4, ...
        -(sArgs.N-2)*sArgs.d/4:sArgs.d:(sArgs.N-2)*sArgs.d/4; ...
        -(sArgs.N-2)*sArgs.d/4:sArgs.d:(sArgs.N-2)*sArgs.d/4, ...
        fliplr(-(sArgs.N-2)*sArgs.d/4:sArgs.d:(sArgs.N-2)*sArgs.d/4);...
        zeros(1,sArgs.N)];
end
end

function cart = makeGrid(sArgs)
D = [sArgs.dx 0;0 sArgs.dy];
%     if (sqrt(sArgs.N)/floor(sqrt(sArgs.N))) == 1
%         N_x = floor(sqrt(sArgs.N)); N_y = N_x;
%     else
%         if (log2(sArgs.N)/floor(log2(sArgs.N))) == 1
%             N_x = 2^ceil(log2(sArgs.N)/2);
%             N_y = sArgs.N/N_x;
%         else
%             fac = factor(sArgs.N);
%             n = max(fac);
%             N_x = max(n,sArgs.N/n);
%             N_y = sArgs.N/N_x;
%             if N_x/N_y > 2 && numel(fac) > 3
%                 n = n*min(fac);
%                 N_x = max(n,sArgs.N/n);
%                 N_y = sArgs.N/N_x;
%             end
%         end
%     end
cart = zeros(3,sArgs.Nx,sArgs.Ny);
is = -(sArgs.Nx-1)/2:(sArgs.Nx-1)/2;
js = -(sArgs.Ny-1)/2:(sArgs.Ny-1)/2;
for l = 1:sArgs.Nx
    for m =  1:sArgs.Ny
        cart(1:2,l,m) = D*[is(l);js(m)];
    end
end
cart = reshape(cart,3,sArgs.Nx*sArgs.Ny);
end

function cart = makeHexagonal(sArgs)
D = sArgs.d*[1 0.5;0 sqrt(3)/2];
D_rot = [cos(sArgs.alpha) -sin(sArgs.alpha);sin(sArgs.alpha) cos(sArgs.alpha)];
D = D_rot.*D;
N_x = 1; N = 1;
while N < sArgs.N
    N_x = N_x + 1;
    if mod(N_x,2)
        N = 1 + sum(6.*(1:(N_x-1)/2));
    end
end
cart = zeros(2,1);
is = -(N_x-1)/2:(N_x-1)/2;
for l = 1:N_x
    N_r = N_x - abs(is(l));
    js = -(N_r-1)/2:(N_r-1)/2;
    for m = 1:N_r
        cart = cat(2,cart,D*flipdim([is(l);js(m)],1));
    end
end
cart = cart(:,2:end);
cart = [cart;zeros(1,size(cart,2))];
if size(cart,2) > sArgs.N
    ita_verbose_info([upper(mfilename) ...
        ':the function returned a larger array than requested, be careful'],0);
elseif size(cart,2) < sArgs.N
    ita_verbose_info([upper(mfilename) ...
        ':the function returned a smaller array than requested, be careful'],0);
end
end

function cart = makeQuincunx(sArgs)
D = sArgs.d*[1 0.5;0 0.5];
if (sqrt(sArgs.N)/floor(sqrt(sArgs.N))) == 1
    N_x = floor(sqrt(sArgs.N));
    N_y = N_x;
else
    if (log2(sArgs.N)/floor(log2(sArgs.N))) == 1
        N_x = 2^ceil(log2(sArgs.N)/2);
        N_y = sArgs.N/N_x;
    else
        fac = factor(sArgs.N);
        n = max(fac);
        N_x = max(n,sArgs.N/n);
        N_y = sArgs.N/N_x;
        if N_x/N_y > 2 && numel(fac) > 3
            n = n*min(fac);
            N_x = max(n,sArgs.N/n);
            N_y = sArgs.N/N_x;
        end
    end
end
if ~mod(N_y,2)
    N_y = N_y + 1;
end
cart = zeros(2,N_x,N_y);
is = -(N_x-1)/2:(N_x-1)/2;
js = -(N_y-1)/2:(N_y-1)/2;
for l = 1:N_x
    for m =  1:N_y
        cart(:,l,m) = D*[is(l);js(m)] - [((js(m)-(~mod(m,2)))*sArgs.d/2);0];
        if ((~mod(m,2)) && l == N_x)
            cart(:,l,m) = [1i;1i];
        end
    end
end
cart = reshape(cart,2,N_x*N_y);
a1 = cart(1,cart(1,:) ~= 1i);
a2 = cart(2,cart(2,:) ~= 1i);
cart = cat(1,a1,a2,zeros(1,numel(a1)));
if size(cart,2) > sArgs.N
    ita_verbose_info([upper(mfilename) ...
        ':the function returned a larger array than requested, be careful'],0);
elseif size(cart,2) < sArgs.N
    ita_verbose_info([upper(mfilename) ...
        ':the function returned a smaller array than requested, be careful'],0);
end
end

function cart = makeLogSpiral(sArgs)
c = 0;
th_0  = c*sArgs.delta;
th = (th_0:sArgs.delta:sArgs.th_max).*pi/180;
a = sArgs.d; b = 0.05;

while numel(th) > sArgs.N
    sArgs.delta = sArgs.delta + 0.5;
    th_0  = c*sArgs.delta;
    th = (th_0:sArgs.delta:sArgs.th_max).*pi/180;
end

while numel(th) < sArgs.N
    sArgs.delta = sArgs.delta - 0.5;
    th_0  = c*sArgs.delta;
    th = (th_0:sArgs.delta:sArgs.th_max).*pi/180;
end
%             th = linspace(th_0,sArgs.th_max,sArgs.N).*pi/180;
x = (a*exp(b.*th)).*cos(th);
y = (a*exp(b.*th)).*sin(th);
ds = sqrt((x-x(end)).^2+(y-y(end)).^2);
d_min = max(ds);
while d_min > sArgs.d/2
    d_min = max(ds);
    b = b*0.99;
    x = (a*exp(b.*th)).*cos(th);
    y = (a*exp(b.*th)).*sin(th);
    for i = 1:numel(x)
        for k = 1:numel(x)
            if i ~= k
                d_min = min(sqrt(((x(i) - x(k)).^2)+((y(i) - y(k)).^2)),d_min);
            end
        end
    end
end
while d_min < sArgs.d/2
    d_min = max(ds);
    b = b*1.01;
    x = (a*exp(b.*th)).*cos(th);
    y = (a*exp(b.*th)).*sin(th);
    for i = 1:numel(x)
        for k = 1:numel(x)
            if i ~= k
                d_min = min(sqrt(((x(i) - x(k)).^2)+((y(i) - y(k)).^2)),d_min);
            end
        end
    end
end
cart = [x;y;zeros(1,numel(x))];
if size(cart,2) > sArgs.N
    ita_verbose_info([upper(mfilename) ...
        ':the function returned a larger array than requested, be careful'],0);
elseif size(cart,2) < sArgs.N
    ita_verbose_info([upper(mfilename) ...
        ':the function returned a smaller array than requested, be careful'],0);
end
end

function cart = makeSpiral(sArgs)
c = 0;
th_0  = c*sArgs.delta;
th = (th_0:sArgs.delta:sArgs.th_max).*pi/180;
a = sArgs.d; b = 0.02;

while numel(th) > sArgs.N
    sArgs.delta = sArgs.delta + 0.5;
    th_0  = c*sArgs.delta;
    th = (th_0:sArgs.delta:sArgs.th_max).*pi/180;
end

while numel(th) < sArgs.N
    sArgs.delta = sArgs.delta - 0.5;
    th_0  = c*sArgs.delta;
    th = (th_0:sArgs.delta:sArgs.th_max).*pi/180;
end
%             th = linspace(th_0,sArgs.th_max,sArgs.N).*pi/180;
x = (a+b.*th).*cos(th);
y = (a+b.*th).*sin(th);
ds = sqrt((x-x(end)).^2+(y-y(end)).^2);
d_min = max(ds);
for i = 1:numel(x)
    for k = 1:numel(x)
        if i ~= k
            d_min = min(sqrt(((x(i) - x(k)).^2)+((y(i) - y(k)).^2)),d_min);
        end
    end
end

while d_min > sArgs.d/2
    d_min = max(ds);
    b = b*0.99;
    x = (a+b.*th).*cos(th);
    y = (a+b.*th).*sin(th);
    for i = 1:numel(x)
        for k = 1:numel(x)
            if i ~= k
                d_min = min(sqrt(((x(i) - x(k)).^2)+((y(i) - y(k)).^2)),d_min);
            end
        end
    end
end

while d_min < sArgs.d/2
    d_min = max(ds);
    b = b*1.01;
    x = (a+b.*th).*cos(th);
    y = (a+b.*th).*sin(th);
    for i = 1:numel(x)
        for k = 1:numel(x)
            if i ~= k
                d_min = min(sqrt(((x(i) - x(k)).^2)+((y(i) - y(k)).^2)),d_min);
            end
        end
    end
end
cart = [x;y;zeros(1,numel(x))];
if size(cart,2) > sArgs.N
    ita_verbose_info([upper(mfilename) ...
        ':the function returned a larger array than requested, be careful'],0);
elseif size(cart,2) < sArgs.N
    ita_verbose_info([upper(mfilename) ...
        ':the function returned a smaller array than requested, be careful'],0);
end
end

function cart = makeCircular(sArgs)
cart = zeros(3,sArgs.N);
d = 0.75*sArgs.d/0.2;
n1 = sArgs.N;
theta = (0:n1-1).*2*pi/n1;
[cart(1,1:n1),cart(2,1:n1)] = pol2cart(theta,repmat(d,1,n1));
%     n1 = min(10,sArgs.N);
%     n2 = 2*floor((sArgs.N-n1)/4);
%     n3 = sArgs.N-n1-n2;
%
%     d_0 = sArgs.d;
%     d = d_0/(sqrt(2)*sqrt(1-cos(2*pi/n1)));
%     r = [sArgs.d,d+d_0,d+3*d_0];
%
%     theta = (0:n1-1).*2*pi/n1;
%     [cart(1,1:n1),cart(2,1:n1)] = pol2cart(theta,repmat(r(1),1,n1));
%     theta = (0:(n2-1)).*2*pi/n2;
%     [cart(1,n1+1:n1+n2),cart(2,n1+1:n1+n2)] = pol2cart(theta,repmat(r(2),1,n2));
%     theta = (0.5:(n3-1)+0.5).*2*pi/n3;
%     [cart(1,n1+n2+1:end),cart(2,n1+n2+1:end)] = pol2cart(theta,repmat(r(3),1,n3));
%     if size(cart,2) > sArgs.N
%         ita_verbose_info([upper(mfilename) ...
%             ':the function returned a larger array than requested, be careful'],0);
%     elseif size(cart,2) < sArgs.N
%         ita_verbose_info([upper(mfilename) ...
%             ':the function returned a smaller array than requested, be careful'],0);
%     end
end

function cart = makeSpherical(sArgs)
[hor, vert] = meshgrid(-180+sArgs.delta:sArgs.delta:180, -90+sArgs.delta:sArgs.delta:90-sArgs.delta);
phi = hor(:).*pi./180; theta = vert(:).*pi./180;
r = sArgs.R.*ones(size(phi));
[X,Y,Z] = sph2cart(phi,theta,r);
X = cat(1,X,[0;0]); Y = cat(1,Y,[0;0]); Z = cat(1,Z,[-sArgs.R;sArgs.R]);
cart = [X';Y';Z'];
end

function cart = makeRandomPlanar(sArgs)
r  = (sArgs.d^2)*sArgs.N*rand(1,sArgs.N);
ph = 2*pi*rand(1,sArgs.N);
X  = sqrt(r).*cos(ph);
Y  = sqrt(r).*sin(ph);
d_min = 10*sArgs.d;
for i = 1:numel(X)
    for k = 1:numel(X)
        if i ~= k
            d_min = min(sqrt(((X(i) - X(k)).^2)+((Y(i) - Y(k)).^2)),d_min);
        end
    end
end
while (d_min < 0.25*sArgs.d) || (d_min > sArgs.d)
    d_min = 10*sArgs.d;
    r  = (sArgs.d^2)*sArgs.N*rand(1,sArgs.N);
    ph = 2*pi*rand(1,sArgs.N);
    X  = sqrt(r).*cos(ph);
    Y  = sqrt(r).*sin(ph);
    for i = 1:numel(X)
        for k = 1:numel(X)
            if i ~= k
                d_min = min(sqrt(((X(i) - X(k)).^2)+((Y(i) - Y(k)).^2)),d_min);
            end
        end
    end
end
%             d_min
Z  = zeros(1,sArgs.N);
cart  = [X;Y;Z];
end

function cart = makeRandomSpherical(sArgs)
z  = -1 + 2*rand(1,sArgs.N);
ph = 2*pi*rand(1,sArgs.N);
r  = sqrt(1-z.^2);
x  = r.*cos(ph);
y  = r.*sin(ph);
cart  = [x;y;z];
end