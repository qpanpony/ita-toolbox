function [zz,pp] = ita_zpk_decompose(H,W,z,p)
%ITA_ZPK_DECOMPOSE - decompose poles and zeroes
%  This function TODO Documentation
%
%  Syntax:
%   audioObjOut = ita_zpk_decompose(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_zpk_decompose(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_zpk_decompose">doc ita_zpk_decompose</a>

% <ITA-Toolbox>
% This file is part of the application PoleZeroProny for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Bruno Masiero -- Email: bma@akustik.rwth-aachen.de
% Created:  01-Sep-2010 


 

%     semilogx(test_freq,H); hold all

zz = [];
pp = [];
aux_z = z;
aux_p = p;

[P,Z] = arrange(aux_z,aux_p);
t = 0;
while (~isempty(P) || ~isempty(Z))
    H = log10(abs(H)) - mean(log10(abs(H)));
    for pdx = 1:size(P,1)
        for zdx = 1:size(Z,1)
            h = freqz(Z(zdx,:),P(pdx,:),W);
            h = log10(abs(h)) - mean(log10(abs(h)));
%             semilogx(test_freq,h);
            dif(pdx,zdx) = sqrt(sum((H - h).^2));
        end
    end
    
    [xx,ind] = min(dif(:));
    [indp indz] = find(dif == dif(ind));
    
    if length(indp) > 1 || length(indz) > 1
        t = t;
    end
    zz = [zz; Z(indz(1),:)];
    pp = [pp; P(indp(1),:)];
    
    h = freqz(Z(indz(1),:),P(indp(1),:),W);
    H = H - h;
    
    aux_z = eliminate(aux_z,zz(end,1));
    aux_z = eliminate(aux_z,zz(end,2));
    aux_p = eliminate(aux_p,pp(end,1));
    aux_p = eliminate(aux_p,pp(end,2));
    
    clear dif
    [P,Z] = arrange(aux_z,aux_p);
    t = t+1
    if t == 38
        t = t;
    end
end

%end function
end

function aux = eliminate(aux,pointxx)
    ind = find(aux == pointxx);
    aux(ind(1)) = [];
end
function [P,Z] = arrange(zo,po)
z = cplxpair(zo);
    p = cplxpair(po);
    ind = find(abs(imag(p)) <= 100*eps(class(p))*abs(p));
    p_real = p(ind);  
    p_conj = p; p_conj(ind) = [];
    ind = find(abs(imag(z)) <= 100*eps(class(z))*abs(z));
    z_real = z(ind);  
    z_conj = z; z_conj(ind) = [];
    
    P = [];
    if ~isempty(p_conj)
        P = [P; reshape(p_conj,2,length(p_conj)/2).'];
    end
    
    if ~isempty(p_real)
        P = [P; nchoosek(p_real,2)];
    end
    
    Z = [];
    if ~isempty(z_conj)
        Z = [Z; reshape(z_conj,2,length(z_conj)/2).'];
    end
    
    if ~isempty(z_real)
        Z = [Z; nchoosek(z_real,2)];
    end
end