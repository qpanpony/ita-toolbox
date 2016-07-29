function varargout = ita_sph_bessely_diff(varargin)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

varargout = {ita_sph_besseldiff(@ita_sph_bessely, varargin{:})};
end