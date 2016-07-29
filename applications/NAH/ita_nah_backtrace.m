function varargout = ita_nah_backtrace(varargin)
%ITA_NAH_BACKTRACE - calculate surface velocity from measured pressure data
%  This function performs the Nearfield Acoustical Holography (NAH).
%  The pressure has to be measured in a plane parallel to the vibrating
%  surface and the algorithm performs the backtracing in order to get the
%  normal surface velocity.
%  Input parameters are the audio object of the pressure measurement or a
%  unv-file (from a simulation), the mesh of scan points or a unv-file
%  where the points were saved and the measurement distance.
%  Optional input argument is the cutoff frequency in k-space 
%  (rule of thumb: k_cutoff = 2*pi/measurementDistance) and a flag whether
%  the data has already been mapped to the scan mesh.
%
%  Syntax:
%   audioObjOut = ITA_NAH_BACKTRACE(p,measurementMesh,measurementDistance, options)
%
%   Options (default):
%           'k_cutoff' (2*pi/measurementDistance) : cutoff frequency in k-space
%           'mapped'   (false)                    : whether data is already mapped
%
%
%
%   Reference page in Help browser 
%        <a href="matlab:doc ITA_NAH_BACKTRACE">doc ITA_NAH_BACKTRACE</a>

% <ITA-Toolbox>
% This file is part of the application NAH for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  25-Aug-2009 

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(3,9);
if ischar(varargin{1}) && strcmpi(varargin{1}(end-2:end),'unv') % unv-file instead of audio object
    varargin{1} = ita_readunv58(varargin{1});
end
if ischar(varargin{2}) && strcmpi(varargin{2}(end-2:end),'unv') % unv-file instead of mesh object
    varargin{2} = ita_readunv2411(varargin{2});
end

sArgs        = struct('pos1_input','itaSuper','pos2_measurementMesh', ...
    'itaMeshNodes','pos3_measurementDistance','numeric', 'k_cutoff',[], ...
    'mapped',false, 'debug', false);
[input,measurementMesh,measurementDistance,sArgs] = ita_parse_arguments(sArgs,varargin); 

% k_cutoff beinhaltet die cutoff-Frequenz im k-space nBins mal (für jede
% Frequenz einen Wert...)
if isempty(sArgs.k_cutoff)
    %sArgs.k_cutoff = repmat(2*pi/measurementDistance,input.nBins,1);
    sArgs.k_cutoff = repmat(1000,input.nBins,1);
elseif numel(sArgs.k_cutoff) < input.nBins
    if numel(sArgs.k_cutoff) == 1
        sArgs.k_cutoff = repmat(sArgs.k_cutoff,input.nBins,1);
    else
        error([thisFuncStr 'number of cutoff wavenumbers must be either 1 or equal to the number of bins!']);
    end
end

%% 'input' is an audioObj and is given back 
% data preprocessing
% pressure data should have dimensions frequency,scanpoints
if ~sArgs.mapped
    input = ita_mapDataToMesh(input,measurementMesh);
end
% different freq - points
nFreq = input.nBins;
% to get all x/y - positions once
x = unique(input.channelCoordinates.x);
y = unique(input.channelCoordinates.y);
% number of different x/y positions
nx = numel(x);
ny = numel(y);
% whole distance in x/y - direction
L_x = max(x)-min(x);
L_y = max(y)-min(y);

% aperture filter 
% (8-tap raised cosine at the edges of the measurement area)
% falls wenige Messpunkte vorhanden sind, wird der Filter steiler gewählt.
% Dabei werden maximal 20% der Messpunkte verwendet!
tap=8;
if ceil(nx*0.2) < tap
    tap=floor(nx*0.2);
