function varargout = ita_deal_units(varargin)
%ITA_DEAL_UNITS - Deal with physical units
%  This function takes care of the physical units used in the header of
%  audioObjs. It can multiply or divide two units or just deal with one
%  unit. Everything is transformed to SI units, rationalized/simplified and
%  transformed back to units used in acoustics.
%
%  Call: unitString = ita_deal_units(unitString)
%
%  ita_deal_units(unitString1) - just check units and simplify
%  ita_deal_units(unitString1,unitString2,'*')
%  ita_deal_units(unitString1,unitString2,'/')
%
%   See also ita_power, ita_multiply_spk, ita_divide_spk.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_deal_units">doc ita_deal_units</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  07-Nov-2008 *checked*

%% Get ITA Toolbox preferences
thisFuncStr  = [upper(mfilename) ':'];
tolerance    = 1e-18;
maxExponentSingle = 30;

%% Table conversion - basic SI units to primes - no 7 allowed? (pdi)
cc.meter    = 2;
cc.second   = 3;
cc.kilogram = 5;
cc.ampere   = 7;

cc.candela  = 29;
cc.kelvin   = 13;
cc.mol      = 27;

%% radiant - meter per meter - very strange unit but useful
cc.rad      = 11;

%% some more - these are not SI units but used in acoutics
cc.db       = 19; 
cc.sone     = 23;

%% SI derivatives
cc.volt     =[(cc.meter^2 * cc.kilogram) ; (cc.second^3 * cc.ampere)];
cc.henry    =[cc.meter^2 * cc.kilogram   ; cc.second^2* cc.ampere^2];
cc.farad    =[cc.second^4 * cc.ampere^2  ; cc.meter^2 * cc.kilogram];
cc.coulomb  =[cc.second*cc.ampere        ; 1];
cc.tesla    =[cc.kilogram                ; cc.second^2*cc.ampere];
cc.newton   =[cc.kilogram * cc.meter     ; cc.second^2];

%% Initialization
narginchk(1,3);
%deal arguments and return prime numbers
if nargin == 1 % only one string given, just check
    [num, den] = unitstr2numbers(varargin{1});
elseif nargin == 2 %power of, exponent
    token = varargin{2};
    if strcmp(token(1),'^')
        exponent = str2double(token(2:end));
        exponent_backup = exponent; %subfunctions are changing exponent
        if sign(exponent) == -1 %negative exponent
            [den, num] = unitstr2numbers(varargin{1});
        elseif sign(exponent) == 1 %positive exponent
            [num, den] = unitstr2numbers(varargin{1});
        else %exponent zero
            num = 1; den = 1;
        end
        exponent = exponent_backup;
    else
        error('ITA_DEAL_UNITS:Oh Lord. Please see syntax!')
    end
    
    num = num^abs(exponent);
    den = den^abs(exponent);
    if ~(isnatural(num) && isnatural(den)) %number is not natural
        ita_verbose_info('The units are probably not correct. Be careful !!!',0)
    end
    
    
elseif nargin == 3 %two strings and option, multiply and divide
    [numA, denA] = unitstr2numbers(varargin{1});
    [numB, denB] = unitstr2numbers(varargin{2});
    switch lower(varargin{3})
        case {'multiply','*'}
            num = numA * numB;
            den = denA * denB;
        case {'divide',  '/'}
            num = numA * denB;
            den = denA * numB;
        otherwise
            error('ITA_DEAL_UNITS:Oh Lord. Please see syntax!')
    end
else
    error('ITA_DEAL_UNITS:Oh Lord. Please see syntax!')
end


%% Build final String
unitString = numbers2unitstr(num,den);

%% Find output parameters
if nargout == 0 %User has not specified a variable
    
else
    varargout(1) = {unitString};
end

