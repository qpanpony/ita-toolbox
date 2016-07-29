function result = ita_invert_spk(varargin)
%ITA_INVERT_SPK - Invert your spk-data (1 ./ spk)
%  This function computes the ratio 1/input signal in frequency domain.
%
%  Syntax: itaAudio = ita_invert_spk(itaAudio,options)
% 
%  Options (default): 'limiter' (0):            could be specified to limit the resulting values. This is normally used if the input spk gets very 
%                                               small at some frequencies. Then the output would go to infinity and the limiter takes care.
%                     'regularization' (0):     calling ita_invert_spk_regularization(itaAudio,[low_freq,high_freq])
%
%   See also ita_invert_spk_regularization, ita_divide_spk, ita_negate_spk.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_invert_spk">doc ita_invert_spk</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  24-Jun-2008


%% Initialization
sArgs       = struct('pos1_a','itaSuper','regularization',0,'limiter',0);
[result,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Invert
if sArgs.regularization
    % call kirkeby regularization
    result = ita_invert_spk_regularization(result,sArgs.regularization);
    return
end

% Invert
result.freqData = result.freqData.^-1;

% Check for singularties
result.freqData(~isfinite(result.freqData)) = 0;

%% Limiter
if sArgs.limiter
    limiter_val = 10.^(sArgs.limiter/20);
    result.freqData(abs(result.freqData) > limiter_val) = limiter_val;
end

%% Check physical entities
for idx = 1:result.nChannels
    result.channelUnits{idx} = ita_deal_units('1',result.channelUnits{idx},'/');
    if isempty(result.channelNames{idx})
        result.channelNames{idx} = '';
    else
        result.channelNames{idx} = ['1/' result.channelNames{idx}];
    end
end

%% check FFTnorm
if isa(result,'itaAudio')
    result.signalType = 'energy';
end
end
