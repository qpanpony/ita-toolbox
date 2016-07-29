function varargout = ita_roomacoustics_analytic_FRF(varargin)
%ITA_ROOMACOUSTICS_ANALYTIC_FRF - After Kuttruff Room Acoustics pp.66
%  This function calculates the ideal FRF of an rectangular room of size
%  (Lx, Ly, Lz) for source position (rs_x, rs_y, rs_z) and receiver
%  positions ... PLUS: cartesian differentian of the source or receiver
%
%  Syntax:
%   audioObjOut = ita_roomacoustics_analytic_FRF_differentiation(geometryCoordinates, sourceCoordinates, receiverCoordinates, options)
%
%   Options (default):
%           'T' (2) : description
%           'f_max' (10000) : description
%           'fft_degree' (18) : description
%           'sourceDiff' ([0 0 0]): monopole, dipole in x ([1 0 0]), etc.
%           'receiverDiff' ([0 0 0]): monopole, dipole in x ([1 0 0]), etc.
%
%  Example:
%   itaPZobject = ita_roomacoustics_analytic_FRF([roomGeo],[source],[receiver])
%   ao  = itaAudioAnalyticRational(itaPZobject); ao.plot_freq
%
%  See also:
%   ita_roomacoustics_analytic_FRF_book
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
    'fft_degree',18,'T',2,'f_max',10000,'c',ita_constants('c'),...
    'receiverDiff',[0 0 0], 'sourceDiff', [0 0 0],'verbose',true,'n',[]);
[geometry, source_pos, receiver_pos ,sArgs] = ita_parse_arguments(sArgs,varargin);

%% Inits
sArgs.f_max     = sArgs.f_max;
% Q             = 1;
c               = double(sArgs.c);
delta_n_raw     = 3*log(10)/sArgs.T;
L               = geometry.cart;
r_source        = source_pos.cart;
r_receiver      = receiver_pos.cart; % TODO: pdi: what about multiple receiving points?

if isempty(sArgs.n)
    %% check loop
    warning off %#ok<WNOFF>
    idx = 0;
    for nx = 0:floor(2*sArgs.f_max/c * L(1))
        for ny = 0:floor( real(sqrt( (2*sArgs.f_max/c)^2 - (nx/L(1))^2 ) * L(2) ))
            if ~isempty(ny) && isreal(ny)
                idx = idx + floor( real(sqrt( (2*sArgs.f_max/c)^2 - (nx/L(1))^2  - (ny/L(2))^2) * L(3))) + 1;
            end
        end
    end
    nModes = idx;
    dummy  = zeros(1,nModes);
    if sArgs.verbose && nModes >= 10000
        disp([num2str(nModes) ' modes have to be calculated...'])
    end
    
    %%
    n = zeros(3,nModes);
    idx = 1;
    nx_max = floor(2*sArgs.f_max/c * L(1));
    for nx = 0:nx_max
        ny_max = floor( real(sqrt( (2*sArgs.f_max/c)^2 - (nx/L(1))^2 ) * L(2) ));
        for ny = 0:ny_max
            nz_max = floor( real(sqrt( (2*sArgs.f_max/c)^2 - (nx/L(1))^2  - (ny/L(2))^2) * L(3)));
            
            idx_end = idx + nz_max;
            n(1,idx:idx_end) = nx;
            n(2,idx:idx_end) = ny;
            n(3,idx:idx_end) = 0:nz_max;
            
            idx = idx + nz_max + 1;
        end
    end
%     test = [nx_max, ny_max, nz_max]
else % mode number is given
    nmax = sArgs.n;
        idx = 1;

    for nx = 0:nmax(1)
        for ny = 0:nmax(2)
            nz_max = nmax(3);
            
            idx_end = idx + nz_max;
            n(1,idx:idx_end) = nx;
            n(2,idx:idx_end) = ny;
            n(3,idx:idx_end) = 0:nz_max;
            
            idx = idx + nz_max + 1;
        end
    end
    nModes = idx;
        dummy  = zeros(1,nModes);

end
ita_verbose_info([num2str(idx - nz_max - 1) ' modes have been calculated...'],1);

%% Eigenfrequencies
f_n = c / 2 * sqrt( sum ( bsxfun(@rdivide,n,L').^2 ,1) );

%% Source Receiver Coefficients
coeff_r = potential_diff(r_receiver,L,n,sArgs.receiverDiff);

coeff_s = potential_diff(r_source,L,n,sArgs.sourceDiff);

%% get the right coefficient
% corr = 2.^sum(n == 0,1); %pdi: nov 2010 - corrected  - integration of cos^2(...)
% coeff = coeff_r .* coeff_s .* corr * prod(L)/8 * 340;

%% new with SourceFactor [kg/s^2]
K_n = itaValue(prod(L),'m3') * 0.5.^(sum(n > 0,1));
factor = sArgs.c^2 / K_n /itaValue('Hz2');
% factor.unit
coeff = coeff_r .* coeff_s .* double(factor).'; %unit = [];

corr  = -(2 * pi * f_n) * 2 * 1i; %pdi:HUHU: not totally correct, should be j*omega after modal superposition
coeff = coeff ./ corr;

coeff(corr == 0) = 0; %avoid NaN for strange correction coefficient (zero)

if isa(delta_n_raw,'itaSuper')
    delta = delta_n_raw.freq2value(f_n).';
else
    delta = dummy + delta_n_raw;
end
delta = -abs(delta);

%% Set Output
if nargout == 3
    varargout(1) = {f_n};
    varargout(2) = {coeff};
    varargout(3) = {delta};
elseif nargout == 2
    varargout(1) = {f_n};
    varargout(2) = {coeff_r .* coeff_s};
elseif nargout == 4
    varargout(1) = {f_n};
    varargout(2) = {coeff_r .* coeff_s};
    varargout(3) = {delta};
    varargout(4) = {n.'};

else
    pz = itaPZ;
    pz.f = f_n;
    pz.C = coeff;
    pz.sigma = delta;
    % pdi: currently it seems to be s/m !!! Jul 2011 - this is probably due
    % to the douple pole handling here and the single pole handling with
    % mirrowing positive poles in the itaPZ.freqresp
    pz.unit = itaValue('1/m') * itaValue('1/m') ^ (sum(sArgs.receiverDiff) + sum(sArgs.sourceDiff));
    
    varargout{1} = pz;
end

%end function
end
function res = potential_diff(pos,L,n,derivation)
% pos: coordinates (not normalized)
% L: geometry of room, length in meters
% n: eigennumber
% derivation: [0 0 0] - monopole, [1 0 0] - first dipole

res = 1;
for idx = 1:3
    
    if mod(derivation(idx),2) % 1 3 5...
        res_part = sin(pi * n(idx,:) * pos(idx)/L(idx));
    else % 0 2 4
        res_part = cos(pi * n(idx,:) * pos(idx)/L(idx));
    end
    res_part = res_part .* (pi * n(idx,:) / L(idx)).^derivation(idx) * (-1).^(1+mod(floor((derivation(idx)-1)/2),2));
    
    res = res.*res_part;
end



end


