function varargout = ita_guisupport_getworkspacelist(varargin)
%ITA_GUISUPPORT_GETWORKSPACELIST - Return list of workspave variables (for use in popup_menus)
%
%  Syntax:
%   List = ita_guisupport_getworkspacelist(Options)
%   [List, varStruct ,CellList, idList] = ita_guisupport_getworkspacelist
%
%   List is a List seperated by '|', for use in popup_menus etc
%   Varstruct is the result of 'whos' in the base workspace
%   CellList is a Cell-Array of strings containing the variable name as well as a description (comment etc.)
%
%       Options (default):
%           'class' (itaAudio) - Class of variables you search for
%
%   See also: ita_compile_developer, ita_wavread_continuous.m, ita_generate_documentation, ita_measurement_sensortypes, ita_measurement_sensortypes, ita_portaudio_deviceID2struct, ita_portaudio_string2deviceID, ita_demosound, play, ita_casa, ccx_plot, ita_hrtf_conv, ita_hrtf_get, ita_binaural_diffuse_rir, ita_hrtf_loadinmemory, ita_coherence_time, ita_italian_setup, ita_sort_channels, ita_split_frequencies, ita_freqfromchannelname, ita_inverse_sweep, ita_parametric_GUI, ita_measurement_getlatency, ita_reduce_spk, ita_kundt_gui, ita_measurement_impedance_with_robo, ita_toolbox_path.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_guisupport_getworkspacelist">doc ita_guisupport_getworkspacelist</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  19-Jun-2009

%% Initialization and Input Parsing
narginchk(0,2);
sArgs        = struct('class','itaSuper');
[sArgs] = ita_parse_arguments(sArgs,varargin);

%% Get Variable List
list_of_var = evalin('base','whos'); % list of workspace variables
% jri: why are we cluttering up the workspace with stuff?
% only takes time
%if numel(list_of_var) == 0 % this is a clear workspace, get some data
%    ita_load_default_variables;
%    list_of_var = evalin('base','whos'); % list of workspace variables
    
%end

list        = '';
celllist    = {};
returnlist  = [];
idlist      = {};
for idx  = 1:numel(list_of_var)
    %if strcmpi(list_of_var(idx).class,sArgs.class) %Display only itaAudios, we cant play the rest
    if evalin('base',['isa(' list_of_var(idx).name ',''' sArgs.class ''');']);
        if evalin('base',['isa(' list_of_var(idx).name ',''itaAudio'');']);
            comment     = evalin('base',[list_of_var(idx).name '.comment']);
            nSamples    = num2str(evalin('base',[list_of_var(idx).name '.nSamples']));
            sr          = num2str(evalin('base',[list_of_var(idx).name '.samplingRate']));
            if length(comment) > 20
                comment = [comment(1:20) '...'];
            end
            comment = [comment '[' nSamples ';' sr 'Hz]']; %#ok<AGROW>
        else
            comment = int2str(evalin('base',[ 'size(' list_of_var(idx).name ');']));
        end
        idlist{end+1} = evalin('base',[list_of_var(idx).name '.id']);
        list = [list list_of_var(idx).name ' (' comment ')|']; %#ok<AGROW>
        celllist{end+1,1} = list_of_var(idx).name; %#ok<AGROW>
        celllist{end,2} = [list_of_var(idx).name ' (' comment ')|']; 
        returnlist{end+1} = list_of_var(idx); %#ok<AGROW>
    end
end
result = list(1:end-1);

%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
    disp(result);
else
    % Write Data
    varargout(1) = {result};
    
    if nargout > 1
        varargout{2} = returnlist;
        if nargout > 2
            varargout{3} = celllist;
            if nargout > 3
                varargout{4} = idlist;
            end
        end
    end
    
end

%end function
end