function varargout = ita_struve1(varargin)
% ITA_STRUVE1 - generates the approximation of the Struve function of the
% first kind as calculated in 'Approximation of the Struve function H1 occurring
% in impedance calculations' from M. Aarts (Philips Research Eindhoven).
%
% Syntax: H1= ita_struve1(input_vector)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Alexandre Bleus -- Email: alexandre.bleus@akustik.rwth-aachen.de
% Created:  08-Jul-2010 


%% Initialisation
narginchk(1,1);
inVector = varargin{1};
%% Calculation
J_0 = besselj(0,inVector);
H1 = (2/pi)-J_0+((16/pi)-5).*(sin(inVector)./inVector)+(12-(36/pi)).*((1-cos(inVector))./(inVector.^2));

%% Set Output
varargout{1} = H1;

end

