%
%  OpenDAFF - A free, open-source software package for directional audio data,
%  OpenDAFF is distributed under the terms of the GNU Lesser Public License (LGPL)
% 
%  Copyright (C) Institute of Technical Acoustics, RWTH Aachen University
%
%  Visit the OpenDAFF homepage: http://www.opendaff.org
%
%  -------------------------------------------------------------------------------
%
%  File:    daff_effective_filter_bounds.m
%  Purpose: Determine effective filter bounds
%  Author:  Frank Wefers (Frank.Wefers@akustik.rwth-aachen.de)
%
%  $Id: daff_write.m,v 1.7 2010/03/08 14:32:41 stienen Exp $
%

% <ITA-Toolbox>
% This file is part of the application openDAFF for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


function [ lwr, upr ] = daffv15_effective_filter_bounds( fcoeffs, threshold )
%DAFF_EFFECTIVE_BOUNDS Find boundaries of effective filter coefficients in impulses
%responses, by scanning from the left/right margin (where filter coefficients exceed a given threshold)
    
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
