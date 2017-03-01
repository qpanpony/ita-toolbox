%%%function varargout = ita_ISO3382(varargin)
%ITA_ISO3382 - apply ISO3382
%  This function applies ISO3382
%
%  Syntax:
%   audioObjOut = ita_ISO3382(audioObjIn)
%
%
%  Example:
%   audioObjOut = ita_ISO3382(audioObjIn)
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_ISO3382">doc ita_ISO3382</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Jonathan Oberreuter -- Email: jonathan.oberreuter@akustik.rwth-aachen.de
% Created:  06-Apr-2010 

%% Equipment
equip={'Loudspeaker ITA dodecahedron new'
    'Loudspeakers ITA dodecahedron old'
    'Loudspeakers ITA dodecahedron 12 inch'
    'Microphone: Blx 1/2 inch'
    'Microphone: Neumann USM69 (Omnidirectional and Bi-directional)'
    'Microphone: ITA Dummyhead'
    'Microphone: WE4 - Sennheiser'
    'Software: Modul ITA'
    'Software: ROBO'
    'Hardware: Nexus'
    'Hardware: BK2610'
    'Hardware: Multiface'
    'Hardware: Octavic'
};
%% Parameters to be calculated
param={'Reverberation Time: EDC'
    'Reverberation Time: T10'
    'Reverberation Time: T20'
    'Reverberation Time: T30'
    'Reverberation Time: T40'
    'Reverberation Time: T50'
    'Reverberation Time: T60'
    'Clarity: C80'
    'Clarity: C50'
    'Definition: D50'
    'Signal to Noise Ratio: SNR'
    'CT'
    'Lateral Fraction: LF'
    'Lateral Fraction: LFC'
    'Iteraural Cross Correlation: IACC'
};

%% GUI
pList = {};
name = 'Room acoustics';

%ele = length(pList) + 1;
pList{1}.datatype    = 'text'; 
pList{1}.description    = 'Measurement of reverberation time ISO3382'; 

%ele = length(pList) + 1;
pList{2}.description    = 'Name of engineer'; 
pList{2}.helptext       = '';
pList{2}.datatype       = 'char';
pList{2}.default        = ita_preferences('AuthorStr');

%ele = length(pList) + 1;
pList{3}.description    = 'Name of the room'; 
pList{3}.helptext       = 'e.g. Konzertsaal Aachen';
pList{3}.datatype       = 'char';
pList{3}.default        = 'name';

%ele = length(pList) + 1;
pList{4}.description    = 'Date of measurement'; 
pList{4}.helptext       = 'e.g. DD/MM/YY';
pList{4}.datatype       = 'char';
pList{4}.default        =  datestr(floor(now));

%ele = length(pList) + 1;
pList{5}.datatype    = 'line'; 

%ele = length(pList) + 1;
pList{6}.datatype    = 'text'; 
pList{6}.description    = 'Advanced'; 

%ele = length(pList) + 1;
pList{7}.description    = 'Volume of the room [m^3]'; 
pList{7}.helptext       = 'e.g. 400';
pList{7}.datatype       = 'double';
pList{7}.default        = '1000';

%ele = length(pList) + 1;
pList{8}.description    = 'Source Information'; 
pList{8}.helptext       = '';
pList{8}.datatype       = 'char_popup';
pList{8}.list           = 'Normal source has one location in the room|Large Stage or Orquestra Pit';
pList{8}.default        = 'Small room';

%ele = length(pList) + 1;
pList{9}.description    = 'Room Purposes'; 
pList{9}.helptext       = '';
pList{9}.datatype       = 'char_popup';
pList{9}.list           = 'Speech and Music|Other Purposes|Both';
pList{9}.default        = 'Speech and Music';

%ele = length(pList) + 1;
pList{10}.description    = 'Estimated T [s]'; 
pList{10}.helptext       = 'e.g. 1.5';
pList{10}.datatype       = 'double';
pList{10}.default        = '1.5';

%ele = length(pList) + 1;
pList{11}.description    = 'Number of Seats';
pList{11}.helptext       = 'e.g. 30 (In case of music and speech)';
pList{11}.datatype       = 'double';
pList{11}.default        = '50';

