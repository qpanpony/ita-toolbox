function acDataSH = ita_sht(acData, gridData, type)
%ITA_SHT - performs a Spherical Harmonic transform on spherical data struct

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Martin Pollow -- Email: mpo@akustik.rwth-aachen.de
% Created:  03-Dec-2008

ita_verbose_obsolete('Marked as obsolete. Please report to mpo, if you still use this function.');

acDataSH = cell(size(acData));

for n = 1:numel(acData)
    acDataSH{n}.header = acData{n}.header;
    % TODO: neue EInheit
    if isfield(acData{n},'dat')
        oldFieldname = 'dat';
        newFieldname = 'dat_SH';
    elseif isfield(acData{n},'spk')
        oldFieldname = 'spk';
        newFieldname = 'spk_SH';
    end
    
    acDataSH{n}.(newFieldname) = ita_sph_SHT(acData{n}.(oldFieldname), gridData, type);
end