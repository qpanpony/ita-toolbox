function varargout = ita_plot_gui(varargin)
%ITA_PLOT_GUI - Part of the ITA-Toolbox GUI
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   handle = ita_plot_gui(options)
%       name ('') :
%       defaultdomain ('spk') :
%
%
%   See also: ita_toolbox_gui.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_plot_gui">doc ita_plot_gui</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  19-Jun-2009 

%% Initialization and Input Parsing
%narginchk(1,1);
sArgs  = struct('name','','defaultdomain','spk');
[Args] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% Get handles, domain and data
% profile on 
% tic
whandle = ita_main_window();
domain  = ita_guisupport_currentdomain();
data    = getappdata(whandle,'audioObj');
% data    = ita_getfrombase(sArgs.name); %
%uiwait(whandle); %Wait till plotting is finished, makes some trouble

%% Clear figure and redraw menu
clf(whandle);
ita_menu('handle',whandle,'type',data);
axis off
if isempty(domain)
    domain = data.domain;
end
    
if ~isempty(data)
    %% Plot
    %% TODO abfrage ob das auch wirklich geht - pdi
    switch lower(domain)
        case {'spk','magnitude','freq'}
            ita_plot_freq(data,'figure_handle',whandle);
        case {'dat','time'}
            ita_plot_time(data,'figure_handle',whandle);
        case {'spkphase','magnitude and phase' }
            ita_plot_freq_phase(data,'figure_handle',whandle);
        case {'magnitude and group delay' }
            ita_plot_freq_groupdelay(data,'figure_handle',whandle);
        case {'real and imaginary part'}
            ita_plot_cmplx(data,'figure_handle',whandle);
        case {'dat_db','time in db'}
            ita_plot_time_dB(data,'figure_handle',whandle);
        case 'all'
            ita_plot_all(data,'figure_handle',whandle)
        case 'spectrogram'
            ita_plot_spectrogram(data,'figure_handle',whandle)
        case 'cepstrum'
            ita_plot_time(ita_cepstrum(data),'figure_handle',whandle)
        case 'envelope'
            ita_plot_time_dB(ita_envelope(data),'figure_handle',whandle)
        case 'barspectrum'
%             ah = get(whandle, 'Children');
            bar(data,'figure_handle',whandle);
            
        otherwise
            ita_plot(data,'figure_handle',whandle);
            ita_verbose_info('ITA_PLOT_GUI: Sorry, I dont know that domain!',1);
    end
end
% toc
% profile viewer

%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
    
else
    % Write Data
    varargout(1) = {whandle}; 
end

%end function
end