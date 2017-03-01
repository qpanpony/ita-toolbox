function varargout = ita_get_available_comports(varargin)
%ITA_GET_AVAILABLE_COMPORTS - cell array with serial port names
%  This function returns a cell array of all available ports for serial
%  communication. Uses java so it should be system independent.
%
%  Syntax:
%   cellstr = ita_get_available_comports()
%
%  Example:
%   aStr = ita_get_available_comports()
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_get_available_comports">doc ita_get_available_comports</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  14-Jan-2010 

%% Get Function String
% thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% get all available ports
% first create a sample serial object
try
    s = serial('a');
    % make it a java object
    jserial = igetfield(s,'jobject');
    % make the java string a character array
    availablePorts = char(jserial.findAllPorts);
    % output should be a cell array, a noDevice is needed if there are no ports
    output = [cellstr(availablePorts); {'noDevice'}];
    % delete the fake serial object, otherwise it will be returned by instrfind
    delete(s);
catch
    output = {'noDevice'};
end
%% Set Output
varargout(1) = {output};

%end function
end

%% old code
% try
%     s=serial('IMPOSSIBLE_NAME_ON_PORT');fopen(s); 
% catch
%     lErrMsg = lasterr;
% end
% 
% %Start of the COM available port
% lIndex1 = findstr(lErrMsg,'COM');
% %End of COM available port
% lIndex2 = findstr(lErrMsg,'Use')-3;
% 
% lComStr = lErrMsg(lIndex1:lIndex2);
% 
% %Parse the resulting string
% lIndexDot = findstr(lComStr,',');
% lCOM_Port{1} = 'noDevice';
% % If no Port are available
% if isempty(lIndex1)
%     return;
% end
% 
% % If only one Port is available
% if isempty(lIndexDot)
%     lCOM_Port= [lCOM_Port {lComStr}];
%     return;
% end
% 
% for i=1:numel(lIndexDot)+1
%     % First One
%     if (i==1)
%         lCOM_Port = [lCOM_Port {lComStr(1:lIndexDot(i)-1)}];
%     % Last One
%     elseif (i==numel(lIndexDot)+1)
%         lCOM_Port = [lCOM_Port {lComStr(lIndexDot(i-1)+2:end)}];       
%     % Others
%     else
%         lCOM_Port = [lCOM_Port lComStr(lIndexDot(i-1)+2:lIndexDot(i)-1)];
%     end
% end    
% 
% fclose(s);
% delete(s);