%end function

    function [num, den] = unitstr2numbers(unitStr)
        tokenStart = strfind(unitStr,'(');
        tokenEnd   = strfind(unitStr,')');
        if length(tokenStart) > 2 || length(tokenEnd) > 2
            error('ITA_DEAL_UNITS:Oh Lord. This unit string ist broken!')
        end
        
        divisorPos = strfind(unitStr,'/');
        
        if isempty(divisorPos) %only numerator here
            %get rid off brackets
            numToken = unitStr( unitStr  ~= '(' );
            numToken = numToken(numToken ~= ')' );
            denToken = '';
        else
            if isequal(unitStr(1),'/') || isequal(unitStr(end),'/')
                error('ITA_DEAL_UNITS:Oh Lord. This unit string ist broken!')
            end
            if isempty(tokenStart)
                %             tokenStart = [1 divisorPos+1];
                numToken   = unitStr(1:divisorPos-1);
                denToken   = unitStr((divisorPos+1):end);
                %             tokenEnd   = [divisorPos-1 length(unitStr)]
            else
                if length(tokenStart) == 2
                    if tokenStart(1) ~= 1
                        error('ITA_DEAL_UNITS:Oh Lord. This unit string ist broken!')
                    end
                    numToken = unitStr(tokenStart(1)+1 : tokenEnd(1)-1 );
                    denToken = unitStr(tokenStart(2)+1 : tokenEnd(2)-1 );
                elseif length(tokenStart) == 1
                    if tokenStart(1) == 1 %only numerator has brackets
                        numToken  = unitStr(tokenStart(1)+1 : tokenEnd(1)-1); %pdi bugfix was tokenEnd(1)+1
                        denToken  = unitStr(divisorPos+1 : end);
                    else % only denumerator has brackets
                        numToken  = unitStr(1 : divisorPos-1);
                        denToken  = unitStr(tokenStart(1)+1 : tokenEnd(1)-1);
                    end
                else
                    error('ITA_DEAL_UNITS:Oh Lord. This unit string ist broken!')
                end
            end
        end
        
        [num1, den1] = unitstr2nums(numToken);
        [den2, num2] = unitstr2nums(denToken);
        num         = num1 * num2;
        den         = den1 * den2;
        
        function [num, den] = unitstr2nums(unitStr)
            if isempty(unitStr)
                den = 1; num = 1;
                return;
            end
            unitStr(unitStr == '*') = ' ';
            tokenPos = strfind(unitStr,' ');
            tokenPos = [1 tokenPos length(unitStr)];
            num = 1; den = 1; %init
            
            for idx = 1:(length(tokenPos)-1)
                token = unitStr(tokenPos(idx):tokenPos(idx+1));
                token = token(token ~= ' ');
                token = token(token ~= '^'); %get rid off exponent operator
                if ~isempty(strfind(token,'/'))
                    position = min(strfind(token,'/'))-1;
                    token = token(1:position);
                    ita_verbose_info([thisFuncStr ': Double Fraction ignored!'],0)
                end
                if ~isempty(token)
                    switch_num_den = false; %standard: leave as it is
                    try %#ok<TRYNC>
                        if strcmpi(token(end-1),'-')
                            token = token(token~='-'); %get rif of minus sign
                            switch_num_den = true;
                        end
                    end
                    exponent = 1;
                    if any(isstrprop(token,'digit'))
                        exponent = sscanf(token(isstrprop(token,'digit')),'%f');
                        token = token(~isstrprop(token,'digit'));
                    end
                                        
                    if switch_num_den
                        [den,num] = deal(num,den);
                    end
                    switch(token)
                        case {'1',''}
                        case 'm'
                            num = num * cc.meter.^exponent;
                        case 'dB'
                            num = num * cc.db;
                        case 'sone'
                            num = num * cc.sone;
                        case 's'
                            num = num * cc.second.^exponent;
                        case 'kg'
                            num = num * cc.kilogram.^exponent;
                        case 'V'
                            num = num * cc.volt(1).^exponent;
                            den = den * cc.volt(2).^exponent;
                        case 'A'
                            num = num * cc.ampere.^exponent;
                        case 'Ohm'
                            num = num * cc.volt(1).^exponent;
                            den = den * (cc.ampere*cc.volt(2)).^exponent;
                        case 'Pa' % kg/ (m s^2)
                            num = num * cc.kilogram.^exponent;
                            den = den * cc.meter.^exponent * cc.second.^exponent * cc.second.^exponent;
                        case 'N'  % (kg m) / s^2
                            num = num * cc.kilogram.^exponent * cc.meter.^exponent;
                            den = den * cc.second.^exponent * cc.second.^exponent;
                        case 'Hz'
                            den = den * cc.second.^exponent;
                        case 'J' %joule
                            num = num * (cc.kilogram*cc.meter.^2).^exponent; 
                            den = den * (cc.second.^2).^exponent;
                        case 'W' %watts
                            num = num * (cc.kilogram*cc.meter.^2).^exponent; 
                            den = den * (cc.second.^3).^exponent;
                        case 'cd'
                            num = num * cc.candela.^exponent;
                        case 'mol'
                            num = num * cc.mol.^exponent;
                        case 'K'
                            num = num * cc.kelvin.^exponent;
                        case 'H'
                            num = num * cc.henry(1).^exponent;
                            den = den * cc.henry(2).^exponent;
                        case 'C'
                            num = num * cc.coulomb(1).^exponent;
                            den = den * cc.coulomb(2).^exponent;
                        case 'F'
                            num = num * cc.farad(1).^exponent;
                            den = den * cc.farad(2).^exponent;
                        case 'T'
                            num = num * cc.tesla(1).^exponent;
                            den = den * cc.tesla(2).^exponent;
                        case 'rad'
                            num = num * cc.rad.^exponent;
                        otherwise
                            if ~isempty(token)
                                ita_verbose_info(['Oh Lord. I do not know this unit: ' token '! Ignoring this...'])
                            end
                    end
                    if switch_num_den
                        [den,num] = deal(num,den);
                    end
                end
            end
        end % end subfunction
    end


    function unitStr = numbers2unitstr(num, den)
        %reduce unit numbers
        if (den > 1e9) || ( num > 1e9)
