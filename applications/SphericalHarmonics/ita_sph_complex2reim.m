function [fRe, fIm] = ita_sph_complex2reim(fCompl)
%ITA_SPH_COMPLEX2REIM - converts complex function to real and imaginary part 
% function [fRe, fIm] = ita_sph_complex2reim(fCompl)
%
% converts a spatial function given by its SH-coefficients to their
% real and imaginary part given also as SH-coefficients
% the resynthesis is: fCompl = fRe + j * fIm  
%
% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 04.11.2008

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

ita_verbose_obsolete('Marked as obsolete. Please report to mpo, if you still use this function.');

nCoef = size(fCompl,1);
[degree, order] = ita_sph_linear2degreeorder(1:nCoef);

fRe = zeros(size(fCompl));
fIm = fRe;

for iCoef = 1:nCoef
    m = order(iCoef);
%     l = degree(iCoef);    
    if ~m % m=0
        fRe(iCoef,:) = real(fCompl(iCoef,:));
        fIm(iCoef,:) = imag(fCompl(iCoef,:));
    elseif m > 0
        fRe(iCoef,:) = (fCompl(iCoef,:) + (-1)^m * conj(fCompl(iCoef-(2*m))))/2;
        fRe(iCoef-(2*m),:) = conj(fRe(iCoef,:)) * (-1)^m; 
        fIm(iCoef,:) = (fCompl(iCoef,:) - (-1)^m * conj(fCompl(iCoef-(2*m))))/(2*j);
        fIm(iCoef-(2*m),:) = conj(fIm(iCoef,:)) * (-1)^m; 
    end
end
