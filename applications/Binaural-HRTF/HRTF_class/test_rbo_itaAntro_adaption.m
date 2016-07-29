function HRTFadapted = test_rbo_itaAntro_adaption(varargin)


% <ITA-Toolbox>
% This file is part of the application HRTF_class for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

sArgs           = struct('HRTF',[],'ref',[],'subj',[]);
sArgs           = ita_parse_arguments(sArgs,varargin);
anthroHRTF_ref  = sArgs.ref;
anthroHRTF_subj = sArgs.subj;
HRTFref         = sArgs.HRTF;


t_refL          = anthroHRTF_ref.meanTimeDelay('L');
t_refR          = anthroHRTF_ref.meanTimeDelay('R');
t_subjL         = anthroHRTF_subj.meanTimeDelay('L');
t_subjR         = anthroHRTF_subj.meanTimeDelay('R');

deltaL          = t_refL - t_subjL;
deltaR          = t_refR - t_subjR;
if sum(deltaL < 0)>0 || sum(deltaR < 0)>0
    minDelta    = min([deltaL deltaR]);
    deltaL      = deltaL-minDelta;
    deltaR      = deltaR-minDelta;
end

deltaT                          = zeros(anthroHRTF_ref.dimensions,1);
deltaT(1:2:HRTFref.dimensions)  = deltaL;
deltaT(2:2:HRTFref.dimensions)  = deltaR;

HRTFadapted = test_rbo_FIR_lagrange_delay(deltaT,HRTFref);
% HRTFadapted.ch(2:2:HRTFref.dimensions).ptd