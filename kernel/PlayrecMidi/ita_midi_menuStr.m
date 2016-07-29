function [devStrIn, devIDsIn, devStrOut, devIDsOut] = ita_midi_menuStr()

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Pascal Dietrich, March 2011 -- using RtMidi and ita_midi

if ~ita_preferences('disable_midi')
%% Init
devStrIn = ''; %TODO delete all that old stuff
devIDsIn = -1;

%% get midi devices
try
    midiStr = ita_midi();
catch
    midiStr = '';
end

startIdx = strfind(midiStr,'|')+1;
endIdx = [ strfind(midiStr,'|')-1, length(midiStr) ];
endIdx = endIdx(2:end);
devs = {};
OutputDevID = [];
for jdx = 1:numel(startIdx)
    devs{jdx} = midiStr(startIdx(jdx):endIdx(jdx));
    OutputDevID(jdx) = jdx-1;
end

devs{end+1} = 'noDevice';
OutputDevID(end+1) = -1;


%% in devices
currentOutputDevID = ita_preferences('out_midi_DeviceID');

idx = find(ismember(OutputDevID,currentOutputDevID));

if isempty(idx)
    devStrOut = devs{end};
    devIDsOut = OutputDevID(end);
else
    devStrOut = devs{idx};
    devIDsOut = OutputDevID(idx);
end

for idx=1:numel(devs)
    if currentOutputDevID ~= OutputDevID(idx) %only if not already in list
        devStrOut = [devStrOut '|' devs{idx}]; %#ok<AGROW>
        devIDsOut = [devIDsOut OutputDevID(idx)]; %#ok<AGROW>
    end
end

else
    devStrIn = 'MIDI disabled';
    devIDsIn  = 1;
    devStrOut = 'MIDI disabled';
    devIDsOut = 1;
    
end