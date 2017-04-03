function varargout = ita_fourpole_multiplication(varargin)
%ITA_FOURPOLE_MULTIPLICATION - multiplies fourpole matrices
%  This function multiplies fourpole matrices
%
%  Syntax:
%   audioObjOut = ita_fourpole_multiplication(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_fourpole_multiplication(audioObjIn)
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_fourpole_multiplication">doc ita_fourpole_multiplication</a>

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  20-Apr-2010 

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','itaAudioFrequency','pos2_data','itaAudioFrequency');
[a,b,sArgs]  = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% 

c(1,1) = a(1,1) * b(1,1) + a(1,2) * b(2,1);
c(1,2) = a(1,1) * b(1,2) + a(1,2) * b(2,2);
c(2,1) = a(2,1) * b(1,1) + a(2,2) * b(2,1);
c(2,2) = a(2,1) * b(1,2) + a(2,2) * b(2,2);

%% Set Output
varargout(1) = {c}; 

%end function
end