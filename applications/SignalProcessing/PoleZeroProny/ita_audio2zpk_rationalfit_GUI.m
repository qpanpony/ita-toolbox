function varargout = ita_audio2zpk_rationalfit_GUI(varargin)
%ITA_AUDIO2ZPK_RATIONALFIT_GUI - GUI for rational fit for itaSuper
%  This function approximates a given itaSuper Object with a rational fit
%
%  Syntax:
%   audioObjOut = ita_audio2zpk_rationalfit_GUI(audioObjIn)
%
%  Example:
%   audioObjOut = ita_audio2zpk_rationalfit_GUI(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_audio2zpk_rationalfit_GUI">doc ita_audio2zpk_rationalfit_GUI</a>

% <ITA-Toolbox>
% This file is part of the application PoleZeroProny for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  15-Nov-2010 


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','itaAudio');
[input,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% GUI 
pList = {};

ele = numel(pList) + 1;
pList{ele}.description = 'Degree'; 
pList{ele}.helptext    = 'Number of independent poles for the positive frequency axis'; 
pList{ele}.datatype    = 'double'; 
pList{ele}.default     = 40;

ele = numel(pList) + 1;
pList{ele}.description = 'Mode'; 
pList{ele}.helptext    = 'Lin or Log scaling of the weights over frequency'; 
pList{ele}.datatype    = 'char_popup'; 
pList{ele}.default     = 'log';
pList{ele}.list        = 'lin|log';

ele = numel(pList) + 1;
pList{ele}.description = 'lower freq'; 
pList{ele}.helptext    = 'Lower frequency range limit'; 
pList{ele}.datatype    = 'int'; 
pList{ele}.default     = 0;

ele = numel(pList) + 1;
pList{ele}.description = 'higher freq'; 
pList{ele}.helptext    = 'Higher frequency range limit'; 
pList{ele}.datatype    = 'int'; 
pList{ele}.default     = 0;

ele = numel(pList) + 1;
pList{ele}.description = 'Tolerance'; 
pList{ele}.helptext    = 'Lin or Log scaling of the weights over frequency'; 
pList{ele}.datatype    = 'int'; 
pList{ele}.default     = -40;


pList = ita_parametric_GUI(pList,'Rational Fit');

%% call
input = ita_audio2zpk_rationalfit(input,'degree',pList{1},'mode',pList{2},'freqRange',[pList{3} pList{4}],'tolerance',pList{5});

%% Set Output
varargout(1) = {input}; 

%end function
end