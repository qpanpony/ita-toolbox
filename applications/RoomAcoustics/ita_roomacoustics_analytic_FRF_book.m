function varargout = ita_roomacoustics_analytic_FRF_book(varargin)
%ITA_ROOMACOUSTICS_ANALYTIC_FRF - Transfer Function of Rectangular Rooms
%  After Kuttruff Room Acoustics pp.66:
%  This function calculates the ideal FRF of an rectangular room of size
%  (Lx, Ly, Lz) for source position (rs_x, rs_y, rs_z) and receiver
%  positions ... PLUS: cartesian differentian of the source or receiver
%
%  Syntax:
%   audioObjOut = ita_roomacoustics_analytic_FRF_book(geometryCoordinates, sourceCoordinates, receiverCoordinates, options)
%
%   Options (default):
%           'T' (2) : description
%           'f_max' (10000) : description
%           'fft_degree' (18) : description
%           'sourceDiff' ([0 0 0]): monopole, dipole in x ([1 0 0]), etc.
%           'receiverDiff' ([0 0 0]): monopole, dipole in x ([1 0 0]), etc.
%
%  Example:
%   audioObjOut = ita_roomacoustics_analytic_FRF(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_roomacoustics_analytic_FRF">doc ita_roomacoustics_analytic_FRF</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: Pascal -- Email: pdi@akustik.rwth-aachen.de
% Created:  13-Jul-2011

% Please take a look at our reference for further details:
%
% @INPROCEEDINGS{mpoRirDAGA2013,
%   author = {Martin Pollow and Pascal Dietrich and Michael Vorländer},
%   title = {Room Impulse Responses of Rectangular Rooms for Sources and Receivers
% 	of Arbitrary Directivity},
%   booktitle = DAGA2013,
%   year = {2013}}

%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaCoordinates', 'pos2_data','itaCoordinates','pos3_data','itaCoordinates',...
    'fftDegree',18,'T',2,'f_max',10000,'c',ita_constants('c'),...
    'receiverDiff',[0 0 0], 'sourceDiff', [0 0 0],'samplingRate',44100,'simple',true,'pressuremode',true);
[geometry, source_pos, receiver_pos ,sArgs] = ita_parse_arguments(sArgs,varargin);

%% Inits
f_max           = max(sArgs.f_max);
% Q             = 1;
c               = double(sArgs.c);
delta_n_raw     = 3*log(10)/sArgs.T;
L               = geometry.cart;
r_source        = source_pos.cart;
r_receiver      = receiver_pos.cart; % TODO: pdi: what about multiple receiving points?

%% get number of room modes
warning off %#ok<WNOFF>
idx = 0;
for nx = 0:floor(2*f_max/c * L(1))
    for ny = 0:floor( real(sqrt( (2*f_max/c)^2 - (nx/L(1))^2 ) * L(2) ))
        if ~isempty(ny) && isreal(ny) % " && isreal" hat keinen Effekt
            idx = idx + floor( real(sqrt( (2*f_max/c)^2 - (nx/L(1))^2  - (ny/L(2))^2) * L(3))) + 1;
        end
    end
end
nModes = idx;
dummy  = zeros(1,nModes);
disp([num2str(nModes) ' modes have to be calculated...'])

%% calculate mode numbers
n = zeros(3,nModes);
idx = 1;
nx_max = floor(2*f_max/c * L(1));
for nx = 0:nx_max
    ny_max = floor( real(sqrt( (2*f_max/c)^2 - (nx/L(1))^2 ) * L(2) ));
    for ny = 0:ny_max
        nz_max = floor( real(sqrt( (2*f_max/c)^2 - (nx/L(1))^2  - (ny/L(2))^2) * L(3)));
        
        idx_end = idx + nz_max;
        n(1,idx:idx_end) = nx;
        n(2,idx:idx_end) = ny;
        n(3,idx:idx_end) = 0:nz_max;
        
        idx = idx + nz_max + 1;
    end
end
ita_verbose_info([num2str(idx - nz_max - 1) ' modes have been calculated...'],1);

