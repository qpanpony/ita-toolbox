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

%% Get ITA Toolbox preferences
thisFuncStr  = [upper(mfilename) ':'];

%% Initialisation
narginchk(1,2);
if nargin == 1
    varargin{2} = [1000 4000];
elseif nargin~=2
    error([thisFuncStr 'Two input arguments are required.'])
end
if ~isa(varargin{1},'itaAudio')
    error([thisFuncStr 'Oh Lord! An audio object (Exponential Sweep) is required.'])
else
    inSweep = varargin{1};
    freq_vec=varargin{2};
end

%% Calculate the sweep rate for some points
freqjump    = round((freq_vec(2)-freq_vec(1))/10);
freq_gdel   = freq_vec(1) + [(1:8).' (2:9).'].*freqjump;
gdel        = ita_groupdelay_ita(inSweep);

sweep_rate  = log(freq_gdel(:,2)./freq_gdel(:,1)) ./ log(2) ./ (gdel.freq2value(freq_gdel(:,2)) - gdel.freq2value(freq_gdel(:,1)));
sweep_rate(sweep_rate < 0) = sweep_rate(end);

%% Verify that the sweep rates are similar
meanRate = round(10*mean(sweep_rate));
if any(abs(round(sweep_rate*10) - meanRate) > 5)
    ita_verbose_info('Oh Lord! Are you sure that you are using an Exponential Sweep?',0);
end

%% Set Output
inSweep.userData.sweep_rate = mean(sweep_rate);
varargout(1) = {inSweep.userData.sweep_rate};

end