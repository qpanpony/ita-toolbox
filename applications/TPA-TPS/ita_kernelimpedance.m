function varargout = ita_kernelimpedance(varargin)
%ITA_KERNELIMPEDANCE - Impedance situation calculation
%  This function is similar to ita_kernel4poles but without the fourpole in
%  the middle.
%
%  Syntax: spk = ita_kernelimpedance(Z_S, Z_R, process_str)
%
%  Z_S is the Source impedance spectrum and Z_R the spectrum of the
%  receiving structure.
%
%  process_str can be ff - force force or vv/aa velocity velocity
%                                   ____
%  This is a potential divider. ----|  |------|
%                                   ÿÿÿ      |
%                                   Z_S       -
%                                            | |  Z_R
%                                            | |
%                                             -
%                                             |
%
%   See also ita_fft, ita_ifft, ita_read, ita_write, ita_make_ita_header, ita_write, ita_BK_pulse_read, ita_split, ita_merge, ita_audioplay, ita_convolve, ita_process_impulseresponse, ita_plot_dat, ita_plot_dat_dB, ita_plot_spk, ita_divide_spk, ita_multiply_spk, ita_JFilter, fridge_auralization_load, fridge_auralization_run, ita_spk2imp, ita_acc2vel, ita_spk2level, ita_time_shift, ita_generate, ita_fourpole_421, ita_fourpole_124, ita_zerophase, ita_zconv.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_kernelimpedance">doc ita_kernelimpedance</a>

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  13-Jul-2008 
% Modified: 29-Sep-2008 - pdi - verboseMode, new ITA Toolbox support
% Modified: 01-Sep-2008 - pdi - 2 input parameters allowed
% Modified: 17-Nov-2008 - pdi - History checked!

%% Get ITA Toolbox preferences
verboseMode  = ita_preferences('verboseMode');

%% Initialization
%Inarg checking
narginchk(2,3)
Z_S     = varargin{1};
Z_R     = varargin{2};
if nargin == 3
    des_str = varargin{3};
else
    des_str = 'ff';
end

if Z_S.nSamples ~= Z_R.nSamples
    error('ITA_KERNELIMPEDANCE:Oh Lord. Sizes do not match.')
end
if (Z_S.nChannels ~= 1) || (Z_R.nChannels ~= 1) 
    error('ITA_KERNELIMPEDANCE:Oh Lord. Here is more than one channel.')
end
one_spk = Z_S;
one_spk.spk = one_spk.spk .* 0 + 1;

%% Body
switch lower(des_str)
    case {'ff','voltage'} 
        if verboseMode, disp('    +++ Force to Force Transmission +++ '), end;
        % Z_R ./ (Z_S + Z_R)
%         result = ita_divide_spk(Z_R,ita_add(Z_S,Z_R));
        result = ita_invert_spk(ita_add(ita_divide_spk(Z_S, Z_R ) ,  one_spk )); %less numerical problems
    case {'vv','aa','current'} 
        if verboseMode, disp('    +++ Acc to Acc Transmission +++'), end;
        %v_r / v_0 = Z_S ./ (Z_S + Z_R)
        result = ita_divide_spk(Z_S,ita_add(Z_S,Z_R));
    case {'vf','af'}  
        
        result = ita_impedance_parallel(Z_S,Z_R);
    otherwise
        error('ITA_KERNELIMPEDANCE:Oh Lord. I cannot calculate this.')
end

%% Check for NaN
result.spk(~isfinite(result.spk)) = 0;

%% Check for equivalent real time domain data
result.spk(:,1)   = real(result.spk(:,1));
result.spk(:,end) = real(result.spk(:,end));

%% Update Header Settings
result.signalType = 'energy';

%% Add history line
result.history = [];
result = ita_metainfo_add_historyline(result,'ita_kernelimpedance',varargin,'withSubs');

%% Find output parameters
varargout(1) = {result};