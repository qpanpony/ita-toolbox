function varargout = ita_sph_sampling_equalarea(varargin)
%ITA_SPH_SAMPLING_EQUALAREA - Equal area sampling on the sphere
%  This function generates a spherical sampling based on the center points
%  of faces with equal area on the sphere. Algorithm based on Leopardi's
%  equalarea algorithm.
%  In order to ensure a feasible SHT the number of sampling points is 
%  increased until the condition number of the SH basis matrix is sufficiently small.
%  For high SH orders it is recommended to start with a higher number of sampling points
%  than (Nmax+1)^2 in order to save computation time.
%  In order to ignore the feasibility criterion, use 'condSHT', inf
%
%  Syntax:
%   sampling = ita_sph_sampling_equalarea(Nmax,options)
%
%  Example:
%   sampling = ita_sph_sampling_equalarea(Nmax,'condSHT',2)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sph_sampling_equalarea">doc ita_sph_sampling_equalarea</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Marco Berzborn -- Email: marco.berzborn@akustik.rwth-aachen.de
% Created:  09-Nov-2016 

sArgs = struct('pos1_Nmax','integer',...
               'condSHT',2.5,...
			   'nPoints',[]);
[Nmax,sArgs] = ita_parse_arguments(sArgs,varargin);
           
if isempty(sArgs.nPoints)
	sArgs.nPoints = (Nmax+1)^2;
else
	if Nmax > 15
		ita_verbose_info('You may want to consider setting a number of points higher than (Nmax+1)^2 as starting point.',1);
	end
end


% find a sampling with a feasible SHT transform as this may not be the case
% for every set of sampling points resulting from the equal area
% partitioning
% use while true to exec the loop at least once
while true
    coordsCart = eq_point_set(2,sArgs.nPoints).';
    sampling = itaSamplingSph(coordsCart,'cart');
    Y = ita_sph_base(sampling,Nmax);
    if sArgs.condSHT ~= inf
        condNum = cond(Y);
        if condNum < sArgs.condSHT
            break;
        end
    else
        break;
    end
    sArgs.nPoints = sArgs.nPoints+1;
end

sampling.nmax = Nmax;

varargout{1} = sampling;

end
