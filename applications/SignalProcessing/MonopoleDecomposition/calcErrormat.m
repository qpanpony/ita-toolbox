function [errormat] = calcErrormat(sources,targetData,f,c,varargin)
%
%  [errormat] = calcErrormat(sources,targetData,f,c,varargin)
%
%  INPUT ARGUMENTS
%   sources     itaAudio/itaResult Object of Monopoles
%   targetData  itaAudio/itaResult Object of measured directivity
%   f           [f_0,f_delta,f_max] or just f for single freq
%               or vektor fvek with set of frequencies
%   c           speed of sound
%   varargin    'weights'    1  -Vector of weights to weight positions in
%                               errorcalculations
%               'phaseweight'1 -used with optimiztion algorithms for
%                               weighted summed error
%
%  OUTPUT ARGUMENTS  1    2          3        4       5       6           7
%   errormat(n,:) = [f,magErrRel,phsErrRel,sqErrsum,corr,sum(diff_abs),sum(diff_ph)];

% <ITA-Toolbox>
% This file is part of the application MonopoleDecomposition for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% args
sArgs = struct('weights',1,'phaseweight',1);
sArgs = ita_parse_arguments(sArgs,varargin);

%% define variables
if length(f) == 3
    fvek = f(1):f(2):f(3);
else
    fvek = f;
end

%% check inputs
if ~isa(sources,'itaSuper') || ~isa(targetData,'itaSuper')
    error('sources and target Data must be itaSuper Objects');
end

if length(f)==3
    fvek = f(1):f(2):f(3);
else
    fvek = f;
end
if length(fvek(:,1))>1
    fvek = fvek.';
end

%% calculate complexe Amplitude for points on the sphere and Plot Loop
dist = calcDist(targetData,sources);
errormat = zeros(length(fvek),8);

for iFreq = 1:numel(fvek)
    src_ampl = sources.freq2value(f(iFreq));
    target_amp = targetData.freq2value(f(iFreq)).';
    [~,diff_abs,diff_ph,corr,diff,~] = calcError(dist,f(iFreq),c,target_amp,src_ampl,...
        'phaseweight',sArgs.phaseweight,'weights',sArgs.weights);
    magErrRel = norm(diff_abs,2)/norm(abs(target_amp),2);
    phsErrRel = norm(diff_ph,2)/norm(unwrap(angle(target_amp)),2);
    %                      1    2          3           4       5       6           7                8
    errormat(iFreq,:) = [f(iFreq),magErrRel,phsErrRel,diff.'*diff,corr,sum(diff_abs),sum(diff_ph),sum(diff_ph)];
end

end
