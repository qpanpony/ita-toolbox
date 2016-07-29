function state = ita_reflectionTimes(params,state,dirs)
% Noam Shabtai
% Institution of Technical Acoustics
% RWTH Aachen
% nsh@akustik.rwth-aachen.de
% 24.7.2014

switch params.stages.reflection_times
case 0
    return;
case 1
    if params.display.headers disp('Calculating reflection times...');end
    c = params.speed_of_sound; 
    fs = params.rir.sampling_frequency;
    Tmax = params.rir.maximum_time;

    gains = state.gains;

    sources_receiver_distances = state.sources_receiver_distances;

    impulse_time_indices =...
         round(fs/c*sources_receiver_distances);

    max_impulse_time_index = Tmax * fs;
    relevant_impulse_time_indices = find(impulse_time_indices < max_impulse_time_index);
    impulse_time_indices = impulse_time_indices(relevant_impulse_time_indices,1);
    gains = gains(relevant_impulse_time_indices,:,:);
    num_of_impulses = length(impulse_time_indices); 


    if params.mode.save_intermediate_results
        save(fullfile(dirs.parent_dir,dirs.mat_dir,...
                      dirs.reflections_filename),...
        'impulse_time_indices',...
        'gains',...
        'num_of_impulses');
    end
case 2
    if params.display.headers disp('Loading reflection times...');end
    load(fullfile(dirs.parent_dir,dirs.mat_dir,...
                  dirs.reflections_filename),...
    'impulse_time_indices',...
    'gains',...
    'num_of_impulses');
end

state.impulse_time_indices = impulse_time_indices;
state.gains = gains;
state.num_of_impulses = num_of_impulses;

% TODO Future work: For a complex base implement something like:
% radiations = gains * pnm;
% gains_reflections_x_frequencies = abs(radiations);
%   
% impulse_time_indices_reflections_x_frequencies =...
%    repmat(impulse_time_indices,1,K) + ...
%     round(phase(radiations) .* repmat(fs./(2*pi*f),num_of_ipulses,1));
%   
% rir_signal = zeros(max(max(impulse_time_indices_reflections_x_frequencies)),K);
% for i=1:num_of_impulses
%   rir_signal(impulse_time_indices_reflections_x_frequencies(i,:) = rir_signal(impulse_time_indices(i),:)+gains(i);
% end
