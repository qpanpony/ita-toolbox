function asResult = ita_append(varargin)
%ITA_APPEND - Append two signals, result displayed in time domain.
%
%  This function appends signal b to the end of time signal a in time domain.
%  The signals can also be in frequency domain - the function does automatically
%  the transformation in time domain before appending the two signals.
%
%  Syntax: asData = ita_append(asA, asB)
%
%  See also ita_merge, ita_subtract, ita_add, ita_extract_dat.
%
%  Reference page in Help browser 
%        <a href="matlab:doc ita_append">doc ita_append</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  18-Jul-2008 




%% Initialization
narginchk(2,2);
if isempty(varargin{1}) && isa(varargin{2},'itaSuper')
    asResult = varargin{2};
    return
elseif isa(varargin{1},'itaSuper') && isempty(varargin{2})
    asResult = varargin{1};
    return
else
    sArgs   = struct('pos1_num','itaAudioTime','pos2_den','itaAudioTime');
    [a, b, sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>
end

%% Check compatibility
if a.nChannels ~= b.nChannels
    error('ITA_APPEND:Oh Lord. Number of channels do not match.')
end
if a.samplingRate ~= b.samplingRate
    error('ITA_APPEND:Oh Lord. Sampling rates do not match.')
end

%% Append Signals
asResult = a;
asResult.data   = [a.data; b.data];

%% Add history line
asResult = ita_metainfo_add_historyline(asResult,'ita_append',{a,b},'withSubs');

%EOF
