function SH = ita_sph_complex2real(SH)
% converts a complex valued base or SH vector into its real base / SH vectors
%

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% SH can be the vector/matrix of coefficients or the maximum order to
% calculate a matrix.

if isnumeric(SH)
    if numel(SH) == 1
        % return a matrix
        SH = ita_sph_complex2real_mat(SH);
    else
        % assume this as SH coefs
        SH = ita_sph_complex2real_coefs(SH);
    end
else
    error('please check syntax')
end

end

function SH = ita_sph_complex2real_coefs(SH)

% assume the SH dimension as first dimension
sizeY = size(SH);

% check for max 2 dimension
if numel(sizeY) > 2
    reshape(SH, sizeY(1), []);
end

% check for SH in 1st dimension
if sizeY(1) == 1 && sizeY(2) > 1
    SH = SH.';
    isTransposed = true;
else
    isTransposed = false;
end

nmax = sqrt(size(SH,1)) - 1;
if nmax ~= round(nmax)
    error('ita_sph_complex2real  something wrong with the number of coefficients (they do not fill up to a full order)');
end

for ind = 1:nmax
    % define the linear indices for the i'th degree
    index_m_neg = ita_sph_degreeorder2linear(ind,-1:-1:-ind);  % count in reverse order
    index_m_pos = ita_sph_degreeorder2linear(ind,1:ind);
    
    for m = 1:length(index_m_neg)
        cPos = SH(index_m_pos(m),:);
        cNeg = SH(index_m_neg(m),:);
        
        rPos = ((-1)^m * cPos + cNeg) / sqrt(2);
        rNeg = ((-1)^m * cNeg - cPos) / sqrt(2) .* 1i;
        
        SH(ita_sph_degreeorder2linear(ind,m),:) = rPos;
        SH(ita_sph_degreeorder2linear(ind,-m),:) = rNeg;
    end
end

if isTransposed
    SH = SH.';
end

% now bring to the old shape
SH = reshape(SH,sizeY);
end

function T = ita_sph_complex2real_mat(nmax)

if numel(nmax) > 1
    error;
end

nSH = (nmax+1).^2;

lin = (1:nSH).';
multiplicator = 2*mod(lin,2) - 1;

[deg,order] = ita_sph_linear2degreeorder(lin);
linNeg = ita_sph_degreeorder2linear(deg,-order);

isPos = order > 0;
isNeg = order < 0;

T = sparse(eye(nSH));
T_orig = T;
T_swap = T .* diag(multiplicator);

T(lin(isPos),:) = (T_swap(lin(isPos),:) + T_orig(linNeg(isPos),:)) / sqrt(2);
T(lin(isNeg),:) = (T_swap(lin(isNeg),:) - T_orig(linNeg(isNeg),:)) / sqrt(2) .* 1i;
end
