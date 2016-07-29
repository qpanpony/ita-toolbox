function varargout = ita_enclosure_fit(varargin)
%ITA_ENCLOSURE_FIT
%
%  Functions calculates the enclosure parameters in the electrical equivalent
%  circuit for dynamic transducers via least squars curve fitting.
%
%  Syntax:
%   [TS, audioObjZ] = ita_enclosure_fit(Z_meas, TS, options)
%
%   Options (default):
%           'fmin'      :   minimum frequency of the fitting range
%           'fmax'      :   maximum frequency of the fitting range
%           'maxIter'   :   maximum Iterations of lsqnonlin
%           'plot'      :   plot the result
%
%           Enclosure fit
%           'n_g'        :   
%           'w_g'        :   
%
%  Example:
%   TS = ita_enclosure_fit(Z_meas, TS, 'L2', 'fmax', 4000, 'fmin', 50)
%
%  See also:
%   ita_thiele_small_fit, ita_thiele_small, ita_linear_loudspeaker, lsqcurvefit
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_inductance_fit">doc ita_inductance_fit</a>

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  31-Mar-2014


%% Initialization and Input Parsing
sArgs = struct('pos1_Z_meas', 'itaAudio', 'pos2_TS', '*', 'maxIter', 200, 'fmax', 16000, 'plot', true, 'fftDegree', 14);
[Z_meas, TS, sArgs] = ita_parse_arguments(sArgs, varargin);

if isa(TS, 'itaThieleSmall')
    TS = TS.convert2struct('double');
else
    TS = structfun(@double, TS, 'UniformOutput', 0);
end


% this should be enough for a lower frequency
fmin = double(TS.f_s)*0.5;
% make Re equal, in case the measurements are not that accurate
Re = mean(real(Z_meas.freq2value(20,30))); % edit jme: changed from ...freq2value(5,10)
Z_meas.freq = Z_meas.freq - Re + double(TS.R_e);

[c,rho0] = ita_constants({'c','rho_0'});

% starting value, can be defined in TS
if isfield(TS, 'n_g')
    ng = double(TS.n_g);
else
    if isfield(TS, 'S_d')
        ng = 1e-3/(double(rho0)*double(c)^2*double(TS.S_d)^2); % 1L volume
    else
        ng = 0.1;
    end
end

b0 = [ng 0.1];
lb = [0 0];
ub = [1 100];


Z_extract = ita_extract_dat(Z_meas, sArgs.fftDegree, 'symmetric');
freqVec = Z_extract.freqVector(Z_extract.freq2index(fmin,sArgs.fmax)).';
impMeas = double(Z_extract.freq2value(fmin,sArgs.fmax));


options = optimset('MaxFunEvals',3000*length(b0),'MaxIter', sArgs.maxIter, 'TolFun',1e-20,'TolX',1e-20, ...
    'Jacobian', 'off', 'PlotFcns', {@optimplotresnorm, @optimplotstepsize});
result = lsqcurvefit(@(x,freqVec) ita_curvefit_enclosure(x,freqVec, TS),b0,freqVec, ...
    [real(impMeas) imag(impMeas)],lb,ub,options);

% enclosure
TS.n_g = result(1); % air spring
TS.w_g = result(2); % losses
TS.f_s = 1/sqrt(TS.m*TS.n*TS.n_g/(TS.n+TS.n_g))/2/pi; % new resonance
TS.Q_g = 1/(2*pi*TS.f_s*TS.n_g*TS.w_g); % quality factor

%% generate plots
audioObjZ = ita_merge(Z_meas, ita_linear_loudspeaker(TS, 'samplingRate', Z_meas.samplingRate, 'fftDegree', Z_meas.fftDegree));
if sArgs.plot
    ita_plot_freq_phase(audioObjZ, 'nodB', 'xlim',[5 20000]);
end


varargout = {itaThieleSmall(TS), audioObjZ};
end