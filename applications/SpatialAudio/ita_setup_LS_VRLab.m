function pos = ita_3da_LSSetup_VRLab(varargin)

% Give back the position, in meters, of the 12 loudspeakers in the VR lab.
% See options for more details 

% Author: Michael Kohnen -- Email: mko@akustik.rwth-aachen.de
% Date: 19-Dec-2017

% Options
opts.virtualSpeaker     = false;            % true      || Indicates whether to add virtual speaker achieve a more regular distribution (stabilizes the pseudoinverse in Ambisonics Decoding)
opts.coordSystem        = 'itaCoordinates'; % 'openGL'  || indicates in which coordinate system the output is
opts.isItaCoordinates   = true;             % true      || indicates whether the output is a itaCoordinate or not (warning: if combined with coordSystem='opneGL', the angles for azimuth and elevation are not correct
opts.heightCorrection   = 0;                % in meter  || ensures that the loudspeakers are around the point (0 0 0), standard value is height of the bigger loudspeaker in the horizontal plane
opts.configuration      = 'acoustic';           % real      || specifies wheter optical measured values are given back ('real'), 'ideal' is theoretical targeted positions, 'acoustic' measured data

opts=ita_parse_arguments(opts, varargin);


pos = itaCoordinates(zeros(12,3));
if(strcmpi(opts.configuration,'real'))
pos.r           = [ 2.28    2.29    2.27    2.28    2.29    2.27    2.28    2.28    2.28    2.28    2.28    2.28    ];
pos.phi_deg     = [ 45.32   313.76  225.55  134.56  0       270     180     90      0       270     180     90      ];
pos.theta_deg   = [ 90      90      90      90      60.27   59.92   60.11   60.36   119.64  119.63  119.75  119.92  ];

elseif(strcmpi(opts.configuration,'ideal'))
pos.r           = repmat(2.28,1,12);
pos.phi_deg     = [ 45:90:360 repmat(0:90:270,1,2) ];
pos.theta_deg   = [ ones(1,4)*90 ones(1,4)*60 ones(1,4)*120 ];

elseif(strcmpi(opts.configuration,'acoustic'))
pos.r           = [ 2.2882    2.3118    2.3190    2.3190    2.2955    2.3063    2.3262    2.3063    2.2647    2.2792    2.3045    2.2792    ];
pos.phi_deg     = [ 45.3200  313.7600  225.5500  134.5600         0  270.0000  180.0000   90.0000         0  270.0000  180.0000   90.0000    ];
pos.theta_deg   = [ 90.0000   90.0000   90.0000   90.0000   60.2700   59.9200   60.1100   60.3600  119.6400  119.6300  119.7500  119.9200    ];
end

if opts.virtualSpeaker
    pos.cart = [pos.cart;...
        0  0  -2.28;... % virtual speaker
        0  0  2.28];   % virtual speaker
end


% Correction of head height
pos.z=pos.z-opts.heightCorrection;

if strcmpi(opts.coordSystem,'opengl')
    pos.cart = ita_matlab2openGL(pos);
    if opts.isItaCoordinates
        warning('itaCoordinates are not made for openGL coordinates! Angles etc. do refer to the mathmatical representation (x-axis to the front). Use ''isItaCoordinates'', ''false''');
    end
end

if (~opts.isItaCoordinates)
    pos = pos.cart;
end




