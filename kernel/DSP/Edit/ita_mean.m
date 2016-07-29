function varargout = ita_mean(varargin)
%ITA_MEAN - Get the mean over all channels
%  This function calculates the mean over all channels. If audioObj is a
%  cell array, the mean is calculated for each channel over the dimension
%  of the cell array (used to average measurement).
%
%  Syntax: audioObj = ita_mean(audioObj, Options)
%
%       Options (default):
%           'same_channelnames_only' (false):    calculate mean only over channels with same name
%           'abs_gdelay'             (false):   calculate mean of abs and gdelay independently           
%   See also ita_median, ita_rms, ita_sum, ita_add, ita_get_value.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_mean">doc ita_mean</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  02-Sep-2008



%% Initialization and Input Parsing
narginchk(1,5);
sArgs           = struct('pos1_a','itaSuper','same_channelnames_only',false,'abs_gdelay',false);
[result, sArgs] = ita_parse_arguments(sArgs,varargin);

  
    if sArgs.same_channelnames_only
        rest = result;
        result = [];
        while rest.nChannels > 0
            chname1 = rest.channelNames{1};
            [temp, rest] = ita_split(rest,chname1);
            
            temp = aux_mean(temp,sArgs);
            temp = ita_metainfo_rm_historyline(temp);
            if isempty(result)
                result = temp;
            else
                result = merge(result,temp);
                result = ita_metainfo_rm_historyline(result);
            end
        end
    else
        result = aux_mean(result,sArgs);
    end
    
    %% Find output parameters
varargout(1) = {result};
end

function result = aux_mean(result,sArgs)

if sArgs.abs_gdelay
    % do mean in the modulus and phase domain
    temp_abs = mean(abs(result.freqAmp),2);
    gdelay = ita_groupdelay(result);
    bin_dist = result.samplingRate/result.nSamples;
    
    temp_gdelay = mean(gdelay,2);
    % forcd DC component to be either 0 or +-pi!
    temp_gdelay(1) = fix(median(gdelay(1,:))*bin_dist*2)/2/bin_dist;
    
    
    
    result.freqAmp = temp_abs .* exp(1i*-cumsum(temp_gdelay,1)*(bin_dist * 2*pi));
else
    result = mean(result);
end

end