function varargout = ita_thiele_small_fit(varargin)
%ITA_THIELE_SMALL_FIT
%
%  Functions calculates the Thiele-Small parameters via least squares curve
%  fitting of the electrical impedance and a velocity measurement.
%
%  Syntax:
%   [TS, audioObjZ, audioObjHx] = ita_thiele_small_fit(Z_meas, v_meas, options)
%
%   Options (default):
%           General options
%           'fmin'      :   minimum frequency of the fitting range
%           'fmax'      :   maximum frequency of the fitting range
%           'fminInd'   :   minimum frequency of the fitting range for an
%                           additional inductance fitting
%           'fmaxInd'   :   maximum frequency of the fitting range for an
%                           additional inductance fitting
%           'maxIter'   :   maximum Iterations of lsqnonlin
%           'S_d'       :   surface of the membrane in m^2
%           'plot'      :   plot the result
%
%           Creep models
%           'nc'        :   neglect suspension creep effects
%           'log'       :   knudsen logarithmic creep model
%           'tpc'       :   three parameter creep model by agverkvist
%
%           Inductance fit
%           'L2'        :   parallel circuit of L2 and R2
%           'Rf'        :   frequency dependent resistior Rf
%
%  Example:
%   TS = test_marco_thiele_small_fit(Z_LS, v_meas, 'tpc', 'L2', 'fmax', 4000, 'fmin', 50, 'maxIter', 300);
%
%  See also:
%   itaThieleSmall, ita_inductance_fit, ita_linear_loudspeaker, lsqcurvefit
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_thiele_small_fit">doc ita_thiele_small_fit</a>

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Marco Berzborn -- Email: marco.berzborn@rwth-aachen.de
% Created:  23-Jan-2014


%% Initialization and Input Parsing
sArgs = struct('pos1_Z_meas', 'itaAudio', 'pos2_v', 'itaAudio', 'log', false, 'nC', true, 'tPC', false, 'L2', false, 'Rf', false, 'maxIter', 500, ...
    'fmin', 10, 'fmax', [], 'fminInd', 10, 'fmaxInd', 16000, 'S_d', [], 'plot', true, 'V_0', [],'fftDegree',15);
[Z_meas, v_meas, sArgs] = ita_parse_arguments(sArgs, varargin);

% Rdc
TS.R_e = itaValue(mean(real(Z_meas.freq2value(5,10))), 'Ohm');

% f_s
maxIndex = Z_meas.freq2index(20) + find(gradient(sign(angle(Z_meas.freq2value(20,sArgs.fmaxInd)))) < 0,1,'first'); % 20Hz to avoid phase = 0 due to freqRange < 20 during measurement
TS.f_s = itaValue(Z_meas.freqVector(maxIndex), 'Hz');

% stopping criterion before Le influence becomes too large
if isempty(sArgs.fmax)
    stopIndex = Z_meas.freq2index(20) + find(gradient(sign(angle(Z_meas.freq2value(20,sArgs.fmaxInd)))) > 0,1,'first'); % 20Hz to avoid phase = 0 due to freqRange < 20 during measurement
    sArgs.fmax = round(Z_meas.freqVector(stopIndex));
end

if ~isempty(sArgs.S_d)
    TS.S_d = itaValue(sArgs.S_d, 'm^2');
end

if ~isempty(sArgs.V_0)
    if isempty(sArgs.S_d)
        error('Effective membrane mass missing!');
    else
        TS.V_0 = itaValue(double(sArgs.V_0),'m^3');
        TS.n_g = TS.V_0/(ita_constants('c')^2*ita_constants('rho_0')*TS.S_d^2);
    end
end

if isempty(TS.f_s.value)
    varargout{1} = 'false';
    varargout{2} = 'false';
    varargout{3} = 'false';
    ita_verbose_info('Resonance frequency not found in the fitting range. Please check fmin and fmax.',0);
    return;
end

%% Impedance & Displacement Fit
Hx_meas = ita_integrate(v_meas);
Hx_extract = ita_extract_dat(Hx_meas, sArgs.fftDegree, 'symmetric');
Z_extract = ita_extract_dat(Z_meas, sArgs.fftDegree, 'symmetric');

% Measurement data
freqVec = Z_extract.freqVector(Z_extract.freq2index(sArgs.fmin,sArgs.fmax)).';
impMeas = double(Z_extract.freq2value(sArgs.fmin,sArgs.fmax));
dispMeas = double(Hx_extract.freq2value(sArgs.fmin,sArgs.fmax));

meanImp = mean(abs(impMeas));
meanDisp = mean(abs(dispMeas));
TS.factor = meanImp/meanDisp;


% starting values
M = 1;
Le = 1*10^(-4);
Lces = 1e-4;
Res = 0.1;
Cmes = 1*10^(-4);
b0 = [Le Lces Res Cmes M];
lb = [Le/100000 Lces/1000000 Res/10000 Cmes/100000 1e-2];
ub = [Le*100000 Lces*1000000 Res*10000 Cmes*100000 1e2];

if sArgs.tPC
    k = 0.35;
    fmin = TS.f_s.value;
    b0 = [b0 k fmin];
    lb = [lb 0 1];
    ub = [ub 500 20000];
end

if sArgs.log
    lambda = 0.35;
    b0 = [b0 lambda];
    lb = [lb 0];
    ub = [ub 1];
end

options = optimset('MaxFunEvals',3000*length(b0),'MaxIter', sArgs.maxIter, 'TolFun',1e-16,'TolX',1e-16, ...
    'Jacobian', 'off', 'PlotFcns', {@optimplotresnorm, @optimplotstepsize});
result = lsqcurvefit(@(x,freqVec) ita_curvefit_thiele_small(x,freqVec,TS),b0,freqVec, ...
    [real(impMeas) imag(impMeas) real(dispMeas).*TS.factor imag(dispMeas).*TS.factor],lb,ub,options);

%% writing output
TS.L_e = itaValue(result(1), 'H');
TS.n = itaValue(result(2)/result(5)^2, 's^2/kg');
TS.m = itaValue(result(4)*result(5)^2, 'kg');
TS.w = itaValue(result(5)^2/result(3), 'kg/s');
TS.M = itaValue(result(5), 'T m');

if sArgs.tPC
    TS.k = itaValue(result(6));
    TS.f_min = itaValue(result(7), 'Hz');
    
elseif sArgs.log
    TS.lambda = itaValue(result(6));
end

if isfield(TS,'factor')
    TS = rmfield(TS,'factor');
end

%% Additional inductance fit
if sArgs.L2 || sArgs.Rf
    if sArgs.L2
        inductanceModel = 'L2';
    elseif sArgs.Rf
        inductanceModel = 'Rf';
    end
    TS = ita_inductance_fit(Z_meas, TS, inductanceModel, 'fmin', sArgs.fminInd, 'fmax', sArgs.fmaxInd, 'plot', false);
end

%% generate plots
[audioObjZ, audioObjHx] = ita_linear_loudspeaker(TS, 'samplingRate', Z_meas.samplingRate, 'fftDegree', Z_meas.fftDegree);
audioObjZ = ita_merge(Z_meas, audioObjZ);
audioObjHx = ita_merge(Hx_meas, audioObjHx);
if sArgs.plot
    ita_plot_freq_phase(audioObjZ, 'nodB', 'xlim',[5 20000]);
    ita_plot_freq_phase(audioObjHx, 'nodB', 'xlim',[20 20000]);
end

%% Set Output
%  Thiele-Small Parameter are given back as itaThieleSmall object
varargout = {itaThieleSmall(TS), audioObjZ, audioObjHx};

%end function
end