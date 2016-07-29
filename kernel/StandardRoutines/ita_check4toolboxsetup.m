function ita_check4toolboxsetup(varargin)
%ITA_CHECK4TOOLBOXSETUP - Call Toolbox Setup if out-of-date
%  This function checks if the last toolbox setup is sufficient or
%  ita_toolbox_setup has be ran again
%
%  ita_preferences('lastToolboxSetupVerNum') gives the last date
%
%  Syntax: itaAudio = ita_check4toolboxsetup(itaAudio)
%
%   See also ita_toolbox_setup.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_check4toolboxsetup">doc ita_check4toolboxsetup</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  14-Apr-2009

%% Get last Time
lastSetupVersionNumber = ita_preferences('lastToolboxSetupVerNum');

%% Get date of ita_toolbox_setup
currentVersionNumber = ita_toolbox_version_number();

%% Check if out-of-date
if lastSetupVersionNumber < currentVersionNumber
    nChar = 90;
    ita_disp(nChar);
    ita_disp(nChar);
    ita_disp(nChar);
    ita_disp(nChar,'You should call ita_toolbox_setup immediately to avoid strange errors. Thank You!');
    ita_disp(nChar);
    ita_disp(nChar);
    ita_disp(nChar);
   
end

%end function
end