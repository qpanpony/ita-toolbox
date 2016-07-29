function varargout = ita_imag(varargin)
%ITA_IMAG - Real part of signal
%  This function calculates the imag part of a signal's spectrum.
%
%  Syntax: itaAudio = ita_imag(itaAudio)
%
%   See also ita_real, ita_abs.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_imag">doc ita_imag</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  27-Feb-2009 


%% Initialization and Input Parsing
narginchk(1,1);
sArgs        = struct('pos1_data','itaSuper');
[result,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Imag
result.freqData = imag(result.freqData);

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

result.channelNames = ita_sprintf('imag(%s)', result.channelNames);

%% Find output parameters
varargout(1) = {result}; 

%end function
end