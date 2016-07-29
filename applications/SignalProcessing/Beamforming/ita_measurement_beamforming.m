function varargout = ita_measurement_beamforming(varargin)
%ITA_MEASUREMENT_BEAMFORMING - (Continuously) Run a beamforming measurement and display the result
%  This function performs a continuous measurement with the settings as
%  specified in the first input argument. On the measured data, Beamforming
%  calculations will be made assuming the given array geometry and scan
%  points. The measured data will be returned as output argument.
%
%  Optional arguments control the plot behavior and whether the measurement
%  will be run at maximum speed (with increased CPU load), important for
%  higher channel numbers.
%
%  Syntax:
%   audioObjOut = ita_measurement_beamforming(measurementSetup,itaMicArray,itaMeshNodes options)
%
%   Options (default):
%           'plotFreqs' (2500)     : vector of plot frequencies
%           'backgroundImage' ([]) : image to use as plot background
%           'aspectMat' ([])       : matrix with aspect values for background image
%           'webcamMode' (false)   : whether to try to access a connected webcam for the background image
%           'runmaxspeed' (false)  : as in ITA_MEASUREMENT_CONTINUOUSLY
%           'pagebuffer' (1)       : as in ITA_MEASUREMENT_CONTINUOUSLY
%
%  Example:
%   result = ita_measurement_beamforming(MS,Array,Scanmesh,'runmaxspeed',true)
%
%   See also: ita_compile_developer, ita_wavread_continuous.m, ita_generate_documentation, ita_measurement_sensortypes, ita_measurement_sensortypes, ita_portaudio_deviceID2struct, ita_portaudio_string2deviceID, ita_demosound, play, ita_casa, ccx_plot, ita_hrtf_conv, ita_hrtf_get, ita_binaural_diffuse_rir, ita_hrtf_loadinmemory, ita_coherence_time, ita_italian_setup, ita_sort_channels, ita_split_frequencies, ita_freqfromchannelname, ita_inverse_sweep, ita_parametric_GUI, ita_measurement_getlatency, ita_reduce_spk, ita_kundt_gui, ita_measurement_impedance_with_robo, ita_toolbox_path, ita_guisupport_getworkspacelist, ita_main_window, ita_getfrombase, ita_write_gui, ita_guisupport_domainlist, ita_guisupport_currentdomain, ita_clear_workspace, ita_parse_arguments_gui, ita_kundt_gui, ita_kundt_run, ita_kundt_setup, ita_kundt_calc, ita_kundt_save, ita_menucallback_KundtsTube, mf, ita_menucallback_Rememberwindowposition, ita_menucallback_Rememberwindowposition, ita_menucallback_Portaudio, test_its_parse_arguments_gui, ita_quantize_gui, ita_metainfo_GUI, ita_guisupport_audiolistdialog, ita_measurement_calibration, ita_frequency_dependent_time_window, ita_measurement_hammer, ita_blockwise_processing, ita_menucallback_Normalize, ita_extract, ita_plottools_colormap, ita_upcontrol_cutting_phase, ita_pitch_shift, ita_upcontrol_split_frequency_bands, ita_freq2bin, ita_double, ita_decimate_spk, ita_upcontrol_exp_average, ita_upcontrol_draw_cutting_line, ita_ANSI_center_frequencies, ita_plottools_change_font_in_eps, ita_kurtosis, ita_roomacoustics_uncertainty, ita_pointsource_p2Q, ita_batch_processor, ita_randomize_phase, ita_copy_phase.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_measurement_beamforming">doc ita_measurement_beamforming</a>

% <ITA-Toolbox>
% This file is part of the application Beamforming for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  08-Oct-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(1,10);
sArgs        = struct('pos1_MS','anything','pos2_Array','itaMicArray','pos3_Scanmesh','itaMeshNodes','plotFreqs',2500, ...
                    'backgroundImage',[],'aspectMat',[],'webcamMode',false,'runmaxspeed',false,'pagebuffer',1);
sArgs = ita_parse_arguments(sArgs,varargin); 

MS = sArgs.MS;
Array = sArgs.Array;
Scanmesh = sArgs.Scanmesh;
runMaxSpeed = sArgs.runmaxspeed;
pageBufCount = sArgs.pagebuffer;
plotFreqs = sArgs.plotFreqs;

%% background image
if sArgs.webcamMode
    a = imaqhwinfo;
    b = imaqhwinfo(a.InstalledAdaptors{2},1);
    vid = videoinput(a.InstalledAdaptors{2}, b.DeviceID, b.SupportedFormats{1});
    % set(vid,'FramesPerTrigger',1);
    x = [-1.2,1.2];
    y = (3/4)*x;
    aspectMat = [x;y];
    start(vid);
    % backgroundImage = flipdim(getdata(vid),1);
    backgroundImage = flipdim(getsnapshot(vid),1);
    stop(vid);
else
    if isempty(sArgs.backgroundImage)
        try
            folder = fileparts(which(mfilename));
            backgroundImage = flipdim(imread([folder filesep 'aufbau.jpg']),1);
        catch
            backgroundImage = [];
        end
    else
        backgroundImage = sArgs.backgroundImage;
    end
