function varargout = ita_rational2itaAudio(varargin)
%ITA_ROOMACOUSTICS_ANALYTIC_FRF - After Kuttruff Room Acoustics pp.66
%  This function calculates the ideal FRF of an rectangular room of size
%  (Lx, Ly, Lz) for source position (rs_x, rs_y, rs_z) and receiver
%  positions ...
%
%  Syntax:
%   audioObjOut = ita_roomacoustics_analytic_FRF(geometryCoordinates, sourceCoordinates, receiverCoordinates, options)
%
% Author: Pascal -- Email: pdi@akustik.rwth-aachen.de
% Created:  25-May-2010

% <ITA-Toolbox>
% This file is part of the application PoleZeroProny for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>



%% Input Parsing
sArgs        = struct('pos1_data','double', 'pos2_data','double','pos3_data','double', 'fftDegree',17);
[fvec_all, delta_all, coeff_all ,sArgs] = ita_parse_arguments(sArgs,varargin);

%% get rid off negative frequencies - we always assume symmetric spectra and PZ distribution
idx   = find(fvec_all > 0);
fvec  = fvec_all(idx);
delta = delta_all(idx);
coeff = coeff_all(idx);
ita_verbose_info([num2str(length(idx)) ' negative poles neglected (but positives are mirrowed, symmetry)'],0)

%% find real poles
idx     = find(fvec_all == 0);
fvec0   = fvec_all (idx);
delta0  = delta_all(idx);
coeff0  = coeff_all(idx);
ita_verbose_info([num2str(length(idx)) ' real poles found'],0)

%% Init
FRF     = itaAudio;
FRF.fftDegree = sArgs.fftDegree;
omega   = FRF(1).freqVector * 2 * pi;
omega2  = omega.^2;

%% Loop for symmetric poles
FRF_data = 0 * omega;
omega_n = 2*pi * fvec;  % speed reason
for idx = 1:length(fvec);
    den = (omega2 - omega_n(idx)^2 + 2*1i * delta(idx) * omega_n(idx)); %pdi: also tried omega instead of the last omega_n, only slower, but same result...
    FRF_data = FRF_data  +  (coeff(idx) ./ den);
end
corr            = -omega * 2 * 1i; %used to be equal with radiafrequency toolbox
FRF_data        = FRF_data .* corr;

%% Loop for Real poles
FRF_data1 = 0 * omega;
for idx = 1:length(fvec0);
    den = (1i*omega + delta0(idx)); %(omega2 - omega_n(idx)^2 - 2*1i * delta(idx) * omega_n(idx)); %pdi: also tried omega instead of the last omega_n, only slower, but same result...
    FRF_data1 = FRF_data1  +  (coeff0(idx) ./ den);
end
% FRF_data1        = FRF_data1 .* corr;

%% Write Data into audio object
FRF.freqData    = [FRF_data FRF_data1 FRF_data + FRF_data1];
FRF.signalType  = 'energy';

%% Set Output
varargout(1) = {FRF};
end