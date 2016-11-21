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
            'beamforming_SteeringType','Finite Distance Focus (spherical waves)','popup_char','Steering Vector Type','Type for the steering vector.[Infinite Distance Focus (plane waves)|Finite Distance Focus (spherical waves)]',0;...
            'beamforming_Method','Delay-and-Sum','popup_char','Your favorite method','Method to calculate beamforming.[Delay-and-Sum|MVDR|MUSIC|Subspace|Functional|CLEAN|CLEAN-SC|DAMAS|SparseDAMAS]',0;...
            };
    end
else
    res = ita_preferences(varargin{:});
end