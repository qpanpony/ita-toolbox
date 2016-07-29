function varargout = ita_freq2cb(varargin)
%ITA_FREQ2CB - Gives the lower and upper frequency and bandwidth of critical band

% <ITA-Toolbox>
% This file is part of the application Psychoacoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%  This function gives the boundaries of the critical band and the bandwidth if the critical band, if the central
%  frequency is given.
%
%  Syntax:
%   [f_low f_central f_high bandwidth Bark ] = ita_freq2cb(f)
%
%  Example:
%   CB = ita_freq2cb([350])
%   with    CB.f_l = 300 
%           CB.f_c = 350
%           CB.f_u = 400
%           CB.BW = 100
%           CB.Bark = 2
%
% CB = ita_freq2cb([1000 1170])
%   with    CB.f_l = 922.1755   1.0825e+003 
%           CB.f_c = 1000 1170
%           CB.f_u = 1.0844e+003 1.2645e+003
%           CB.BW = 162.2167 181.9683
%           CB.Bark = 8.5098 9.5324
%
%   See also: 
%
% [1] E. Zwicker and E. Terhardt, Analytical expressions for critical-band rate and critical bandwidth as a function of frequency, J. Acoust. Soc. Am. 68, 1523 (1980)
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_freq2cb">doc ita_freq2cb</a>

% Author: Sebastian Fingerhuth -- Email: sfi@akustik.rwth-aachen.de
% Created:  17-Jul-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(1,5);
sArgs        = struct('pos1_data','vector');
[data,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Calculate the paramters
freq = data;

BW = 25 + 75*(1 + 1.4*(freq/1000).^2 ).^0.69 ; % from [1]
Bark = 13*atan(0.76*(freq/1000)) + 3.5*(atan(freq/(7.5*1000))).^2; % from [1]

f_low= 0.5*( -BW + sqrt( BW.^2+4*(freq.^2)) ) ; % from x = (-b  +-sqrt(4ac)/2a
f_up = f_low + BW;


%% Prepare output
result.f_l = f_low;
result.f_c = freq ;
result.f_u = f_up;
result.BW = BW;
result.Bark = Bark ;

%% Add history line
% Not used here

%% Check header
% Not used here

%% Find output parameters
varargout(1) = {result};
%end function
end