%% Eigenfrequencies
f_n = c / 2 * sqrt( sum ( bsxfun(@rdivide,n,L').^2 ,1) );

if numel(sArgs.f_max) == 2 %use only a frequency band
    idxx = find(f_n <= max(sArgs.f_max) & f_n >= min(sArgs.f_max));
    f_n = f_n(idxx);
    n = n(:,idxx);
    ita_verbose_info(['reduced to: ' num2str(size(n,2)) ' modes.'],1);
end

%% Source Receiver Coefficients
coeff_r = potential_diff(r_receiver,L,n,sArgs.receiverDiff);
coeff_s = potential_diff(r_source,L,n,sArgs.sourceDiff);

%% new with SourceFactor [kg/s^2] - mass acceleration
% orthonormality of eigenfunctions - integration of cos^2(x) -> x/2 +
% sin...; sin term is not important
K_n     = itaValue(prod(L),'m3') * 0.5.^(sum(n > 0,1)); % in Allen/Berkley ASA1979  Image method for efficiently simulating small-room acoustics

% factor  = (-4*pi)*itaValue(double(sArgs.c),'m/s')^2 / K_n /itaValue('Hz2');
factor  = itaValue(double(sArgs.c),'m/s')^2 / K_n /itaValue('Hz2'); % pdi: dec-2012, -4*pi term is not in Eq.3.10. thanks to mpo!
% SourceFactor = j Q omega rho_0

coeff   = coeff_r .* coeff_s .* double(factor).'; %unit = [];

%% pressure mode at 0 frequency
if ~sArgs.pressuremode
    coeff(1) = 0; % remove resonance at DC frequency
end

%% damping
if isa(delta_n_raw,'itaSuper')
    delta = delta_n_raw.freq2value(f_n).';
else
    delta = dummy + delta_n_raw;
end

%% loop
res              = itaAudio;
res.samplingRate = sArgs.samplingRate;
res.signalType   = 'energy'; %pdi: bugfix
res.fftDegree    = sArgs.fftDegree;
omega            = res(1).freqVector * 2 * pi; %pre-calculation to save time
omega2           = omega.^2; %pre-calculation to save time

%% Loop for symmetric poles
FRF_data = 0 * omega;
omega_n = 2*pi * f_n;  % speed reason
if sArgs.simple
    for idx = 1:length(f_n);
        % kuttruff says -delta !
        den = (omega2 -  delta(idx)^2 - omega_n(idx)^2 - 2*1i * delta(idx) * omega_n(idx)); %pdi: also tried omega instead of the last omega_n, only slower, but same result... %pdi: marc 2013. -delta due to NaN at DC!
        FRF_data = FRF_data  +  (coeff(idx) ./ den);
        if sum(isnan(FRF_data))
            disp
        end
    end
else
    for idx = 1:length(f_n);
        % kuttruff says -delta !
        den = (+omega2 -  delta(idx)^2 - omega_n(idx)^2 - 2*1i * delta(idx) .* omega); % accurate result
        FRF_data = FRF_data  +  (coeff(idx) ./ den);
    end
    
end

%% 2itaAudio
res.freq        = FRF_data;
res.comment     = ['geo=[' num2str(geometry.cart) ' ' ' ' ']' ' sDiff' num2str(sArgs.sourceDiff), ' rDiff' num2str(sArgs.receiverDiff) ];
res.channelNames{1} = res.comment;
varargout{1}    = res;

%end function
end

%% helper functions
function res = potential_diff(pos,L,n,derivation)
% pos: coordinates (not normalized)
% L: geometry of room, length in meters
% n: eigennumber
% derivation: [0 0 0] - monopole, [1 0 0] - first dipole

res = 1; %accumulate results
for idx = 1:3 % go thru x,y,z
    
    if mod(derivation(idx),2) % 1 3 5...
        res_part = sin(pi * n(idx,:) * pos(idx)/L(idx));
    else % 0 2 4
        res_part = cos(pi * n(idx,:) * pos(idx)/L(idx));
    end
    res_part = res_part .* (pi * n(idx,:) / L(idx)).^derivation(idx) * (-1).^(1+mod(floor((derivation(idx)-1)/2),2));
    
    res = res.*res_part;
end
end %end helper


