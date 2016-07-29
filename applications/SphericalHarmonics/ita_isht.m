function acData = ita_isht(acDataSH, gridData)
%ITA_ISHT - performs an inverse Spherical Harmonic transform on spherical data struct

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Martin Pollow -- Email: mpo@akustik.rwth-aachen.de
% Created:  03-Dec-2008

ita_verbose_obsolete('Marked as obsolete. Please report to mpo, if you still use this function.');

acData = cell(size(acDataSH));

for n = 1:numel(acDataSH)
    acData{n}.header = acDataSH{n}.header;
    % TODO: neue EInheit
    if isfield(acDataSH{n},'dat_SH')
        oldFieldname = 'dat_SH';
        newFieldname = 'dat';
    elseif isfield(acDataSH{n},'spk_SH')
        oldFieldname = 'spk_SH';
        newFieldname = 'spk';
    end
    
    acData{n}.(newFieldname) = ita_sph_ISHT(acDataSH{n}.(oldFieldname), gridData);
end