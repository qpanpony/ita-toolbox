function ita_show_struct(varargin)
%ITA_SHOW_STRUCT - shows the contents of a struct
%  This function shows the contents of a struct, considering the names and
%  the information of each element.
%
%  Syntax:
%   audioObjOut = ita_show_struct(inputStruct)
%
%  Example:
%   testStruct = (itaValue1, itaValue2)
%   ita_show_struct(testStruct);
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_show_struct">doc ita_show_struct</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Christian Haar -- Email: christian.haar@akustik.rwth-aachen.de
% Created:  12-May-2011 


%% Get Function String
% thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_inputStruct','struct');
[sArgs] = ita_parse_arguments(sArgs,varargin); 

%%
inputStruct = sArgs.inputStruct;
fieldNames = fieldnames(inputStruct);
fieldNamesChar = char(fieldNames);
for idx = 1 : numel(fieldNames)
    disp([fieldNamesChar(idx,:) ' : ' num2str(inputStruct.(fieldNames{idx}))]);
end

%% Set Output
% varargout(1) = {inputStruct}; 
%end function
end