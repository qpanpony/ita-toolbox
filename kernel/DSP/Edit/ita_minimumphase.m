function varargout = ita_minimumphase(varargin)
%ITA_MINIMUMPHASE - Calculates the minimum phase representation.
%
%  This function calculates the minimum phase respresentation of a given
%  filter spectrum. Internally, it takes the natural logarithm of the
%  magnitude of the spectrum and brings it to time domain. There the signal
%  is processed to aim the hilbert transformation in frequency domain by
%  its counterpart in time domain. The result is brought ot frequency
%  domain and applied as the new phase to the magnitude given before.
%
%  It calls ita_uncle_hilbert which does this operations. Therefore this
%  function is just a link!
%
%  Syntax: itaAudio = ita_minimumphase(itaAudio,options)
%  Syntax: itaAudio = ita_minimumphase(itaAudio,'cutoff',options) -- (default) 
%                       - extend, minimumphase and then cut off with extract again.
% Options (default):
%  'cutoff' ('true'):       extend, minimumphase and then cut off with extract again if true
%  'symmetric' ('false'):   extend and extract symmetricaly if true
%  'window' (0):            apply time window
%
%  See also ita_uncle_hilbert, ita_envelope, ita_zerophase, hilbert.
%
%  Reference page in Help browser <a href="matlab:doc ita_minimumphase">doc ita_minimumphase</a>
%
%  Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
%  Created:  01-Oct-2008 

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%% Initialization and Input Parsing
sArgs           = struct('pos1_a','itaAudio','cutoff','true','window',0);
[result, sArgs] = ita_parse_arguments(sArgs,varargin);

%% Call external function
result = ita_uncle_hilbert(result,'window',sArgs.window,'cutoff',sArgs.cutoff);

%% Add history line
result = ita_metainfo_rm_historyline (result); %delete ita_uncle_hilbert line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
varargout(1) = {result};
%end function
end