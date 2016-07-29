function varargout = ita_groupdelay_ita(varargin)
%ITA_GROUPDELAY_ITA - Calculate Group Delay
% Same as ita_groupdelay, but result is an itaAudio
%  This function calculates the group delay of a spectrum
%
%  Syntax: result = ita_groupdelay(audioObj)
%  Syntax: result = ita_groupdelay(spk_vec)
%
%   See also ita_plot_spkgdelay.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_groupdelay">doc ita_groupdelay</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de

phase_vec = ita_groupdelay(varargin{:});
result = varargin{1}';
result.freqData = phase_vec;

for idx = 1:result.nChannels
   result.channelNames{idx} = ['Groupdelay ' result.channelNames{idx}]; 
end

result.channelUnits(:) = {'s'}; % unit for groupdelay

%% Find output parameters
if nargout == 1 %User has not specified a variable
    varargout{1} = result;
% mmt: what is this? asData is never defined
% elseif nargout == 2
%     % Write Data
%     varargout{1} = phase_vec.'; 
%     varargout{2} = asData;
end

%end function
end