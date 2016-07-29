function res = ita_preferences_beamforming(varargin)

% <ITA-Toolbox>
% This file is part of the application Beamforming for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


if nargin < 1
    if nargout == 0 % Show GUI
        ita_preferences_gui_tabs(eval(mfilename), {mfilename}, true);
    else
        res = { 'Beamforming_Settings','ita_preferences_beamforming','simple_button','App: Beamforming','',4;...
            'beamforming_ManifoldType','Finite Distance Focus (spherical waves)','popup_char','Manifold Vector Type','Type for the manifold vector.[Infinite Distance Focus (plane waves)|Finite Distance Focus (spherical waves)]',0;...
            'beamforming_Method','Delay-and-Sum','popup_char','Your favorite method','Method to calculate beamforming.[Delay-and-Sum|Delay-and-Sum w/o Autospectra|Cross-Spectral Imaging|Cross-Spectral Imaging w/o Autospectra|MVDR|Eigenanalysis|CLEAN-SC]',0;...
            };
    end
else
    res = ita_preferences(varargin{:});
end