function varargout = ita_filter_fractional_octavebands(varargin)
%ITA_FRACTIONAL_OCTAVEBANDS - Calculate Fractional Octave bands
%  This function splits a signal into its fractional octave bands.
%
%  Syntax:
%   audioObjOut = ita_fractional_octavebands(audioObjIn, options)
%
%   Options (default):
%           'bandsperoctave' (ita_preferences('bandsperoctave')) : Bands per Octave
%           'freqRange' (ita_preferences('freqRange')) : Frequency range for bands
%           'zerophase' (true) : use zerophase octave band filters. non-causal!
%           'order'(10): order of filter cut off
%
%  See also:
%   ita_mpb_filter
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_fractional_octavebands">doc ita_fractional_octavebands</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  05-May-2011

sArgs = struct('pos1_data','itaAudio',  'bandsperoctave', (ita_preferences('bandsperoctave')), 'freqRange', (ita_preferences('freqRange')),'zerophase', true ,'order',10);


if nargin==0
    sArgs.varname = 'outputVariableName';
    sArgs = ita_parse_arguments_gui(sArgs,'title','Fractional Octave Bands');
else
    [sArgs] = ita_parse_arguments(sArgs,varargin);
end

input = sArgs.data;


%% Call mpb filter
input = ita_mpb_filter(input,'oct',sArgs.bandsperoctave,'octavefreqrange',sArgs.freqRange,'zerophase',sArgs.zerophase,'order',sArgs.order);
% units are not copied in mpf_filter routine, do it here (?)
input.channelUnits(:) = input.channelUnits(1);

if nargin == 0
   % setin base
   ita_setinbase(sArgs.varname,input);
end

%% Set Output
varargout(1) = {input};

%end function
end