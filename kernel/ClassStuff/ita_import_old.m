function result = ita_import_old(input)
%ITA_IMPORT_OLD - import old data files
%  This function imports old data files
%
%  Syntax:
%   audioObjOut = ita_import_old(audioObjIn, options)
%
%   See also: ita_compile_developer, ita_wavread_continuous.m, ita_generate_documentation, ita_measurement_sensortypes, ita_measurement_sensortypes, ita_portaudio_deviceID2struct, ita_portaudio_string2deviceID, ita_demosound, play, ita_casa, ccx_plot, ita_hrtf_conv, ita_hrtf_get, ita_binaural_diffuse_rir, ita_hrtf_loadinmemory, ita_coherence_time, ita_italian_setup, ita_sort_channels, ita_split_frequencies, ita_freqfromchannelname, ita_inverse_sweep, ita_parametric_GUI, ita_measurement_getlatency, ita_reduce_spk, ita_kundt_gui, ita_measurement_impedance_with_robo, ita_toolbox_path, ita_guisupport_getworkspacelist, ita_main_window, ita_getfrombase, ita_write_gui, ita_guisupport_domainlist, ita_guisupport_currentdomain, ita_clear_workspace, ita_parse_arguments_gui, ita_kundt_gui, ita_kundt_run, ita_kundt_setup, ita_kundt_calc, ita_kundt_save, ita_menucallback_KundtsTube, mf, ita_menucallback_Rememberwindowposition, ita_menucallback_Rememberwindowposition, ita_menucallback_Portaudio, test_its_parse_arguments_gui, ita_quantize_gui, ita_metainfo_GUI, ita_guisupport_audiolistdialog, ita_measurement_calibration, ita_frequency_dependent_time_window, ita_measurement_hammer, ita_blockwise_processing, ita_menucallback_Normalize, ita_extract, ita_plottools_colormap, ita_upcontrol_cutting_phase, ita_pitch_shift, ita_upcontrol_split_frequency_bands, ita_freq2bin, ita_double, ita_decimate_spk, ita_upcontrol_exp_average, ita_upcontrol_draw_cutting_line, ita_ANSI_center_frequencies, ita_plottools_change_font_in_eps, ita_kurtosis, ita_roomacoustics_uncertainty, ita_pointsource_p2Q, ita_batch_processor, ita_randomize_phase, ita_copy_phase, ita_errorlog_add, ita_errorlog_show, ita_errorlog_clear.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_import_old">doc ita_import_old</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  13-Oct-2009

if isstruct(input) && isfield(input,'ITA_TOOLBOX_AUDIO_STRUCT') % Unpack old ita struct structure
    input = input.ITA_TOOLBOX_AUDIO_STRUCT; 
end

if isa(input,'itaSuper')
    %if alread new class, nothing to do
    result = input;
    return
end

