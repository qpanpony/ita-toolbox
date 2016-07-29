function varargout = ita_asa(varargin)
%ITA_ASA - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_asa(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_asa(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_asa">doc ita_asa</a>

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  17-Aug-2012 


%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','itaAudio', 'opt1', true);
[input,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% +++Body - Your Code here+++ 'input' is an audioObj and is given back 

%% Binaural Model for Source Localization
gf = ita_CASA_gammatone_filterbank(input);
[xcorr_res,itd,ic] = ita_CASA_xcorr_timewindow(gf,'azi',1);
ild = ita_CASA_ild_timewindow(gf);
source_positions = ita_CASA_analyse_binaural_cues(itd,ild,ic,xcorr_res,'azi',1);

ita_verbose_info(['Recognized ' int2str(numel(source_positions)) ' sources. At:'],1);
for idx = 1:numel(source_positions)
    ita_verbose_info([num2str(source_positions(idx)) 'deg'],1);
end



% sample use of the ita warning/ informing function
%ita_verbose_info('Testwarning',0); 


%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {input}; 

%end function
end