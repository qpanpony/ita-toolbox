function coeffStr = ita_nonlinear_polycoeff2string(coeffs)
%ITA_NONLINEAR_POLYCOEFF2STRING - String to show polynom
%
%  Syntax:
%   audioObjOut = ita_nonlinear_polycoeff2string([coeff_vec])
%
%
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_nonlinear_polycoeff2string">doc ita_nonlinear_polycoeff2string</a>

% <ITA-Toolbox>
% This file is part of the application Nonlinear for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  28-Feb-2013 

coeffStr = [];
for jdx = 1:numel(coeffs) % get nice polynom
    if jdx > 1
        expStr  = ['^{' num2str(jdx) '}'] ;
        if sign(coeffs(jdx)) >= 1
            signStr = '+';
        else
            signStr = '-';
        end
    else
        expStr  = '';
        signStr = '';
    end
    if coeffs(jdx) ~= 0
        if coeffs(jdx) ~= 1
            thisCoeff = [num2str(coeffs(jdx)) '\cdot '];
        else
            thisCoeff = '';
        end
        coeffStr = [coeffStr signStr thisCoeff 'x' expStr ]; %#ok<AGROW>
    end
end
if strcmp(coeffStr(1),'+') %clear + in the begging
    coeffStr = coeffStr(2:end);
end

coeffStr = ['$y=' coeffStr '$'];

    
%end function
end