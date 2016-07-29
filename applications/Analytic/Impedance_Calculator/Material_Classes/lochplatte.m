classdef lochplatte
% Klasse für Lochplatten in geschichtetem Absorber Modell

% <ITA-Toolbox>
% This file is part of the application Impedance_Calculator for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

   properties
       name = '';
       dicke = -1;
       lochSchlitzAbmessung = 0;
       lochSchlitzAbstand = 0;
       lochTyp = 1; % Lochplatte
       side = 0; % bestimmt ob Belag vor(0) oder hinter(1) Lochplatte innerhalb einer Lage
   end
    
   methods
      function lp = lochplatte(name)
      % BELAG  Constructs a belag object.
         if nargin > 0
             if ischar(name)
                lp.name = name;
             else
                error('Name must be a character array!');
             end
         end
      end
      
   end % methods
end % classdef

    
    