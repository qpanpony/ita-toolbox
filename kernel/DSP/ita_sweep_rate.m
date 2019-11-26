function varargout = ita_sweep_rate(varargin)
%ITA_SWEEP_RATE - Calculates the sweep rate of an exponential sweep.
%
% Call: sweep_rate = ita_sweep_rate(inExpSweep,[lower_frequency upper_frequency])
%
% See also:
%   ita_groupdelay, ita_coefficient,
%
% Note: A too short sweep or a too small frequency range may be problematic.

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Alexandre Bleus -- alexandre.bleus@akustik.rwth-aachen.de
% Created: 12-March-2010

%% Initialisation
sArgs        = struct('pos1_inSweep','itaAudio', 'freqRange',[1000 4000],'type','exp','f0',[]);
[inSweep,sArgs] = ita_parse_arguments(sArgs,varargin);

%% Calculate the sweep rate for some points
freqjump    = round((sArgs.freqRange(2)-sArgs.freqRange(1))/10);
freq_gdel   = sArgs.freqRange(1) + [(1:8).' (2:9).'].*freqjump;
gdel        = ita_groupdelay_ita(inSweep);

switch sArgs.type
    case 'exp'
        sweep_rate = log2(freq_gdel(:,2)./freq_gdel(:,1)) ./ (gdel.freq2value(freq_gdel(:,2)) - gdel.freq2value(freq_gdel(:,1)));
    case 'lin'
        sweep_rate = (freq_gdel(:,2) - freq_gdel(:,1)) ./ (gdel.freq2value(freq_gdel(:,2)) - gdel.freq2value(freq_gdel(:,1)));
        if isempty(sArgs.f0)
            error('Need f0 for linear sweep rate');
        else
            sweep_rate = sweep_rate./sArgs.f0;
        end
    otherwise
        error('Type can only be exp or lin');
end
sweep_rate(sweep_rate < 0) = nan;

%% Verify that the sweep rates are similar
meanRate = round(10*mean(sweep_rate,'omitnan'));
if any(abs(round(sweep_rate*10) - meanRate) > 5)
    ita_verbose_info('Oh Lord! Are you sure that you are using an Exponential Sweep?',0);
end

%% Set Output
inSweep.userData.sweep_rate = mean(sweep_rate,'omitnan');
varargout(1) = {inSweep.userData.sweep_rate};

end