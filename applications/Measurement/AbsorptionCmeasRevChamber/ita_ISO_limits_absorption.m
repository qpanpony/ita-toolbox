function varargout = ita_ISO_limits_absorption(varargin)
%ITA_ISO_LIMITS_ABSORPTION - returns ISO354 limits 
%  This function accepts the room volume and an optional frequency vector
%  and returns an object with the limits given in ISO354.
%
%  Syntax:
%   resultObjOut = ita_ISO_limits_absorption(roomVolume, options)
%
%   Options (default):
%           'freqVector' ([]) : frequency vector
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_ISO_limits_absorption">doc ita_ISO_limits_absorption</a>

% <ITA-Toolbox>
% This file is part of the application RevChamberAbsMeas for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  03-Oct-2012 


%% Initialization and Input Parsing
sArgs        = struct('pos1_Volume','numeric', 'freqVector', []);
[V,sArgs] = ita_parse_arguments(sArgs,varargin);

freqVectorISO = ita_ANSI_center_frequencies([100 5000],3,44100);
if isempty(sArgs.freqVector)
    freqVector = freqVectorISO(:);
else
    freqVector = sArgs.freqVector(:);
end

idx_fISO_1 = find(freqVector >= 100,1,'first');
idx_fISO_2 = find(freqVector <= 5000,1,'last');

dummy = itaResult(ones(numel(freqVector),1),freqVector,'freq');
dummy.allowDBPlot = false;
dummy.channelUnits = {'m^2'};

%% Maximum absorption area for the empty room
A_empty = dummy;
const = (V/200)^(2/3);
A_empty_ISO_values = itaResult([repmat(6.5,1,10) 7 7.5 8 9.5 10.5 12 13 14].',freqVectorISO,'freq');

if any(freqVector < 100) || any(freqVector > 5000)
    nBelow = numel(find(freqVector < 100));
    nAbove = numel(find(freqVector > 5000));
    A_empty.freq = [repmat(6.5,nBelow,1); A_empty_ISO_values.freq2value(freqVector(idx_fISO_1:idx_fISO_2)); repmat(14,nAbove,1)];
else
    A_empty = itaResult(A_empty_ISO_values,freqVector);
end

A_empty.freq = const.*A_empty.freq;
A_empty.comment = 'Absorption Area';
A_empty.channelNames = {'Maximum Absorption Area of the Empty Room (ISO 354)'};
A_empty.channelUnits(:) = {'m^2'};
A_empty.allowDBPlot = 0;

%% Add history line
A_empty = ita_metainfo_add_historyline(A_empty,mfilename,varargin);

%% Set Output
varargout(1) = {A_empty}; 

%end function
end