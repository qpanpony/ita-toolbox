function [ diff_o,diff_abs,diff_phase,corr,diff_sum,res_amp ] = calcError(dist,f,c,target_amp,src_amp,varargin )
%CALCERROR calculates error at a single freq, can also be used in optimisation algorithms
%
%[ diff_o,diff_abs,diff_phase,corr,diff_sum,res_amp ] = CALCERROR(dist,f,c,target_amp,src_amp,varargin )
%
%  INPUT ARGUMENTS
%   'dist'          distanceMatrix calculated \w calcDist
%   'c'             speed of sound
%   'f'             singular Frequency
%   'target_amp'    measured pressure
%   'src_amp'
%
%  VARARGIN options w/ defaults
%   'phaseweight'    1        allows for weighted phase in diff_o = errAbs + phaseweight*errPhs
%   'weights'        1        weight per measurement position
%   'useCorr'        false    set true to use in optimizer as optimisation target
%
%  Output Arguments
%   diff_o      summed error of phase and abs (either corr or abs) to use
%               with optimizers, uses weighted phase
%   diff_abs    abs error
%   diff_phase  phase error
%   corr        crosscorrelation of measured and monopole-directivity (cmplx)
%   diff_sum    unweighted sum of phase and abs error
%   res_amp     soundpressure at measurementpositions created by monopoles

% <ITA-Toolbox>
% This file is part of the application MonopoleDecomposition for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>



sArgs = struct('phaseweight',1,'weights',1,'useCorr', false);
sArgs = ita_parse_arguments(sArgs,varargin);

k = 2*pi*f/c;
greenMat = exp(-1i*k.*dist)/4/pi./dist;
res_amp = greenMat*src_amp.';
diff_abs = abs(target_amp-res_amp);
diff_phase = abs(unwrap(angle(target_amp))-unwrap(angle(res_amp)));

diff_abs = diff_abs.*sArgs.weights;
diff_phase = diff_phase.*sArgs.weights;


diff_sum = diff_phase+diff_phase;
corr = corrcoef(target_amp,res_amp);
corr = corr(2);

if sArgs.useCorr
    diff_o = 1-abs(corr)+angle(corr);
else
    diff_o = diff_phase+sArgs.phaseweight*diff_phase;
end

end  %function