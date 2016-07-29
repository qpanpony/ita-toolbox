function varargout = ita_convert_RT_alpha_R_Z(varargin)
%ITA_CONVERT_RT_ALPHA_R_Z - conversion between different room acoustic quantities
%  This function converts one room acoustic quantity to another.
%  The possible quantities are: 
%          - Reverberation Time 'RT' (T60)
%          - Absorption Coefficient 'alpha'
%          - Reflection Factor 'R'
%          - (Wall) Impedance 'Z'
%
%  Input arguments are an itaAudio object as the input quantity, strings
%  specifying the type of the input and output quantity and the room volume
%  and (wall) surface.
%
%  If no input argument or just an itaAudio object are given, a GUI will be
%  displayed.
%
%  Syntax:
%   audioObjOut = ita_convert_RT_alpha_R_Z(audioObjIn, options)
%
%   Options (default):
%           'inQty' ('RT')     : name of input quantity
%           'outQty' ('alpha') : name of output quantity
%           'V' (100)          : room volume [m^3]
%           'S' (50)           : wall surface [m^2]
%
%  Example:
%   alpha = ita_convert_RT_alpha_R_Z(RT)
%   Z = ita_convert_RT_alpha_R_Z(RT,'inQty','RT','outQty','Z','V',50,'S',30)
%
%   See also: ita_compile_developer, ita_wavread_continuous.m, ita_generate_documentation, ita_measurement_sensortypes, ita_measurement_sensortypes, ita_portaudio_deviceID2struct, ita_portaudio_string2deviceID, ita_demosound, play, ita_casa, ccx_plot, ita_hrtf_conv, ita_hrtf_get, ita_binaural_diffuse_rir, ita_hrtf_loadinmemory, ita_coherence_time, ita_italian_setup, ita_sort_channels, ita_split_frequencies, ita_freqfromchannelname, ita_inverse_sweep, ita_parametric_GUI, ita_measurement_getlatency, ita_reduce_spk, ita_kundt_gui, ita_measurement_impedance_with_robo, ita_toolbox_path, ita_guisupport_getworkspacelist, ita_main_window, ita_getfrombase, ita_write_gui, ita_guisupport_domainlist, ita_guisupport_currentdomain, ita_clear_workspace, ita_parse_arguments_gui, ita_kundt_gui, ita_kundt_run, ita_kundt_setup, ita_kundt_calc, ita_kundt_save, ita_menucallback_KundtsTube, mf, ita_menucallback_Rememberwindowposition, ita_menucallback_Rememberwindowposition, ita_menucallback_Portaudio, test_its_parse_arguments_gui, ita_quantize_gui, ita_metainfo_GUI, ita_guisupport_audiolistdialog, ita_measurement_calibration, ita_frequency_dependent_time_window, ita_measurement_hammer, ita_blockwise_processing, ita_menucallback_Normalize, ita_extract, ita_plottools_colormap, ita_upcontrol_cutting_phase, ita_pitch_shift, ita_upcontrol_split_frequency_bands, ita_freq2bin, ita_double, ita_decimate_spk, ita_upcontrol_exp_average, ita_upcontrol_draw_cutting_line, ita_ANSI_center_frequencies, ita_plottools_change_font_in_eps, ita_kurtosis, ita_roomacoustics_uncertainty, ita_pointsource_p2Q, ita_batch_processor, ita_readunv, ita_writeunv.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_convert_z_alpha">doc ita_convert_RT_alpha_R_Z</a>

% <ITA-Toolbox>
% This file is part of the application Conversions for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  30-Sep-2009 

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(0,9);
if nargin
    sArgs        = struct('pos1_data','itaSuper','inQty','RT','outQty','alpha','V',100,'S',50);
    [data,sArgs] = ita_parse_arguments(sArgs,varargin);
end

