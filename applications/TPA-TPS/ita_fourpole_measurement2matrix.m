function varargout = ita_fourpole_measurement2matrix(varargin)
%ITA_FOURPOLE_MEASUREMENT2MATRIX - calculates transmission matrix (Hynnä 2002) of a
%fourpole element 
%  This function takes a measurement of a fourpole element a_top, F_top,
%  F_bottom and calculates the transmission matrix as in Hynnä 2002
%
%  Syntax:
%   audioObjOut = ita_fourpole_measurement2matrix(a_top,F_top,F_bottom)
%
%  Example:
%   audioObjOut = ita_fourpole_measurement2matrix(audioObjIn)
%
%   See also: ita_make_fourpole.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_fourpole_measurement2matrix">doc ita_fourpole_measurement2matrix</a>

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  23-Nov-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('pos1_a1','itaAudio','pos2_f1','itaAudio','pos3_f2','itaAudio');
[acc1,force1,force2,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% Fourpole Parameter Calculations
%as in dickens and nordwood 2002

alpha(1,1) = force1 / force2;
alpha(1,1).comment = 'alpha11';

alpha(2,2) = alpha(1,1);
alpha(2,2).comment = 'alpha22 as 11';

alpha(2,1) = acc1 / force2;
alpha(2,1).comment = 'alpha21';

alpha(1,2) = (alpha(1,1)*alpha(2,2) - 1) / alpha(2,1);
alpha(1,2).comment = 'alpha12';


%% Find output parameters
varargout(1) = {itaFourpole(alpha,'A')};

%end function
end