function varargout = ita_sph_sampling_displacement(varargin)
%ITA_SPH_SAMPLING_DISPLACEMENT - displaced sampling positions
%  This function creates a sampling grid with an additive error in the sampling
%  positions taken from a given sampling grid. The default option for the displacement
%  is a relative displacement in percent/100. For a absolute displacement in meters
%  choose the option 'absolute'.
%  
%   Syntax:
%   samplingDisplaced = ita_sph_sampling_displacement(sampling, displacement, opts)
%
%   Options (default):
%			'absolute' (false)	: displacement is a absolute value
%			'weightPoles' (true): weigting for smaller errors towards the poles
%			'projectRad' (true)	: project displaced sampling back onto the original radius
%
%
%  Example:
%   samplingDisplaced = ita_sph_sampling_displacement(sampling, [5/10,5/10,5/10] * 1e-3, 'absolute')
%
%  See also:
%   ita_sph_sampling, ita_sph_mimo_error_simulation
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sph_sampling_displacement">doc ita_sph_sampling_displacement</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Marco Berzborn -- Email: marco.berzborn@akustik.rwth-aachen.de
% Created:  29-Mar-2016 

sArgs = struct('pos1_sampling','itaCoordinates',...
               'pos2_error','double',...
			   'absolute',false,...
			   'weightPoles',true,...
               'projectRad',true);
[sampling, displacement, sArgs] = ita_parse_arguments(sArgs,varargin);

if numel(displacement) == 1
	displacement = repmat(displacement,1,3);
end

if ~sArgs.absolute
	posError = randn(size(sampling.sph));
	posError = (bsxfun(@rdivide,posError,sqrt(sum(posError.^2,2))) .* repmat(sampling.sph(:,1),1,3)) * diag(displacement);
elseif sArgs.absolute
	posError = randn(size(sampling.sph));
	posError = bsxfun(@rdivide,posError,sqrt(sum(posError.^2,2))) * diag(displacement);
end

posError = itaCoordinates(posError,'cart');
if sArgs.weightPoles
	% consideration of the smaller deviations towards the poles
	% Ref: Rafaely - 2005 - Analysis and Design of Spherical Microphone Arrays
	posError.sph(:,2) = posError.sph(:,2)./sin(sampling.theta);


	% set all NaNs and Infs to zero as they are not wanted and lead to missing
	% sampling points.
	posError.cart(isnan(posError.cart)) = 0;
	posError.cart(isinf(posError.cart)) = 0;
end
% new sampling coordinates with erroneous positions
samplingError = itaCoordinates(sampling.cart + posError.cart,'cart');

if sArgs.projectRad
    samplingError.sph(:,1) = sampling.sph(:,1);
end

varargout{1} = samplingError;
end
