function varargout = itaTemplate(varargin)
%ITATEMPLATE - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = itaTemplate(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = itaTemplate(audioObjIn)
%
%  See also:
%   $ITAFUNCTIONNAMES$
%
%   Reference page in Help browser 
%        <a href="matlab:doc itaTemplate">doc itaTemplate</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: AuthorStr -- Email: EmailStr
% $itaCREATED$


%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','itaAudio', 'opt1', true);
[input,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% +++Body - Your Code here+++ 'input' is an audioObj and is given back 


% sample use of the ita warning/ informing function
ita_verbose_info('Testwarning',0); 


%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {input}; 

%end function
end