function varargout = ita_extract_samples(data, ind, WindowType)
%ITA_EXTRACT_SAMPLES - Extract samples from itaAudio
%  This function extracts samples from an itaAudio and can apply a window,
%   it works similar to ita_extract_dat but is designed for speed (Window is cached, no checks or whatsoever)
%
%  Syntax:
%   audioObj = ita_extract(audioObj,Indexes,options)
% 
%  Options:
%   WindowType ('Rectangle'):  choose 'rectangle', 'hanning' or 'sqrt_hanning' window
%  Example:
%   audioObj = ita_extract(audioObj)
%
%   See also: ita_compile_developer, ita_wavread_continuous.m, ita_generate_documentation, ita_measurement_sensortypes, ita_measurement_sensortypes, ita_portaudio_deviceID2struct, ita_portaudio_string2deviceID, ita_demosound, play, ita_casa, ccx_plot, ita_hrtf_conv, ita_hrtf_get, ita_binaural_diffuse_rir, ita_hrtf_loadinmemory, ita_coherence_time, ita_italian_setup, ita_sort_channels, ita_split_frequencies, ita_freqfromchannelname, ita_inverse_sweep, ita_parametric_GUI, ita_measurement_getlatency, ita_reduce_spk, ita_kundt_gui, ita_measurement_impedance_with_robo, ita_toolbox_path, ita_guisupport_getworkspacelist, ita_main_window, ita_getfrombase, ita_write_gui, ita_guisupport_domainlist, ita_guisupport_currentdomain, ita_clear_workspace, ita_parse_arguments_gui, ita_kundt_gui, ita_kundt_run, ita_kundt_setup, ita_kundt_calc, ita_kundt_save, ita_menucallback_KundtsTube, mf, ita_menucallback_Rememberwindowposition, ita_menucallback_Rememberwindowposition, ita_menucallback_Portaudio, test_its_parse_arguments_gui, ita_quantize_gui, ita_metainfo_GUI, ita_guisupport_audiolistdialog, ita_measurement_calibration, ita_frequency_dependent_time_window, ita_measurement_hammer, ita_blockwise_processing, ita_menucallback_Normalize.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_extract">doc ita_extract</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  08-Jul-2009

%% Get ITA Toolbox preferences and Function String
%verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
%thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(2,3);

persistent ita_extract_window;
persistent ita_extract_window_type;
persistent ita_extract_window_size;

%data = varargin{1};
%ind = varargin{2};
if nargin > 2
%    WindowType = varargin{3};
else
    WindowType = 'Rectangle';
end

if max(ind) > size(data.data,1);
    data.data(end+1:max(ind),:) = 0;
end

%% Recalculate Window if necessary (new window, type changed, size changed)
if ~strcmpi(WindowType,'rectangle')
    if isempty(ita_extract_window) ||  ~strcmpi(ita_extract_window_type,WindowType) || any(ita_extract_window_size ~= [numel(ind) data.nChannels])   %recalculate window
        switch lower(WindowType)
            case {'hanning' , 'sqrt_hanning'};
                wname = @hann;
            case 'rectangle'
                wname = @rectwin;
            otherwise
                error([WindowType ' not known']); %#ok<*WNTAG>
                
                
        end
        ita_extract_window_type = WindowType;
        ita_extract_window_size = [numel(ind) data.nChannels];
        ita_extract_window = window(wname,numel(ind)+1);
        if strcmpi(WindowType, 'sqrt_hanning')
            ita_extract_window = sqrt(ita_extract_window);
        end
        ita_extract_window(end,:) = [];
        ita_extract_window = repmat(ita_extract_window,1,data.nChannels);
    end
        
    data.data = data.data(ind,:) .* ita_extract_window;

else %It's a rec window, nothing to do but extract
    data.data = data.data(ind,:);
end

%% Add history line
%data.header = ita_metainfo_add_historyline(data.header,mfilename,varargin);

%% Find output parameters
varargout(1) = {data};
%end function
end