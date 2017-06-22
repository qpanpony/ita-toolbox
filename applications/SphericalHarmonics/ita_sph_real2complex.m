function SH = ita_sph_real2complex(varargin)
%ITA_SPH_REAL2COMPLEX - Transforms from real to complex valued basis functions
%  This function transfroms spherical harmonic coefficients with real
%  valued basis functions to their corresponding complex valued
%  representation. The sign convention of the real valued basis functions
%  can be chosen. The definition in 'Williams - Fourier Acoustics' is
%  specified for the complex basis functions (including the Condon-Shotley
%  phase). The phase conventions for the real valued spherical harmonics
%  can be 'raven' (which equals the ambix phase convention as defined in
%  "Nachbar - AMBIX: A Suggested Ambisonics Format (revised by Zotter)") 
%  or 'zotter' as defined in "Zotter - Analysis and synthesis of 
%  sound-radiation with spherical arrays"
%
%  Syntax:
%   SH_cplx = ita_sph_real2complex(SH_real, options)
%
%   Options (default):
%           'phase' ('ambix')	: Phase definitions as in the AmbiX format
%
%  Example:
%   SH_cplx = ita_sph_real2complex(SH_real)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sph_real2complex">doc ita_sph_real2complex</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

% Rewrite, original author unknown
%
% Author: Marco Berzborn -- Email: marco.berzborn@akustik.rwth-aachen.de
% Created:  12-Jun-2017

%

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% SH can be the vector/matrix of coefficients or the maximum order to
% calculate a matrix.

sArgs = struct('pos1_SH', 'double' ,...
               'phase', 'ambix');
[SH, sArgs] = ita_parse_arguments(sArgs, varargin);

if ~isnatural(sqrt(size(SH, 1)) - 1)
    ita_verbose_info('The dimensions of the input data do not match.', 0)
    SH = [];
    return
end

Nmax = floor(sqrt(size(SH,1))-1);


for ind = 1:Nmax
    % define the linear indices for the i'th degree
    index_m_neg = ita_sph_degreeorder2linear(ind,-1:-1:-ind);  % count in reverse order
    index_m_pos = ita_sph_degreeorder2linear(ind,1:ind);
    
    for m = 1:length(index_m_neg)
        rPos = SH(index_m_pos(m),:);
        rNeg = SH(index_m_neg(m),:);
        
        switch lower(sArgs.phase)
            case {'ambix','raven'}
                cPos = (rPos + 1i.* rNeg) * (-1)^m / sqrt(2);
                cNeg = (rPos - 1i * rNeg) ./ sqrt(2);
            case {'zotter'}
                cPos = (rPos - 1i.* rNeg) * (-1)^m / sqrt(2);
                cNeg = (rPos + 1i * rNeg) ./ sqrt(2);
            otherwise
                ita_verbose_info('I do not know this phase convention. Aborting...', 0);
                SH = [];
                return
        end
        SH(ita_sph_degreeorder2linear(ind,m),:) = cPos;
        SH(ita_sph_degreeorder2linear(ind,-m),:) = cNeg;
    end
end