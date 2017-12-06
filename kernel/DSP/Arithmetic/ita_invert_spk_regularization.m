function varargout = ita_invert_spk_regularization(varargin)
%ITA_INVERT_SPK_REGULARIZATION - Invert spectrum (Kirkeby method)
%  This function inverts a spectrum in Frequency domain, commonly used for
%  sweep excitation signals, after a method proposed by Angelo Farina.
%  Farina's method is only a one-dimensional look on Kirkeby's method.
%  Given a frequency vector consisting of lower and higher cutoff frequency
%  this functions operates in the given frequency range by inverting the
%  signal. The resulting spectrum is therefore a compensation spectrum.
%  Multiplied with the input spectrum, the obtained impulse response is
%  very compact.
%
%  Syntax:
%   itaAudio = ita_invert_spk_regularization(itaAudio, [low_freq high_freq],options)
%  
%   [min_phase, all_pass] = ita... for minimumphase regularization
%
%  Options (default): 'beta' (0) - TODO HUHU
%                     'filter' (false) - use additional filtering
%                     'zerophase' (true) - use additional filtering
%
%  Example:
%   audioObj = ita_invert_spk_regularization(audioObj,[40 10000])
%
%   See also: ita_invert_spk_regularization_old, ita_divide_spk, ita_generate.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_invert_spk_regularization">doc ita_invert_spk_regularization</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  27-May-2009 

%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudioFrequency','pos2_freqvec','vector',...
    'beta',10^(-200/20),... % used as regularization parameter INSIDE frequency range
    'filter',false,... %use extra filter for the output with frequency range specified
    'zerophase',true,... % zerophase is used for the filter
    'epsilon',[]... %specify regularization parameter manually
    );
[data,freq_vec,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Init
data.signalType = 'energy'; % set signal type after transformation to freq domain !

b = data * 0 + sArgs.beta;  % inside  of freqrange
a = data * 0 + 1;           % outside of freqrange

f_low  = freq_vec(1); 
f_high = freq_vec(2);

%% Get epsilon for regularization
if isempty(sArgs.epsilon)
    %% Generate frequency dependent epsilon
    epsilon = ita_xfade_spk(a,b,[f_low/sqrt(2),f_low]);
    if f_high < min(f_high*sqrt(2),epsilon.samplingRate/2)
        epsilon = ita_xfade_spk(epsilon,a,[f_high, min(f_high*sqrt(2),epsilon.samplingRate/2)]);
    end
    epsilon2 = epsilon^2;
    %     epsilon  = epsilon2^2;
    epsilon.channelUnits = epsilon2.channelUnits;
    
    epsilon = ita_amplify(epsilon, max(max(abs(data.freqData))).^2 *50 / 100 );
    %     epsilon = epsilon + 1*eps;% was 10*eps + 10i*eps;
else
    %% use specified regularization constant
    epsilon = sArgs.epsilon;
end

%% Invert with kirkeby regularization
result = ita_conj(data) / (ita_conj(data)*data + epsilon);

%% and use additional filtering ?
if sArgs.zerophase
    if sArgs.filter
        if f_low ~= 0
            result = ita_mpb_filter(result,[f_low*0.98 0],'zerophase',sArgs.zerophase,'order',10); %pdi changed
            %result = ita_mpb_filter(result,[f_low*0.98 0],'zerophase','order',10); %pdi changed
        end
        if f_high * 1.01 < result.samplingRate/2
            result = ita_mpb_filter(result,[0 f_high*1.01],'zerophase',sArgs.zerophase,'order',16);
        else
            ita_verbose_info('LowPass filter just a bit below Nyquist', 1);
            result = ita_mpb_filter(result,[0 0.98 * result.samplingRate/2],'zerophase',sArgs.zerophase,'order',16);
        end
        result.freqData(1,:) = 0; % set DC explicitly to zero !
        
    end
else
    if sArgs.filter
        if f_low ~= 0
            result = ita_mpb_filter(result,[f_low*0.98 0],'order',10); %pdi changed
        end
        if f_high * 1.01 < result.samplingRate/2
            result = ita_mpb_filter(result,[0 f_high*1.01],'order',16);
        else
            ita_verbose_info('LowPass filter just a bit below Nyquist', 1);
            result = ita_mpb_filter(result,[0 0.98 * result.samplingRate/2],'order',16);
        end
        result.freqData(1,:) = 0; % set DC explicitly to zero !
    end
end

%% ChannelName handling
for idx = 1:data.nChannels
   result.channelNames{idx} = ['1 / ' data.channelNames{idx} ];
   result.channelUnits{idx} = ita_deal_units('',data.channelUnits{idx},'/');
end

%% Add history line
% result = ita_metainfo_rm_historyline(result,'all');
result = ita_metainfo_add_historyline(result,mfilename,varargin);

varargout{1} = result;

if nargout == 2
    H = data * result; %ideal impulse response
    H_min = ita_minimumphase(H,'cutoff',true); %get minphase and all-pass
    H_ap = H / H_min;
    varargout{1} = H_min*1/data;
    varargout{2} = H_ap;

%end function
end