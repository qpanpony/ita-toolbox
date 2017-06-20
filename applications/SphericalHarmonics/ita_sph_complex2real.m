function SH = ita_sph_complex2real(varargin)
%ITA_SPH_COMPLEX2REAL - Transforms from complex to valued basis functions
%  This function transfroms spherical harmonic coefficients with complex
%  valued basis functions to their corresponding real valued
%  representation. The sign convention of the real valued basis functions
%  can be chosen. The definition in 'Williams - Fourier Acoustics' is
%  assumed for the complex basis functions (including the Condon-Shotley
%  phase). The phase conventions for the real valued spherical harmonics
%  can be 'raven' (which equals the ambix phase convention as defined in
%  "Nachbar - AMBIX: A Suggested Ambisonics Format (revised by Zotter)") 
%  or 'zotter' as defined in "Zotter - Analysis and synthesis of 
%  sound-radiation with spherical arrays"
%
%  Syntax:
%   SH_real = ita_sph_complex2real(SH_cplx, options)
%
%   Options (default):
%           'phase' ('ambix')	: Phase definitions as in the AmbiX format
%
%  Example:
%   SH_real = ita_sph_complex2real(SH_cplx)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sph_complex2real">doc ita_sph_complex2real</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

% Rewrite, original author unknown
%
% Author: Marco Berzborn -- Email: marco.berzborn@akustik.rwth-aachen.de
% Created:  12-Jun-2017

sArgs = struct('pos1_SH', 'double', ...
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
        cPos = SH(index_m_pos(m),:);
        cNeg = SH(index_m_neg(m),:);

        rPos = ((-1)^m * cPos + cNeg) / sqrt(2);
        switch sArgs.phase
            case {'ambix', 'raven'}
                rNeg = (cNeg - (-1)^m*cPos) / sqrt(2) .* 1i;
            case 'zotter'
                rNeg = (-cNeg + (-1)^m * cPos) / sqrt(2) .* 1i;
            otherwise
                ita_verbose_info('I do not know this phase convention. Aborting...', 0);
                SH = [];
                return
        end
        SH(ita_sph_degreeorder2linear(ind,m),:) = rPos;
        SH(ita_sph_degreeorder2linear(ind,-m),:) = rNeg;
    end
end