end

if isempty(sArgs.aspectMat) && ~sArgs.webcamMode
    % use a standard aspectMat
    x = [-1.2,1.2];
    y = (3/4)*x
    aspectMat = [x;y];
else
   aspectMat = sArgs.aspectMat; 
end

%% plot figure
v = ceil(numel(plotFreqs)/2);
if numel(plotFreqs) > 1
    h = 2;
else
    h = 1;
end
scrsz = get(0,'ScreenSize');
plotFigure = figure('Position',[1 1 scrsz(3) scrsz(4)]);

drawnow;
hand = -1.*ones(numel(plotFreqs),1);
alpha = 0.5;

%% Find device
playdeviceID = -1;
recdeviceID = -1;
driver_name = 'Hammerfall';
output_name = 'Hammerfall';

Devices = playrec('getDevices');
for dev_i = 1:length(Devices)
    if ~isempty(strfind(Devices(dev_i).name,driver_name))
        if recdeviceID > -1
            error('ITA_AUDIOPLAYRECORD:More than one device found, please be more accurate.');
        else
            recdeviceID = Devices(dev_i).deviceID;
%             recdeviceinfo = Devices(dev_i);
        end
    end
    if ~isempty(strfind(Devices(dev_i).name,output_name))
        if playdeviceID > -1
            error('ITA_AUDIOPLAYRECORD:More than one device found, please be more accurate.');
        else
            playdeviceID = Devices(dev_i).deviceID;
%             playdeviceinfo = Devices(dev_i);
        end
    end
    
end

%% Perform measurement
data = MS.Excitation;

% Playrec initialisation
if playrec('isInitialised') && ((playrec('getSampleRate') ~= data.samplingRate) || (playrec('getRecDevice') ~= recdeviceID)  || (playrec('getPlayDevice') ~= playdeviceID))
    if playrec('isInitialised')
        playrec('reset');
    end
    
end
if(~playrec('isInitialised'))
    playrec('init', data.samplingRate, playdeviceID, recdeviceID);
end
if(~playrec('isInitialised'))
    error ('ITA_AUDIOPLAYRECORD:Unable to initialise playrec correctly');
end

%% Create vector to act as FIFO for page numbers
pageNumList = repmat(-1, [1 pageBufCount]);

firstTimeThrough = true;

%Clear all previous pages
playrec('delPage');
raw_result = itaAudio();
raw_result.samplingRate = data.samplingRate;

while(ishandle(plotFigure))
    pageNumList = [pageNumList playrec('playrec',data.dat.',MS.OutputChannels,-1,MS.InputChannels)];
    
    if(firstTimeThrough)
        %This is the first time through so reset the skipped sample count
        playrec('resetSkippedSampleCount');
        firstTimeThrough = false;
    else
        if(playrec('getSkippedSampleCount'))
            fprintf('%d samples skipped!!\n', playrec('getSkippedSampleCount'));
            %return
            %Let the code recover and then reset the count
            firstTimeThrough = true;
        end
    end
    
    % runMaxSpeed==true means a very tight while loop is entered until the
    % page has completed whereas when runMaxSpeed==false the 'block'
    % command in playrec is used.  This repeatedly suspends the thread
    % until the page has completed, meaning the time between page
    % completing and the 'block' command returning can be much longer than
    % that with the tight while loop
    if(runMaxSpeed)
        while(playrec('isFinished', pageNumList(1)) == 0)
        end
    else
        playrec('block', pageNumList(1));
    end
    
    raw_result.dat = playrec('getRec', pageNumList(1)).';
    
    playrec('delPage', pageNumList(1));
    %pop page number from FIFO
    pageNumList = pageNumList(2:end);
    
    
    if ~isempty(raw_result.dat) %Will be empty for the first repeat(s)
        raw_result = ita_metainfo_check(raw_result);
        %% Apply Channel Settings
        raw_result = ita_channel_settings(raw_result,MS.ChannelSettings);
        result = raw_result;
        
        if sArgs.webcamMode
            start(vid);
%             backgroundImage = flipdim(getdata(vid),1);
            backgroundImage = flipdim(getsnapshot(vid),1);
            stop(vid);
        end
        tic
        p = ita_time_window(result,[0.2 0.15 0.5 0.55],'time');
        f = ita_ANSI_center_frequencies([0.8*min(plotFreqs) 1.25*max(plotFreqs)],12);
        p = itaResult(p',f,'frequency');
        B = ita_beam_beamforming(Array,p,Scanmesh,1);
        %     M = ita_beam_beamforming(Array,p,Scanmesh,5);
        %     C = ita_beam_beamforming(Array,p,Scanmesh,7);
        
        if ishandle(plotFigure)
            for i=1:numel(plotFreqs)
                if v > 1 || h > 1
                    subplot(v,h,i);
                end
                hand(i) = ita_plot_beamforming(B,plotFreqs(i),'mag',6,alpha,hand(i),backgroundImage,aspectMat);
            end
        end
        toc
        drawnow;
    end
end

playrec('reset');

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters

varargout(1) = {result};

%end function
end