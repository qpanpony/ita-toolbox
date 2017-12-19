function pos = VR_loudspeaker_position(varargin)

% Give back the position, in meters, of the 12 loudspeakers in the VR lab.
% See options for more details 

% Author: Michael Kohnen -- Email: mko@akustik.rwth-aachen.de
% Date: 19-Dec-2017

% Options
opts.virtualSpeaker     = false;            % true      || Indicates whether to add virtual speaker achieve a more regular distribution (stabilizes the pseudoinverse in Ambisonics Decoding)
opts.coordSystem        = 'itaCoordinates'; % 'openGL'  || indicates in which coordinate system the output is
opts.isItaCoordinates   = true;             % true      || indicates whether the output is a itaCoordinate or not (warning: if combined with coordSystem='opneGL', the angles for azimuth and elevation are not correct
opts.heightCorrection   = 0;                % in meter  || ensures that the loudspeakers are around the point (0 0 0), standard value is height of the bigger loudspeaker in the horizontal plane

opts=ita_parse_arguments(opts, varargin);

% X     Y     Z    (openGL)
pos = itaCoordinates(zeros(12,3));
pos.r= [2.283 2.293 2.273 2.278 2.344 2.324 2.333 2.336 2.233 2.228 2.231 2.233];
pos.phi_deg=[45.317 313.757 225.547 134.557 0 270 180 90 0 270 180 90];
pos.theta_deg=[90 90 90 90 58.148 57.783 57.980 58.228 117.411 117.391 117.524 117.700];

if opts.virtualSpeaker
    pos.cart = [pos.cart;...
        0  0  -2.3;... % virtual speaker
        0  0  2.3];   % virtual speaker
end

% Correction of head height
pos.z=pos.z-opts.heightCorrection;

if strcmpi(opts.coordSystem,'opengl')
    pos.cart = ita_matlab2openGL(pos);
end

if (~opts.isItaCoordinates)
    pos = pos.cart;
end