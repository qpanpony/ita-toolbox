function varargout = ita_import_array(varargin)
%ITA_IMPORT_ARRAY - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
% 
%  TODO HUHU Documentation
% 
%  Syntax:
%   audioObjOut = ita_import_array(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_import_array(audioObjIn)
%
%   See also: ita_compile_developer, ita_wavread_continuous.m, ita_generate_documentation, ita_measurement_sensortypes, ita_measurement_sensortypes, ita_portaudio_deviceID2struct, ita_portaudio_string2deviceID, ita_demosound, play, ita_casa, ccx_plot, ita_hrtf_conv, ita_hrtf_get, ita_binaural_diffuse_rir, ita_hrtf_loadinmemory, ita_coherence_time, ita_italian_setup, ita_sort_channels, ita_split_frequencies, ita_freqfromchannelname, ita_inverse_sweep, ita_parametric_GUI, ita_measurement_getlatency, ita_reduce_spk, ita_kundt_gui, ita_measurement_impedance_with_robo, ita_toolbox_path, ita_guisupport_getworkspacelist, ita_main_window, ita_getfrombase, ita_write_gui, ita_guisupport_domainlist, ita_guisupport_currentdomain, ita_clear_workspace, ita_parse_arguments_gui, ita_kundt_gui, ita_kundt_run, ita_kundt_setup, ita_kundt_calc, ita_kundt_save, ita_menucallback_KundtsTube, mf, ita_menucallback_Rememberwindowposition, ita_menucallback_Rememberwindowposition, ita_menucallback_Portaudio, test_its_parse_arguments_gui, ita_quantize_gui, ita_metainfo_GUI, ita_guisupport_audiolistdialog, ita_measurement_calibration, ita_frequency_dependent_time_window, ita_measurement_hammer, ita_blockwise_processing, ita_menucallback_Normalize, ita_extract, ita_plottools_colormap, ita_upcontrol_cutting_phase, ita_pitch_shift, ita_upcontrol_split_frequency_bands, ita_freq2bin, ita_double, ita_decimate_spk, ita_upcontrol_exp_average, ita_upcontrol_draw_cutting_line, ita_ANSI_center_frequencies, ita_plottools_change_font_in_eps, ita_kurtosis, ita_roomacoustics_uncertainty, ita_pointsource_p2Q.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_import_array">doc ita_import_array</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  01-Sep-2009

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('dbpath','','precision','double','namefilter','*.ita','coord_mode','','mirror',false,'mod',[] );
sArgs = ita_parse_arguments(sArgs,varargin); 

%% +++Body - Your Code here+++ 'result' is an audioObj and is given back

if isempty(sArgs.dbpath)
    sArgs.dbpath = uigetdir();
end
dbpath = sArgs.dbpath;

[x1, dbname] = fileparts(dbpath);

%% Get all 'ita' in folder
FileList = recursive_filelist(dbpath, sArgs.namefilter,sArgs.mod);
nfiles = numel(FileList);

%% Preallocate Memory
filename = [FileList{1}];
tmp = ita_fft(ita_read(filename,[],[],'parse_coordinates'));
resultfreq = nan(size(tmp.data,1),size(tmp.data,2),nfiles,sArgs.precision);
Coordinates = nan(tmp.nChannels,nfiles, 3);
Orientation = nan(tmp.nChannels,nfiles, 3);
nChannels = size(tmp.data,2);
resultChannelNames = cell(nChannels,nfiles);
resultChannelUnits = cell(nChannels,nfiles);
resultChannelSensors = cell(nChannels,nfiles);
resultChannelUserData = cell(nChannels,nfiles);

%% Process every file
for idx = 1:nfiles
    if mod(idx,100) == 0
        disp([num2str(idx/numel(FileList)*100, 3) '% processed']);
    end
    filename = [FileList{idx}];
    tmp = ita_fft(ita_read(filename));
    resultfreq(:,:,idx) = tmp.data;
    resultChannelNames(:,idx) = tmp.channelNames;
    resultChannelUnits(:,idx) = tmp.channelUnits;
    resultChannelSensors(:,idx) = tmp.channelSensors;
    resultChannelUserData(:,idx) = tmp.channelUserData;
    if isempty(sArgs.coord_mode)
        Coordinates(:,idx,:) = tmp.channelCoordinates.sph;
        Orientation(:,idx,:) = tmp.channelOrientation.sph;
    else % Parse coordinates
        switch lower(sArgs.coord_mode)
            case 'hakk' % 90 oben -90 unten, rotation mathematisch 0 - 359
                V = str2double(filename(end-10:end-8));
                H = str2double(filename(end-6:end-4));
                theta = (90-V) / 180*pi;
                phi = H / 180*pi;
                r = 1;
                Coordinates(:,idx,:) = repmat([r theta phi],nChannels,1);
                Orientation(:,idx,:) = repmat([0 0 0],nChannels,1);
            case 'd200' % 180 oben, 0 unten, rotation mathematisch
                V = str2double(filename(end-10:end-8));
                H = str2double(filename(end-6:end-4));
                theta = (180-V) / 180*pi;
                phi = H / 180*pi;
                r = 1;
                Coordinates(:,idx,:) = repmat([r theta phi],nChannels,1);
                Orientation(:,idx,:) = repmat([0 0 0],nChannels,1);
            otherwise
                error('I don''t know this cord mode');
        end
    end
end
totalchannelno = size(Coordinates,1)*size(Coordinates,2);
Coordinates = reshape(Coordinates,totalchannelno,3);
Orientation = reshape(Orientation,totalchannelno,3);

result = itaAudio();
result.freq = resultfreq;
result = cast(result,sArgs.precision);
clear resultfreq;
result.channelNames = reshape(resultChannelNames,totalchannelno,1);
result.channelUnits = reshape(resultChannelUnits,totalchannelno,1);
result.channelSensors = reshape(resultChannelSensors,totalchannelno,1);
result.channelUserData = reshape(resultChannelUserData,totalchannelno,1);
result.channelCoordinates = itaCoordinates(Coordinates,'sph');
result.channelOrientation = itaCoordinates(Orientation,'sph');
result.signalType = tmp.signalType;
result.samplingRate = tmp.samplingRate;
result.comment = dbname;

if sArgs.mirror % Mirror top to bottom
    domain = result.domain;
    npos = result.dims(2);
    result.(domain)(:,:,end+1:end+npos) = result.(domain); % Mirror data
    result.channelNames = [result.channelNames(1:npos*nChannels); result.channelNames(1:npos*nChannels)];
    result.channelUnits = [result.channelUnits(1:npos*nChannels); result.channelUnits(1:npos*nChannels)];
    result.channelSensors = [result.channelSensors(1:npos*nChannels); result.channelSensors(1:npos*nChannels)];
    result.channelUserData = [result.channelUserData(1:npos*nChannels); result.channelUserData(1:npos*nChannels)];
    Coordinates = [Coordinates(1:npos*nChannels,:); Coordinates(1:npos*nChannels,:)];
    Coordinates(npos*nChannels+1:end,2) = pi - Coordinates(1:npos*nChannels,2);
    result.channelCoordinates = itaCoordinates(Coordinates,'sph');

end


%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
    
else
    % Write Data
    varargout(1) = {result};
end

%end function
end

function filelist = recursive_filelist(path, filter,modulus)
% Find subdirs
list = dir(path);
filelist = {};
for idx = 1:numel(list)
    if list(idx).isdir && ~strcmpi(list(idx).name(1),'.')
        filelist = [filelist recursive_filelist([path filesep list(idx).name],filter,modulus)]; %#ok<AGROW> %Recursive calling for subdirs
    end
end

% Add files from current dir
list = dir([path filesep filter]);
for idx = 1:numel(list)
    if ~list(idx).isdir
        if isempty(modulus)
            rest = 0;
        else
            V = str2double(list(idx).name(end-10:end-8));
            H = str2double(list(idx).name(end-6:end-4));
            rest = mod(V,modulus) + mod(H,modulus);
        end
        if rest == 0
            filename = [path filesep list(idx).name]; %Full path filename
            filelist = [filelist {filename}]; %#ok<AGROW>
        end
    end
end
end