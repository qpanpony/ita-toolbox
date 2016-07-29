function varargout = ita_calculate_horn_geometry(varargin)
%ITA_CALCULATE_HORN_GEOMETRY - calculate various types of horns
%  This function calculates the geometry of a given horn type with given
%  specifications, which depend on the chosen type, which can be:
%  'conical','exponential','tractrix'.
%
%  Mandatory input arguments are the type and the throat radius (r0).
%  By default, most optional parameters are empty, so that checking them
%  for correctness is easier.
%
%  Syntax:
%   outputStruct = ita_calculate_horn_geometry(string,double,options)
%
%   Options (default):
%           'rm' ([])       : mouth radius
%           'L' ([])        : length (will be ignored for tractrix type)
%           'fc' ([])       : cutoff frequency (ignored for conical type)
%           'theta' (45)    : angle at the mouth of the exponential type
%           'c' (ita_constants('c')) : speed of sound
%           'nPoints' (40)  : nr of points used to describe the geometry
%
%  Example:
%   tractrixParams = ita_calculate_horn_geometry('tractrix',50e-3,'fc',1000)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_calculate_horn_geometry">doc ita_calculate_horn_geometry</a>

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  13-Jun-2011 


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('pos1_type','string','pos2_r0', 'double', 'fc', [],'rm',[],'L',[],'c',ita_constants('c'),'nPoints',40,'theta',45);
[type,r0,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% get input parameters
r0      = double(r0);
rm      = double(sArgs.rm);
L       = double(sArgs.L);
fc      = double(sArgs.fc);
theta   = sArgs.theta;
nPoints = sArgs.nPoints;
c = double(sArgs.c);

%% get the horn geometry
switch lower(type)
    case 'conical'
        % cone: r = r0 + (rm - r0)/L*x;
        fc = []; % there is not cutoff frequency
        if isempty(rm) || isempty (L)
            error([thisFuncStr 'I need some parameters']);            
        end
        x = linspace(0,L,nPoints);
        m = (rm - r0)/L;
        r = r0 + m.*x;
    case 'exponential'
        % expo: r = r0*e^(m*x), theta defines the angle at the mouth
        if isempty(L)
            if ~isempty(fc)
                m = 2*pi*fc/c;
            else
                error([thisFuncStr 'I need some parameters']);
            end
            L = 1/m*log(tan(theta*pi/180)/(r0*m));
            if L < 0
                error([thisFuncStr 'parameters lead to unbuildable horn geometry']);
            end
        elseif isempty(rm)
            if ~isempty(fc)
                m = 2*pi*fc/c;
            else
                error([thisFuncStr 'I need some parameters']);
            end
            rm = r0*exp(m*L);
        else
            m = 1/L*log(rm/r0);
        end
        x = linspace(0,L,nPoints);
        r = r0.*exp(m.*x);
    case 'tractrix'
        % tractrix: x = rm*ln((rm + sqrt(rm^2 - rx^2))/rx) - sqrt(rm^2 - rx^2)
        if isempty(rm)
            if isempty(fc)
                % define a standard value
                rm = sqrt(5)*r0;
                fc = c/(2*pi*rm);
            else
                rm = c/(2*pi*fc);
            end
        end
        A  = sqrt(rm^2 - r0^2);
        L = rm*log((rm + A)/r0) - A; % at r0
        if L < 0
            error('parameters lead to unbuildable horn geometry');
        end
        % random values between r0 and rm, explicitly include r0 and rm
        rx = unique([r0; rm; r0 + (rm - r0).*rand(nPoints,1)]);
        A  = sqrt(rm^2 - rx.^2);
        x = L - (rm.*log((rm + A)./rx) - A);
        [x, sortIdx] = sort(x);
        r = rx(sortIdx);
    otherwise
        error([thisFuncStr 'I do not know this horn type (yet)']);
end

if ~all(r >= r0)
    error([thisFuncStr 'radius is computed to be too small']);
end

outputStruct = struct('r',r,'x',x,'L',L,'r0',r0,'rm',rm,'fc',fc);

%% TODO
% calculate throat impedance

%% Set Output
varargout(1) = {outputStruct}; 

%end function
end