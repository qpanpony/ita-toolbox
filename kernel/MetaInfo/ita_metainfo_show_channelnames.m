function ita_header_show_channelnames(varargin)
%ITA_HEADER_SHOW_CHANNELNAMES - Print Channel Names
%  This function shows all channels in a struct with physical units.
%
%  Syntax: ita_header_show_channelnames(data_struct)
%  Syntax: ita_header_show_channelnames(header)
%
%   See also ita_fft, ita_ifft, ita_ita_read, ita_ita_write, ita_make_ita_header, ita_ita_write, ita_BK_pulse_read, ita_split, ita_merge, ita_audioplay, ita_convolve, ita_process_impulseresponse, ita_plot_dat, ita_plot_dat_dB, ita_plot_spk, ita_divide_spk, ita_multiply_spk, ita_JFilter, fridge_auralization_load, fridge_auralization_run, ita_spk2imp, ita_acc2vel, ita_spk2level, ita_time_shift, ita_generate, ita_fourpole_421, ita_fourpole_124, ita_zerophase, ita_zconv, ita_kernelimpedance, ita_make_frequencyvector, test, ita_, test, fullscreen_figure, ita_comment2names, ita_vel2acc.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_header_show_channelnames">doc ita_header_show_channelnames</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  01-Sep-2008


%% Initialization
% Number of Input Arguments
narginchk(1,2);
% Find Audio Data
if isa(varargin{1},'itaSuper')
    audioObj = varargin{1};
else
    error('ITA_HEADER_SHOW_CHANNELNAMES:Oh Lord. Only structs allowed.')
end

%% Print
if nargin == 2
    channelVector = varargin{2};
else
    channelVector = 1:audioObj.nChannels;
end
global lastDiplayedVariableName;
if numel(channelVector) <= 16
    for idx = channelVector
        numberString = num2str(idx);
        if length(numberString) == 1
            numberString = [' ' numberString]; %#ok<AGROW>
        end
        if isa(audioObj,'itaAudio') %add play line
            chStr = [' <a href = "matlab: play(ch(' lastDiplayedVariableName ',' num2str(idx) '))' '">play</a> '];
        else
            chStr = '';
        end
        chName = audioObj.channelNames{idx};
        if length(chName) > 30
            chName = [chName(1:27) '...'];
        end
        fprintf(['      Channel ' numberString ': ' chName ' [' audioObj.channelUnits{idx} ']' chStr '\n']);
    end
else
    disp('Lots of Channels');
end

%end function
end