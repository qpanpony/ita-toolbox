function state = ita_reflectionGains(params,state,dirs)
% Noam Shabtai
% Institution of Technical Acoustics
% RWTH Aachen
% nsh@akustik.rwth-aachen.de
% 24.7.2014

if ~params.stages.reflection_gains return; end

if params.display.headers disp('Calculating reflection gains...');end
Ns = params.source.radiation.order;

reflection_coefficients_Rx1 = state.reflection_coefficients;
sources_receiver_distances_Rx1 = state.sources_receiver_distances;
radiation_Ynm_RxNMs = state.radiation_Ynm_RxNM;

gains_Rx1 = reflection_coefficients_Rx1 ./ sources_receiver_distances_Rx1;

switch params.mode.domain.method
case 'sh_to_rir'
    if ~strcmp(params.mode.microphone_directivity.method,'omni')
        directivity_Ynm_RxNMm = state.directivity_Ynm_RxNM;
        anm_NMmx1 = params.microphone.directivity.anm_NMmx1;
        a_Rx1 = directivity_Ynm_RxNMm*anm_NMmx1;
        gains_Rx1 = gains_Rx1 .* abs(a_Rx1);
    end
    gains_RxNMs = radiation_Ynm_RxNMs .* repmat(gains_Rx1,1,(Ns+1)^2);
    gains = gains_RxNMs;
case 'sh_to_sh'
    gains_RxNMs = radiation_Ynm_RxNMs .* repmat(gains_Rx1,1,(Ns+1)^2);

    Nm = params.microphone.directivity.order;
    directivity_Ynm_RxNMm = state.directivity_Ynm_RxNM;
    directivity_Ynm_Rx1xNMm = permute(directivity_Ynm_RxNMm,[1,3,2]);
    directivity_Ynm_RxNMsxNMm = repmat(directivity_Ynm_Rx1xNMm,[1,(Ns+1)^2,1]);
    gains_RxNMsxNMm = repmat(gains_RxNMs,[1,1,(Nm+1)^2]);
    gains_RxNMsxNMm = directivity_Ynm_RxNMsxNMm .* gains_RxNMsxNMm;
    gains = gains_RxNMsxNMm;
end

state.gains = gains;
