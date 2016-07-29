function varargout = ita_angle2str(varargin)
%ITA_ANGLE2STR - Get 3 or more digit string
%  This function produces a 3 digit string from a number if no other number
%  is specified.
%
%  Syntax: outString = ita_angle2str(intNumber)
%  Syntax: outString = ita_angle2str(intNumber, nDigits)
%
%   See also ita_fft, ita_ifft, ita_ita_read, ita_ita_write, ita_ita_write, ita_BK_pulse_read, ita_split, ita_merge, ita_audioplay, ita_convolve, ita_process_impulseresponse, ita_plot_dat, ita_plot_dat_dB, ita_plot_spk, ita_divide_spk, ita_multiply_spk, ita_JFilter, fridge_auralization_load, fridge_auralization_run, ita_spk2imp, ita_acc2vel, ita_spk2level, ita_time_shift, ita_generate, ita_fourpole_421, ita_fourpole_124, ita_zerophase, ita_zconv, ita_kernelimpedance, ita_make_frequencyvector, test, ita_, test, fullscreen_figure, ita_comment2names, ita_vel2acc, ita_metainfo_show_channelnames, ita_set_working_dir.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_angle2str">doc ita_angle2str</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created: 01-Sep-2008 

%% Initialization
% Number of Input Arguments
narginchk(1,2);

% number of digits
if nargin == 1
    nDigits = 3;
else
    nDigits = varargin{2};
end

%% +++Body - Your Code here+++
numberString = num2str(varargin{1});

numberString = [repmat('0',1,nDigits-length(numberString)) numberString];


%% Find output parameters
varargout(1) = {numberString};

%end function
end