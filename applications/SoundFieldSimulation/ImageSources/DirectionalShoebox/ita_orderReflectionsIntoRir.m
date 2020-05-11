function state = ita_orderReflectionsIntoRir(params,state,dirs)
% Noam Shabtai
% Institution of Technical Acoustics
% RWTH Aachen
% nsh@akustik.rwth-aachen.de
% 24.7.2014

switch params.stages.order_reflections_into_rir
case 0
    return;
case 1
    if params.display.headers disp('Ordering the reflections into RIR signal...');end
    Ns = params.source.radiation.order;
    Nm = params.microphone.directivity.order;

    impulse_time_indices = state.impulse_time_indices;
    gains = state.gains;
    num_of_impulses = state.num_of_impulses;

    % Can't do rir_signal(impulse_time_indices,:) = gains because some reflections occur at the same time
    switch params.mode.domain.method
    case 'sh_to_rir'
        rir_signal = zeros(max(impulse_time_indices),(Ns+1)^2);
    case 'sh_to_sh'
        rir_signal = zeros(max(impulse_time_indices),(Ns+1)^2,(Nm+1)^2);
    end
    for i=1:num_of_impulses
        rir_signal(impulse_time_indices(i),:,:) = rir_signal(impulse_time_indices(i),:,:)+gains(i,:,:);
    end
    state.rir_signal = rir_signal;
end