%% Old ITA Class => Convert to new
if isstruct(input) %got a struct
    %% Find domain and data
    if isfield(input,'ITA_TOOLBOX_AUDIO_STRUCT')
       input = input.ITA_TOOLBOX_AUDIO_STRUCT; 
    end
    
    if isfield(input,'dimensions') && iscellstr(input.dimensions)
        output.domain = lower(input.dimensions{1}(1:4)); 
        output.data = input.data;
    elseif isfield(input,'spk')
        output.domain = 'freq';
        output.data = input.spk.';
        input = rmfield(input,'spk');
    elseif isfield(input,'dat')
        output.domain = 'time';
        output.data = input.dat.';
        input = rmfield(input,'dat');
    else
        error('no data found');
    end
    
    %% Process header
    if isfield(input,'header') %We got a header, lets get rid of it
        
        if isa(input.header,'itaHeader')
            warning('off','MATLAB:structOnObject')
            input.header = struct(input.header);
            warning('on','MATLAB:structOnObject')
        end
        
        if isfield(input.header,'fcentre') && ~isempty(input.header.fcentre)
            % return an itaResult object
            isResult = true;
            tmpdata = output.data;
            output.domain = 'freq';
            output.freqVector = input.header.fcentre;
            output.data = tmpdata;
        else
            isResult = false;
            output.samplingRate = input.header.samplingRate;
            switch input.header.FFTnorm
                case 1
                    output.signalType = 'energy';
                otherwise
                    output.signalType = 'power';
            end
        end
        output.comment = input.header.Comment;
        sz = size(output.data);
        output.dimensions = sz(2:end);
        output.dateCreated = input.header.DateVector;
        output.history = input.header.History;
        
        output.fileName = ...
         [fullfile(input.header.Filepath,input.header.Filename) '.' ...
          input.header.FileExt(isstrprop(input.header.FileExt,'alphanum'))];
        
        if isfield(input.header,'UserData')
            output.userData = input.header.UserData;
        end
        
        if isfield(input.header,'Channel') %Header with Channel(x). Layout
            if isfield(input.header,'nChannels')
                nChannels = input.header.nChannels;
            elseif isfield(input.header,'Channels')
                nChannels = input.header.Channels;
            else
                nChannels = size(output.data,2);
            end
            output.channelCoordinates = itaCoordinates(nChannels);
            output.channelOrientation = itaCoordinates(nChannels);
            for idx = 1:input.header.nChannels
                output.channelNames{idx}       = input.header.Channel(idx).Name;
                output.channelUnits{idx}       = input.header.Channel(idx).Unit;
                output.channelSensors{idx}     = input.header.Channel(idx).Sensor;
                if ~isempty(input.header.Channel(idx).Coordinates)
                    try %pdi: old formats on harddrive can contain old itaCoordinates
                        output.channelCoordinates.cart(idx,:) = input.header.Channel(idx).Coordinates;
                    catch %#ok<CTCH>
                        ita_verbose_info('Discarding coordinate information',1);
                        %output.channelCoordinates(idx) = itaCoordinates;
                    end
                else
                    ita_verbose_info('Discarding coordinate information',1);
                    %output.channelCoordinates(idx) = itaCoordinates();
                end
                
                if ~isempty(input.header.Channel(idx).Orientation)
                    output.channelOrientation.cart(idx,:) = input.header.Channel(idx).Orientation;
                else
                    ita_verbose_info('Discarding orientation information',1);
%                     output.channelOrientation(idx) = itaCoordinates();
                end
                output.channelUserData{idx}    = input.header.Channel(idx).UserData;
%                 if str2num(input.header.Channel(idx).Sensitivity) ~= 1
%                     warning('ITA_READ:ChannelSensitivity','Sensitivity not 1. Did you compensate for it?')
%                 end
            end
        else
            output.channelNames = input.header.ChannelNames;
            output.channelUnits = input.header.ChannelUnits;
            
            if isfield(input.header,'ChannelCoordinates')
                if ~isempty(input.header.ChannelCoordinates)
                    output.channelCoordinates = itaCoordinates(input.header.ChannelCoordinates,'cart');
                else
                    output.channelCoordinates = itaCoordinates(numel(output.channelNames));
                end
            else
                output.channelCoordinates = itaCoordinates(numel(output.channelNames));
            end
            
            if isfield(input.header,'ChannelOrientation')
                if ~isempty(input.header.ChannelOrientation)
                    output.channelOrientation = itaCoordinates(input.header.ChannelOrientation,'cart');
                else
                    output.channelOrientation = itaCoordinates(numel(output.channelNames));
                end
            else
                output.channelOrientation = itaCoordinates(numel(output.channelNames));
            end
        end
   
    end
    
    output.data = reshape(output.data,size(output.data,1),[]);
    
    if isResult
        % make an itaResult object
        result = itaResult(output);
    else
        % make an itaAudio object
        result = itaAudio(output);
    end
else
    error('%:Oh Lord, no data in the struct',upper(mfilename));
end