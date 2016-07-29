function ita_guisupport_updateGUI(fgh)
% plot audio in figure


currentDomain = getappdata(fgh,'ita_domain');
data =  getappdata(fgh,'audioObj');

clf(fgh, 'reset')


if isempty(currentDomain)
    error('')
    currentDomain = data.domain;
end
    
if ~isempty(data)
    %% Plot
    %% TODO abfrage ob das auch wirklich geht - pdi
    switch lower(currentDomain)
        case {'spk','magnitude','frequency'}
            ita_plot_freq(data,'figure_handle',fgh);
        case {'dat','time'}
            ita_plot_time(data,'figure_handle',fgh);
        case {'spkphase','magnitude and phase' 'frequency and phase'}
            ita_plot_freq_phase(data,'figure_handle',fgh);
        case {'magnitude and group delay' 'frequency and group delay' }
            ita_plot_freq_groupdelay(data,'figure_handle',fgh);
        case {'real and imaginary part'}
            ita_plot_cmplx(data,'figure_handle',fgh);
        case {'dat_db','time in db' 'time_db'}
            ita_plot_time_dB(data,'figure_handle',fgh);
        case 'all'
            ita_plot_all(data,'figure_handle',fgh)
        case 'spectrogram'
            ita_plot_spectrogram(data,'figure_handle',fgh)
        case 'cepstrum'
            ita_plot_time(ita_cepstrum(data),'figure_handle',fgh)
        case 'envelope'
            ita_plot_time_dB(ita_envelope(data),'figure_handle',fgh)
        case 'barspectrum'
%             ah = get(fgh, 'Children');
            bar(data,'figure_handle',fgh);
            
        otherwise
            ita_plot(data,'figure_handle',fgh);
            ita_verbose_info('ITA_PLOT_GUI: Sorry, I dont know that domain!',1);
    end
    
    % update menu like this???
    ita_menu('handle',fgh,'type',data);
end