classdef WRW3D_Material < handle
    %WRW3D_MATERIAL contains acoustic (and visual) properties of materials

    % TODO: setter und getter
    
    properties (Access = public)
        name;   % name of the material
        rgb;    % color given as RGB value
        amb;    %
        emis;   %
        spec;   % reflection coefficient
        shi;    %
        trans;  %
    end

end

