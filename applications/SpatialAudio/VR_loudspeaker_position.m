function pos = VR_loudspeaker_position(varargin)

% Give back the position, in meters, of the 8 loudspeakers in the VR lab.
% See options for more details

% Author: Michael Kohnen -- Email: mko@akustik.rwth-aachen.de
% Date: 03-May-2017

% Options
opts.virtualSpeaker     = false;            % true      || Indicates whether to add virtual speaker achieve a more regular distribution (stabilizes the pseudoinverse in Ambisonics Decoding)
opts.coordSystem        = 'itaCoordinates'; % 'openGL'  || indicates in which coordinate system the output is
opts.isItaCoordinates   = false;            % true      || indicates whether the output is a itaCoordinate or not (warning: if combined with coordSystem='opneGL', the angles for azimuth and elevation are not correct
opts.heightCorrection   = -1.3275;          % in meter  || ensures that the loudspeakers are around the point (0 0 0), standard value is height of the bigger loudspeaker in the horizontal plane

opts=ita_parse_arguments(opts, varargin);

hc=opts.heightCorrection;
% X     Y     Z    (openGL)
pos = [...
    -2  1.3275+hc   -2;...
     2  1.3275+hc   -2;...
     2  1.3275+hc    2;...
    -2  1.3275+hc    2;...
     0  2.6+hc      -3;... % ls5
     3  2.6+hc       0;...
     0  2.6+hc       3;...
    -3  2.6+hc       0;...
     0  0.2+hc      -3;...
     3  0.2+hc       0;... % ls10
     0  0.2+hc       3;...
    -3  0.2+hc       0;];
if opts.virtualSpeaker
    pos = [pos;...
        0  0+hc  0;... % virtual speaker
        0  3+hc  0];   % virtual speaker
end

if strcmp(opts.coordSystem,'itaCoordinates')
    pos = ita_openGL2Matlab(pos);
end

if opts.isItaCoordinates
    pos = itaCoordinates(pos);
end