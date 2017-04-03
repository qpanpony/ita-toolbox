function varargout = ita_nah_supersonicIntensity(varargin)
%ITA_NAH_SUPERSONICINTENSITY - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_nah_supersonicIntensity(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_nah_supersonicIntensity(audioObjIn)
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_nah_supersonicIntensity">doc ita_nah_supersonicIntensity</a>

% <ITA-Toolbox>
% This file is part of the application NAH for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  07-Jan-2010 

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_input', 'itaSuper', 'k_cutoff', []);
[input,sArgs] = ita_parse_arguments(sArgs,varargin); 

if isempty(sArgs.k_cutoff)
    sArgs.k_cutoff = 2*pi.*1.5.*input.freqVector./340;
elseif numel(sArgs.k_cutoff) < input.nBins
    if numel(sArgs.k_cutoff) == 1
        sArgs.k_cutoff = sArgs.k_cutoff(ones(input.nBins,1));
    else
        error([thisFuncStr 'number of cutoff wavenumbers must be either 1 or equal to the number of bins!']);
    end
end

%% 'input' is an audioObj and is given back
nFreq = input.nBins;
x = input.userData{find(strcmpi(input.userData,'x')==1)+1}(:);
y = input.userData{find(strcmpi(input.userData,'y')==1)+1}(:);
nx = numel(x);
ny = numel(y);
L_x = max(x)-min(x);
L_y = max(y)-min(y);

% k-space (supersonic) filter
% (circular exponential filter with defined cutoff frequency)
k_cutoff = sArgs.k_cutoff;
delta_kx = 2*pi/L_x;
delta_ky = 2*pi/L_y;
if rem(nx,2)
    kx = (-(nx-1)/2:(nx-1)/2).*delta_kx;
else
    kx = (-nx/2:nx/2-1).*delta_kx;
end
if rem(ny,2)
    ky = (-(ny-1)/2:(ny-1)/2).*delta_ky;
else
    ky = (-ny/2:ny/2-1).*delta_ky;
end
[kx,ky] = meshgrid(kx,ky);

kr = sqrt((kx.^2)+(ky.^2));
alpha = 0.1; % 0.05

% supersonic intensity algorithm
f  = input.freqVector;
w  = input.freq;
ps = zeros(size(w));
ws = zeros(size(w));
for i=1:nFreq
    ita_verbose_info([thisFuncStr 'processing frequency bin ' num2str(i) ' of ' num2str(nFreq)],2);
    % k-space filter
    k_con1 = (kr <= k_cutoff(i));
    k_con2 = (kr >  k_cutoff(i));
    if alpha == 0
        F_k = k_con1;
    else
        F_k = k_con1.*(1-0.5.*exp(-(1-kr./k_cutoff(i))./alpha))+k_con2.*0.5.*exp((1-kr./k_cutoff(i))./alpha);
    end
    % xy velocity frequency response in the source plane
    W = fftshift(fft2(squeeze(w(i,:,:))));
    % Rayleigh integral to get P from W
    k  = repmat(2*pi*f(i)/340,size(kx,1),size(kx,2));
    kz = sqrt((k.^2)-(kx.^2)-(ky.^2));
    % xy pressure frequency response in the source plane
    P  = 1.225*340.*k./kz.*W;
    % supersonic pressure and velocity (function of space)
    ps(i,:,:) = ifft2(ifftshift(F_k.*P));
    ws(i,:,:) = ifft2(ifftshift(F_k.*W));
end

% supersonic intensity (just like 'regular' one
input.freq = 0.5.*real(ps.*conj(ws));
input.channelNames(:) = {'normal supersonic intensity'};
input.channelUnits(:) = {'W/m^2'};

%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {input}; 

%end function
end