function varargout = ita_italian_sort_measurementPositions(varargin)
%ITA_ITALIAN_SORT_MEASUREMENTPOSITIONS - sort measurement positions of
%ballon
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_italian_sort_measurementPositions(audioObjIn, options)
%
%   Options (default):
%           'plot' (false)  : plot result (true or false)
%           'above' (90)    : maximum of theta angle 
%
%  Example:
%   Coordinates = ita_italian_sort_measurementPositions(Coordinates)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_italian_sort_measurementPositions">doc ita_italian_sort_measurementPositions</a>

% <ITA-Toolbox>
% This file is part of the application Movtec for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Christian Haar -- Email: christian.haar@akustik.rwth-aachen.de
% Created:  17-Nov-2010 


%% Initialization and Input Parsing
sArgs        = struct('pos1_data','anything','plot',false,'below',90);
[input,sArgs] = ita_parse_arguments(sArgs,varargin);

%%
sampling = input;
theta = sampling.theta;
phi = sampling.phi;


[theta idx] = sort(theta,'descend');
phi = phi(idx);

% arm moves just 90°
tmp = find(theta>sArgs.below/180*pi);
theta(tmp) = [];
phi(tmp) = [];

switching_points = [0 find(diff(theta))' length(theta)];

phi2 = [];

for jdx = 2 : numel(switching_points)
    token = phi((switching_points(jdx-1)+1) : switching_points(jdx));
    token = sort(token);
    if mod(jdx,2)
        token = flipud(token(:));
    end
    phi2 = [phi2; token]; %#ok<AGROW>
end

%% Set Output
sampling2       = itaCoordinates(length(theta));
sampling2.theta = theta;
sampling2.phi   = phi2;
sampling2.r     = phi2 * 0 + 1;
varargout(1) = {sampling2}; 


figure();sampling2.scatter;
pause(0.5)
if sArgs.plot
    for idx = 1:sampling2.nPoints
        sampling2.n(1:idx).scatter;
    end
    pause(0.5)
end

%end function
end