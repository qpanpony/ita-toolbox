function varargout = ita_sph_sampling_displacement(varargin)
%ITA_SPH_SAMPLING_DISPLACEMENT - displaced sampling positions
%  This function creates a sampling grid with an additive error in the sampling
%  positions taken from a given sampling grid
%  
%   Syntax:
%   samplingDisplaced = ita_sph_sampling_displacement(sampling, opts)
%
%   Options (default):
%           'relativeError' ([0.1,0.1,0.1]) : relative displacement in percent/100
%
%  Example:
%   samplingDisplaced = ita_sph_sampling_displacement(sampling, [0.01,0.01,0.01])
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sph_sampling_displacement">doc ita_sph_sampling_displacement</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Marco Berzborn -- Email: marco.berzborn@akustik.rwth-aachen.de
% Created:  29-Mar-2016 


%% Initialization and Input Parsing

sArgs = struct('pos1_sampling','itaCoordinates',...
               'relativeError',[0.01 0.01 0.01]);
[sampling, sArgs] = ita_parse_arguments(sArgs,varargin);

if isempty(sArgs.relativeError)
    sArgs.relativeError = zeros(1,3);
elseif numel(sArgs.relativeError) == 1
    sArgs.relativeError = repmat(sArgs.relativeError,1,3);
end

posError = randn(size(sampling.sph));
posError = (bsxfun(@rdivide,posError,sqrt(sum(posError.^2,2))) .* repmat(sampling.sph(:,1),1,3)) * diag(sArgs.relativeError);

posError = itaCoordinates(posError,'cart');
posError = posError.makeSph;
% consideration of the smaller deviations towards the poles
% Ref: Rafaely - 2005 - Analysis and Design of Spherical Microphone Arrays
posError.sph(:,2) = posError.sph(:,2)./sin(sampling.theta);

posError = posError.makeCart;

% set all NaNs and Infs to zero as they are not wanted and lead to missing
% sampling points.
posError.cart(isnan(posError.cart)) = 0;
posError.cart(isinf(posError.cart)) = 0;

% new sampling coordinates with erroneous positions
samplingError = itaCoordinates(sampling.cart + posError.cart,'cart');

if sArgs.relativeError(:,1) == 0
    samplingError.sph(:,1) = sampling.sph(:,1);
end

varargout{1} = samplingError;
end
