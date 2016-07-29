function varargout = ita_cef(varargin)
%ITA_CEF - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_cef(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_cef(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_cef">doc ita_cef</a>

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  08-Apr-2011


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','itaAudio', 'blocksizes', 4:1:18,'fraction',1,'limits',[50 20000]);
[input,sArgs] = ita_parse_arguments(sArgs,varargin);

bs = sArgs.blocksizes;

%% +++Body - Your Code here+++ 'input' is an audioObj and is given back
if input.nChannels ~= 2
    error([thisFuncStr ' I need exactly two channels']);
end



for idx = 1:numel(bs)  
    ita_verbose_info(num2str(bs(idx)),2);
    %coh(idx) = ita_interpolate_spk(ita_coherence(ita_extract_dat(input,bs(idx)+4),'blocksize',2^bs(idx)), max(bs));   
    %coh(idx) = ita_interpolate_spk(ita_coherence(input,'blocksize',2^bs(idx)), max(bs));   
    coh(idx) = ita_spk2frequencybands(abs(ita_coherence(input,'blocksize',2^bs(idx),'complex',true)), 'bandsperoctave', sArgs.fraction, 'freqRange', sArgs.limits, 'method', 'averaged','squared_input',true); %Bänder berechnen

    coh(idx).channelNames = {['2^(' num2str(bs(idx)) ')']};
end

input = ita_merge(coh);


%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {input};

%end function
end