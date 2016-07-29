function varargout = ita_randomize_phase(varargin)
%ITA_RANDOMIZE_PHASE - Randomize the Phase
%  This function deletes the phase and adds random phase information. 
%
%  Syntax:
%   audioObjOut = ita_randomize_phase(audioObjIn, options)
%
%
%  See also:
%   ita_scramble
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_randomize_phase">doc ita_randomize_phase</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  12-Nov-2010 


%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudio');
[input,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% random
input.freq = abs(input.freq) .* exp(1i * 2 * pi * rand(size(input.freq)));

%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {input}; 

%end function
end