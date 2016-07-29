

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

function [coh_theo1] = ita_analytic_coeherence_estimate_function(varargin)

sArgs = struct('sr',44100,'t',1,'drr',1,'bs',4:1:20,'snr',1,'offset',0,'flat',1,'trueanalytical',true);
sArgs = ita_parse_arguments(sArgs,varargin);

bs = sArgs.bs;
t_c = (2.^(bs))./sArgs.sr;
drr = sArgs.drr;
T = sArgs.t;
snr = sArgs.snr;

a1 = 0.05;
a2 = 0.5;

%coh_theo1 = 1 .* 1./(1+(1./((1+drr).*exp(6*log(10)*(t_c/T))-1)) ).^(2); % ToDo: SNR

if sArgs.trueanalytical
coh_theo1 = 1 .* 1./(1+(1./((drr).*(exp(6*log(10)*(t_c/T-sArgs.offset).^(sArgs.flat))))) ).^(2); % ToDo: SNR
else
    coh_theo1 = 1 .* 1./(1+(1./((drr).*(exp(6*log(10)*(t_c/T * a1).^(a2) )))) ).^(2); % ToDo: SNR
end

