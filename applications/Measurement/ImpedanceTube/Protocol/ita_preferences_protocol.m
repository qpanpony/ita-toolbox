function res = ita_preferences_protocol()
% ITA_PREFERENCES_Protocol -

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


if nargout == 0 % Show GUI
    ita_preferences_gui_tabs(eval(mfilename), {mfilename}, true);
else
    res = {'miktexpath','','path','Path to MikTeX','Specify path to MikTeX distribution for Protocol generation',3 };
end