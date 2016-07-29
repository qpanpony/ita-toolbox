function [result, max_rec_lvl, shiftSamples] = run_HD(this, varargin)
% run_HD - Run harmonic distortion measurement.
%
% This function runs a measurement with input measurement chain
% correction and deconvolution, and splits the result into
% seperate channels for every harmonic.
%
% The propagation delay in the impulse response is automatically removed
% and the resulting shift samples are returned as a third output argument

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

sArgs = struct('degree', 5, 'windowFactor', 0.6);
sArgs = ita_parse_arguments(sArgs, varargin);

if this.fftDegree < 18
    ita_verbose_info('You will not get any reasonable results with your FFT degree. Changing it temporarily...',1);
    MS = itaMSTF(this);
    MS.fftDegree = 18;
else
    MS = this;
end

[result, max_rec_lvl] = run_raw_imc_dec(MS);

[result,shiftSamples] = ita_nonlinear_extract_harmonics(result, MS.final_excitation,'windowFactor', sArgs.windowFactor, 'degree', sArgs.degree);

end