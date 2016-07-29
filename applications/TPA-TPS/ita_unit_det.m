function varargout = ita_unit_det(varargin)
%ITA_UNIT_DET - Physical Units of Determinant
%  This function calculates the physical units of a determinant of an
%  itaValue matrix. 
%
%
%  See also:
%   ita_unit_inv, itaValue
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_unit_det">doc ita_unit_det</a>

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  21-Jul-2011 

%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaValue');
[input,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% 
determinant = input(1,1);
for idx = 2:size(input,1)
    determinant = determinant * input(idx,idx);
end

% determinant = prod(diag(input));

determinant.value = 0;

%% Set Output
varargout(1) = {determinant}; 

%end function
end