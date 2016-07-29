function ita_newm(varargin)
%ITA_NEWM - Open m-File with ITA Template
%  This function creates an .m File according to the ITA Template
%
%  Syntax: ita_newm <filename>
%
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_">doc ita_</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created: 25-Aug-2008 

%% Check for Author information in Preferences - ask if not already there
AuthorStr = ita_preferences('AuthorStr');
EmailStr  = ita_preferences('EmailStr');

%% Check input arg
% if no name specified
if nargin == 0
    pList{1}.description = 'Function Name';
    pList{1}.helptext    = 'Specify the name of your new function. If it is a kernel function it should start with the prefix ita_';
    pList{1}.datatype    = 'char';
    pList{1}.default     = 'ita_(your_function_name)';
    
    pList{2}.description = 'Path for new Function';
    pList{2}.helptext    = 'Specify the path of your new function. If it is not a kernel function, start searching for a place in /Applications/';
    pList{2}.datatype    = 'path';
    pList{2}.default     = [ita_toolbox_path() filesep 'applications'];
    
    
    pList = ita_parametric_GUI(pList,mfilename);
    if isempty(pList)
        return
    end
    cd (pList{2})
    functionname = pList{1};
    
else
    functionname = varargin{1};
    if isequal(functionname(end-1:end),'.m' )
        functionname = functionname(1:end-2);
    end
end

% Open template file
fid = fopen('itaTemplate.m');

% Read template file
funcTemplate = fread(fid, 'uint8=>char');

% Close Template file
fclose(fid);

%% Read the other ita function names out of file
% itaFunNamesPath = which('itaFunctionnames.m');
% fid = fopen(itaFunNamesPath);
% itaFunNames = fread(fid, 'uint8=>char');
% fclose(fid);
% itaFunNames = itaFunNames(:)';
% fid = fopen(itaFunNamesPath,'w');
% fwrite( fid, [itaFunNames ', ' functionname],'char' );
% fclose( fid );

% Make sure template is traversing the right dimension
funcTemplate = funcTemplate(:)';

% Replace $ITAFUNCTIONNAMES$ Token
funcTemplate = strrep(funcTemplate, '$ITAFUNCTIONNAMES$', 'ita_toolbox_gui, ita_read, ita_write, ita_generate');

% Replace $Created$ Token
createdToken = sprintf('Created:  %s %s', datestr(now, 1));
funcTemplate = strrep(funcTemplate, '$itaCREATED$', createdToken);

% Replace itaTemplate Token
createdToken = functionname;
funcTemplate = strrep(funcTemplate, 'itaTemplate', createdToken);

% Replace itaTemplate uppercase Token
createdToken = upper(functionname);
funcTemplate = strrep(funcTemplate, upper('itaTemplate'), createdToken);

% Replace Author Information
funcTemplate = strrep(funcTemplate, 'AuthorStr', AuthorStr);
funcTemplate = strrep(funcTemplate, 'EmailStr' , EmailStr );

% try without robot
fid = fopen( strcat(functionname,'.m'),'a' );
fwrite( fid, funcTemplate,'char');
fclose( fid );

% Open the new m-file
edit( functionname );
