function varargout = ita_rational2itaAudio_new(varargin)
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
[fvec, delta, coeff ,sArgs] = ita_parse_arguments(sArgs,varargin);

%% Init
FRF             = itaAudio;
FRF.fftDegree   = sArgs.fftDegree;
omega           = FRF(1).freqVector * 2 * pi;

%% get negative frequencies
if ~any(find(fvec < 0))
    ita_verbose_info('Mirrowing positive poles for you...',0)
    idx   = find(fvec > 0);
    fvec  = [fvec -fvec(idx)];
    delta = [delta delta(idx)];
    coeff = [coeff conj(coeff(idx))];
end

%% Loop
omega_n = 2*pi * fvec;
FRF_data = 0 * omega;
for idx = 1:length(fvec);
    den = (1i*omega - delta(idx) - 1i*real(omega_n(idx)) ); %(omega2 - omega_n(idx)^2 - 2*1i * delta(idx) * omega_n(idx)); %pdi: also tried omega instead of the last omega_n, only slower, but same result...
    if isinf(den)
       disp(' INF data') 
    end
    FRF_data = FRF_data  +  (coeff(idx) ./ den);
end
FRF.freqData    = FRF_data;
FRF.signalType  = 'energy';

%% Set Output
varargout(1) = {FRF};
end