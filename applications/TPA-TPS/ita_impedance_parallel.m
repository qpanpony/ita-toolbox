function varargout = ita_impedance_parallel(Z1, Z2)
%ITA_IMPEDANCE_PARALLEL - Two impedances in parallel
%  This function calculates the parallel connection of two impedances
%
%  Syntax: impedance = ita_impedance_parallel(impedance1, impedance2)
%
%   See also ita_make_impedance
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_impedance_parallel">doc ita_impedance_parallel</a>

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  29-Sep-2008 
% Modified: 29-Sep-2008 - pdi - supports more than two inputs

%% Impedance in Parallel
admittance        = 1/Z1 + 1/Z2;
result            = 1/admittance;

%% Check for singularties
result.data(~isfinite(result.data)) = 0;

%% Add history line
result = ita_metainfo_add_historyline(result,'ita_impedance_parallel');

%% Find output parameters
varargout(1) = {result};
%end function
end