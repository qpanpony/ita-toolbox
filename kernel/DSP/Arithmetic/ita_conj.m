function varargout = ita_conj(varargin)
%ITA_CONJ - Conjugate Complex Frequency Vector
%  This function calculates the conjugate complex of ita structures in
%  frequency domain. That means, the frequency vector will become conjugate
%  complex.
%
%  Syntax: asData = ita_conj(asData)
%
%   See also ita_power, ita_negate, ita_divide.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_conj">doc ita_conj</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Matthias Lievens -- Email: mli@akustik.rwth-aachen.de
% Created:  13-Dec-2008 


%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU>
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU>

%% Initialization
narginchk(1,1);
% Find Audio Data
sArgs        = struct('pos1_a','itaSuper');
[data,sArgs] = ita_parse_arguments(sArgs,varargin);

data = conj(data);

%% Find output parameters
% Write Data
varargout(1) = {data};
%end function
end