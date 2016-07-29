function T = ita_sph_ztransT(d_z,n_max,k)
%ITA_SPH_ZTRANST - Transformation matrix for coaxial translations in z 
% function T = ita_sph_ztransT(d_z,n_max,k)
% 
% Creates the transformation Matrix for a coaxial translation in z
% direction. 
% 
% application: f_translated(n,m) = T * f(n,m)
% f(n,m) being an SH/Multipole vector.
%
% Algorythm from "Analysis and Synthesis of Sound-Radiaton with Spherical
% Arrays", Zotter, 2009 and "Recursions for the Computation of Multipole
% Translation and Rotation Coefficients for the 3-D Helmholtz Equation",
% Gumerov and Duraiswami , 2003
%
% Johannes Klein (johannes.klein@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 15.11.2011

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

% Indices after Gumerov and Duraiswami.
% Shape of T: n x l x m => T(idn,idl,idm)

% Problem: Matrix indexing starts at 1, so we need counters to adress the
% matrix entries (idn, idl, idm) besides the indexes for n, l, m.
% The computation of the single matrix entries however, will be done using
% the original indexes, n, l, m.

% Save time
if(d_z == 0)
    T = 1;
    return;
end

% m_max is derivable from n_max, here just for the positive side. The
% negative side will be taken care of later.
m_max = n_max;

% l_max is derivable from n_max
l_max = n_max;

T = zeros(n_max+1, (l_max+1)+m_max, m_max+1);

% 1 Initialization
% Get initial value T^(m=0,m=0)_(n',n=0)(d_z).
% m,n=0, idm,idn=1 respectively.
for idl = 1:(l_max+1)+m_max
    l = idl - 1;
    T(1,idl,1) = get_T_0(l,k,d_z);
end

% 2 Recurrence, going through n' to create initial row of n in next m.
% for (m,n) for n'
for idm = 1:(m_max) % Last m matrix and thus the last row has not to be regarded.
    idn = idm;
    m = idm -1;
    n = idn -1;    
    for idl = (idm+1):(l_max+1)+m_max-(m+1)
        l = idl - 1;
        T(idn+1,idl,idm+1) = recurrence_I(n,l,m,T);
    end
end

% 3 Recurrence, going through l for every n in one m to fill the matrix for
% every m.
% for m for n for l
for idm = 1:(m_max) % Last m matrix and thus the last row has not to be regarded.
    m = idm -1;
    for idn = idm:(n_max) % Last row has not to be regarded.
        n = idn -1;
        for idl = (1+idn):(l_max+1)+m_max-(idn)
            l = idl - 1;
            T(idn+1,idl,idm)   = recurrence_II(n,l,m,T);
        end
    end
end

% 4 Cut of additional matrix parts in n' dimension.

T_temp = T(:,1:l_max+1,:);
clear T;

% 5 Symmetry
for idm = 1:(m_max+1)
    for idn = 1:(n_max) % Last row has not to be regarded.
        n = idn -1;
        for idl = (idn+1):(l_max+1) % Diagonal has not to be regarded.
            l = idl - 1;
            T_temp(idl,idn,idm) = (-1)^(n+l)*T_temp(idn,idl,idm);
        end
    end
end


% 6.1 Create vector for iteration consisting of two parts.
% First part for n iteration, looking like this:  0 111 22222 and so on.
% Second part for m iteration, looking like this: 0 101 21012 and so on.
% Just positive values, since until here, only positive
% m have been calculated and the negative m are the same as the
% corresponding positive ones. This step will take care of the missing
% negative m.
% Derive indexing vecotrs, by adding 1 to the just generated vectors.
% Put them together to get an indexing vector that can be stepped through.

[n_vec m_vec] = ita_sph_linear2degreeorder(1:(n_max+1)^2);
x_vec = [n_vec', m_vec'];

% 6.2 Sort
% row: nm tuple, column: lm tuple 

% initialize T first (mpo)
T = zeros(size(x_vec,1));

for idx = 1:size(x_vec,1)
    % Step through the tuples for n'm (columns of the final matrix)
    l =  x_vec(idx,1);
    md = x_vec(idx,2);
    
    idl = l +1;
    
    for idy = 1:size(x_vec,1)
        % Step through the tuples for nm (rows of the final matrix)
        n = x_vec(idy,1);
        m = x_vec(idy,2);
        
        idn = n +1;
        idm = abs(m) + 1;
        
        if m == md
            T(idx,idy) = T_temp(idn,idl,idm);
        else
            T(idx,idy) = 0;
        end
    end
end

% 7 Sign correction
% sign(x) results in 0 if x = 0, thus do if query. 
if ~(d_z == 0)
    T = sign(d_z)*T;
end
end

function T_0 = get_T_0(l,k,d_z)
%   Gumerov/Duraiswami: Factor (-1)^l
%   T_0 = (-1)^l * sqrt(2*l+1) * ita_sph_besselj(l,k*d_z);
%   Zotter (corrected error in original equation):    
    T_0 = sqrt(2*l+1) * ita_sph_besselj(l,k*d_z);
end

function a = get_a(m,n)
    if ge(n,0) && ge(m,-n) && le(m,n)
        num = (n-abs(m)+1)*(n+abs(m)+1);
        den = (2*n+1)*(2*n+3);
        a = sqrt(num/den);
    else
        a = 0;
    end
end

function b = get_b(m,n)
    if ge(n,0) && ge(m,0) && le(m,n)
        num = (n-m-1)*(n-m);
        den = (2*n-1)*(2*n+1);
        b = sqrt(num/den);
    elseif ge(n,0) && ge(m,-n) && le(m,0)
        num = (n-m-1)*(n-m);
        den = (2*n-1)*(2*n+1);
        b = -1*sqrt(num/den);
    else
        b = 0;
    end
end

function T_entry = recurrence_I(n,l,m,T)
    idn = n+1;
    idl = l +1;
    idm = m +1;
    pre  = 1 / get_b(-m-1,n+1);
    sumA = -1*get_b(m,l+1)*T(idn,idl+1,idm);
    sumB = get_b(-m-1,l)*T(idn,idl-1,idm);
    try
        sumC = get_b(m,n)*T(idn-1,idl,idm+1);
    catch
        sumC = 0;
    end
    T_entry = pre * (sumA + sumB + sumC);
end

function T_entry = recurrence_II(n,l,m,T)
    idn = n+1;
    idl = l +1;
    idm = m +1;
    pre  = 1 / get_a(m,n);
    sumA = -1*get_a(m,l)*T(idn,idl+1,idm);
    sumB = get_a(m,l-1)*T(idn,idl-1,idm);
    try
        sumC = get_a(m,n-1)*T(idn-1,idl,idm);
    catch
        sumC = 0;
    end
    T_entry = pre * (sumA + sumB + sumC);
end