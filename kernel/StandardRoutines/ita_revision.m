function varargout = ita_revision(varargin)
%ITA_REVISION - Revisionrange 
%  This function returns the Revision-Range of your working-copy. It's just
%  a simple trigger for the subversion tool svnversion for Unix based Systems 
%  or SubWCREv which comes with tortoiseSVN on Windows Systems.
%  Please NOTE: this script only works ether svnversion or SubWCREv is
%  installed.
%  
%
%  Syntax:
%   ita_revision
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_revision">doc ita_revision</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Gregor Powarzynski -- Email: gregor.powarzynski@akustik.rwth-aachen.de
% Created:  09-Nov-2009 

% thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> 

if isunix 
    fcnstring = '!svnversion -c ';
elseif ispc
    fcnstring = '!SubWCRev ';
end

pathStr     = [path() pathsep];

tokenIdx    = [0 findstr(pathStr,pathsep)];
installPath= cell(0);

for idx=1:(length(tokenIdx)-1)
   tokenCell = pathStr(tokenIdx(idx)+1:tokenIdx(idx+1)-1); 

   if strcmp(tokenCell(end-10:end),'ITA-Toolbox')
      installPath=[installPath tokenCell];
   elseif strcmp(tokenCell(end-14:end),'ITA-Toolbox-dev')
      installPath=[installPath tokenCell];
   end
   
end

for i=1:length(installPath)
   [pathof,name,ext] = fileparts(installPath{i});
      
   % tries to change to the install Path and trigger the svnversion-fcn  
   disp (['The Revision-Number of ' name ' is ']);
   eval([fcnstring installPath{i}]); 
end


end