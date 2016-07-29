function s = ita_sph_sampling_lebedev(nmax,varargin)
% s = ita_sph_sampling_lebedev(nmax,varargin)
%
% output: s: itaSamplingSph object
%
% input:  maximum order of the Lebedev sampling
%
% This file was adapted from Rob Parrish code, provided at Matlab Exchange.
% Please see subfunction getLebedevSphere for license notes.

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>



sArgs = struct('noSH',false); % added maku : sometimes I just need the sampling
if nargin > 1
    sArgs = ita_parse_arguments(sArgs, varargin);
end

% And these are the equivalent number of points for every maximal order.
configs = [6, 14, 26, 38, 50, 74, 86, 110, 146, 170, 194, 230, 266, 302, ...
    350, 434, 590, 770, 974, 1202, 1454, 1730, 2030, 2354, 2702, 3074, ...
    3470, 3890, 4334, 4802, 5294, 5810];

[ind] = find(ceil(4/3*(nmax+1)^2) <= configs,1,'first');
if isempty(ind)
    error('This Lebedev Grid implementation supports only orders below 57.')
end
[leb_tmp] = getLebedevSphere(configs(ind));
s = itaSamplingSph(configs(ind));
s.cart = [leb_tmp.x leb_tmp.y leb_tmp.z];
s.weights = leb_tmp.w;


if ~sArgs.noSH
    s.nmax = nmax;
end
end %[EOF]
