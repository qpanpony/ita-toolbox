function vector_out = ita_sph_convSH(vector_1,vector_2,MAX_degree)
%ITA_SPH_CONVSH - convolution of spherical harmonic coefficients
% function vector_out = ita_sph_convSH(vector1,vector2,MAX_degree)
%
% Function calculates the convolution of two sets of SH coefficients
% Input shoud be two vectors of size N^2 with the coefficients to be
% convoluted.
%
% MAX_degree allows for the user to define the up to which degree the
% convolution should be calculated. If not specified,
% MAX_degree = degree_1 + degree_2
%
% For velocity, when a given coefficient is calculated for the first time
% it is saved at a cell array inside the MAT-file "GauntValues",
% considerably increasing the calculation speed on the subsequent runs.
%
% The definition was taken from:
% [1] Driscoll and Healy, "Computing Fourier Transforms and Convolutions on the
% 2-D Sphere", Advances in Applied Mathematics, 15, 202-250, 1994
%
% [2] Messiah, A. "Quantum Mechanics", Courier Dover Publications, 1999
% in page 1057
%
% Bruno Masiero (bma@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany,
% 19/08/2008

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


[m,n] = size(vector_1);
if n > 1
    if m > 1
        error('Input should be a vector.')
    else
        vector_1 = vector_1(:);
    end
end
% assure that vector2 is a column vector
[m,n] = size(vector_2);
if n > 1
    if m > 1
        error('Input should be a vector.')
    else
        vector_2 = vector_2(:);
    end
end
% get degree and order of the inputs
size_vector_1 = length(vector_1); degree_1 = sqrt(size_vector_1)-1;
size_vector_2 = length(vector_2); degree_2 = sqrt(size_vector_2)-1;
if (rem(degree_1,1) ~= 0) || (rem(degree_2,1) ~= 0)
    error('Vectors should be of size N^2.');
end
% if vectors are not the same size, vector2 should be the largest one
if size_vector_1 > size_vector_2
    aux = vector_2;
    vector_2 = vector_1;
    vector_1 = aux;
    clear aux;
    
    size_vector_1 = length(vector_1); degree_1 = sqrt(size_vector_1)-1;
    size_vector_2 = length(vector_2); degree_2 = sqrt(size_vector_2)-1;
end
% generate degree and order vectors
[aux_degree_1,aux_order_1] = ita_sph_linear2degreeorder(1:size_vector_1);
[aux_degree_2,aux_order_2] = ita_sph_linear2degreeorder(1:size_vector_2);
% calculate the order and size of resulting vector
if nargin == 3
    degree_out = MAX_degree;
else
    degree_out = degree_1 + degree_2;
end
size_vector_out = (degree_out + 1)^2;
vector_out = zeros(size_vector_out,1);
%%%%%%%  Initiate Memory Matrix  %%%%%%%
if ~exist('GauntValues.mat')
    GauntCoefficients = cell(size_vector_1,size_vector_2);
else
    load('GauntValues.mat')
    [size_1,size_2] = size(GauntCoefficients);
    if  size_1 < size_vector_1
        GauntCoefficients = [GauntCoefficients;...
            cell(size_vector_1-size_1,size_2)];
        size_1 = size_vector_1;
    end
    if size_2 < size_vector_2
        GauntCoefficients = [GauntCoefficients ...
            cell(size_1,size_vector_2-size_2)];
    end
end
update = 0;
% Calculate Coefficients
for p = 1:size_vector_1
    for q = 1:size_vector_2
        l1 = aux_degree_1(p);
        l2 = aux_degree_2(q);
                      
        % Check if value was already calculated, remembering the diagonal
        % simetry of the cell array, since
        % (l1 m1 l2 m2 L M)(l1 0 l2 0 L 0) = (l2 m2 l1 m1 L M)(l2 0 l1 0 L 0).
        if q >= p
            G = GauntCoefficients{p,q};
        else
            G = GauntCoefficients{q,p};
        end
        
        % if not yet calculated, calculate it.
        if isempty(G)
            m1 = aux_order_1(p);
            m2 = aux_order_2(q);
            G = sparse(ita_sph_degreeorder2linear(l1+l2),1);
            
            % Y*Y = SUM(Y), see reference [2].
            for L = abs(l1-l2):l1+l2
                M = m1+m2;
                % if abs(M) > L, then Ylm is defined as 0.
                if abs(M) <= L
                    index = ita_sph_degreeorder2linear(L,M);
                    C1 = Wigner3j([l1 l2 L],[0 0 0]);
                    C2 = Wigner3j([l1 l2 L],[m1 m2 -M]);
                    cte = (-1)^M * sqrt((2*l1+1)*(2*l2+1)*(2*L+1)/(4*pi));
                    G(index) = cte*C1*C2;
                end
            end
            GauntCoefficients{p,q} = G;
            update = 1;
        end
        l12 = l1+l2;
        if l12 > degree_out
            l12 = degree_out;
        end
        index_l12 = ita_sph_degreeorder2linear(l12);
        
        vector_out(1:index_l12) = vector_out(1:index_l12) + ...
                (G(1:index_l12)*vector_1(p)*vector_2(q));
    end
end
if update
    save('GauntValues.mat', 'GauntCoefficients')
end
        
function wigner = Wigner3j( j123, m123 )
% Compute the Wigner 3j symbol using the Racah formula. 
%
% W = Wigner3j( J123, M123 ) 
%
% J123 = [J1, J2, J3], with the condition:
%        |Ji - Jj| <= Jk <= (Ji + Jj)    (i,j,k are permutations of 1,2,3)
% M123 = [M1, M2, M3], with the conditions:
%        |Mi| <= Ji    (i = 1,2,3)
%        M1 + M2 + M3 = 0
% All Ji and Mi have to be half integers (correspondingly).
% 
% Reference: 
% Wigner 3j-Symbol entry of Eric Weinstein's Mathworld:
% http://mathworld.wolfram.com/Wigner3j-Symbol.html
%
% Inspired by Wigner3j.m by David Terr, Raytheon, 6-17-04
%  (available at www.mathworks.com/matlabcentral/fileexchange).
%
% By Kobi Kraus, Technion, 25-6-08.
% Modified by BMA on 19/08/2008
j1 = j123(1); j2 = j123(2); j3 = j123(3);
m1 = m123(1); m2 = m123(2); m3 = m123(3);
% Input error checking
if any( j123 < 0 )
    wigner = 0; return%error( 'The j must be non-negative' )
elseif any( rem( [j123, m123], 0.5 ) )
    wigner = 0; return%error( 'All arguments must be integers or half-integers' );
elseif any( rem( (j123 - m123), 1 ) | ( abs( m123 ) > j123 ) )
    wigner = 0; return%error( 'j123 and m123 do not match' );
elseif ( j3 > (j1 + j2) ) || ( j3 < abs(j1 - j2) )
    wigner = 0; return%error( 'j3 is out of bounds' );
elseif m1 + m2 + m3 ~= 0
    wigner = 0; return%error( 'm3 does not match m1 + m2' );
end
% Simple common case
if ~any( m123 ) && rem( sum( j123 ), 2 ) % m1 = m2 = m3 = 0 & j1 + j2 + j3 is odd
    wigner = 0;
    return
end
% Calculation
t1 = j2 - m1 - j3;
t2 = j1 + m2 - j3;
t3 = j1 + j2 - j3;
t4 = j1 - m1;
t5 = j2 + m2;
tmin = max( 0,  max( t1, t2 ) );
tmax = min( t3, min( t4, t5 ) );
t = tmin : tmax;
wigner = sum( (-1).^t .* exp( -ones(1,6) *...
    gammaln( [t; t-t1; t-t2; t3-t; t4-t; t5-t] +1 ) + ...
    gammaln( [j1+j2+j3+1, j1+j2-j3, j1-j2+j3, -j1+j2+j3, j1+m1, j1-m1, j2+m2, j2-m2, j3+m3, j3-m3] +1 )...
     * [-1; ones(9,1)] * 0.5 ) ) * (-1)^( j1-j2-m3 );
         
% Warnings
% if isnan( wigner )
%     warning( 'Wigner3J is NaN!' )
% elseif isinf( wigner )
%     warning( 'Wigner3J is Inf!' )
% end
