function [ lwr, upr ] = daffv15_effective_bounds( fcoeffs, threshold )
%DAFF_EFFECTIVE_BOUNDS Find boundaries of effective 'zones' in impulses
%responses (where filter coefficients are unequal zero)

% <ITA-Toolbox>
% This file is part of the application openDAFF for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    
    if ~isvector(fcoeffs), error('Input parameter ''fcoeffs'' must be a vector'); end;
    
    n = length(fcoeffs);
    if (n == 0), error('Input parameter ''fcoeffs'' may not be an empty vector'); end;
    
    x = abs(fcoeffs);
    lwr = 1;
    upr = n;
    
    % Scan from the left
    while (lwr <= n)
        if (x(lwr) >= threshold), break; end;
        lwr = lwr + 1;
    end
    
    % Special case: Everything below threshold
    if (lwr == (n+1))
        lwr = -1;
        upr = -1;
        return;
    end

    % Scan from the right
    while (upr > 1)
        if (x(upr) >= threshold), break; end;
        upr = upr - 1;
    end
end
