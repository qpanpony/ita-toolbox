function varargout = ita_velocity_from_pressure_gradient(varargin)
%ITA_VELOCITY_FROM_PRESSURE_GRADIENT - Sound velocity from pressure gradient
%  This function will calculate the approximate velocity from the pressure
%  gradient of two channels. The function can only handle 2 channel inputs
%  with channel one the sound pressure at poisiton x and channel 2 the
%  sound pressure at position x+d. The result will be the proximate
%  velocity at the position x+d/2.
%
%  Syntax:
%   audioObj = ita_pressure_gradient_to_velocity(audioObj)
%
%   Options (default):
%           distance ([]):      distance between the sensors, will be evaluated
%                               from channelCoordinates if empty
%
%  Example:
%   audioObj = ita_pressure_gradient_to_velocity(audioObj)
%
%   See also: ita_integrate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_pressure_gradient_to_velocity">doc ita_pressure_gradient_to_velocity</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  13-Jul-2009

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(1,4);
sArgs        = struct('pos1_data','itaAudioFrequency','distance',[],'normalized',false);
[data,sArgs] = ita_parse_arguments(sArgs,varargin);


%% Gradient
if data.nChannels ~= 2
    error([thisFuncStr ' I can only handle two channels']);
end

if isempty(sArgs.distance)
    distance = data.channelCoordinates.n(2)-data.channelCoordinates.n(1);
    sArgs.distance = distance.r;
end


channelNames = data.channelNames;
data = ita_split(data,1) - ita_split(data,2);
data = ita_integrate(data,'domain','freq');
denum = (ita_constants('rho_0') * itaValue(double(sArgs.distance),'m'));
data = data ./ denum;

if sArgs.normalized
   data = data * ita_constants('z_0');
end

for idx = 1
    %data.channelUnits{idx} = ita_deal_units(data.channelUnits{idx},denum.unit,'/');
    data.channelNames{idx} = ['Approximate velocity between ' channelNames{1} ' and ' channelNames{2}];
end

%% Add history line
data = ita_metainfo_add_historyline(data,mfilename,varargin);

%% Find output parameters
varargout(1) = {data};

%end function
end