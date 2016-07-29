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
%  File:    daff_lwrmul.m
%  Purpose: Calculate next lower multiple
%  Author:  Frank Wefers (Frank.Wefers@akustik.rwth-aachen.de)
%
%  $Id: daff_write.m,v 1.7 2010/03/08 14:32:41 stienen Exp $
%

% <ITA-Toolbox>
% This file is part of the application openDAFF for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


function [ c ] = daffv15_lwrmul( a, b )
%DAFF_LWRMUL Calculate next lower multiple 

    % Note: This function is used for data alignment calculations
    
    r = mod(a,b);
    if (r == 0)
        c = a;
    else
        c = a - r;
    end
end
