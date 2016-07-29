function disp(this)
% shows the Object

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
if ita_preferences('nakedClasses')
    builtin('disp',this)
else
    disp@itaAudio(this)
    disp@itaSuperSph(this)
%     this.displayEndOfClass(mfilename('class'));
end