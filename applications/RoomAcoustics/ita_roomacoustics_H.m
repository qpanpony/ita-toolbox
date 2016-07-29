function varargout = ita_roomacoustics_H(varargin)
%ITA_ROOMACOUSTICS_H - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   H = ita_roomacoustics_H(rir)
%
%
%  Example:
%   H = ita_roomacoustics_H(rir)
%
%  See also:
%   ita_roomacoustics, ita_roomacoustics_parameters, ita_roomacoustics_lateral , ita_roomacoustics_IACC, ita_roomacoustics_sound_strength, ita_roomacoustics_tonal_color
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_roomacoustics_H">doc ita_roomacoustics_H</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  09-Sep-2011


%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudio');
sArgs = ita_parse_arguments(sArgs,varargin);

%% calculate H

res = ita_roomacoustics(sArgs.data, 'bandsPerOctave', 1, 'freqRange', [1000 1000], 'C50', 'oldOutput');  % calculate C50 in the 1 kHz octave
res.freqData    = -res.freqData;
res.comment     = strrep(res.comment, 'C50', 'H');


%% Set Output
varargout(1) = {res};

%end function
end