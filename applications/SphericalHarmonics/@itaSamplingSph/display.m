function display(this)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

display@itaCoordinates(this);
if ~isempty(this.nmax)
    disp([' maximum order nmax = ' num2str(this.nmax) ]);
        disp([' that means ' num2str(size(this.Y,2)) ' SH-base functions, calculated for ' num2str(size(this.Y,1)) ' points ']);
    if size(this.Y,1) ~= this.nPoints
        ita_verbose_info('   SH base does not match to the given grid',1);
    end
else
    disp(' no maximum order set, set s.nmax to an integer maximum order ')
end