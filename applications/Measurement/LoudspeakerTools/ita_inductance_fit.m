function varargout = ita_inductance_fit(varargin)
%ITA_INDUCTANCE_FIT
%
%  Functions calculates the inductance in the electrical equivalent
%  circuit for dynamic transducers via least squars curve fitting.
%
%  Syntax:
%   [TS, audioObjZ] = ita_inductance_fit(Z_meas, TS, options)
%
%   Options (default):
%           'fmin'      :   minimum frequency of the fitting range
%           'fmax'      :   maximum frequency of the fitting range
%           'maxIter'   :   maximum Iterations of lsqnonlin
%           'plot'      :   plot the result
%
%           Inductance fit
%           'L2'        :   parallel circuit of L2 and R2
%           'Rf'        :   frequency dependent resistior Rf
%
%  Example:
%   TS = ita_inductance_fit(Z_meas, TS, 'L2', 'fmax', 4000, 'fmin', 50)
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


% Author: Marco Berzborn -- Email: marco.berzborn@rwth-aachen.de
% Created:  23-Jan-2014


%% Initialization and Input Parsing
sArgs = struct('pos1_Z_meas', 'itaAudio', 'pos2_TS', '*', 'L2', false, 'Rf', false, 'Le', false', 'maxIter', 50, ...
    'fmin', 10, 'fmax', 16000, 'plot', true, 'fftDegree', 14);
[Z_meas, TS, sArgs] = ita_parse_arguments(sArgs, varargin);

if isa(TS, 'itaThieleSmall')
    TS = TS.convert2struct('double');
else
    TS = structfun(@double, TS, 'UniformOutput', 0);
end


%%
if isfield(TS, 'L_e')
    Le = double(TS.L_e);
else
    Le = 1e-4;
end

if sArgs.Le
    b0 = Le;
    lb = Le/1e6;
    ub = Le*1e6;
    
elseif sArgs.L2
    R2 = 1;
    L2 = 1e-4;
    
    b0 = [Le R2 L2];
    lb = [Le/1e6 R2/1e6 L2/1e6];
    ub = [Le*1e6 R2*1e6 L2*1e6];
    
elseif sArgs.Rf
    Rf = 1;
    
    b0 = [Le Rf];
    lb = [Le/1e6 Rf/1e6];
    ub = [Le*1e6 Rf*1e6];
    
end

Z_extract = ita_extract_dat(Z_meas, sArgs.fftDegree, 'symmetric');
freqVec = Z_extract.freqVector(Z_extract.freq2index(sArgs.fmin,sArgs.fmax)).';
impMeas = double(Z_extract.freq2value(sArgs.fmin,sArgs.fmax));

options = optimset('MaxFunEvals',3000*length(b0),'MaxIter', sArgs.maxIter, 'TolFun',1e-16,'TolX',1e-16, ...
    'Jacobian', 'off', 'PlotFcns', {@optimplotresnorm, @optimplotstepsize});
result = lsqcurvefit(@(x,freqVec) ita_curvefit_inductance(x,freqVec, TS),b0,freqVec, ...
    [real(impMeas) imag(impMeas)],lb,ub,options);
close(gcf);

TS.L_e = itaValue(result(1), 'H');

if sArgs.L2
    TS.R_2 = itaValue(result(2), 'Ohm');
    TS.L_2 = itaValue(result(3), 'H');
    
elseif sArgs.Rf
    TS.R_f = itaValue(result(2), 'Ohm/Hz');
    
end

%% generate plots
audioObjZ = ita_merge(Z_meas, ita_linear_loudspeaker(TS, 'samplingRate', Z_meas.samplingRate, 'fftDegree', Z_meas.fftDegree));
if sArgs.plot
    ita_plot_freq_phase(audioObjZ, 'nodB', 'xlim',[5 20000]);
end

varargout = {itaThieleSmall(TS), audioObjZ};
end