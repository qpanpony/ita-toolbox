function pos = VR_loudspeaker_position(varargin)

% Give back the position, in meters, of the 8 loudspeakers in the VR lab.
% See options for more details

% Author: Michael Kohnen -- Email: mko@akustik.rwth-aachen.de
% Date: 03-May-2017

% Options
opts.virtualSpeaker     = false;            % true      || Indicates whether to add virtual speaker achieve a more regular distribution (stabilizes the pseudoinverse in Ambisonics Decoding)
opts.coordSystem        = 'itaCoordinates'; % 'openGL'  || indicates in which coordinate system the output is
opts.isItaCoordinates   = true;            % true      || indicates whether the output is a itaCoordinate or not (warning: if combined with coordSystem='opneGL', the angles for azimuth and elevation are not correct
opts.heightCorrection   = 0.0597;          % in meter  || ensures that the loudspeakers are around the point (0 0 0), standard value is height of the bigger loudspeaker in the horizontal plane

opts=ita_parse_arguments(opts, varargin);

hc=opts.heightCorrection;
% X     Y     Z    (openGL)
pos = itaCoordinates(zeros(12,3));
pos.r= 2.28;
pos.phi_deg=[45 315 225 135 0 270 180 90 0 270 180 90];
pos.theta_deg=[88.5 88.5 88.5 88.5 60 60 60 60 118 118 118 118];
    
pos.z=pos.z-hc;

if opts.virtualSpeaker
    pos = [pos;...
        0  0+hc  0;... % virtual speaker
        0  3+hc  0];   % virtual speaker
end

if strcmp(opts.coordSystem,'openGL')
    pos = ita_matlab2openGL(pos);
end

if (~opts.isItaCoordinates)
    pos = pos.cart;
end