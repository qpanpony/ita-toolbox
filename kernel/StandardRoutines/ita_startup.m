% if exist('ccx','file')
%     ccx
%     thisFuncStr  = [upper(mfilename) ':  '];     %#ok<NASGU> Use to show warnings or infos in this functions
%     cprintf('blue',[thisFuncStr 'ccx.m clears all and sets warning messages. \n'])
% end

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Set path
disp('Loading ita_toolbox_path from local pathdef.')
path(pathdef());
