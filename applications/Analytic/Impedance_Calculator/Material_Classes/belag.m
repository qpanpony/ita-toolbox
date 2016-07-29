classdef belag
    % Klasse für Beläge in geschichtetem Absorber Modell
    
    % <ITA-Toolbox>
    % This file is part of the application Impedance_Calculator for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    properties
        name = '';
        belagsTyp = 1;             % 1 = normaler Belag, 2 = Mikroperforierter Panel Absorber
        dicke = -1;
        dichte = 0;
        eModul = 0;
        querKontraktionsZahl = 0;
        verlustFaktor = 0;
        lochDurchmesser = 0;
        perforationsRatio = 0;
        stroemungsResistanz = -1;
    end
    
    methods
        function b = belag(name)
            % BELAG  Constructs a belag object.
            if nargin > 0
                if ischar(name)
                    b.name = name;
                else
                    error('Name must be a character array!');
                end
            end
        end
        
    end % methods
end % classdef


