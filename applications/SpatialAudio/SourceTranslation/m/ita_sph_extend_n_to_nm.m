function f_ext = ita_sph_extend_n_to_nm(f, dim)
% ita_sph_extend_n_to_nm.m
% Author: Noam Shabtai
% ITA-RWTH, 22.10.2013
%
% f_ext = extend(f)
% Extend matrix of n rows (colomns) to (n+1)^2 rows (columns) to take over the m indices.
% Basically extends fn to fnm.
% Useful in Bessel and Henkel functions allignment before multiplication with Ynm.
%
% Input Parameters:
%   f - Matrix, if dim=1 (default) each row represents function vector of order n.
%
%   dim - if 1, add rows, if 2, add columns.
%
% Output Parameters:
%   ext_f - Matrix with (N+1)^2 rows (columns) consist of repeating rows (columns) from f.

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
% Default values
if exist('dim')~=1
    dim = 1;
end

% Transpose if dim=2
if dim==2
    f = f.';
end

% Add rows 
N = size(f,1)-1;
f_ext = [];
for n=0:N
    replicas = 2*n+1;
    f_ext = [f_ext; repmat(f(n+1,:), replicas, 1)];
end

% Transpose if dim=2
if dim==2
    f_ext = f_ext.';
end
