function varargout = ita_extrapolate(varargin)
%ITA_EXTRAPOLATE - Extrapolate spectrum
%  This function 
%
%  Syntax:
%   audioObjOut = ita_extrapolate(audioObjIn, freqrange)
%
%   Options (default):
%           'opt1' (defaultopt1) : description

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%  Example:
%   audioObjOut = ita_extrapolate(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_extrapolate">doc ita_extrapolate</a>

% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  25-Feb-2011 

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','itaAudio', 'pos2_freqrange', 'double','degree',20);
[input, freqrange, sArgs] = ita_parse_arguments(sArgs,varargin); 

%% 
x = [1 20]/100;
freqrange_low = freqrange(2)*(x) + freqrange(1)*(1-x);

x = [90 99]/100;
freqrange_high = freqrange(end)*(x) + freqrange(end-1)*(1-x);

delaytime = 0;
if isa(input,'itaAudio')
    [input, delaytime] = ita_time_shift(input,'-1dB');
    disp(delaytime)
end

reslow  = ita_audio2zpk_rationalfit(input,'degree',[1 sArgs.degree(1)],'mode','log', 'freqRange', freqrange_low);
reshigh = ita_audio2zpk_rationalfit(input,'degree',[1 sArgs.degree(end)],'mode','log', 'freqRange', freqrange_high);

res = ita_xfade_spk(reslow,input,freqrange(1));
res = ita_xfade_spk(res,reshigh,freqrange(end));

if isa(input,'itaAudio')
    res = ita_time_shift(res,-delaytime);
end

%% Add history line
res = ita_metainfo_add_historyline(res,mfilename,varargin);

%% Set Output
varargout(1) = {res}; 

%end function
end