%             ita_verbose_info('ita_deal_units:using higher precision',1);
            tolerance = 1e-30;
        end
        [num, den] = rat(num/den,tolerance);
        
        numStr = ''; denStr = ''; %init
        
        %% Check for Abnormal Units
        if num == cc.db && den == 1
            numStr = 'dB';
            num = 1; den = 1;
        end
        if num == cc.sone && den == 1
            numStr = 'sone';
            num = 1; den = 1;
        end
        
        %% Check for Hertz
        [num,den,numStr] = check4farad(num,den,numStr);
        [den,num,denStr] = check4volt_mech(den,num,denStr);
        [num,den,numStr] = check4pascalmeterpervolt(num,den,numStr);
        [num,den,numStr] = check4voltperpascal(num,den,numStr);
        [num,den,numStr] = check4voltpermetersecondsquare(num,den,numStr);
        [num,den,numStr] = check4voltpernewton(num,den,numStr);
        [num,den,numStr] = check4newtonpervolt(num,den,numStr);
        [num,den,numStr] = check4pascalpervolt(num,den,numStr);
        [num,den,numStr] = check4hertz(num,den,numStr);
        [num,den,numStr] = check4ohm   (num,den,numStr);
        [num,den,numStr] = check4volt_mech (num,den,numStr);
        [num,den,numStr] = check4watt  (num,den,numStr);
        
        if num > 1 || den > 1
            
            % pre-run to find newton and pascal in denominator - order of appearance is important
            [den,num,denStr] = check4pascal(den,num,denStr);
            [den,num,denStr] = check4ohm   (den,num,denStr); %changed to here
            [den,num,denStr] = check4volt_mech(den,num,denStr);
            [den,num,denStr] = check4newton(den,num,denStr);
            [den,num,denStr] = check4watt  (den,num,denStr);
            
            if num > 1 || den > 1
                % find in numerator position
                [num,den,numStr] = check4henry(num,den,numStr);
                [num,den,numStr] = check4tesla(num,den,numStr);
                [num,den,numStr] = check4pascal(num,den,numStr);
                [num,den,numStr] = check4newton(num,den,numStr);
                [num,den,numStr] = check4coulomb(num,den,numStr);
                
                %% find single units with exponent in numerator
                if num > 1 || den > 1
                    [num,den,numStr] = check4volt(num,den,numStr);
                    [num,den,numStr] = check4ampere(num,den,numStr);
                    [num,den,numStr] = check4kg(num,den,numStr);
                    [num,den,numStr] = check4second(num,den,numStr);
                    [num,den,numStr] = check4meter(num,den,numStr);
                    [num,den,numStr] = check4mol(num,den,numStr);
                    [num,den,numStr] = check4kelvin(num,den,numStr);
                    [num,den,numStr] = check4candela(num,den,numStr);
                    [num,den,numStr] = check4rad(num,den,numStr);
                    
                    %% find single units with exponent in denominator
                    if num > 1 || den > 1
                        [den,num,denStr] = check4volt(den,num,denStr);
                        [den,num,denStr] = check4ampere(den,num,denStr);
                        [den,num,denStr] = check4kg(den,num,denStr);
                        [den,num,denStr] = check4second(den,num,denStr);
                        [den,num,denStr] = check4meter(den,num,denStr);
                        [den,num,denStr] = check4mol(den,num,denStr);
                        [den,num,denStr] = check4kelvin(den,num,denStr);
                        [den,num,denStr] = check4candela(den,num,denStr);
                        [den,num,denStr] = check4rad(den,num,denStr);
                    end
                end
            end
        end
        
        if num ~= 1
            ita_verbose_info([thisFuncStr 'numerator wrong: ' num2str(num) ' remaining.'],0)
        end
        if den ~= 1
            ita_verbose_info([thisFuncStr 'denominator wrong: ' num2str(den) ' remaining.'],0)
        end
        
        %% more than one element?
        if ~isempty(strfind(numStr,' ')) %#ok<*REMFF1> %more than one token
            numStr = ['(' numStr ')'];
        end
        if ~isempty(strfind(denStr,' ')) %more than one token
            denStr = ['(' denStr ')'];
        end
        if isempty(numStr) && isempty(denStr)
            numStr = ''; denStr = '';
        elseif isempty(numStr)
            numStr = '1';
        end
        if isempty(denStr) || isequal(denStr,'1')
            unitStr = numStr(numStr ~= '(');
            unitStr = unitStr(unitStr ~= ')');
        else
            unitStr = [numStr '/' denStr ];
        end
        
        function [iNum, iDen, numString] = check4pascalmeterpervolt(iNum,iDen,numString)
            
            numFactor = cc.volt(2);
            denFactor = cc.volt(1);
            
            %pascal meter
            numFactor = numFactor * cc.kilogram ;
            denFactor = denFactor * cc.second * cc.second;
            
            [numFactor, denFactor] = rat(numFactor/denFactor,1e-4);
            newString = 'Pa m/V'; maxExponent = 1;
            if iNum == numFactor && iDen == denFactor
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum) && isfactor(denFactor.^i,iDen)
                        if i ~= 1
                            newString = [newString '^' num2str(i)]; 
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                    end
                end
            end
        end
        
        function [iNum, iDen, numString] = check4voltperpascal(iNum,iDen,numString)
            numFactor = cc.volt(1);
            denFactor = cc.volt(2);
            %pas
            denFactor = denFactor * cc.kilogram;
            numFactor = numFactor * cc.meter * cc.second * cc.second;
            [numFactor, denFactor] = rat(numFactor/denFactor,1e-4);
            newString = 'V/Pa'; maxExponent = 1;
            if iNum == numFactor && iDen == denFactor
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum) && isfactor(denFactor.^i,iDen)
                        if i ~= 1
                            newString = [newString '^' num2str(i)];
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                    end
                end
            end
        end
        
        function [iNum, iDen, numString] = check4voltpermetersecondsquare(iNum,iDen,numString)
            numFactor = cc.volt(1);
            denFactor = cc.volt(2);
            %pas
            denFactor = denFactor * cc.meter;
            numFactor = numFactor * cc.second^2;
            [numFactor, denFactor] = rat(numFactor/denFactor,1e-4);
            newString = 'V s^2/m'; maxExponent = 1;
            if iNum == numFactor && iDen == denFactor
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum) && isfactor(denFactor.^i,iDen)
                        if i ~= 1
                            newString = [newString '^' num2str(i)];
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                    end
                end
            end
        end
        
        function [iNum, iDen, numString] = check4voltpernewton(iNum,iDen,numString)
            numFactor = cc.volt(1);
            denFactor = cc.volt(2);
            %pas
            denFactor = denFactor * cc.newton(1);
            numFactor = numFactor * cc.newton(2);
            [numFactor, denFactor] = rat(numFactor/denFactor,1e-4);
            newString = 'V/N'; maxExponent = 1;
            if iNum == numFactor && iDen == denFactor
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum) && isfactor(denFactor.^i,iDen)
                        if i ~= 1
                            newString = [newString '^' num2str(i)]; 
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                    end
                end
            end
        end
        
        function [iNum, iDen, numString] = check4newtonpervolt(iNum,iDen,numString)
            denFactor = cc.volt(1);
            numFactor = cc.volt(2);
            %pas
            numFactor = numFactor * cc.newton(1);
            denFactor = denFactor * cc.newton(2);
            [numFactor, denFactor] = rat(numFactor/denFactor,1e-4);
            newString = 'N/V'; maxExponent = 1;
            if iNum == numFactor && iDen == denFactor
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum) && isfactor(denFactor.^i,iDen)
                        if i ~= 1
                            newString = [newString '^' num2str(i)]; 
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                    end
                end
            end
        end
        
        function [iNum, iDen, numString] = check4pascalpervolt(iNum,iDen,numString)
            numFactor = cc.volt(2);
            denFactor = cc.volt(1);
            %pas
            numFactor = numFactor * cc.kilogram;
            denFactor = denFactor * cc.meter * cc.second^2;
            [numFactor, denFactor] = rat(numFactor/denFactor,tolerance);
            newString = 'Pa/V'; maxExponent = 1;
            if iNum == numFactor && iDen == denFactor
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum) && isfactor(denFactor.^i,iDen)
                        if i ~= 1
                            newString = [newString '^' num2str(i)]; 
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                    end
                end
            end
        end
        
        function [iNum, iDen, numString] = check4henry(iNum,iDen,numString)
            numFactor = cc.henry(1); denFactor = cc.henry(2); newString = 'H'; maxExponent = 16;
            if isfactor(numFactor,iNum) && isfactor(denFactor, iDen)
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum) && isfactor(denFactor.^i,iDen)
                        if i ~= 1
                            newString = [newString '^' num2str(i)]; %#ok<*AGROW>
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                    end
                end
            end
        end
        
        function [iNum, iDen, numString] = check4tesla(iNum,iDen,numString)
            numFactor = cc.tesla(1); denFactor = cc.tesla(2); newString = 'T'; maxExponent = 16;
            if isfactor(numFactor,iNum) && isfactor(denFactor, iDen)
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum) && isfactor(denFactor.^i,iDen)
                        if i ~= 1
                            newString = [newString '^' num2str(i)];
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                    end
                end
            end
        end
        
        function [iNum, iDen, numString] = check4farad(iNum,iDen,numString)
            numFactor = cc.farad(1); denFactor = cc.farad(2); newString = 'F'; maxExponent = 16;
            if isfactor(numFactor,iNum) && isfactor(denFactor, iDen)
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum) && isfactor(denFactor.^i,iDen)
                        if i ~= 1
                            newString = [newString '^' num2str(i)];
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                    end
                end
            end
        end
        
        function [iNum, iDen, numString] = check4coulomb(iNum,iDen,numString)
            numFactor = cc.coulomb(1); denFactor = cc.coulomb(2); newString = 'C'; maxExponent = 16;
            if isfactor(numFactor,iNum) && isfactor(denFactor, iDen)
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum) && isfactor(denFactor.^i,iDen)
                        if i ~= 1
                            newString = [newString '^' num2str(i)];
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                    end
                end
            end
        end
        
        function [iNum, iDen, numString] = check4pascal(iNum,iDen,numString)
            numFactor = cc.kilogram; denFactor = cc.meter*cc.second^2; newString = 'Pa'; maxExponent = 16;
            if isfactor(numFactor,iNum) && isfactor(denFactor, iDen)
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum) && isfactor(denFactor.^i,iDen)
                        if i ~= 1
                            newString = [newString '^' num2str(i)];
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                    end
                end
            end
        end
        
        function [iNum, iDen, numString] = check4newton(iNum,iDen,numString)
            numFactor = cc.kilogram*cc.meter; denFactor = cc.second^2; newString = 'N'; maxExponent = 16;
            if isfactor(numFactor,iNum) && isfactor(denFactor, iDen)
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum) && isfactor(denFactor.^i,iDen)
                        if i ~= 1
                            newString = [newString '^' num2str(i)];
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                    end
                end
            end
        end
        
        function [iNum, iDen, numString] = check4ohm(iNum,iDen,numString)
            numFactor = cc.volt(1); denFactor = cc.ampere*cc.volt(2); newString = 'Ohm'; 
            maxExponent = min(floor([maxExponentSingle, min(iNum/numFactor, iDen/denFactor) ]));
            if isfactor(numFactor,iNum) && isfactor(denFactor, iDen)
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum) && isfactor(denFactor.^i,iDen)
                        if i ~= 1
                            newString = [newString '^' num2str(i)];
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                    end
                end
            end
        end
        
        function [iNum, iDen, numString] = check4volt(iNum,iDen,numString)
            numFactor = cc.volt(1); denFactor = cc.volt(2); newString = 'V';
            maxExponent = min(floor([maxExponentSingle, min(iNum/numFactor, iDen/denFactor) ]));
            if iNum >= numFactor && iDen >= denFactor
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum) && isfactor(denFactor.^i,iDen)
                        if i ~= 1
                            newString = [newString '^' num2str(i)];
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                    end
                end
            end
        end
        
        function [iNum, iDen, numString] = check4kelvin(iNum,iDen,numString)
            numFactor = cc.kelvin; denFactor = 1; newString = 'K'; maxExponent = maxExponentSingle; 
            if isfactor(numFactor,iNum) 
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum)
                        if i ~= 1
                            newString = [newString '^' num2str(i)];
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                    end
                end
            end
        end
        
        function [iNum, iDen, numString] = check4mol(iNum,iDen,numString)
            numFactor = cc.mol; denFactor = 1; newString = 'mol'; maxExponent = maxExponentSingle; 
            if isfactor(numFactor,iNum) 
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum)
                        if i ~= 1
                            newString = [newString '^' num2str(i)];
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                    end
                end
            end
        end
        
        function [iNum, iDen, numString] = check4candela(iNum,iDen,numString)
            numFactor = cc.candela; denFactor = 1; newString = 'cd'; maxExponent = maxExponentSingle;
            if isfactor(numFactor,iNum) 
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum) 
                        if i ~= 1
                            newString = [newString '^' num2str(i)];
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                    end
                end
            end
        end
        
        
        function [iNum, iDen, numString] = check4volt_mech(iNum,iDen,numString)
            numFactor = cc.kilogram*cc.meter^2; denFactor = cc.second^3*cc.ampere; newString = 'V'; 
            maxExponent = min(floor([maxExponentSingle, min(iNum/numFactor, iDen/denFactor) ]));
            if isfactor(numFactor,iNum) && isfactor(denFactor, iDen)
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum) && isfactor(denFactor.^i,iDen)
                        if i ~= 1
                            newString = [newString '^' num2str(i)];
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                        break
                    end
                end
            end
            %check ampere - mechanical
            numFactor = cc.kilogram*cc.meter^2*cc.volt(2); denFactor = cc.second^3*cc.volt(1); newString = 'A'; 
            maxExponent = min(floor([maxExponentSingle, min(iNum/numFactor, iDen/denFactor) ]));
            if isfactor(numFactor,iNum) && isfactor(denFactor, iDen)
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum) && isfactor(denFactor.^i,iDen)
                        if i ~= 1
                            newString = [newString '^' num2str(i)];
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                        break
                    end
                end
            end
        end
        
        function [iNum, iDen, numString] = check4ampere(iNum,iDen,numString)
            numFactor = cc.ampere; denFactor = 1; newString = 'A'; 
            maxExponent = min(floor([maxExponentSingle, iNum/numFactor]));
            if isfactor(numFactor,iNum)
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum) 
                        if i ~= 1
                            newString = [newString '^' num2str(i)];
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                        break
                    end
                end
            end
        end
        
        function [iNum, iDen, numString] = check4second(iNum,iDen,numString)
            numFactor = cc.second; denFactor = 1; newString = 's';
            maxExponent = min(floor([maxExponentSingle, iNum/numFactor ]));
            if isfactor(numFactor,iNum) 
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum) 
                        if i ~= 1
                            newString = [newString '^' num2str(i)];
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                        break
                    end
                end
            end
        end
        
        function [iNum, iDen, numString] = check4meter(iNum,iDen,numString)
            numFactor = cc.meter; denFactor = 1; newString = 'm'; maxExponent = maxExponentSingle;
            if isfactor(numFactor,iNum) 
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum) 
                        if i ~= 1
                            newString = [newString '^' num2str(i)];
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                        break
                    end
                end
            end
        end
        
        function [iNum, iDen, numString] = check4rad(iNum,iDen,numString)
            numFactor = cc.rad; denFactor = 1; newString = 'rad'; 
            maxExponent = min(floor([maxExponentSingle, max(iNum/numFactor, iDen/denFactor) ]));
            if isfactor(numFactor,iNum)
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum) 
                        if i ~= 1
                            newString = [newString '^' num2str(i)];
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                        break
                    end
                end
            end
        end
        
        function [iNum, iDen, numString] = check4kg(iNum,iDen,numString)
            numFactor = cc.kilogram; denFactor = 1; newString = 'kg'; 
            maxExponent = min(floor([maxExponentSingle, iNum/numFactor]));
            if isfactor(numFactor,iNum)
                for i = maxExponent:-1:1
                    if isfactor(numFactor.^i,iNum)
                        if i ~= 1
                            newString = [newString '^' num2str(i)];
                        end
                        iNum = iNum/numFactor.^i;
                        iDen = iDen/denFactor.^i;
                        numString = appendString(numString,newString);
                        break
                    end
                end
            end
        end
        
        function [iNum, iDen, numString] = check4watt(iNum,iDen,numString) %watts
            numFactor = cc.volt(1)*cc.ampere; denFactor = cc.volt(2); newString = 'W'; % mechanical units
            if iNum >= numFactor && iDen >= denFactor
                if isfactor(numFactor,iNum) && isfactor(denFactor,iDen)
                    iNum = iNum/numFactor;
                    iDen = iDen/denFactor;
                    numString = appendString(numString,newString);
                end
            end
            numFactor = cc.kilogram*2^2; denFactor = cc.second^3; newString = 'W'; % electrical units
            if iNum >= numFactor && iDen >= denFactor
                if isfactor(numFactor,iNum) && isfactor(denFactor,iDen)
                    iNum = iNum/numFactor;
                    iDen = iDen/denFactor;
                    numString = appendString(numString,newString);
                end
            end
        end
        
        function [iNum, iDen, numString] = check4hertz(iNum,iDen,numString)
            numFactor = 1; denFactor = cc.second; newString = 'Hz'; %hertz
            if iDen == denFactor && iNum == numFactor
                iNum = iNum/numFactor;
                iDen = iDen/denFactor;
                numString = appendString(numString,newString);
            end
        end
        
        function unitString = appendString(unitString,newString)
            if newString(end) == '2'
                newString = newString(1:end-1); newString = newString(newString ~= '^');
                newString = [newString '^2'];
            elseif newString(end) == '3'                
                newString = newString(1:end-1); newString = newString(newString ~= '^');
                newString = [newString '^3'];
            end
            if isempty(unitString)
                unitString = newString;
            else
                unitString = [unitString ' ' newString];
            end
        end
    end
end