end
x_w = tap*mean(diff(x));
y_w = tap*mean(diff(y));
x_con1 = (x > (max(x)-x_w));
x_con2 = (x < (min(x)+x_w));
x_con3 = (x <= (max(x)-x_w)).*(x >= (min(x)+x_w));
f_x = x_con1.*0.5.*(1-cos(pi.*(x-max(x))./x_w)) + x_con2.*0.5.*(1-cos(pi.*(min(x)-x)./x_w)) + x_con3;

y_con1 = (y > (max(y)-y_w));
y_con2 = (y < (min(y)+y_w));
y_con3 = (y <= (max(y)-y_w)).*(y >= (min(y)+y_w));
f_y = y_con1.*0.5.*(1-cos(pi.*(y-max(y))./y_w)) + y_con2.*0.5.*(1-cos(pi.*(min(y)-y)./y_w)) + y_con3;

% F_a ist die Gewichtungsmatrix der örtlichen Filterung
F_a = f_x*f_y.';

% k-space (supersonic) filter % warum supersonic? evanescente Wellenanteile
% sind eigentlich subsonic...
% (circular exponential filter with defined cutoff frequency)
k_cutoff = sArgs.k_cutoff;
delta_kx = 2*pi/L_x;
delta_ky = 2*pi/L_y;
if rem(nx,2)    % ungerade
    kx = (-(nx-1)/2:(nx-1)/2).*delta_kx;
else            % gerade
    kx = (-nx/2:nx/2-1).*delta_kx;
end
if rem(ny,2)
    ky = (-(ny-1)/2:(ny-1)/2).*delta_ky;
else
    ky = (-ny/2:ny/2-1).*delta_ky;
end
[kx,ky] = meshgrid(kx,ky); % kx&ky scheint irgendwie richtig zu sein: mesh((sinc(kx*2*pi*0.001)+sinc(ky*2*pi*0.001)))
kr = sqrt((kx.^2)+(ky.^2));
alpha = 0.1; % 0.05 % Faktor für die k-Space-Filterung

% NAH algorithm
f = input.freqVector;
p = input.freq;
w = zeros(size(p));
Z_0 = double(ita_constants('z_0'));
for i=1:nFreq
    %ita_verbose_info([thisFuncStr 'processing frequency bin ' num2str(i) ' of ' num2str(nFreq)],2);
    % k-space filter
    k_con1 = (kr <= k_cutoff(i));
    k_con2 = (kr >  k_cutoff(i));
    if alpha == 0
        F_k = k_con1;
    else
        F_k = k_con1.*(1-0.5.*exp(-(1-kr./k_cutoff(i))./alpha))+k_con2.*0.5.*exp((1-kr./k_cutoff(i))./alpha);
    end
    % inverse velocity propagator
    k  = repmat(2*pi*f(i)/340,size(kx,1),size(kx,2));
    kz = sqrt((k.^2)-(kx.^2)-(ky.^2));
    G = (kz./(Z_0.*k)).*exp(-1i.*kz*measurementDistance);   % Gl. (3.3)
    % xy velocity frequency response in the source plane
    p_i = squeeze(p(i,:,:));  % anschauen mit: contourf(unique(input.channelCoordinates.x),unique(input.channelCoordinates.y),abs(p_i))
    p_if = p_i.*F_a;     % örtliche Filterung
    W = fftshift(fft2(p_if)); % k-Transformation
    Wk = W .* F_k;    % k-space Filterung
    W_zh= Wk.*G;    % propagation W_zh ist schnelle auf Oberfläche!
    % xy velocity function in the source plane
    w(i,:,:) = ifft2(ifftshift(W_zh));
    
    % just debugging... 
    if sArgs.debug && (f(i)==100 || f(i)== 1000 || f(i) == 10000 || f(i) == 16000) % rem(i,100) == 0   
        show_nah;
    end
end

input.freq = w;
input.channelCoordinates.z = input.channelCoordinates.z - measurementDistance;
input.channelNames(:) = {'normal velocity from NAH'};
input.channelUnits(:) = {'m/s'};

%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {input}; 

%end function
end