if nargin == 0 || nargin == 1
    % the GUI
    pList = [];
    
    if nargin == 0
        ele = numel(pList)+1;
        pList{ele}.description = 'Name of Input Object';
        pList{ele}.helptext    = 'This is the itaAudio Object to be converted';
        pList{ele}.datatype    = 'itaAudio';
        pList{ele}.default     = '';
        
        ele = numel(pList)+1;
        pList{ele}.datatype    = 'line';
    end
    
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'text';
    pList{ele}.description = 'Choose the type of conversion';
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Input quantity';
    pList{ele}.helptext    = '';
    pList{ele}.datatype    = 'char_popup';
    pList{ele}.default     = 'RT';
    pList{ele}.list        = 'RT|alpha|R|Z';
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Output quantity';
    pList{ele}.helptext    = '';
    pList{ele}.datatype    = 'char_popup';
    pList{ele}.default     = 'alpha';
    pList{ele}.list        = 'alpha|RT|R|Z';
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Room Volume [m^3]';
    pList{ele}.helptext    = '';
    pList{ele}.datatype    = 'double';
    pList{ele}.default     = 100;
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Room Wall Surface [m^2]';
    pList{ele}.helptext    = '';
    pList{ele}.datatype    = 'double';
    pList{ele}.default     = 50;
    
    if nargout == 0
        ele = numel(pList)+1;
        pList{ele}.datatype    = 'line';
        
        ele = numel(pList)+1;
        pList{ele}.description = 'Name of Output Object';
        pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
        pList{ele}.datatype    = 'itaAudioResult';
        pList{ele}.default     = ['result_' mfilename];
    end
    
    pList = ita_parametric_GUI(pList,[mfilename ' - Convert room acoustic quantities']);
    
    if ~isempty(pList)
        offset = 0;
        if nargin == 0
           data = pList{1};
           offset = 1;
        end
        % fill sArgs
        sArgs.inQty  = pList{1+offset};
        sArgs.outQty = pList{2+offset};
        sArgs.V      = pList{3+offset};
        sArgs.S      = pList{4+offset};
    else
        disp([thisFuncStr 'operation cancelled by user']);
        return;
    end
end
result = convertFromA2B(data,sArgs.inQty,sArgs.outQty,sArgs.V,sArgs.S);

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
if nargout == 0 && ~isempty(pList) %User has not specified a variable
    ita_setinbase(pList{end}, result);
else
    % Write Data
    varargout(1) = {result}; 
end

%end function
end

%% help functions
function as_out = convertFromA2B(as_in,in,out,V,S)
% possible: RT|alpha|R|Z
% some constants
constants = ita_constants('all','f',as_in.freqVector);
z_0 = constants.z_0;

if strcmpi(in,out) % no conversion
    as_out = as_in;
else
    if isa(as_in,'itaAudio')
        as_in = itaResult(as_in);
    end
    oneVal = itaResult(ones(size(as_in.freq)),as_in.freqVector,'freq');
    switch out
        case 'RT'
            if strcmpi(in,'R')
                alpha = oneVal - abs(as_in)^2;
            elseif strcmpi(in,'Z')
                R = ((as_in/z_0)-oneVal)/((as_in/z_0)+oneVal);
                alpha = oneVal - abs(R)^2;
            else
                alpha = as_in;
            end
            as_out              = ita_sabine('c',constants.c,'v',V,'m',constants.m,'s',S,'alpha',alpha);
            as_out.comment      = 'Reverberation Time';
            as_out.channelNames = repmat({'(converted) Reverberation Time'},1,as_in.nChannels);
            as_out.channelUnits = repmat({'s'},1,as_in.nChannels);
        case 'alpha'
            if strcmpi(in,'RT')
                % first as_out = ln(1-alpha)
                as_out = (24*log(10)*V/S/constants.c)*(as_in)^-1;
                % now as_out = alpha
                as_out.data = 1 - exp(-as_out.data);
            else
                if strcmpi(in,'Z')
                    R = ((as_in/z_0)-oneVal)/((as_in/z_0)+oneVal);
                else % R
                    R = as_in;
                end
                as_out = oneVal - abs(R)^2;
            end
            as_out.comment      = 'Absorption Coefficient';
            as_out.channelNames = repmat({'(converted) Absorption Coefficient'},1,as_in.nChannels);
            as_out.channelUnits = repmat({'1'},1,as_in.nChannels);
        case 'R'
            if strcmpi(in,'Z')
                as_out = ((as_in/z_0)-oneVal)/((as_in/z_0)+oneVal);
            else
                if strcmpi(in,'alpha')
                    alpha = as_in;
                else % RT
                    % as before, ln(1-alpha)
                    alpha = (24*log(10)*V/S/constants.c)*(as_in)^-1;
                    % now alpha
                    alpha.data = 1 - exp(-alpha.data);
                end
                as_out = sqrt(oneVal - alpha);
            end
            as_out.comment      = 'Reflection Factor';
            as_out.channelNames = repmat({'(converted) Reflection Factor'},1,as_in.nChannels);
            as_out.channelUnits = repmat({'1'},1,as_in.nChannels);
        case 'Z'
            if strcmpi(in,'R')
               R = as_in;
            elseif strcmpi(in,'RT')
                % ln(1-alpha)
                alpha = (24*log(10)*V/S/constants.c)*(as_in)^-1;
                % alpha
                alpha.data = 1 - exp(-alpha.data);
                R = sqrt(oneVal - alpha);
            else % alpha
                R = sqrt(oneVal - as_in);
            end
            as_out              = z_0*(oneVal + R)/(oneVal - R); 
            as_out.comment      = 'Impedance';
            as_out.channelNames = repmat({'(converted) Impedance'},1,as_in.nChannels);
        otherwise
           error([thisFuncStr 'I cannot handle that quantity yet!']); 
    end
end

end