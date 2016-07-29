function varargout = ita_sfc_pp2pu(varargin)
%ITA_SFC_PP2PU - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_sfc_pp2pu(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_sfc_pp2pu(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sfc_pp2pu">doc ita_sfc_pp2pu</a>

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  07-Sep-2011 


%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','itaAudio', 'distance', 0.012);
[input,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% +++Body - Your Code here+++ 'input' is an audioObj and is given back 


input = merge((input.ch(1) + input.ch(2))/2, ita_velocity_from_pressure_gradient(input,'normalized','distance',sArgs.distance));


%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {input}; 

%end function
end