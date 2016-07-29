function varargout = ita_roomacoustics_tonal_color(varargin)
%ITA_ROOMACOUSTICS_TONAL_COLOR - calculates bass and treble ratio
%  The tonal color describes the degree to which the room influences the
%  frequency balance between low, middle and high frequencies
%
%   bass ratio   = ( T_125Hz + T_250Hz )  / ( T_500Hz + T_1kHz )
%   treble ratio = ( T_2kHz  + T_4kHz  )  / ( T_500Hz + T_1kHz )
%
%   T_xxHz is the reverberation time (by default T20) in the xxHz octave.
%
%  Syntax:
%   tonalColorPar           = ita_roomacoustics_tonal_color(impulseResponse, options)
%   [bassRatio trebleRatio] = ita_roomacoustics_tonal_color(impulseResponse, 'bass_ratio', 'treble_ratio')
%
%   Options (default):
%           'bass_ratio'            (true)
%           'treble_ratio'          (true)
%           'reverberationTime'     ('T20')
%
%  Example:
%   [bassRatio trebleRatio] = ita_roomacoustics_tonal_color(ir)
%   bassRatio               = ita_roomacoustics_tonal_color(ir, 'treble_ratio', false )
%   trebleRatio             = ita_roomacoustics_tonal_color(ir, 'bass_ratio',   false )
%
%  See also:
%   ita_roomacoustics
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_roomacoustics_tonal_color">doc ita_roomacoustics_tonal_color</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  06-Sep-2011


%% Initialization and Input Parsing
sArgs           = struct('pos1_data','itaAudio', 'bass_ratio', true, 'treble_ratio', true, 'reverberationTime', 'T20');
[input,sArgs]   = ita_parse_arguments(sArgs,varargin);

par2calc = [sArgs.bass_ratio sArgs.treble_ratio];

if (sum(par2calc) ~= nargout) && nargout
    error('wrong number of output arguments ( %i parameter(s) to calculate, but %i output var defined )', sum(par2calc), nargout)
end


if ~any(par2calc)
    ita_verbose_info('Nothing to calculate.', 1)
    return
elseif isequal(par2calc, [true false])
    freqVec =  [125; 250; 500; 1000];
elseif isequal(par2calc, [ false true])
    freqVec =  [ 500; 1000; 2000; 4000];
elseif isequal(par2calc, [ true true])
    freqVec =  [125; 250; 500; 1000; 2000; 4000];
end

%%
freqRange = [min(freqVec) max(freqVec)];

% calculate reverberation times
revTime     = ita_roomacoustics(input, 'freqRange', freqRange, 'bandsPerOctave', 1, sArgs.reverberationTime, 'oldOutput');

% check for correct frequencies
if ~isequal(freqVec, revTime.freqVector)
    error('roomacoustics output with wrong freqVector! => report mgu')
end

freqData    = revTime.freqData;

if isequal(par2calc, [true false])      % bass_ratio
    varargout{1} = ((freqData(1,:) + freqData(2,:))  ./ (freqData(3,:) + freqData(4,:))).';
elseif isequal(par2calc, [ false true])
    varargout{1} = (((freqData(3,:) + freqData(4,:)) ./ (freqData(1,:) + freqData(2,:)))).';
elseif isequal(par2calc, [ true true])
    varargout{1} = ((freqData(1,:) + freqData(2,:))  ./ (freqData(3,:) + freqData(4,:))).';
    varargout{2} = ((freqData(5,:) + freqData(6,:))  ./ (freqData(3,:) + freqData(4,:))).';
end


%end function
end