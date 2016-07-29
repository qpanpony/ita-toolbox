classdef schicht
% Klasse für Schichten in geschichtetem Absorber Modell

% <ITA-Toolbox>
% This file is part of the application Impedance_Calculator for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

   properties
       name                = '';
       ausbreitungsArt     = 0;     % ausbreitungsArt legt fest ob Schicht lokal (0) oder lateral (1) wirksam ist
       schichtModell       = 1;     % 1 = Luftschicht, 2 = por. Abs. nach klassischer Theorie, 3 = por. Abs. nach empirischer Kennwertrelation, 4 = por. Absorber nach Komatsu-Modell
       klassMat            = 1;
       empiricalMat        = 1;
       dicke               = -1;
       stroemungsResistanz = 0;
       raumGewicht         = 0;
       porositaet          = 0;
       strukturFaktor      = 1;
       adiabatenKoeff      = 1;
   end
   
   properties (Constant = true, Access = private)
        % Umrechnungsfaktoren zwischen Strömungsres. und Raumgewicht bei klassischer Theorie
        % siehe Mechel Band II, Bild 6.4 sowie Tabelle 6.4
        % die erste Spalte ist NaN, weil der erste Eintrag in der Materialien
        % Listbox = "selbstdefiniert" ( => keine Umrechnung zwischen Str-Res und RG)
        resistivity2DensityCoefs = [ NaN, 0.656,  0.367,  0.122,  0.121,  0.0335, 0.08,   0.0192, 0.044,  0.00166;...
                                     NaN, 1.621,  1.359,  1.564,  1.401,  1.676,  1.271,  1.551,  1.304,  1.831 ]; 
                                 
        % Liste der empirischen Parameter
        % empiricCoeffList = [kappa1re, kappa1im, kappa2re, kappa2im, b11, b12, b21, b22]
        empiricCoeffList = [ 1.60, 0.10, 1.40, 0.10, 1.00, 1.00, 1.00, 1.50;
                             1.40, 0.15, 1.40, 0.10, 1.00, 0.90, 1.00, 1.70;
                             1.70, 0.10, 1.40, 0.10, 1.00, 0.90, 0.60, 1.70 ];
                                 
   end
   
   properties (Dependent = true, SetAccess = private)
       b11;
       b12;
       b21;
       b22;
       kappa1re;
       kappa1im;
       kappa2re;
       kappa2im;
   end
   
   methods
      function s = schicht(name)
         if nargin > 0
              if ischar(name)
                s.name = name;
             else
                error('Name must be a character array!');
             end
         end
      end
      
      function obj = calcDensityFromResistivity(obj)
        coeffs = obj.resistivity2DensityCoefs(:,obj.klassMat);
        raumgew = ( (obj.stroemungsResistanz/1000)/coeffs(1) )^(1/coeffs(2));
        obj.raumGewicht = raumgew;
      end
      
      function obj = calcResistivityFromDensity(obj)
        coeffs = obj.resistivity2DensityCoefs(:,obj.klassMat);
        res =  1000*(coeffs(1)*obj.raumGewicht^coeffs(2));
        obj.stroemungsResistanz = res;
      end
      
      function value = get.kappa1re(obj)
          value = obj.empiricCoeffList( obj.empiricalMat , 1);
      end

      function value = get.kappa1im(obj)
          value = obj.empiricCoeffList( obj.empiricalMat , 2);
      end
      
      function value = get.kappa2re(obj)
          value = obj.empiricCoeffList( obj.empiricalMat , 3);
      end
      
      function value = get.kappa2im(obj)
          value = obj.empiricCoeffList( obj.empiricalMat , 4);
      end
      
      function value = get.b11(obj)
          value = obj.empiricCoeffList( obj.empiricalMat , 5);
      end
      
      function value = get.b12(obj)
          value = obj.empiricCoeffList( obj.empiricalMat , 6);
      end
      
      function value = get.b21(obj)
          value = obj.empiricCoeffList( obj.empiricalMat , 7);
      end
      
      function value = get.b22(obj)
          value = obj.empiricCoeffList( obj.empiricalMat , 8);
      end
      
   end % methods
end % classdef

    
    