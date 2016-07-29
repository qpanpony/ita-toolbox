function value = ita_sph_functionvalue(func, sampling)
% function value = ita_sph_functionvalue(func, sampling)
%
%   value = sampling.Y * func

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% number of SHs of func
nFunc = size(func,1);

% check if a column vector was given
if nFunc == 1
    func = func.';
    nFunc = size(func,1);    
end

% number of SHs of sampling
nSamp = size(sampling.Y,2);
if ~nSamp
    error('sampling parameter needs some SHs to get the functionvalue');
end

if nFunc < nSamp
    % enlarge with zeros in 1st dim
    func = [func; zeros(nSamp-nFunc,size(func,2))];
    disp('function enlarged with zeros for higher order SHs');
elseif nFunc > nSamp
    % cut upper SHs
    func = func(1:nSamp,:);
    warning('function cut to the maximum order of sampling grid');
end
value = sampling.Y * func;
