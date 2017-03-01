function varargout = ita_roomacoustics_equipment(varargin)
%ITA_ROOMACOUSTICS_EQUIPMENT - equipment
%  This function TODO HUHU Description Documentation
%
%  Syntax:
%   audioObjOut = ita_roomacoustics_equipment(audioObjIn, options)
%
%
%  Example:
%   audioObjOut = ita_roomacoustics_equipment(audioObjIn)
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_roomacoustics_equipment">doc ita_roomacoustics_equipment</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Jonathan Oberreuter -- Email: jonathan.oberreuter@akustik.rwth-aachen.de
% Created:  06-May-2010 

%% Equipment GUI

pList = {};
name = 'Equipment';

vector_length = 13;
standard_vector = ones(1,vector_length);

if nargin == 1
   varargout{1} = standard_vector; %just return standard for preferences
   return;
end
   

old_vector = ita_preferences('roomacousticEquipment');
if length(old_vector) ~= vector_length;
    old_vector = standard_vector;
end
%% ------------
ele = 1;
pList{ele}.description = 'Equipment';
pList{ele}.helptext    = '';
pList{ele}.text        = ['Choose the equipment used in the measurement'];
pList{ele}.datatype    = 'simple_text';
pList{ele}.color       = [0.2 0.5 0.2];

%% ************************************************************************
ls = {'Loudspeakers: ITA dodecahedron',1;'ITA dode (new)', 0;'ITA dode (old)',0};

ele = length(pList) + 1;
pList{ele}.datatype    = 'line'; 

ele = length(pList) + 1;
pList{ele}.datatype    = 'text';
pList{ele}.description    = 'Loudspeakers: ITA dodecahedron';

for idx = 1:size(ls,1)
    ele = length(pList) + 1;
    pList{ele}.description = ls{idx,1}; 
    pList{ele}.helptext    = ''; 
    pList{ele}.datatype    = 'bool'; 
    pList{ele}.default     = old_vector(idx); 
end

%% ************************************************************************
mics = {'BK 1/2 inch',1;'Neumann USM69 (Omnidirectional and Bi-directional)', 0;'ITA Dummyhead',0;'KE4 - Sennheiser',1};

ele = length(pList) + 1;
pList{ele}.datatype    = 'line'; 

ele = length(pList) + 1;
pList{ele}.datatype    = 'text';
pList{ele}.description    = 'Microphone Types';

for idx = 1:size(mics,1)
    ele = length(pList) + 1;
    pList{ele}.description = mics{idx,1}; 
    pList{ele}.helptext    = ''; 
    pList{ele}.datatype    = 'bool'; 
    pList{ele}.default     = old_vector(idx+size(ls,1)); 
end


%% ************************************************************************
interfaces = {'ModulITA',1;'ITA Robo', 0;'BK Nexus',0;'BK2610',1;'RME Multiface',1;'RME Octamic Rack',0};

ele = length(pList) + 1;
pList{ele}.datatype    = 'line'; 

ele = length(pList) + 1;
pList{ele}.datatype    = 'text';
pList{ele}.description    = 'Microphone Types';

for idx = 1:size(interfaces,1)
    ele = length(pList) + 1;
    pList{ele}.description = interfaces{idx,1}; 
    pList{ele}.helptext    = ''; 
    pList{ele}.datatype    = 'bool'; 
    pList{ele}.default     = old_vector(idx+size(ls,1)+size(mics,1)); 
end

%% Call GUI
vareq = ita_parametric_GUI(pList,name);
vector = double(cell2mat(vareq));

ita_preferences('roomacousticEquipment',vector);

%% RSC GUI fix??

%% Save Options
% % % setpref('ITA_ROOMACOUSTICS','equipment',roomPres); %
%var=getpref('mytoolbox','version')

%pOutList{1} %nur von 1 bis 13

%% Add history line
%input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
if nargout == 1
varargout(1) = {vector}; 
end

%end function
end