%ele = length(pList) + 1;

pList{12}.description    = 'Room description';
pList{12}.helptext       = 'e.g. Shape and material for walls and ceiling';
pList{12}.datatype       = 'char';
pList{12}.default        = '';

%ele = length(pList) + 1;
pList{13}.description = 'Save pdf ...'; 
pList{13}.helptext    = 'Select your special path'; 
pList{13}.datatype    = 'path'; 
pList{13}.filter    = ''; %Filter
pList{13}.default     = pwd; 

%ele = length(pList) + 1;
pList{14}.description = 'Equipment'; %this text will be shown in the GUI
pList{14}.helptext    = 'Call ita_roomacoustics_equipment'; %this text should be shown when the mouse moves over the textfield for the description
pList{14}.datatype    = 'int_result_button'; %based on this type a different row of elements has to drawn in the GUI
pList{14}.default     = ''; %default value, could also be empty, otherwise it has to be of the datatype specified above
pList{14}.callback    = 'ita_roomacoustics_equipment';
pList{14}.buttonname  = 'Equipment'; %this is optional

%ele = length(pList) + 1;
pList{15}.description = 'Parameters'; %this text will be shown in the GUI
pList{15}.helptext    = 'Call ita_roomacoustics_parameters'; %this text should be shown when the mouse moves over the textfield for the description
pList{15}.datatype    = 'int_result_button'; %based on this type a different row of elements has to drawn in the GUI
pList{15}.default     = ''; %default value, could also be empty, otherwise it has to be of the datatype specified above
pList{15}.callback    = 'ita_roomacoustics_parameers';
pList{15}.buttonname  = 'Parameters'; %this is optional

%% Call GUI
pOutList = ita_parametric_GUI(pList,name);

%% Set Output
%%%varargout(1) = {input}; 

%Equipment Information 
if isempty(pOutList{1,11})==1 || length(pOutList{1,11})~=13
    disp('Please select the equipment correctly')
    break
else
    equip={pOutList{1,11}' equip};
end
%Parameters Information 
if isempty(pOutList{1,12})==1 || length(pOutList{1,12})~=15
    disp('Please select the parameters correctly')
    break
else
    param={pOutList{1,12}' param};
end

%%Verarbeitung
CritDist=2*sqrt(pOutList{4}/(340*pOutList{7}));
if pOutList{8}<1000
    MinMicPos=6;
elseif 1000<=pOutList{8}<2000
    MinMicPos=8;
elseif pOutList{8}>=2000
    MinMicPos=8;
end

path=pOutList{10};

%Copy the files in choosen Folder
cd (path)
%create new directories
mkdir logos
mkdir figs
mkdir chap

template_path = [fileparts(which('ita_iso3382.m')) filesep 'latexroomacoustics' filesep];

%Copying files
copyfile([template_path 'mcode.sty'],path)
copyfile([template_path 'latexroomacoustics.tex'],path)
copyfile([template_path 'logos' filesep 'rwth-logo.pdf'],[path filesep 'logos' filesep])
copyfile([template_path 'logos' filesep 'ita-logo.pdf'],[path filesep 'logos' filesep])
copyfile([template_path 'chap' filesep 'title.tex'],[path filesep 'chap' filesep])
copyfile([template_path 'chap' filesep 'introduction.tex'],[path filesep 'chap' filesep])


%%
% Open file from ItaToolbox
fid = fopen([path filesep 'chap' filesep 'title.tex']);


% Read template file
funcTemplate = fread(fid, 'uint8=>char');
% Close Template file
fclose(fid);

% Transponieren
funcTemplate = funcTemplate(:)';

%Replace some Fields
funcTemplate = strrep(funcTemplate, 'ITAROOMACOUSTICSsubject', '---');
funcTemplate = strrep(funcTemplate, 'ITAROOMACOUSTICStitle', '---');
funcTemplate = strrep(funcTemplate, 'ITAROOMACOUSTICSauthor', ita_preferences('AuthorStr'));

%% write file
fid = fopen([path filesep 'chap' filesep 'title.tex'],'w');
fwrite(fid,funcTemplate,'char');
fclose(fid);
